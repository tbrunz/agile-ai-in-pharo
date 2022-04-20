"
I represent a species of individuals in a NEAT neural network.
"
Class {
	#name : #NESpecies,
	#superclass : #Object,
	#instVars : [
		'id',
		'individuals'
	],
	#category : #'NEAT-Core'
}

{ #category : #accessing }
NESpecies >> averageFitness [ 
	"Reply with the average fitness of the individuals in the species."
	
	^ (self individuals collect: #fitness) average
]

{ #category : #viewing }
NESpecies >> gtInspectorListOfIndividualsIn: composite [ 

	<gtInspectorPresentationOrder: -10>
	
	composite list 
		title: 'Individuals';
		display: individuals 
]

{ #category : #accessing }
NESpecies >> id [

	^ id
]

{ #category : #accessing }
NESpecies >> id: anInteger [

	id := anInteger
]

{ #category : #accessing }
NESpecies >> individuals [

	^ individuals
]

{ #category : #accessing }
NESpecies >> individuals: someIndividuals [

	individuals := someIndividuals
]

{ #category : #accessing }
NESpecies >> maxFitness [ 
	"Reply with the maximum fitness of the individuals in the species."
	
	^ (self individuals collect: #fitness) max
]

{ #category : #accessing }
NESpecies >> numberOfIndividuals [

	^ individuals size
]
