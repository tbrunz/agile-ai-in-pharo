"
I abstract the representation of mutation operations for NEAT individuals.
"
Class {
	#name : #NEAbstractMutationOperation,
	#superclass : #Object,
	#instVars : [
		'randomGenerator'
	],
	#category : #NEAT
}

{ #category : #actions }
NEAbstractMutationOperation >> on: anIndividual [
	"Override this core method for specific mutation algorithms."
	
	self subclassResponsibility 
]

{ #category : #actions }
NEAbstractMutationOperation >> performOn: anIndividual [ 
	"This is a public method that performs a mutation on the individual argument."
	
	randomGenerator := anIndividual randomGenerator .
	anIndividual resetFitness .
	self on: anIndividual .
]

{ #category : #accessing }
NEAbstractMutationOperation >> randomGenerator: aRandomNumberGenerator [

	randomGenerator := aRandomNumberGenerator
]

{ #category : #actions }
NEAbstractMutationOperation >> randomWeight [
	"Reply with a random float between -5 and +5."
	
	^ randomGenerator next * 10 - 5
]
