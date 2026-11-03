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
			package: 'DM-Model';
		
			package: 'DM-Model-Tests'
			with: [ spec requires: #('DM-Model') ] ].
]
