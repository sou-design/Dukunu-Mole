Class {
	#name : 'DMCommercialLogging',
	#superclass : 'DMLogging',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'as yet unclassified' }
DMCommercialLogging class >> code [
	^ 'commercialWood'
]

{ #category : 'as yet unclassified' }
DMCommercialLogging class >> label [
	^ 'Commercial wood'
]

{ #category : 'as yet unclassified' }
DMCommercialLogging class >> needsTruck [
	^ true
]

{ #category : 'accessing' }
DMCommercialLogging >> produce [
	| felled |
	felled := plot landCover fellAllTrees.
	self give: (felled count: [ :t | t isHighValue not ]) of: #lowWood.
	self give: (felled count: [ :t | t isHighValue ]) of: #highWood
]
