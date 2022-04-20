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
	#category : #'NEAT-Core'
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

{ #category : #viewing }
NESpeciation >> visualize [ 
	"Visualize groups of individuals."
	
	| b legendBuilder |
	b := RTMondrian new.
	b shape box size: [ :s | s individuals size ] .
	b nodes: (self groups reverseSortedAs: #maxFitness) .
	b layout grid .
	b normalizer normalizeColor: #maxFitness .
	b build .
	
	legendBuilder := RTLegendBuilder new.
	legendBuilder view: b view .
	legendBuilder addText: 'Species visualization' .
	legendBuilder addText: 'Box size = Species size' .
	legendBuilder addColorFadingFrom: Color gray to: Color red text: 'Max fitness' .
	legendBuilder build .
	
	^ b view
]
