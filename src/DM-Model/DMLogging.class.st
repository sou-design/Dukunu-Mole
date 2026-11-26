Class {
	#name : 'DMLogging',
	#superclass : 'DMActivity',
	#instVars : [
		'hasPermit',
		'confiscated'
	],
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'as yet unclassified' }
DMLogging class >> canBePlacedOn: aPlot [
	^ self isForestWithTrees: aPlot
]

{ #category : 'permits' }
DMLogging class >> canHavePermitOn: aPlot [
	^ aPlot elevation = 0 and: [ (aPlot cormasModel isInPark: aPlot) not ]
]

{ #category : 'permits' }
DMLogging class >> permitCostOn: aPlot [
	^ self subclassResponsibility
]

{ #category : 'permits' }
DMLogging >> confiscate [
	confiscated := true
]

{ #category : 'accessing' }
DMLogging >> give: anInteger of: aResource [
	confiscated ifTrue: [ ^ self ].
	super give: anInteger of: aResource
]

{ #category : 'permits' }
DMLogging >> givePermit [
	hasPermit := true
]

{ #category : 'permits' }
DMLogging >> hasPermit [
	^ hasPermit
]

{ #category : 'initialization' }
DMLogging >> initialize [
	super initialize.
	hasPermit := false.
	confiscated := false
]

{ #category : 'permits' }
DMLogging >> isConfiscated [
	^ confiscated
]

{ #category : 'permits' }
DMLogging >> isLegal [
	| model |
	model := plot cormasModel.
	(model isInPark: plot) ifTrue: [ ^ model isAllowedInPark: self class ].
	model isRound3OrLater ifFalse: [ ^ true ].
	^ hasPermit
]

{ #category : 'testing' }
DMLogging >> isLogging [
	^ true
]
