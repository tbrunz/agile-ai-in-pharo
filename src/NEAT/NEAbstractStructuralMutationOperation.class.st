"
I abstract the representation of structural mutation operations for NEAT individuals.
"
Class {
	#name : #NEAbstractStructuralMutationOperation,
	#superclass : #NEAbstractMutationOperation,
	#classVars : [
		'InnovationNumber'
	],
	#category : #'NEAT-Core'
}

{ #category : #actions }
NEAbstractStructuralMutationOperation >> performOn: anIndividual [ 

	"Lazy initialization -- On first execution, set it to '1'."
	InnovationNumber ifNil: [ InnovationNumber := 1 ] .
	
	InnovationNumber := InnovationNumber + 1 .
	
	super performOn: anIndividual .
]
