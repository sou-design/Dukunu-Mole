Class {
	#name : 'DMFarmingWithTruck',
	#superclass : 'DMFarming',
	#category : 'DM-Model',
	#package : 'DM-Model'
}

{ #category : 'accessing' }
DMFarmingWithTruck class >> code [
	^ 'farmingTruck'
]

{ #category : 'accessing' }
DMFarmingWithTruck class >> label [
	^ 'Vegetables to sell (truck)'
]

{ #category : 'accessing' }
DMFarmingWithTruck >> needsTruck [
	^ true
]
