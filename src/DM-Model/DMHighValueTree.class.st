Class {
	#name : 'DMHighValueTree',
	#superclass : 'DMTree',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'accessing' }
DMHighValueTree >> aspectDefault: look [
	<aspect>
	^ look  image:  'highValueTree'; size: 0.26
]

{ #category : 'initialization' }
DMHighValueTree >> initialize [
	super initialize.
	value := 7
]

{ #category : 'testing' }
DMHighValueTree >> isHighValue [
	^ true
]
