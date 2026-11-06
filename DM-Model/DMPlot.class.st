Class {
	#name : 'DMPlot',
	#superclass : 'CMCell',
	#instVars : [
		'elevation',
		'hasRoad',
		'landCover',
		'owner',
		'cocoaYear'
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

{ #category : 'accessing' }
DMPlot >> cocoaYear [
	^ cocoaYear
]

{ #category : 'accessing' }
DMPlot >> cocoaYear: anInteger [
	cocoaYear := anInteger
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
	cocoaYear := 0.
	self landCover: DMOutside new
]

{ #category : 'as yet unclassified' }
DMPlot >> isCoast [
	^ self isOnIsland not and: [ self neighbourhood anySatisfy: [ :n | n isOnIsland ] ]
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
DMPlot >> transportCost [
	| paths frontier |
	hasRoad ifTrue: [ ^ 1 ].
	paths := Dictionary new.
	paths at: self put: (OrderedCollection with: self).
	frontier := OrderedCollection with: self.
	[ frontier notEmpty ] whileTrue: [
		| next |
		next := OrderedCollection new.
		frontier do: [ :plot |
			(plot neighbourhood select: [ :n | n isOnIsland and: [ (paths includesKey: n) not ] ])
				do: [ :n |
					| path |
					path := (paths at: plot) copyWith: n.
					n hasRoad ifTrue: [
						| cost top |
						cost := path size.
						top := n elevation.
						path reversed do: [ :c |
							c elevation > top ifTrue: [
								cost := cost + 1.
								top := c elevation ] ].
						^ cost ].
					paths at: n put: path.
					next add: n ] ].
		frontier := next ].
	^ 1
]
