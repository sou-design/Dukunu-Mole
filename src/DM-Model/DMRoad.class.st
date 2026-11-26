Class {
	#name : 'DMRoad',
	#superclass : 'CMLink',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'aspects' }
DMRoad >> aspectDefault: look [ 
	<aspect>
	look
		color: (Color fromHexString: '4A4A4A');
		thickness: 0.12
]

{ #category : 'testing' }
DMRoad >> isDirected [ 
	^ false
]
