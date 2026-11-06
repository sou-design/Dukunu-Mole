Class {
	#name : 'DMActivity',
	#superclass : 'Object',
	#instVars : [
		'plot',
		'family',
		'produced'
	],
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'as yet unclassified' }
DMActivity class >> baseCostOn: aPlot [
	^ 0
]

{ #category : 'as yet unclassified' }
DMActivity class >> canBePlacedOn: aPlot [
	^ self subclassResponsibility
]

{ #category : 'as yet unclassified' }
DMActivity class >> costOn: aPlot [
	^ (self baseCostOn: aPlot) + (self needsTruck ifTrue: [ aPlot transportCost ] ifFalse: [ 0 ])
]

{ #category : 'as yet unclassified' }
DMActivity class >> isForestWithTrees: aPlot [
	^ aPlot landCover isForest and: [ aPlot landCover trees notEmpty ]
]

{ #category : 'as yet unclassified' }
DMActivity class >> needsTruck [
	^ false
]

{ #category : 'accessing' }
DMActivity >> community [
	^ family community
]

{ #category : 'accessing' }
DMActivity >> cost [
	^ self class costOn: plot
]

{ #category : 'accessing' }
DMActivity >> family [
	^ family
]

{ #category : 'accessing' }
DMActivity >> family: aFamily [
	family := aFamily
]

{ #category : 'accessing' }
DMActivity >> finish [
	family stopWorking
]

{ #category : 'accessing' }
DMActivity >> give: anInteger of: aResource [
	self community add: anInteger of: aResource.
	self needsTruck ifTrue: [ self community sell: anInteger of: aResource ].
	produced at: aResource put: (produced at: aResource ifAbsent: [ 0 ]) + anInteger
]

{ #category : 'initialization' }
DMActivity >> initialize [
	super initialize.
	produced := Dictionary new
]

{ #category : 'accessing' }
DMActivity >> needsTruck [
	^ self class needsTruck
]

{ #category : 'initialization' }
DMActivity >> plot [
	^ plot
]

{ #category : 'accessing' }
DMActivity >> plot: aPlot [
	plot := aPlot
]

{ #category : 'accessing' }
DMActivity >> produce [
	^ self subclassResponsibility
]

{ #category : 'accessing' }
DMActivity >> produced [
	^ produced
]

{ #category : 'accessing' }
DMActivity >> start [
	family startWorkingOn: plot
]
