Class {
	#name : 'DMGameServer',
	#superclass : 'CMGameServer',
	#instVars : [
		'game'
	],
	#category : 'DM-Game',
	#package : 'DM-Game'
}

{ #category : 'as yet unclassified' }
DMGameServer class >> web: aFileName [
	^ ((IceRepository registry detect: [ :r | r name = 'Dukunu-Mole' ]) location / 'web' / aFileName) contents
]

{ #category : 'as yet unclassified' }
DMGameServer >> assignRole: aRoleName toPlayerNamed: aPlayerName [
	| player |
	player := self clients detect: [ :c | c name = aPlayerName ].
	player role: (game availableRoles detect: [ :r | r roleName = aRoleName ])
]

{ #category : 'as yet unclassified' }
DMGameServer >> canStart [
	^ (self players allSatisfy: #hasRole) and: [ self playingCommunities notEmpty ]
]

{ #category : 'accessing' }
DMGameServer >> clientRegistered: aClient [
	game catchUp: aClient
]

{ #category : 'accessing' }
DMGameServer >> game: aGame [
	game := aGame
]

{ #category : 'as yet unclassified' }
DMGameServer >> handleData: aDictionary forClient: aClient [
	| type |
	type := aDictionary at: 'type'.
	type = 'ping' ifTrue: [ ^ aClient sendPongMessage ].
	type = 'gmLogin' ifTrue: [
		aClient role: DMGameMasterRole.
		aClient sendMessage: (Dictionary new
			at: 'type' put: 'join';
			at: 'addresses' put: self localNetworkAddresses;
			at: 'port' put: self portNumber;
			yourself) ].
	type = 'gmAssignRole' ifTrue: [
		self assignRole: (aDictionary at: 'role') toPlayerNamed: (aDictionary at: 'player') ].
	(type = 'gmStart' and: [ self canStart ]) ifTrue: [ ^ game startGame ].
	type = 'gmProceed' ifTrue: [ ^ game proceed ].
	type = 'submit' ifTrue: [ game submit: (aDictionary at: 'value') from: aClient ].
	aClient sendMessage: self lobbyState.
	game catchUp: aClient
]

{ #category : 'as yet unclassified' }
DMGameServer >> lobbyState [
	^ Dictionary new
		at: 'type' put: 'lobby';
		at: 'canStart' put: self canStart;
		at: 'roles' put: ((game availableRoles copyWithout: DMGameMasterRole) collect: #roleName);
		at: 'players' put: (self players collect: [ :c |
			Dictionary new
				at: 'name' put: c name;
				at: 'role' put: c role roleName;
				yourself ]) asArray;
		yourself
]

{ #category : 'accessing' }
DMGameServer >> localNetworkAddresses [
	| file command output addresses rank |
	file := FileLocator temp / 'cormas-ipconfig.txt'.
	command := OSPlatform current isWindows
		ifTrue: [ 'ipconfig > "' , file fullName , '"' ]
		ifFalse: [ '(ip -4 -o addr || /sbin/ifconfig) > "' , file fullName , '" 2>/dev/null' ].
	output := [
		LibC runCommand: command.
		file exists
			ifTrue: [ file binaryReadStreamDo: [ :stream | stream upToEnd asString ] ]
			ifFalse: [ '' ] ]
		on: Error
		do: [ :e | '' ].
	file ensureDelete.
	addresses := OrderedCollection new.
	output lines do: [ :line |
		#( 'IPv4' 'inet ' )
			detect: [ :marker | line includesSubstring: marker ]
			ifFound: [ :marker |
				| found |
				found := (line copyFrom: (line findString: marker) + marker size to: line size)
					allRegexMatches: '\d+\.\d+\.\d+\.\d+'.
				found ifNotEmpty: [ addresses addIfNotPresent: found first ] ] ].
	addresses := addresses reject: [ :each | (each beginsWith: '127.') or: [ each beginsWith: '169.254.' ] ].
	rank := [ :ip |
		(ip beginsWith: '192.168.')
			ifTrue: [ 1 ]
			ifFalse: [ (ip beginsWith: '10.') ifTrue: [ 2 ] ifFalse: [ 3 ] ] ].
	^ (addresses asSortedCollection: [ :a :b | (rank value: a) <= (rank value: b) ]) asArray
]

{ #category : 'as yet unclassified' }
DMGameServer >> players [
	^ self clients select: [ :c | c isConnected and: [ c role ~= DMGameMasterRole ] ]
]

{ #category : 'as yet unclassified' }
DMGameServer >> playingCommunities [
	^ (self players select: [ :c | game isCommunityClient: c ]) collect: [ :c | game communityOf: c ]
]

{ #category : 'as yet unclassified' }
DMGameServer >> publishState [
	self clients do: [ :client | game catchUp: client ].
	game refreshCormasUI
]

{ #category : 'accessing' }
DMGameServer >> startOn: aPortNumber [
	| wsDelegate dispatcher |
	self stopOtherServersOn: aPortNumber.
	game initializeSimulation.
	dispatcher := ZnDispatcherDelegate new.
	wsDelegate := ZnWebSocketDelegate map: '/' to: [ :ws | self handleWebSocket: ws ].
	dispatcher map: '/ws' to: [ :request :response | wsDelegate handleRequest: request ].
	#( '/' 'index.html' '/gm' 'gm.html' '/app.js' 'app.js' '/gm.js' 'gm.js'
	   '/board.js' 'board.js' '/style.css' 'style.css' '/qrcode.js' 'qrcode.js' ) pairsDo: [ :path :file |
		dispatcher map: path to: [ :request :response |
			response entity: (ZnEntity
				with: (self class web: file)
				type: (ZnMimeType forFilenameExtension: (file copyAfterLast: $.))) ] ].
	"The same pictures as in the Cormas window"
	{ 'lowValueTree' -> DMTiles lowValueTree. 'highValueTree' -> DMTiles highValueTree.
	  'elevation1' -> (DMTiles elevation: 1). 'elevation2' -> (DMTiles elevation: 2).
	  'elevation3' -> (DMTiles elevation: 3) } do: [ :icon |
		dispatcher map: '/icons/' , icon key , '.png' to: [ :request :response |
			response entity: (ZnEntity
				with: (ByteArray streamContents: [ :s | PNGReadWriter putForm: icon value largeForm onStream: s ])
				type: ZnMimeType imagePng) ] ].
	server := self startZincFrom: aPortNumber.
	server delegate: dispatcher
]
