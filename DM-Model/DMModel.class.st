Class {
	#name : 'DMModel',
	#superclass : 'CMModel',
	#instVars : [
		'plots'
	],
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'as yet unclassified' }
DMModel class >> modelName [

	^ 'DM'
]

{ #category : 'accessing' }
DMModel class >> prefix [

	^ 'DM'
]

{ #category : 'as yet unclassified' }
DMModel >> applyInitialBoard [
	| index |
	index := 0.
	1 to: 8 do: [ :i |
		1 to: 6 do: [ :j |
			| plot cover |
			index := index + 1.
			plot := self cellAt: i at: j.
			cover := (self coverClasses at: (self coverMatrix at: index)) new.
			cover isForest ifTrue: [
				(self lowValueTreesMatrix at: index) timesRepeat: [ cover addTree: DMLowValueTree new ].
				(self highValueTreesMatrix at: index) timesRepeat: [ cover addTree: DMHighValueTree new ] ].
			plot
				landCover: cover;
				elevation: (self elevationMatrix at: index);
				hasRoad: (self roadMatrix at: index) = 1;
				owner: (self ownerCodes at: (self ownerMatrix at: index)) ] ]
]

{ #category : 'as yet unclassified' }
DMModel >> coverClasses [
	^ Dictionary new
		at: #P put: DMPrimaryForest;
		at: #S put: DMSecondaryForest;
		at: #F put: DMFarmland;
		at: #U put: DMUrban;
		at: #X put: DMOutside;
		yourself
]

{ #category : 'as yet unclassified' }
DMModel >> coverMatrix [
	^ #(
	X X X X X X
	P P P P P X
	S P P P P P
	S S P P S X
	X S S S S X
	X F F F X X
	X X F F X X
	X X U X X X )
]

{ #category : 'as yet unclassified' }
DMModel >> elevationMatrix [
	^ #(
	0 0 0 0 0 0
	0 1 3 3 1 0
	0 0 1 2 2 0
	0 0 0 0 0 0
	0 0 0 0 0 0
	0 0 0 0 0 0
	0 0 0 0 0 0
	0 0 0 0 0 0 )
]

{ #category : 'as yet unclassified' }
DMModel >> highValueTreesMatrix [
	^ #(
	0 0 0 0 0 0
	2 3 3 3 2 0
	0 2 2 3 2 1
	0 0 1 1 0 0
	0 0 0 0 0 0
	0 0 0 0 0 0
	0 0 0 0 0 0
	0 0 0 0 0 0 )
]

{ #category : 'as yet unclassified' }
DMModel >> init [
	<init>
	self createGridNumberOfRows: 8 numberOfColumns: 6 neighbourhood: 6 closed: true.
	self applyInitialBoard
]

{ #category : 'initialization' }
DMModel >> initialize [
	super initialize.
	plots := OrderedCollection new
]

{ #category : 'as yet unclassified' }
DMModel >> islandPlots [
	^ self cells select: [ :plot | plot isOnIsland ]
]

{ #category : 'as yet unclassified' }
DMModel >> lowValueTreesMatrix [
	^ #(
	0 0 0 0 0 0
	0 0 0 0 0 0
	1 0 0 0 0 1
	1 2 0 0 1 0
	0 1 1 0 1 0
	0 0 0 0 0 0
	0 0 0 0 0 0
	0 0 0 0 0 0 )
]

{ #category : 'as yet unclassified' }
DMModel >> ownerCodes [
	^ Dictionary new
		at: #B put: #blue;
		at: #G put: #green;
		at: #R put: #red;
		at: #Y put: #yellow;
		at: #N put: #none;
		yourself
]

{ #category : 'as yet unclassified' }
DMModel >> ownerMatrix [
	^ #(
	N N N N N N
	N N N N N N
	B N N N N N
	B N N N Y N
	N N N N Y N
	N G N R N N
	N N G R N N
	N N N N N N )
]

{ #category : 'as yet unclassified' }
DMModel >> roadMatrix [
	^ #(
	0 0 0 0 0 0
	0 0 0 0 0 0
	0 0 0 0 0 0
	0 0 0 0 0 0
	0 1 0 0 1 0
	0 1 0 1 0 0
	0 0 1 1 0 0
	0 0 1 0 0 0 )
]

{ #category : 'as yet unclassified' }
DMModel >> step [

	<control>
	
]
