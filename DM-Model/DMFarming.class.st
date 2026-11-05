Class {
	#name : 'DMFarming',
	#superclass : 'DMActivity',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'as yet unclassified' }
DMFarming class >> canBePlacedOn: aPlot [
	^ aPlot landCover class = DMFarmland
]

{ #category : 'as yet unclassified' }
DMFarming class >> code [
	^ 'farming'
]

{ #category : 'as yet unclassified' }
DMFarming class >> label [
	^ 'Vegetables'
]

{ #category : 'accessing' }
DMFarming >> produce [
	self give: (plot cormasModel primaryForestCount < 10 ifTrue: [ 1 ] ifFalse: [ 2 ]) of: #vegetables
]
