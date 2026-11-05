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

{ #category : 'as yet unclassified' }
DMGathering class >> code [
	^ 'gathering'
]

{ #category : 'as yet unclassified' }
DMGathering class >> label [
	^ 'Gathering'
]

{ #category : 'accessing' }
DMGathering >> produce [
	self give: 1 of: #gathering
]
