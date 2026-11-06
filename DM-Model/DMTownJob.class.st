Class {
	#name : 'DMTownJob',
	#superclass : 'DMActivity',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'as yet unclassified' }
DMTownJob class >> canBePlacedOn: aPlot [
	^ aPlot landCover class = DMUrban and: [ aPlot cormasModel currentTimeStep >= 1 ]
]
