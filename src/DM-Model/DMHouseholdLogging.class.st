Class {
	#name : 'DMHouseholdLogging',
	#superclass : 'DMLogging',
	#instVars : [
		'treeKind'
	],
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'permits' }
DMHouseholdLogging class >> permitCostOn: aPlot [
	^ aPlot landCover class = DMPrimaryForest ifTrue: [ 1 ] ifFalse: [ 0 ]
]

{ #category : 'initialization' }
DMHouseholdLogging >> initialize [
	super initialize.
	treeKind := #low
]

{ #category : 'accessing' }
DMHouseholdLogging >> produce [
	| forest tree |
	forest := plot landCover.
	tree := forest trees detect: [ :t | t isHighValue = (treeKind = #high) ] ifNone: [ forest trees first ].
	forest cutOneTree: tree.
	self give: 1 of: #householdWood
]

{ #category : 'accessing' }
DMHouseholdLogging >> treeKind: aSymbol [
	treeKind := aSymbol
]
