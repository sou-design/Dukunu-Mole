Class {
	#name : 'DMHunting',
	#superclass : 'DMActivity',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'as yet unclassified' }
DMHunting class >> canBePlacedOn: aPlot [
	^ aPlot landCover isForest
]

{ #category : 'as yet unclassified' }
DMHunting class >> code [
	^ 'hunting'
]

{ #category : 'as yet unclassified' }
DMHunting class >> label [
	^ 'Hunting'
]

{ #category : 'accessing' }
DMHunting >> produce [
	self give: (plot cormasModel huntingRollOn: plot) of: #hunting
]
