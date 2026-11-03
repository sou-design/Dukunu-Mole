Class {
	#name : 'DMTree',
	#superclass : 'Object',
	#instVars : [
		'value'
	],
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'initialization' }
DMTree >> initialize [
	super initialize.
	value := 0
]

{ #category : 'initialization' }
DMTree >> value [
	^ value
]
