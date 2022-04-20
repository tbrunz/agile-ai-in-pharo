"
I represent a connection between two nodes in a NEAT neural network.
"
Class {
	#name : #NEConnection,
	#superclass : #Object,
	#instVars : [
		'in',
		'out',
		'weight',
		'enabled',
		'innovationNumber'
	],
	#category : #'NEAT-Core'
}

{ #category : #accessing }
NEConnection >> enabled [

	^ enabled
]

{ #category : #accessing }
NEConnection >> in [

	^ in
]

{ #category : #accessing }
NEConnection >> in: anInteger [

	in := anInteger 
]

{ #category : #accessing }
NEConnection >> innovationNumber [

	^ innovationNumber
]

{ #category : #accessing }
NEConnection >> innovationNumber: anInteger [

	innovationNumber := anInteger
]

{ #category : #accessing }
NEConnection >> isEnabled [ 

	^ enabled
]

{ #category : #accessing }
NEConnection >> makeDisabled [ 

	enabled := false
]

{ #category : #accessing }
NEConnection >> makeEnabled [ 

	enabled := true
]

{ #category : #accessing }
NEConnection >> out [

	^ out
]

{ #category : #accessing }
NEConnection >> out: anInteger [

	out := anInteger
]

{ #category : #accessing }
NEConnection >> weight [

	^ weight
]

{ #category : #accessing }
NEConnection >> weight: aFloat [

	weight := aFloat
]
