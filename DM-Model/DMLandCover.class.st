Class {
	#name : 'DMLandCover',
	#superclass : 'Object',
	#instVars : [
		'plot'
	],
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'testing' }
DMLandCover >> color [
	^ self subclassResponsibility

]

{ #category : 'testing' }
DMLandCover >> isForest [
	^ false
]

{ #category : 'testing' }
DMLandCover >> isOnIsland [
	^ true
]

{ #category : 'accessing' }
DMLandCover >> plot [

	^ plot
]

{ #category : 'accessing' }
DMLandCover >> plot: anObject [

	plot := anObject
]
