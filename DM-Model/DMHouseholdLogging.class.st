Class {
	#name : 'DMHouseholdLogging',
	#superclass : 'DMLogging',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'accessing' }
DMHouseholdLogging >> produce [
	| forest tree |
	forest := plot landCover.
	tree := forest trees detect: [ :t | t isHighValue not ] ifNone: [ forest trees first ].
	forest cutOneTree: tree.
	self give: 1 of: #householdWood
]
