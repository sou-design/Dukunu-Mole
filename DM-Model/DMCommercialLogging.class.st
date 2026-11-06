Class {
	#name : 'DMCommercialLogging',
	#superclass : 'DMLogging',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'as yet unclassified' }
DMCommercialLogging class >> needsTruck [
	^ true
]

{ #category : 'accessing' }
DMCommercialLogging >> produce [
	| felled |
	felled := plot landCover fellAllTrees.
	(felled anySatisfy: [ :t | t isHighValue not ]) ifTrue: [ self give: 1 of: #lowWood ].
	(felled anySatisfy: [ :t | t isHighValue ]) ifTrue: [ self give: 1 of: #highWood ]
]
