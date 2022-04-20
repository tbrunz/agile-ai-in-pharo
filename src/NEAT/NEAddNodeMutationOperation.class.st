"
I represent a structural mutation operation of adding a new node for NEAT individuals.
"
Class {
	#name : #NEAddNodeMutationOperation,
	#superclass : #NEAbstractStructuralMutationOperation,
	#category : #'NEAT-Core'
}

{ #category : #actions }
NEAddNodeMutationOperation >> on: anIndividual [
	"Add a hidden node and two new connections in the individual."
	
	| relevantConnections connection |
	relevantConnections := anIndividual connections select: #isEnabled .
	relevantConnections ifEmpty: [ ^ self ] .
	
	"Pick a random connection and disable it."
	connection := relevantConnections atRandom: anIndividual randomGenerator .
	connection makeDisabled .
	
	"Now add a new hidden node..."
	anIndividual addHiddenNode innovationNumber: InnovationNumber .
	
	"...and two new connections."
	anIndividual addConnection: 
		(NEConnection new 
			in: connection in;
			out: anIndividual numberOfNodesWithBias;
			weight: 1;
			makeEnabled;
			innovationNumber: InnovationNumber ) .
			
	anIndividual addConnection: 
		(NEConnection new 
			in: anIndividual numberOfNodesWithBias; 
			out: connection out;
			weight: connection weight;
			makeEnabled;
			innovationNumber: InnovationNumber ) .
]
