Class {
	#name : 'DMSecondaryForest',
	#superclass : 'DMForest',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'testing' }
DMSecondaryForest >> canRegrow [
	^ (plot hasRoad and: [ self lowValueTrees >= 1 ]) not
]

{ #category : 'accessing' }
DMSecondaryForest >> code [
	^ 'S'
]

{ #category : 'accessing' }
DMSecondaryForest >> color [
	^ Color r: 0.49 g: 0.73 b: 0.34
]

{ #category : 'as yet unclassified' }
DMSecondaryForest >> transition [
	self lowValueTrees >= 3 ifTrue: [
		plot becomeForest: DMPrimaryForest low: 0 high: 1 ]
]
