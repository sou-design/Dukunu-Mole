Class {
	#name : 'DMPlot',
	#superclass : 'CMCell',
	#instVars : [
		'elevation',
		'hasRoad',
		'landCover',
		'owner'
	],
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'as yet unclassified' }
DMPlot >> becomeForest: aForestClass low: lowCount high: highCount [

	landCover isForest ifTrue: [ landCover removeAllTrees ].
	self landCover: aForestClass new.
	landCover addLow: lowCount high: highCount
]

{ #category : 'initialization' }
DMPlot >> elevation [
	^ elevation
]

{ #category : 'initialization' }
DMPlot >> elevation: anInteger [
	elevation := anInteger
]

{ #category : 'testing' }
DMPlot >> hasOwner [
	^ owner ~= #none
]

{ #category : 'initialization' }
DMPlot >> hasRoad [
	^ hasRoad
]

{ #category : 'initialization' }
DMPlot >> hasRoad: aBoolean [
	hasRoad := aBoolean
]

{ #category : 'initialization' }
DMPlot >> initialize [
	super initialize.
	elevation := 0.
	hasRoad := false.
	owner := #none.
	self landCover: DMOutside new
]

{ #category : 'initialization' }
DMPlot >> isOnIsland [
	^ landCover isOnIsland
]

{ #category : 'initialization' }
DMPlot >> landCover [
	^ landCover
]

{ #category : 'initialization' }
DMPlot >> landCover: aLandCover [
	landCover := aLandCover.
	aLandCover plot: self
]

{ #category : 'initialization' }
DMPlot >> owner [
	^ owner
]

{ #category : 'accessing' }
DMPlot >> owner: anObject [

	owner := anObject
]

{ #category : 'as yet unclassified' }
DMPlot >> pov [
	<pov>
	| visible borderWidth borderColor |
	visible := self isOnIsland or: [
		self neighbourhood anySatisfy: [ :n | n isOnIsland ] ].
	borderWidth := 0.01.
	borderColor := visible
		ifTrue: [ CMColor gray ]
		ifFalse: [ CMColor white ].
	self hasOwner ifTrue: [
		borderColor := owner displayColor.
		borderWidth := 0.05 ].
	^ CMPointOfView new
		color: landCover color;
		borderWidth: borderWidth;
		borderColor: borderColor;
		yourself
]

{ #category : 'as yet unclassified' }
DMPlot >> povLandCover [
	<pov>
	^ CMPointOfView color: landCover color
]
