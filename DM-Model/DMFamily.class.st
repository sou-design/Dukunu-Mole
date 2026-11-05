Class {
	#name : 'DMFamily',
	#superclass : 'CMAgent',
	#instVars : [
		'community',
		'educated',
		'busy'
	],
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'as yet unclassified' }
DMFamily >> beEducated [
	educated := true
]

{ #category : 'as yet unclassified' }
DMFamily >> community [
	^ community
]

{ #category : 'as yet unclassified' }
DMFamily >> community: aCommunity [
	community := aCommunity
]

{ #category : 'initialization' }
DMFamily >> initialize [
	super initialize.
	educated := false.
	busy := false
]

{ #category : 'as yet unclassified' }
DMFamily >> isBusy [
	^ busy
]

{ #category : 'as yet unclassified' }
DMFamily >> isEducated [
	^ educated
]

{ #category : 'as yet unclassified' }
DMFamily >> pov [
	<pov>
	^ CMPointOfView color: community displayColor shape: #o size: 0.18
]

{ #category : 'as yet unclassified' }
DMFamily >> startWorkingOn: aPlot [
	busy := true.
	self moveTo: aPlot.
	self positionInCell: 0.22 @ 0.3
]

{ #category : 'as yet unclassified' }
DMFamily >> stopWorking [
	busy := false.
	self leave
]
