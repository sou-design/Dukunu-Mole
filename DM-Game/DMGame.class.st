Class {
	#name : 'DMGame',
	#superclass : 'CMGame',
	#instVars : [
		'phase',
		'placements',
		'orders',
		'reports',
		'runnerPresenter'
	],
	#category : 'DM-Game',
	#package : 'DM-Game'
}

{ #category : 'instance creation' }
DMGame >> availableRoles [
	^ super availableRoles reject: [ :each | each = DMCommunityRole ]
]

{ #category : 'as yet unclassified' }
DMGame >> catchUp: aClient [
	aClient isConnected ifTrue: [ aClient sendMessage: (self stateFor: aClient) ]
]

{ #category : 'as yet unclassified' }
DMGame >> cellStates [
	| model columns |
	model := self cormasModel.
	columns := model spaceModel numberOfColumns.
	^ (model cells collectWithIndex: [ :plot :index |
		| cover activity |
		cover := plot landCover.
		activity := model activities detect: [ :each | each plot == plot ] ifNone: [ #none ].
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
			at: 'owner' put: (plot hasOwner ifTrue: [ plot owner color ] ifFalse: [ '' ]);
			at: 'cocoa' put: plot cocoaYear;
			at: 'activity' put: (activity = #none ifTrue: [ '' ] ifFalse: [ activity class code ]);
			at: 'activityTeam' put: (activity = #none ifTrue: [ '' ] ifFalse: [ activity community color ]);
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
		yourself
]

{ #category : 'initialization' }
DMGame >> initialize [
	super initialize.
	phase := 'lobby'.
	placements := OrderedDictionary new.
	orders := Dictionary new.
	reports := Dictionary new.
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
				options add: (Dictionary new
					at: 'plot' put: index;
					at: 'code' put: class code;
					at: 'label' put: class label;
					at: 'cost' put: (class costOn: plot);
					yourself) ] ] ].
	^ options asArray
]

{ #category : 'instance creation' }
DMGame >> phase [
	^ phase
]

{ #category : 'stepping - auto' }
DMGame >> proceed [
	phase = 'ready' ifTrue: [
		self startRound.
		phase := 'activities'.
		^ server publishState ].
	phase = 'activities' ifTrue: [
		self resolvePlacements.
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

{ #category : 'as yet unclassified' }
DMGame >> reportOf: aCommunity [
	^ reports at: aCommunity ifAbsentPut: [ Dictionary new ]
]

{ #category : 'initialization' }
DMGame >> resolveMarket [
	| model |
	model := self cormasModel.
	orders keysAndValuesDo: [ :community :order |
		| foodShort woodShort loan needsMet |
		(order at: 'sell') keysAndValuesDo: [ :resource :n | community sell: n of: resource asSymbol ].
		community sell: (community amountOf: #cocoa) of: #cocoa.
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
				ifTrue: [ community payHealthAndEducation: (order at: 'health') ]
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
			ifFound: [ :class |
				((model place: class on: (model cellAt: (each value at: 'plot')) for: each key) = 'ok'
					and: [ class = DMHunting ]) ifTrue: [
						each value at: 'animals' ifPresent: [ :n | model activities last animals: n ] ] ] ]
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
	placements := OrderedDictionary new.
	orders := Dictionary new.
	reports := Dictionary new
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
		at: 'board' put: self cellStates;
		yourself.
	(self isCommunityClient: aClient) ifTrue: [
		community := self communityOf: aClient.
		state
			at: 'community' put: (self communityState: community);
			at: 'options' put: (phase = 'activities' ifTrue: [ self optionsFor: community ] ifFalse: [ #() ]) ].
	aClient role = DMParkManagerRole ifTrue: [ state at: 'parkManager' put: true ].
	aClient role = DMGameMasterRole ifTrue: [
		state at: 'teams' put: (model communities collect: [ :c | self communityState: c ]) asArray ].
	^ state
]

{ #category : 'initialization' }
DMGame >> submit: aValue from: aClient [
	phase = 'activities' ifTrue: [ placements at: (self communityOf: aClient) put: aValue ].
	phase = 'market' ifTrue: [ orders at: (self communityOf: aClient) put: aValue ]
]
