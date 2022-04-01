"
I represent a speciation log at each generation of NEAT network evolution.
"
Class {
	#name : #NELog,
	#superclass : #Object,
	#instVars : [
		'generation',
		'speciation',
		'minFitness',
		'maxFitness',
		'avgFitness',
		'bestIndividual'
	],
	#category : #NEAT
}

{ #category : #accessing }
NELog >> avgFitness [

	^ avgFitness
]

{ #category : #accessing }
NELog >> avgFitness: aNumber [

	avgFitness := aNumber
]

{ #category : #accessing }
NELog >> bestIndividual [

	^ bestIndividual
]

{ #category : #accessing }
NELog >> bestIndividual: anIndividual [

	bestIndividual := anIndividual
]

{ #category : #accessing }
NELog >> generation [

	^ generation
]

{ #category : #accessing }
NELog >> generation: anInteger [

	generation := anInteger
]

{ #category : #accessing }
NELog >> maxFitness [

	^ maxFitness
]

{ #category : #accessing }
NELog >> maxFitness: aNumber [

	maxFitness := aNumber
]

{ #category : #accessing }
NELog >> minFitness [

	^ minFitness
]

{ #category : #accessing }
NELog >> minFitness: aNumber [

	minFitness := aNumber
]

{ #category : #accessing }
NELog >> numberOfSpecies [
	"Reply with the number of species in the speciation."
	
	speciation ifNil: [ ^ 0 ] .
	
	^ speciation numberOfSpecies 
]

{ #category : #initialization }
NELog >> release [ 
	"Release the speciation, reducing the amount of consumed memory."
	
	speciation := nil .
	bestIndividual := nil .
]

{ #category : #accessing }
NELog >> speciation [

	^ speciation
]

{ #category : #accessing }
NELog >> speciation: aSpeciation [

	speciation := aSpeciation
]
