Class {
	#name : 'DMCommunity',
	#superclass : 'CMAgent',
	#instVars : [
		'color',
		'ownedPlots'
	],
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'initialization' }
DMCommunity >> addOwnedPlot: aPlot [
	ownedPlots add: aPlot
]

{ #category : 'accessing' }
DMCommunity >> color [
	^ color
]

{ #category : 'accessing' }
DMCommunity >> color: aSymbol [
	color := aSymbol
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

{ #category : 'initialization' }
DMCommunity >> initialize [
	super initialize.
	color := #none.
	ownedPlots := OrderedCollection new
]

{ #category : 'initialization' }
DMCommunity >> ownedPlots [
	^ ownedPlots
]
