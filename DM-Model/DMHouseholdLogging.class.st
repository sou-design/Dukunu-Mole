Class {
	#name : 'DMHouseholdLogging',
	#superclass : 'DMLogging',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'permits' }
DMHouseholdLogging class >> permitCostOn: aPlot [
	^ aPlot landCover class = DMPrimaryForest ifTrue: [ 1 ] ifFalse: [ 0 ]
]

{ #category : 'accessing' }
DMHouseholdLogging >> produce [
	| forest tree |
	forest := plot landCover.
	tree := forest trees detect: [ :t | t isHighValue not ] ifNone: [ forest trees first ].
	forest cutOneTree: tree.
	self give: 1 of: #householdWood
]
