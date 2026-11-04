Class {
	#name : 'DMForest',
	#superclass : 'DMLandCover',
	#instVars : [
		'trees',
		'logging'
	],
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'testing' }
DMForest class >> isForest [
	^ true
]

{ #category : 'testing' }
DMForest class >> treeSlots [
	^ { 0.3 @ 0.55. 0.5 @ 0.55. 0.7 @ 0.55. 0.4 @ 0.78. 0.6 @ 0.78. 0.5 @ 0.32 }
]

{ #category : 'as yet unclassified' }
DMForest >> addLow: lowCount high: highCount [
	lowCount timesRepeat: [ self addTree: DMLowValueTree ].
	highCount timesRepeat: [ self addTree: DMHighValueTree ]
]

{ #category : 'as yet unclassified' }
DMForest >> addTree: aTreeClass [
	| tree |
	tree := plot cormasModel newEntity: aTreeClass.
	trees add: tree.
	tree moveTo: plot.
	self arrangeTrees
]

{ #category : 'as yet unclassified' }
DMForest >> arrangeTrees [
	| slots |
	slots := self class treeSlots.
	trees doWithIndex: [ :t :i | t positionInCell: (slots at: (i min: slots size)) ]
]

{ #category : 'testing' }
DMForest >> canRegrow [
	^ self subclassResponsibility
]

{ #category : 'initialization' }
DMForest >> cutOneTree: aTree [
	logging := #household.
	^ self removeTree: aTree
]

{ #category : 'initialization' }
DMForest >> evolve [
	logging = #none
		ifTrue: [ self regrow ]
		ifFalse: [ self degrade ].
	logging := #none
]

{ #category : 'initialization' }
DMForest >> fellAllTrees [
	logging := #commercial.
	^ self removeAllTrees
]

{ #category : 'testing' }
DMForest >> highValueTrees [
	^ trees count: [ :t | t isHighValue ]
]

{ #category : 'initialization' }
DMForest >> initialize [
	super initialize.
	trees := OrderedCollection new.
	logging := #none
]

{ #category : 'adding' }
DMForest >> isForest [
	^ true
]

{ #category : 'testing' }
DMForest >> low: lowCount high: highCount [
	^ self new addLow: lowCount high: highCount; yourself
]

{ #category : 'testing' }
DMForest >> lowValueTrees [
	^ trees count: [ :t | t isHighValue not ]
]

{ #category : 'initialization' }
DMForest >> regrow [
	self canRegrow ifTrue: [ self addTree: DMLowValueTree ].
	self transition
]

{ #category : 'removing' }
DMForest >> removeAllTrees [
	^ trees copy collect: [ :t | self removeTree: t ]
]

{ #category : 'removing' }
DMForest >> removeTree: aTree [
	trees remove: aTree.
	aTree delete.
	self arrangeTrees.
	^ aTree
]

{ #category : 'as yet unclassified' }
DMForest >> transition [
	^ self subclassResponsibility
]

{ #category : 'as yet unclassified' }
DMForest >> treeSlots [
	^ { 0.3 @ 0.55. 0.5 @ 0.55. 0.7 @ 0.55. 0.4 @ 0.78. 0.6 @ 0.78. 0.5 @ 0.32 }
]

{ #category : 'testing' }
DMForest >> trees [
	^ trees
]
