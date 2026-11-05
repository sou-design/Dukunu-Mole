Class {
	#name : 'DMHouseholdLogging',
	#superclass : 'DMLogging',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'as yet unclassified' }
DMHouseholdLogging class >> code [
	^ 'householdWood'
]

{ #category : 'as yet unclassified' }
DMHouseholdLogging class >> label [
	^ 'Household wood'
]

{ #category : 'accessing' }
DMHouseholdLogging >> produce [
	| forest tree |
	forest := plot landCover.
	tree := forest trees detect: [ :t | t isHighValue not ] ifNone: [ forest trees first ].
	forest cutOneTree: tree.
	self give: 1 of: #householdWood
]
