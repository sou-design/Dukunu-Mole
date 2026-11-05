Class {
	#name : 'DMLogging',
	#superclass : 'DMActivity',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'as yet unclassified' }
DMLogging class >> canBePlacedOn: aPlot [
	^ self isForestWithTrees: aPlot
]
