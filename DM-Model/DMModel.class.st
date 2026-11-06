Class {
	#name : 'DMModel',
	#superclass : 'CMModel',
	#instVars : [
		'plots',
		'activities'
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
DMModel >> activities [
	^ activities
]

{ #category : 'as yet unclassified' }
DMModel >> activityClasses [
	^ { DMFarming. DMCocoaProduction. DMGathering. DMHunting. DMHouseholdLogging. DMCommercialLogging. DMMotoTaxiDriver. DMSkilledJob }
]

{ #category : 'as yet unclassified' }
DMModel >> applyInitialBoard [
	| index |
	index := 0.
	1 to: 9 do: [ :i |
		1 to: 8 do: [ :j |
			| plot |
			index := index + 1.
			plot := self cellAt: i at: j.
			plot hasRoad: (self roadMatrix at: index) = 1.
			self setCoverOf: plot index: index.
			self setElevationOf: plot level: (self elevationMatrix at: index).
			self setOwnerOf: plot code: (self ownerMatrix at: index) ] ]
]

{ #category : 'as yet unclassified' }
DMModel >> buyPrices [
	^ Dictionary new
		at: #chicken put: 2;
		at: #importedWood put: 6;
		yourself
]

{ #category : 'as yet unclassified' }
DMModel >> communities [
	^ self entitiesOfClass: DMCommunity
]

{ #category : 'as yet unclassified' }
DMModel >> communityOfColor: aSymbol [
	^ (self entitiesOfClass: DMCommunity) detect: [ :c | c color = aSymbol ]
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
	X X X X X X X X
	X P P P P P X X
	X S P P P P P X
	X S S P P S X X
	X X S S S S X X
	X X F F F X X X
	X X X F F X X X
	X X X U X X X X
	X X X X X X X X )
]

{ #category : 'as yet unclassified' }
DMModel >> createCommunities [
	#( blue green red yellow ) do: [ :c |
		(self newEntity: DMCommunity) color: c ]
]

{ #category : 'as yet unclassified' }
DMModel >> createFamilies [
	self communities do: [ :c |
		3 timesRepeat: [ c addFamily: (self newEntity: DMFamily) ] ]
]

{ #category : 'as yet unclassified' }
DMModel >> elevationMatrix [
	^ #(
	0 0 0 0 0 0 0 0
	0 0 1 3 3 1 0 0
	0 0 0 1 2 2 0 0
	0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 )
]

{ #category : 'as yet unclassified' }
DMModel >> highValueTreesMatrix [
	^ #(
	0 0 0 0 0 0 0 0
	0 2 3 3 3 2 0 0
	0 0 2 2 3 2 1 0
	0 0 0 1 1 0 0 0
	0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 )
]

{ #category : 'accessing' }
DMModel >> huntingRollOn: aPlot [
	| faces |
	faces := (aPlot landCover class = DMPrimaryForest and: [ self primaryForestCount > 10 ])
		ifTrue: [ self primaryForestDie ]
		ifFalse: [ self secondaryForestDie ].
	^ self selectRandomlyFrom: faces
]

{ #category : 'as yet unclassified' }
DMModel >> init [
	<init>
	activities := OrderedCollection new.
	self createGridNumberOfRows: 9 numberOfColumns: 8 neighbourhood: 6 closed: true.
	self createCommunities.
	self applyInitialBoard.
	self createFamilies
]

{ #category : 'initialization' }
DMModel >> initialize [
	super initialize.
	activities := OrderedCollection new
]

{ #category : 'as yet unclassified' }
DMModel >> isFree: aPlot [
	^ activities noneSatisfy: [ :each | each plot == aPlot ]
]

{ #category : 'as yet unclassified' }
DMModel >> islandPlots [
	^ self cells select: [ :plot | plot isOnIsland ]
]

{ #category : 'as yet unclassified' }
DMModel >> lowValueTreesMatrix [
	^ #(
	0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0
	0 1 0 0 0 0 1 0
	0 1 2 0 0 1 0 0
	0 0 1 1 0 1 0 0
	0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 )
]

{ #category : 'as yet unclassified' }
DMModel >> maxTrucks [
	^ 6
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
	N N N N N N N N
	N N N N N N N N
	N B N N N N N N
	N B N N N Y N N
	N N N N N Y N N
	N N G N R N N N
	N N N G R N N N
	N N N N N N N N
	N N N N N N N N )
]

{ #category : 'as yet unclassified' }
DMModel >> place: anActivityClass on: aPlot for: aCommunity [
	| reason activity |
	reason := self reasonAgainst: anActivityClass on: aPlot for: aCommunity.
	reason = 'ok' ifFalse: [ ^ reason ].
	activity := anActivityClass new
		plot: aPlot;
		family: (anActivityClass familiesFrom: aCommunity) first;
		yourself.
	aCommunity pay: activity cost.
	activities add: activity.
	activity start.
	^ 'ok'
]

{ #category : 'accessing' }
DMModel >> primaryForestCount [
	^ self islandPlots count: [ :p | p landCover class = DMPrimaryForest ]
]

{ #category : 'accessing' }
DMModel >> primaryForestDie [
	^ #( 0 1 1 2 2 3 )
]

{ #category : 'accessing' }
DMModel >> produce [
	activities do: [ :each | each produce ]
]

{ #category : 'as yet unclassified' }
DMModel >> reasonAgainst: anActivityClass on: aPlot for: aCommunity [
	aPlot isOnIsland ifFalse: [ ^ 'notOnIsland' ].
	((self isFree: aPlot) or: [ anActivityClass inheritsFrom: DMTownJob ]) ifFalse: [ ^ 'plotTaken' ].
	(aPlot hasOwner and: [ aPlot owner ~~ aCommunity ]) ifTrue: [ ^ 'ownedByOtherTeam' ].
	(anActivityClass canBePlacedOn: aPlot) ifFalse: [ ^ 'notAllowedHere' ].
	(anActivityClass familiesFrom: aCommunity) isEmpty ifTrue: [ ^ 'noFamilyLeft' ].
	(anActivityClass = DMSkilledJob and: [
		(activities count: [ :a | a class = DMSkilledJob ]) >= 2 ]) ifTrue: [ ^ 'noSkilledJobLeft' ].
	(anActivityClass needsTruck and: [ self trucksInUse >= self maxTrucks ]) ifTrue: [ ^ 'noTruckLeft' ].
	(anActivityClass costOn: aPlot) > aCommunity cash ifTrue: [ ^ 'notEnoughMoney' ].
	^ 'ok'
]

{ #category : 'as yet unclassified' }
DMModel >> roadMatrix [
	^ #(
	0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0
	0 0 1 0 0 1 0 0
	0 0 1 0 1 0 0 0
	0 0 0 1 1 0 0 0
	0 0 0 1 0 0 0 0
	0 0 0 0 0 0 0 0 )
]

{ #category : 'accessing' }
DMModel >> secondaryForestDie [
	^ #( 0 0 1 1 1 2 )
]

{ #category : 'as yet unclassified' }
DMModel >> sellPrices [
	^ Dictionary new
		at: #vegetables put: 2;
		at: #gathering put: 1;
		at: #hunting put: 1;
		at: #cocoa put: 3;
		at: #lowWood put: 5;
		at: #highWood put: 5;
		yourself
]

{ #category : 'initialization' }
DMModel >> setCoverOf: aPlot index: index [
	| class |
	class := self coverClasses at: (self coverMatrix at: index).
	class isForest
		ifTrue: [ aPlot becomeForest: class
				low: (self lowValueTreesMatrix at: index)
				high: (self highValueTreesMatrix at: index) ]
		ifFalse: [ aPlot landCover: class new ]
]

{ #category : 'initialization' }
DMModel >> setElevationOf: aPlot level: aLevel [
	| marker |
	aPlot elevation: aLevel.
	aLevel = 0 ifTrue: [ ^ self ].
	marker := self newEntity: DMElevationMarker.
	marker level: aLevel.
	marker moveTo: aPlot.
	marker positionInCell: 0.75 @ 0.28
]

{ #category : 'accessing' }
DMModel >> setOwnerOf: aPlot code: aCode [
	| community |
	aCode = #N ifTrue: [ ^ self ].
	community := self communityOfColor: (self ownerCodes at: aCode).
	aPlot owner: community.
	community addOwnedPlot: aPlot
]

{ #category : 'stepping' }
DMModel >> step [
	<control>
	(self islandPlots select: [ :p | p cocoaYear > 0 ]) do: [ :p |
		(activities anySatisfy: [ :a | a plot == p and: [ a class = DMCocoaProduction ] ])
			ifFalse: [ p cocoaYear: 0 ] ].
	activities do: [ :each | each finish ].
	activities := OrderedCollection new.
	self updateForests
]

{ #category : 'as yet unclassified' }
DMModel >> trucksInUse [
	^ activities count: [ :each | each needsTruck ]
]

{ #category : 'accessing' }
DMModel >> updateForests [
	self islandPlots do: [ :plot | plot landCover evolve ]
]
