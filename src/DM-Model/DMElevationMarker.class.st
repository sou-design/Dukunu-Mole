Class {
	#name : 'DMElevationMarker',
	#superclass : 'CMAgent',
	#instVars : [
		'level'
	],
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'initialization' }
DMElevationMarker >> aspectDefault: look [
	<aspect>
	^ look image: 'elevation' , level printString ;size: 0.28
]

{ #category : 'initialization' }
DMElevationMarker >> initialize [
	super initialize.
	level := 1
]

{ #category : 'initialization' }
DMElevationMarker >> level: anInteger [
	level := anInteger
]
