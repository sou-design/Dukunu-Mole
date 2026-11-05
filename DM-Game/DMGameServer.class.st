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
	type = 'gmLogin' ifTrue: [ aClient role: DMGameMasterRole ].
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

{ #category : 'as yet unclassified' }
DMGameServer >> players [
	^ self clients reject: [ :c | c role = DMGameMasterRole ]
]

{ #category : 'as yet unclassified' }
DMGameServer >> playingCommunities [
	^ (self players select: [ :c | game isCommunityClient: c ]) collect: [ :c | game communityOf: c ]
]

{ #category : 'as yet unclassified' }
DMGameServer >> publishState [
	self clients do: [ :client | game catchUp: client ]
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
	   '/board.js' 'board.js' '/style.css' 'style.css' ) pairsDo: [ :path :file |
		dispatcher map: path to: [ :request :response |
			response entity: (ZnEntity
				with: (self class web: file)
				type: (ZnMimeType forFilenameExtension: (file copyAfterLast: $.))) ] ].
	server := self startZincFrom: aPortNumber.
	server delegate: dispatcher
]
