Class {
	#name : 'DMCocoaProduction',
	#superclass : 'DMActivity',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'as yet unclassified' }
DMCocoaProduction class >> baseCostOn: aPlot [
	^ aPlot cocoaYear = 0 ifTrue: [ 1 ] ifFalse: [ 0 ]
]

{ #category : 'as yet unclassified' }
DMCocoaProduction class >> canBePlacedOn: aPlot [
	^ aPlot cocoaYear > 0 or: [
		aPlot landCover class = DMSecondaryForest and: [ aPlot landCover trees notEmpty ] ]
]

{ #category : 'as yet unclassified' }
DMCocoaProduction class >> code [
	^ 'cocoa'
]

{ #category : 'as yet unclassified' }
DMCocoaProduction class >> label [
	^ 'Cocoa'
]

{ #category : 'as yet unclassified' }
DMCocoaProduction class >> needsTruck [
	^ true
]

{ #category : 'accessing' }
DMCocoaProduction >> finish [
	| year |
	super finish.
	year := self year.
	plot cocoaYear: (year = 3 ifTrue: [ 0 ] ifFalse: [ year + 1 ])
]

{ #category : 'accessing' }
DMCocoaProduction >> produce [
	self give: (#( 1 3 2 ) at: self year) of: #cocoa
]

{ #category : 'accessing' }
DMCocoaProduction >> year [
	^ plot cocoaYear max: 1
]
