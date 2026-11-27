Class {
	#name : 'DMLowValueTree',
	#superclass : 'DMTree',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'accessing' }
DMLowValueTree >> aspectDefault: look [
	<aspect>
	^ look image: 'lowValueTree';size: 0.2
]

{ #category : 'initialization' }
DMLowValueTree >> initialize [
	super initialize.
	value := 5  
]
