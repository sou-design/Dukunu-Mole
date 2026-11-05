Class {
	#name : 'DMFarmland',
	#superclass : 'DMLandCover',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'accessing' }
DMFarmland >> code [
	^ 'F'
]

{ #category : 'testing' }
DMFarmland >> color [
	^ CMColor fromHexString: 'E3C12F'
]
