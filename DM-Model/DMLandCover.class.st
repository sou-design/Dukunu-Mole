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
DMLandCover class >> isForest [
	^ false
]

{ #category : 'accessing' }
DMLandCover >> code [
	^ self subclassResponsibility
]

{ #category : 'testing' }
DMLandCover >> color [
	^ self subclassResponsibility

]

{ #category : 'initialization' }
DMLandCover >> evolve [
	
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
