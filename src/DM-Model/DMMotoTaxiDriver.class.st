Class {
	#name : 'DMMotoTaxiDriver',
	#superclass : 'DMTownJob',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'accessing' }
DMMotoTaxiDriver class >> code [
	^ 'motoTaxi'
]

{ #category : 'accessing' }
DMMotoTaxiDriver class >> label [
	^ 'Moto-taxi (earns 1)'
]

{ #category : 'accessing' }
DMMotoTaxiDriver >> produce [
	self community earn: 1
]
