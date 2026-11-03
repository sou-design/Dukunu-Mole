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
	^ CMPointOfView color: landCover color
]

{ #category : 'as yet unclassified' }
DMPlot >> povLandCover [
	<pov>
	^ CMPointOfView color: landCover color
]
