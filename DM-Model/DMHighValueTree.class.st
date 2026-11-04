Class {
	#name : 'DMHighValueTree',
	#superclass : 'DMTree',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'initialization' }
DMHighValueTree >> initialize [
	super initialize.
	value := 7
]

{ #category : 'testing' }
DMHighValueTree >> isHighValue [
	^ true
]

{ #category : 'accessing' }
DMHighValueTree >> pov [
	<pov>
	^ CMPointOfView tile: DMTiles highValueTree size: 0.26
]
