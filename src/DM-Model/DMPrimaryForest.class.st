Class {
	#name : 'DMPrimaryForest',
	#superclass : 'DMForest',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'testing' }
DMPrimaryForest >> canRegrow [
	^ self highValueTrees < 3
]

{ #category : 'accessing' }
DMPrimaryForest >> color [
	^ Color r: 0.18 g: 0.42 b: 0.16
]

{ #category : 'as yet unclassified' }
DMPrimaryForest >> degrade [
	trees ifNotEmpty: [ ^ self ].
	plot becomeForest: DMSecondaryForest
		low: (logging = #household ifTrue: [ 2 ] ifFalse: [ 1 ])
		high: 0
]

{ #category : 'as yet unclassified' }
DMPrimaryForest >> transition [
	| low |
	low := trees reject: [ :t | t isHighValue ].
	low size < 3 ifTrue: [ ^ self ].
	(low first: 3) do: [ :t | self removeTree: t ].
	self addTree: DMHighValueTree
]
