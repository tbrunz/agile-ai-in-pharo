"
I represent a genetic individual in a NEAT neural network.
"
Class {
	#name : #NEIndividual,
	#superclass : #Object,
	#instVars : [
		'nodes',
		'connections',
		'randomGenerator',
		'fitness',
		'species'
	],
	#category : #NEAT
}

{ #category : #adding }
NEIndividual >> addConnection: aConnection [ 

	connections add: aConnection .
	self resetNetwork .
]

{ #category : #adding }
NEIndividual >> addHiddenNode [
	"Add a hidden node to the individual."
	
	self addNode: (NENode new setAsHidden) .
]

{ #category : #adding }
NEIndividual >> addInputNode [
	"Add an input node to the individual."
	
	self addNode: (NENode new setAsInput; innovationNumber: 1) .
]

{ #category : #adding }
NEIndividual >> addNode: aNode [ 
	"Add a node to the individual.  Note that the individual's 
	connections must be invalidated and are therefore reset."
	
	self resetNetwork .
	nodes add: aNode .
	aNode id: nodes size .
	^ aNode
]

{ #category : #adding }
NEIndividual >> addOutputNode [
	"Add an output node to the individual."
	
	self addNode: (NENode new setAsOutput; innovationNumber: 1) .
]

{ #category : #actions }
NEIndividual >> buildNetwork [ 
	"Build the neural network represented by the individual."
	
	self resetNetwork .
	
	(connections select: #isEnabled) do: [ :conn | 
		(nodes at: conn in) connect: (nodes at: conn out) weight: conn weight .
		(nodes at: conn out) increaseNumberOfInputs .
		].
]

{ #category : #actions }
NEIndividual >> computeFitness: oneArgBlock [ 
	"Compute the fitness of the individual."
	"If already computed, then do nothing."
	
	fitness ifNotNil: [ ^ self ] .
	fitness := oneArgBlock value: self .
]

{ #category : #accessing }
NEIndividual >> connections [

	^ connections
]

{ #category : #accessing }
NEIndividual >> connections: someConnections [
	"Set some connections.  This method is used when performing the crossover."
	
	connections := someConnections
]

{ #category : #copying }
NEIndividual >> copy [ 
	"Reply with a copy of the individual."
	
	| newInd |
	newInd := self class new.
	newInd randomGenerator: self randomGenerator .
	newInd nodes: (self nodes collect: #copy) .
	newInd connections: (self connections collect: #copy) .
	^ newInd 
]

{ #category : #actions }
NEIndividual >> evaluate: anArray [ 
	"Evaluate the individual's network using some input values."
	"The method replies with the resulting outputs of the network."
	
	self assert: [ anArray size = self numberOfInputs ] 
		description: 'Wrong number of arguments' .
	self buildNetwork .
	
	"We provide '1' to the first node, which is considered the bias node."
	self inputNodes with: #(1) , anArray 
		do: [ :node :aValue | node evaluate: aValue ].
	
	^ self outputNodes collect: [ :node | node result ] as: Array
]

{ #category : #accessing }
NEIndividual >> fitness [

	self assert: [ fitness notNil ] 
		description: 'Need to compute fitness first' .
	^ fitness
]

{ #category : #accessing }
NEIndividual >> fitness: aFitnessValue [
	"Set the fitness value, useful when copying an individual."

	fitness := aFitnessValue
]

{ #category : #initialization }
NEIndividual >> initialize [ 

	super initialize .
	nodes := OrderedCollection new.
	connections := OrderedCollection new.
	
	"This first node is the bias node."
	self addInputNode .
]

{ #category : #accessing }
NEIndividual >> innovationNumberSequence [ 
	"Reply with the list of innovation numbers."
	
	self connections ifEmpty: [ ^ #( 0 ) ] .
	
	^ self connections collect: #innovationNumber as: Array
]

{ #category : #accessing }
NEIndividual >> inputNodes [

	^ nodes select: #isInput
]

{ #category : #accessing }
NEIndividual >> nodes [

	^ nodes
]

{ #category : #accessing }
NEIndividual >> nodes: someNodes [

	nodes := someNodes
]

{ #category : #accessing }
NEIndividual >> numberOfConnections [

	^ connections size
]

{ #category : #accessing }
NEIndividual >> numberOfInputs [ 
	"Substract one for the bias."
	
	^ self inputNodes size - 1
]

{ #category : #accessing }
NEIndividual >> numberOfNodesWithBias [
	"Reply with the total number of nodes in the individual."
	
	^ self nodes size
]

{ #category : #accessing }
NEIndividual >> outputNodes [

	^ nodes select: #isOutput
]

{ #category : #actions }
NEIndividual >> predict: inputs [ 
	"Make a prediction.  This method assumes that the number of outputs is 
	the same as the number of different values the network can output."
	
	| outputs |
	outputs := self evaluate: inputs .
	
	"Recall that the index of a collection starts with 1 in Pharo, not 0."
	^ (outputs indexOf: (outputs max)) - 1
]

{ #category : #accessing }
NEIndividual >> randomGenerator [

	^ randomGenerator
]

{ #category : #accessing }
NEIndividual >> randomGenerator: aRandomNumberGenerator [

	randomGenerator := aRandomNumberGenerator
]

{ #category : #actions }
NEIndividual >> resetFitness [ 
	"Invalidate the fitness value."
	
	fitness := nil .
]

{ #category : #actions }
NEIndividual >> resetNetwork [
	"Reset the network, which invalidates the network and fitness value."
	
	nodes do: #resetConnections .
]

{ #category : #accessing }
NEIndividual >> species [

	^ species
]

{ #category : #accessing }
NEIndividual >> species: aSpecies [

	species := aSpecies
]
