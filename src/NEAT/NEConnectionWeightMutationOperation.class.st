"
I represent a non-structural mutation operation of modifying a connection weight for NEAT individuals.
"
Class {
	#name : #NEConnectionWeightMutationOperation,
	#superclass : #NEAbstractNonStructuralMutationOperation,
	#category : #NEAT
}

{ #category : #actions }
NEConnectionWeightMutationOperation >> on: anIndividual [
	"Modify the weight of a connection."
	
	| connection |
	anIndividual connections ifEmpty: [ ^ self ] .
	
	connection := (anIndividual connections atRandom: randomGenerator) .
	connection weight: self randomWeight + connection weight .
]
