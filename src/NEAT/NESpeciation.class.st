"
I represent the speciation algorithm for classifying the NEAT individuals.
"
Class {
	#name : #NESpeciation,
	#superclass : #Object,
	#instVars : [
		'frameSize',
		'groups'
	],
	#category : #NEAT
}

{ #category : #accessing }
NESpeciation >> frameSize: anInteger [

	frameSize := anInteger
]

{ #category : #accessing }
NESpeciation >> groups [

	^ groups
]

{ #category : #initialization }
NESpeciation >> initialize [ 

	super initialize .
	frameSize := 3 .
]

{ #category : #accessing }
NESpeciation >> numberOfSpecies [ 
	"Reply with the number of species produced by the algorithm."

	^ groups size
]

{ #category : #accessing }
NESpeciation >> process: someIndividuals [ 
	"Run the speciation algorithm for a given collection of individuals."
	"This method takes a collection of innovation numbers as its argument."
	
	| g |
	g := someIndividuals groupedBy: [ :individual | 
		| seq |
		seq := individual innovationNumberSequence .
		seq size < 2 
			ifTrue: [ seq first ] 
			ifFalse: [ (seq last: (frameSize min: seq size - 1)) first ] .
		].
	
	"Bind each species to its corresponding individuals."
	groups := g associations collect: [ :assoc | 
		NESpecies new 
			individuals: assoc value; 
			id: assoc key
		].
	groups do: [ :aSpecies | 
		aSpecies individuals do: [ :ind | ind species: aSpecies ] .
		]
]
