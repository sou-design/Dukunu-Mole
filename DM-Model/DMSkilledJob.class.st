Class {
	#name : 'DMSkilledJob',
	#superclass : 'DMTownJob',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'accessing' }
DMSkilledJob class >> code [
	^ 'skilledJob'
]

{ #category : 'as yet unclassified' }
DMSkilledJob class >> familiesFrom: aCommunity [
	^ aCommunity freeFamilies select: [ :f | f isEducated ]
]

{ #category : 'accessing' }
DMSkilledJob class >> label [
	^ 'Skilled job (earns 4)'
]

{ #category : 'accessing' }
DMSkilledJob >> produce [
	self community earn: 4
]
