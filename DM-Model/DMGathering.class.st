Class {
	#name : 'DMGathering',
	#superclass : 'DMActivity',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'as yet unclassified' }
DMGathering class >> canBePlacedOn: aPlot [
	^ aPlot landCover isForest
]

{ #category : 'accessing' }
DMGathering >> produce [
	self give: 1 of: #gathering
]
