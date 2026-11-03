Class {
	#name : 'DMForest',
	#superclass : 'DMLandCover',
	#instVars : [
		'trees'
	],
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'testing' }
DMForest >> addTree: aTree [
	trees add: aTree
]

{ #category : 'testing' }
DMForest >> highValueTrees [
	^ trees count: [ :t | t isKindOf: DMHighValueTree ]
]

{ #category : 'initialization' }
DMForest >> initialize [
	super initialize.
	trees := OrderedCollection new
]

{ #category : 'testing' }
DMForest >> isForest [
	^ true
]

{ #category : 'testing' }
DMForest >> lowValueTrees [
	^ trees count: [ :t | t isKindOf: DMLowValueTree ]
]

{ #category : 'testing' }
DMForest >> trees [
	^ trees
]
