Class {
	#name : 'DMFarming',
	#superclass : 'DMActivity',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'as yet unclassified' }
DMFarming class >> baseCostOn: aPlot [
	^ 1
]

{ #category : 'as yet unclassified' }
DMFarming class >> canBePlacedOn: aPlot [
	^ aPlot landCover class = DMFarmland
]

{ #category : 'accessing' }
DMFarming >> produce [
	self give: 1 of: #vegetables
]
