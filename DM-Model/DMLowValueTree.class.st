Class {
	#name : 'DMLowValueTree',
	#superclass : 'DMTree',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'initialization' }
DMLowValueTree >> initialize [
	super initialize.
	value := 5  
]

{ #category : 'accessing' }
DMLowValueTree >> pov [
	<pov>
	^ CMPointOfView tile: DMTiles lowValueTree size: 0.2
]
