Class {
	#name : 'DMEcoGuide',
	#superclass : 'DMActivity',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'as yet unclassified' }
DMEcoGuide class >> canBePlacedOn: aPlot [
	^ aPlot landCover isForest and: [ aPlot cormasModel isRound3OrLater ]
]

{ #category : 'as yet unclassified' }
DMEcoGuide class >> sharesPlot [
	^ true
]

{ #category : 'accessing' }
DMEcoGuide >> produce [
	plot cormasModel guideTourist ifTrue: [ self community earn: 3 ]
]
