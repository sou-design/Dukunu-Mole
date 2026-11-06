Class {
	#name : 'DMCommunity',
	#superclass : 'CMAgent',
	#instVars : [
		'color',
		'ownedPlots',
		'families',
		'cash',
		'debt',
		'stock'
	],
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'adding' }
DMCommunity >> add: anInteger of: aResource [
	stock at: aResource put: (stock at: aResource) + anInteger
]

{ #category : 'adding' }
DMCommunity >> addFamily: aFamily [
	families add: aFamily.
	aFamily community: self
]

{ #category : 'initialization' }
DMCommunity >> addOwnedPlot: aPlot [
	ownedPlots add: aPlot
]

{ #category : 'adding' }
DMCommunity >> amountOf: aResource [
	^ stock at: aResource
]

{ #category : 'adding' }
DMCommunity >> buy: anInteger of: aResource [
	"Buy as many as the cash allows. Answer the number bought"
	| price count |
	price := self cormasModel buyPrices at: aResource.
	count := (anInteger max: 0) min: cash // price.
	cash := cash - (count * price).
	stock at: aResource put: (stock at: aResource) + count.
	^ count
]

{ #category : 'accessing' }
DMCommunity >> cash [
	^ cash
]

{ #category : 'accessing' }
DMCommunity >> color [
	^ color
]

{ #category : 'accessing' }
DMCommunity >> color: aSymbol [
	color := aSymbol
]

{ #category : 'adding' }
DMCommunity >> consume: anInteger from: resources [

	| left |
	left := anInteger.
	resources do: [ :each |
		| used |
		used := left min: (stock at: each).
		stock at: each put: (stock at: each) - used.
		left := left - used ].
	^ left
]

{ #category : 'accessing' }
DMCommunity >> debt [
	^ debt
]

{ #category : 'initialization' }
DMCommunity >> displayColor [
	| hex |
	hex := Dictionary new
		at: #blue put: '378ADD';
		at: #green put: '3B6D11';
		at: #red put: 'E24B4A';
		at: #yellow put: 'EF9F27';
		yourself.
	^ CMColor fromHexString: (hex at: color)
]

{ #category : 'as yet unclassified' }
DMCommunity >> earn: anInteger [
	cash := cash + anInteger
]

{ #category : 'adding' }
DMCommunity >> educatedCount [
	^ families count: [ :f | f isEducated ]
]

{ #category : 'adding' }
DMCommunity >> emptyStock [
	| d |
	d := Dictionary new.
	#( vegetables gathering hunting cocoa householdWood lowWood highWood chicken importedWood )
		do: [ :each | d at: each put: 0 ].
	^ d
]

{ #category : 'accessing' }
DMCommunity >> families [
	^ families
]

{ #category : 'adding' }
DMCommunity >> foodAvailable [
	^ self foodResources inject: 0 into: [ :sum :each | sum + (stock at: each) ]
]

{ #category : 'adding' }
DMCommunity >> foodNeed [
	^ families size
]

{ #category : 'adding' }
DMCommunity >> foodResources [
	^ #( chicken gathering hunting vegetables )
]

{ #category : 'adding' }
DMCommunity >> freeFamilies [
	^ families reject: [ :f | f isBusy ]
]

{ #category : 'adding' }
DMCommunity >> initialize [
	super initialize.
	color := #none.
	ownedPlots := OrderedCollection new.
	families := OrderedCollection new.
	cash := 3.
	debt := 0.
	stock := self emptyStock
]

{ #category : 'adding' }
DMCommunity >> meetNeeds [
	| foodLeft woodLeft |
	foodLeft := self consume: self foodNeed from: self foodResources.
	woodLeft := self consume: self woodNeed from: self woodResources.
	^ foodLeft = 0 and: [ woodLeft = 0 ]
]

{ #category : 'initialization' }
DMCommunity >> ownedPlots [
	^ ownedPlots
]

{ #category : 'adding' }
DMCommunity >> pay: anInteger [
	cash := cash - anInteger
]

{ #category : 'adding' }
DMCommunity >> payHealthAndEducation: anInteger [
	| count |
	count := ((anInteger max: 0) min: families size) min: cash.
	cash := cash - count.
	(families first: count) do: [ :f | f beEducated ].
	^ count
]

{ #category : 'adding' }
DMCommunity >> repayDebt [
	| paid |
	paid := debt min: cash.
	cash := cash - paid.
	debt := debt - paid.
	^ paid
]

{ #category : 'as yet unclassified' }
DMCommunity >> sell: anInteger of: aResource [
  	| count |
  	count := (anInteger max: 0) min: (stock at: aResource).
  	stock at: aResource put: (stock at: aResource) - count.
  	cash := cash + (count * (self cormasModel sellPrices at: aResource)).
  	^ count
]

{ #category : 'accessing' }
DMCommunity >> stock [
	^ stock
]

{ #category : 'adding' }
DMCommunity >> takeLoan [
	cash := cash + 3.
	debt := debt + 4
]

{ #category : 'adding' }
DMCommunity >> woodAvailable [
	^ self woodResources inject: 0 into: [ :sum :each | sum + (stock at: each) ]
]

{ #category : 'adding' }
DMCommunity >> woodNeed [
	^ self cormasModel currentTimeStep >= 2 ifTrue: [ 2 ] ifFalse: [ 1 ]
]

{ #category : 'adding' }
DMCommunity >> woodResources [
	^ #( householdWood importedWood lowWood highWood )
]
