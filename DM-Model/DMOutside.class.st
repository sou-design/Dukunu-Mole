Class {
	#name : 'DMOutside',
	#superclass : 'DMLandCover',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'accessing' }
DMOutside >> code [
	^ 'X'
]

{ #category : 'testing' }
DMOutside >> color [
	^ (plot neighbourhood anySatisfy: [ :n | n isOnIsland ])
		ifTrue: [ CMColor fromHexString: '5B9BD5' ]
		ifFalse: [ CMColor white ]
]

{ #category : 'testing' }
DMOutside >> isOnIsland [
	^ false
]
