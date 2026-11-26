Class {
	#name : 'DMCommunityRole',
	#superclass : 'CMGameRole',
	#category : 'DM-Game',
	#package : 'DM-Game'
}

{ #category : 'as yet unclassified' }
DMCommunityRole class >> communityColor [
	^ self subclassResponsibility
]

{ #category : 'as yet unclassified' }
DMCommunityRole class >> roleName [
	^ self communityColor asString capitalized
]
