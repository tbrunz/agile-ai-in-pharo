"
I represent a structural mutation operation of adding a new connection for NEAT individuals.
"
Class {
	#name : #NEAddConnectionMutationOperation,
	#superclass : #NEAbstractStructuralMutationOperation,
	#category : #NEAT
}

{ #category : #actions }
NEAddConnectionMutationOperation >> basicIs: node1 accessibleFrom: node2 [
	"Recursively look for a path from #node2 to #node1."
	
	node1 == node2 ifTrue: [ ^ true ] .
	
	node2 connectedNodes do: [ :node | 
		node1 == node ifTrue: [ ^ true ] .
		(self basicIs: node1 accessibleFrom: node) ifTrue: [ ^ true ]
		].
	
	^ false
]

{ #category : #actions }
NEAddConnectionMutationOperation >> findMissingConnectionIn: anIndividual numberOfTries: numOfTries [
	"Reply with an array containing two nodes."
	"Only a finite number of tries are made to find them."
	
	| node1 node2 |
	
	"If we've made all our tries, then return #nil, 
	meaning that no connections can be made."
	numOfTries = 0 ifTrue: [ ^ nil ] .
	
	"The connection will go from #node1 to #node2."
	"Therefore #node1 cannot be an output node."
	node1 := (anIndividual nodes reject: #isOutput) atRandom: randomGenerator .
	
	"Similarly, #node2 cannot be an input node."
	node2 := (anIndividual nodes reject: #isInput) atRandom: randomGenerator .
	
	"Is there already a connection between #node1 and #node2 ?"
	(anIndividual connections anySatisfy: [ :conn | 
		(conn in = node1 id and: [ conn out = node2 id ] ) ] )
			ifTrue: [ "If yes, then iterate once more" 
				^ self findMissingConnectionIn: anIndividual 
					numberOfTries: (numOfTries - 1) ] .
				
	"We need to check that there is no path going from #node2 to #node1."
	"Adding a new connection should not result in a graph cycle."
	(self is: node1 accessibleFrom: node2 in: anIndividual)
		ifTrue: [ ^ self findMissingConnectionIn: anIndividual 
			numberOfTries: (numOfTries - 1) ] .
	
	^ { node1 id . node2 id }
]

{ #category : #actions }
NEAddConnectionMutationOperation >> is: node1 accessibleFrom: node2 in: anIndividual [
	"Is there a path going from #node2 to #node1 ?"
	
	anIndividual buildNetwork .
	
	^ self basicIs: node1 accessibleFrom: node2
]

{ #category : #actions }
NEAddConnectionMutationOperation >> on: anIndividual [
	"Add a new connection between two nodes in an individual."
	
	| array |
	
	"Find two nodes between which we can add a connection."
	"Do not make more than 5 tries to find a pair."
	array := self findMissingConnectionIn: anIndividual numberOfTries: 5 .
	
	"If we do not find a solution, merely return."
	array ifNil: [ ^ self ] .
	
	"Otherwise, add the connection."
	anIndividual 
		addConnection: (NEConnection new
			in: array first;
			out: array second;
			weight: self randomWeight;
			makeEnabled;
			innovationNumber: InnovationNumber ) 
]
