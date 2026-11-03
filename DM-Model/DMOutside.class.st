Class {
	#name : 'DMOutside',
	#superclass : 'DMLandCover',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'accessing' }
DMOutside >> color [
	^ Color white

]

{ #category : 'testing' }
DMOutside >> isOnIsland [
	^ false
]
