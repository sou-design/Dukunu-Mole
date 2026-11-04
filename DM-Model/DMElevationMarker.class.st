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
DMElevationMarker >> initialize [
	super initialize.
	level := 1
]

{ #category : 'initialization' }
DMElevationMarker >> level: anInteger [
	level := anInteger
]

{ #category : 'initialization' }
DMElevationMarker >> pov [
	<pov>
	^ CMPointOfView tile: (DMTiles elevation: level) size: 0.28
]
