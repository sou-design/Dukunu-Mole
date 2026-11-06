Class {
	#name : 'DMHunting',
	#superclass : 'DMActivity',
	#instVars : [
		'animals'
	],
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'as yet unclassified' }
DMHunting class >> canBePlacedOn: aPlot [
	^ aPlot landCover isForest
]

{ #category : 'accessing' }
DMHunting >> animals: anInteger [
	animals := anInteger
]

{ #category : 'accessing' }
DMHunting >> produce [
	self give: animals of: #hunting
]

{ #category : 'accessing' }
DMHunting >> start [
	super start.
	animals := plot cormasModel huntingRollOn: plot
]
