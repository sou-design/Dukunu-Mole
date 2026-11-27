Class {
	#name : 'DMGame',
	#superclass : 'CMGame',
	#instVars : [
		'phase',
		'placements',
		'orders',
		'reports',
		'runnerPresenter',
		'guardChoice'
	],
	#category : 'DM-Game',
	#package : 'DM-Game'
}

{ #category : 'round 3' }
DMGame >> applyGuard [
	| model |
	model := self cormasModel.
	guardChoice isEmpty ifTrue: [ ^ self ].
	(model
		inspect: (model cellAt: (guardChoice at: 'guard'))
		fine: (guardChoice at: 'fine' ifAbsent: [ 0 ])) = 'ok' ifFalse: [ ^ self ].
	(model inspection at: 'legal') ifTrue: [ ^ self ].
	(self reportOf: (model communityOfColor: (model inspection at: 'team')))
		at: 'controlled' put: true
]

{ #category : 'instance creation' }
DMGame >> availableRoles [
	^ super availableRoles reject: [ :each | each = DMCommunityRole ]
]

{ #category : 'as yet unclassified' }
DMGame >> catchUp: aClient [
	aClient isConnected ifTrue: [ aClient sendMessage: (self stateFor: aClient) ]
]

{ #category : 'round 3' }
DMGame >> caught [
	| inspection |
	inspection := self cormasModel inspection.
	(inspection includesKey: 'legal') ifFalse: [ ^ 0 ].
	(inspection at: 'legal') ifTrue: [ ^ 0 ].
	^ 1
]

{ #category : 'as yet unclassified' }
DMGame >> cellStates [
	| model columns |
	model := self cormasModel.
	columns := model spaceModel numberOfColumns.
	^ (model cells collectWithIndex: [ :plot :index |
		| cover activity |
		cover := plot landCover.
		activity := model activities
			detect: [ :each | each plot == plot and: [ each class ~= DMEcoGuide ] ]
			ifNone: [ #none ].
		Dictionary new
			at: 'id' put: index;
			at: 'row' put: index - 1 // columns + 1;
			at: 'col' put: index - 1 \\ columns + 1;
			at: 'cover' put: cover code;
			at: 'coast' put: plot isCoast;
			at: 'low' put: (cover isForest ifTrue: [ cover lowValueTrees ] ifFalse: [ 0 ]);
			at: 'high' put: (cover isForest ifTrue: [ cover highValueTrees ] ifFalse: [ 0 ]);
			at: 'elevation' put: plot elevation;
			at: 'road' put: plot hasRoad;
			at: 'roadTo' put: (((model entitiesOfClass: DMRoad) select: [ :road | road from == plot ])
				collect: [ :road | model cells indexOf: road to ]) asArray;
			at: 'owner' put: (plot hasOwner ifTrue: [ plot owner color ] ifFalse: [ '' ]);
			at: 'cocoa' put: plot cocoaYear;
			at: 'activity' put: (activity = #none ifTrue: [ '' ] ifFalse: [ activity class code ]);
			at: 'activityTeam' put: (activity = #none ifTrue: [ '' ] ifFalse: [ activity community color ]);
			at: 'park' put: (model isInPark: plot);
			at: 'ecoGuides' put: ((model activities select: [ :each |
				each plot == plot and: [ each class = DMEcoGuide ] ]) collect: [ :each | each community color ]) asArray;
			yourself ]) asArray
]

{ #category : 'testing' }
DMGame >> communityOf: aClient [
	^ self cormasModel communityOfColor: aClient role communityColor
]

{ #category : 'as yet unclassified' }
DMGame >> communityState: aCommunity [
	^ Dictionary new
		at: 'color' put: aCommunity color;
		at: 'families' put: aCommunity families size;
		at: 'educated' put: aCommunity educatedCount;
		at: 'cash' put: aCommunity cash;
		at: 'debt' put: aCommunity debt;
		at: 'stock' put: aCommunity stock;
		at: 'foodNeed' put: aCommunity foodNeed;
		at: 'woodNeed' put: aCommunity woodNeed;
		at: 'report' put: (self reportOf: aCommunity);
		at: 'allowed' put: (aCommunity allowed collect: [ :c | c color ]) asArray;
		yourself
]

{ #category : 'round 3' }
DMGame >> createParkFrom: aDictionary [
	| model rules forbidden |
	model := self cormasModel.
	forbidden := aDictionary at: 'forbidden' ifAbsent: [ #() ].
	rules := Dictionary new.
	self parkActivityClasses do: [ :class |
		rules at: class put: (forbidden includes: class code) not ].
	^ model
		setPark: ((aDictionary at: 'park') collect: [ :id | model cellAt: id ])
		rules: rules
]

{ #category : 'initialization' }
DMGame >> initialize [
	super initialize.
	phase := 'lobby'.
	placements := OrderedDictionary new.
	orders := Dictionary new.
	reports := Dictionary new.
	guardChoice := Dictionary new.
	server := DMGameServer new.
	server game: self
]

{ #category : 'testing' }
DMGame >> isCommunityClient: aClient [
	^ aClient role isRole and: [ aClient role inheritsFrom: DMCommunityRole ]
]

{ #category : 'instance creation' }
DMGame >> maxRounds [
	^ 4
]

{ #category : 'as yet unclassified' }
DMGame >> optionsFor: aCommunity [
	| model options |
	model := self cormasModel.
	options := OrderedCollection new.
	model cells doWithIndex: [ :plot :index |
		model activityClasses do: [ :class |
			(model reasonAgainst: class on: plot for: aCommunity) = 'ok' ifTrue: [
				| option |
				option := Dictionary new
					at: 'plot' put: index;
					at: 'code' put: class code;
					at: 'label' put: class label;
					at: 'cost' put: (class costOn: plot);
					yourself.
				((class inheritsFrom: DMLogging)
					and: [ model isRound3OrLater and: [ class canHavePermitOn: plot ] ])
						ifTrue: [ option at: 'permit' put: (class permitCostOn: plot) ].
				options add: option ] ] ].
	^ options asArray
]

{ #category : 'round 3' }
DMGame >> parkActivityClasses [
	^ { DMHunting. DMGathering. DMHouseholdLogging. DMCommercialLogging }
]

{ #category : 'round 3' }
DMGame >> parkManagerState [
	| model |
	model := self cormasModel.
	^ Dictionary new
		at: 'canCreatePark' put: phase = 'park';
		at: 'canCertify' put: (model isRound3OrLater and: [ #( 'park' 'activities' ) includes: phase ]);
		at: 'caught' put: self caught;
		at: 'forbidden' put: ((self parkActivityClasses reject: [ :class | model isAllowedInPark: class ])
			collect: [ :class | class code ]) asArray;
		at: 'certificatesLeft' put: 3 - model certificatesIssued;
		at: 'teams' put: (model communities collect: [ :c |
			Dictionary new
				at: 'color' put: c color;
				at: 'educated' put: c educatedCount;
				at: 'cash' put: c cash;
				at: 'certificates' put: (model certificatesOf: c);
				yourself ]) asArray;
		yourself
]

{ #category : 'round 3' }
DMGame >> parkManagerSubmit: aValue [
	| model |
	model := self cormasModel.
	(phase = 'park' and: [ aValue includesKey: 'park' ]) ifTrue: [ self createParkFrom: aValue ].
	(phase = 'guard' and: [ aValue includesKey: 'guard' ]) ifTrue: [ guardChoice := aValue ].
	(aValue includesKey: 'certify') ifTrue: [
		(model isRound3OrLater and: [ #( 'park' 'activities' ) includes: phase ]) ifTrue: [
			model certify: (model communityOfColor: (aValue at: 'certify') asSymbol) ] ].
	server publishState
]

{ #category : 'activities' }
DMGame >> permission: aDictionary from: aClient [
	| owner other |
	(self isCommunityClient: aClient) ifFalse: [ ^ self ].
	owner := self communityOf: aClient.
	other := self cormasModel communityOfColor: (aDictionary at: 'team') asSymbol.
	(aDictionary at: 'allow') = true
		ifTrue: [ owner allow: other ]
		ifFalse: [ owner refuse: other ].
	server publishState
]

{ #category : 'instance creation' }
DMGame >> phase [
	^ phase
]

{ #category : 'activities' }
DMGame >> place: anActivityClass card: aCard for: aCommunity [
	| model activity |
	model := self cormasModel.
	(model place: anActivityClass on: (model cellAt: (aCard at: 'plot')) for: aCommunity) = 'ok'
		ifFalse: [ ^ self ].
	activity := model activities last.
	anActivityClass = DMHunting ifTrue: [ self report: activity animals huntedOn: (aCard at: 'plot') for: aCommunity ].
	anActivityClass = DMHouseholdLogging ifTrue: [ activity treeKind: (aCard at: 'tree' ifAbsent: [ 'low' ]) asSymbol ].
	(activity isLogging and: [ (aCard at: 'permit' ifAbsent: [ false ]) = true ]) ifTrue: [
		(self reportOf: aCommunity) at: 'permit' put: (model buyPermitFor: activity) ]
]

{ #category : 'stepping - auto' }
DMGame >> proceed [
	phase = 'ready' ifTrue: [
		self startRound.
		phase := self round = 3 ifTrue: [ 'park' ] ifFalse: [ 'activities' ].
		^ server publishState ].
	phase = 'park' ifTrue: [
		phase := 'activities'.
		^ server publishState ].
	phase = 'activities' ifTrue: [
		self resolvePlacements.
		self cormasModel isRound3OrLater
			ifTrue: [ phase := 'guard' ]
			ifFalse: [
				self cormasModel produce.
				phase := 'market' ].
		^ server publishState ].
	phase = 'guard' ifTrue: [
		self applyGuard.
		self cormasModel produce.
		phase := 'market'.
		^ server publishState ].
	phase = 'market' ifTrue: [
		self resolveMarket.
		phase := 'results'.
		^ server publishState ].
	phase = 'results' ifTrue: [
		self runStep.
		phase := self currentTimeStep >= self maxRounds ifTrue: [ 'ended' ] ifFalse: [ 'ready' ].
		^ server publishState ]
]

{ #category : 'ui' }
DMGame >> refreshCormasUI [
	| builder |
	[ runnerPresenter displayCurrentTimeStep.
	builder := (runnerPresenter instVarNamed: 'spacePresenter') spaceBuilder.
	builder renderIn: builder container.
	builder container signalUpdate ]
		on: Error
		do: [ :e | Transcript showCr: 'Cormas window not refreshed: ' , e messageText ]
]

{ #category : 'activities' }
DMGame >> report: animals huntedOn: aPlotId for: aCommunity [
	| report |
	report := self reportOf: aCommunity.
	report
		at: 'hunting'
		put: ((report at: 'hunting' ifAbsent: [ #() ]) copyWith: (Dictionary new
			at: 'plot' put: aPlotId;
			at: 'animals' put: animals;
			yourself))
]

{ #category : 'as yet unclassified' }
DMGame >> reportOf: aCommunity [
	^ reports at: aCommunity ifAbsentPut: [ Dictionary new ]
]

{ #category : 'initialization' }
DMGame >> resolveMarket [
	| model |
	model := self cormasModel.
	server playingCommunities asSet do: [ :community |
		| order foodShort woodShort loan needsMet |
		order := orders at: community ifAbsent: [ Dictionary new ].
		(order at: 'sell' ifAbsent: [ Dictionary new ]) keysAndValuesDo: [ :resource :n |
			(model sellPrices includesKey: resource asSymbol) ifTrue: [ community sell: n of: resource asSymbol ] ].
		community sell: (community amountOf: #cocoa) of: #cocoa.
		(order at: 'buy' ifAbsent: [ Dictionary new ]) keysAndValuesDo: [ :resource :n |
			(model buyPrices includesKey: resource asSymbol) ifTrue: [ community buy: n of: resource asSymbol ] ].
		foodShort := community foodNeed - community foodAvailable max: 0.
		woodShort := community woodNeed - community woodAvailable max: 0.
		loan := foodShort * (model buyPrices at: #chicken)
			+ (woodShort * (model buyPrices at: #importedWood)) > community cash.
		loan ifTrue: [ community takeLoan ].
		community buy: foodShort of: #chicken.
		community buy: woodShort of: #importedWood.
		needsMet := community meetNeeds.
		(self reportOf: community)
			at: 'loan' put: loan;
			at: 'needsMet' put: needsMet;
			at: 'health' put: (needsMet
				ifTrue: [ community payHealthAndEducation: (order at: 'health' ifAbsent: [ 0 ]) ]
				ifFalse: [ 0 ]) ]
]

{ #category : 'initialization' }
DMGame >> resolvePlacements [
	| model cards |
	model := self cormasModel.
	cards := OrderedCollection new.
	placements keysAndValuesDo: [ :community :list |
		list do: [ :card | cards add: community -> card ] ].
	cards := (cards select: [ :each | (each value at: 'code') = 'skilledJob' ]) shuffled
		, (cards reject: [ :each | (each value at: 'code') = 'skilledJob' ]).
	cards do: [ :each |
		model activityClasses
			detect: [ :class | class code = (each value at: 'code') ]
			ifFound: [ :class | self place: class card: each value for: each key ] ]
]

{ #category : 'instance creation' }
DMGame >> round [
	^ self currentTimeStep + 1
]

{ #category : 'simulation runner - running' }
DMGame >> runStep [
	super runStep.
	server publishState
]

{ #category : 'accessing' }
DMGame >> runnerPresenter: aPresenter [
	runnerPresenter := aPresenter

]

{ #category : 'initialization' }
DMGame >> startGame [
	super startGame.
	phase := 'ready'.
	server publishState
]

{ #category : 'initialization' }
DMGame >> startRound [
	| model |
	model := self cormasModel.
	self round > 1 ifTrue: [
		model communities do: [ :c | c addFamily: (model newEntity: DMFamily) ] ].
	model communities do: [ :c | c repayDebt ].
	model startRound: self round.
	placements := OrderedDictionary new.
	orders := Dictionary new.
	reports := Dictionary new.
	guardChoice := Dictionary new
]

{ #category : 'initialization' }
DMGame >> stateFor: aClient [
	| model state community |
	model := self cormasModel.
	state := Dictionary new
		at: 'type' put: 'state';
		at: 'phase' put: phase;
		at: 'round' put: (self round min: self maxRounds);
		at: 'maxRounds' put: self maxRounds;
		at: 'prices' put: model sellPrices;
		at: 'buyPrices' put: model buyPrices;
		at: 'board' put: self cellStates;
		at: 'tourists' put: model tourists;
		at: 'guided' put: model guided;
		at: 'inspection' put: model inspection;
		yourself.
	(self isCommunityClient: aClient) ifTrue: [
		community := self communityOf: aClient.
		state
			at: 'community' put: (self communityState: community);
			at: 'options' put: (phase = 'activities' ifTrue: [ self optionsFor: community ] ifFalse: [ #() ]) ].
	aClient role = DMParkManagerRole ifTrue: [
		state at: 'parkManager' put: self parkManagerState ].
	aClient role = DMGameMasterRole ifTrue: [
		state at: 'teams' put: (model communities collect: [ :c | self communityState: c ]) asArray ].
	^ state
]

{ #category : 'initialization' }
DMGame >> submit: aValue from: aClient [
	aClient role = DMParkManagerRole ifTrue: [ ^ self parkManagerSubmit: aValue ].
	(self isCommunityClient: aClient) ifFalse: [ ^ self ].
	phase = 'activities' ifTrue: [ placements at: (self communityOf: aClient) put: aValue ].
	phase = 'market' ifTrue: [ orders at: (self communityOf: aClient) put: aValue ]
]
