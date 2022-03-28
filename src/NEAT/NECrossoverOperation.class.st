"
I represent the crossover operations that are performed between two individuals in the same species for NEAT NN's.
"
Class {
	#name : #NECrossoverOperation,
	#superclass : #Object,
	#category : #NEAT
}

{ #category : #actions }
NECrossoverOperation >> performOn: ind1 and: ind2 [ 
	"Reply with a child individual that is the result of 
	a crossover between individuals #ind1 and #ind2."
	"This method assumes the the fitness of #ind1 is 
	higher that the fitness of #ind2."
	
	| newConnections indexInd1 indexInd2 shouldIterate newNodes |
	
	"#newNodes are the nodes of the child individual."
	"It is simply a copy of the nodes of the best individual, #ind1."
	newNodes := ind1 nodes collect: #copy .
	
	"#newConnections are the connections of the child individual."
	newConnections := OrderedCollection new.
	
	"If no individual has a connection, then we create 
	a new individual with no connections."
	(ind1 connections notEmpty and: [ ind2 connections notEmpty ])
		ifFalse: [ ^ NEIndividual new 
			nodes: newNodes;
			connections: newConnections;
			randomGenerator: ind1 randomGenerator ] .
	
	"Set up our temporary variables."
	indexInd1 := 1.
	indexInd2 := 1.
	shouldIterate := true.
	
	"This is the iteration loop."
	[ shouldIterate ] whileTrue: [ 
		| conn1 conn2 |
		indexInd1 := indexInd1 min: ind1 numberOfConnections .
		indexInd2 := indexInd2 min: ind2 numberOfConnections .
		
		conn1 := ind1 connections at: indexInd1 .
		conn2 := ind2 connections at: indexInd2 .
		
		conn1 innovationNumber = conn2 innovationNumber 
			ifTrue: [ 
				newConnections add: (ind1 randomGenerator next > 0.5
					ifTrue: [ conn1 ] 
					ifFalse: [ conn2 ] ) copy .
				indexInd1 := indexInd1 + 1 .
				indexInd2 := indexInd2 + 1 .
				] 
			ifFalse: [ shouldIterate := false ] .
			
		(indexInd1 >= indexInd1 numberOfConnections 
			and: [ indexInd2 >= indexInd2 numberOfConnections  ] )
				ifTrue: [ shouldIterate := false ] .
		].
	
	"We consider the remainder connections from the best individual."
	newConnections addAll: 
		((ind1 connections allButFirst: indexInd1 - 1) collect: #copy) .
	
	^ NEIndividual new 
		nodes: newNodes;
		connections: newConnections;
		randomGenerator: ind1 randomGenerator 
]
