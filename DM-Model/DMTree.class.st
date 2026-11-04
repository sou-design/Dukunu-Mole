Class {
	#name : 'DMTree',
	#superclass : 'CMAgent',
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

{ #category : 'testing' }
DMTree >> isHighValue [
	^ false
]

{ #category : 'initialization' }
DMTree >> value [
	^ value
]
