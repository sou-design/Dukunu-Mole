Class {
	#name : 'BaselineOfDMModel',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfDMModel',
	#package : 'BaselineOfDMModel'
}

{ #category : 'as yet unclassified' }
BaselineOfDMModel >> baseline: spec [
	<baseline>
	spec for: #common do: [
		spec
			baseline: 'CormasGameServer'
			with: [ spec repository: 'github://cormas/cormas-game-server:main/src' ].
		spec
			package: 'DM-Model';
			package: 'DM-Model-Tests' with: [ spec requires: #( 'DM-Model' ) ];
			package: 'DM-Game' with: [ spec requires: #( 'DM-Model' 'CormasGameServer' ) ] ]
]
