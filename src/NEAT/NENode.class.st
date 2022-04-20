"
I represent a Node in a NEAT neural network.
"
Class {
	#name : #NENode,
	#superclass : #Object,
	#instVars : [
		'id',
		'kind',
		'connectionsCache',
		'innovationNumber',
		'numberOfInputs',
		'zValue',
		'numOfReceivedValues',
		'result'
	],
	#category : #'NEAT-Core'
}

{ #category : #configuration }
NENode >> connect: aNode weight: aWeight [ 
	"Establish a connection between the receiver and another node."
	"This method is intended to be called by NEIndividual>>#buildNetwork."
	
	connectionsCache add: aWeight -> aNode .
]

{ #category : #configuration }
NENode >> connectedNodes [ 
	"Reply with the collection of nodes connected to the receiver."
	
	^ connectionsCache collect: #value as: Array
]

{ #category : #copying }
NENode >> copy [ 
	"Reply with a copy of the receiving node."
	
	| newNode |
	newNode := self class new.
	newNode id: self id .
	newNode kind: self kind .
	newNode innovationNumber: self innovationNumber .
	^ newNode 
]

{ #category : #actions }
NENode >> evaluate: aValue [ 
	"Use the input value to the node as a contribution to the intermediate zValue."
	
	zValue := zValue + aValue .
	numOfReceivedValues := numOfReceivedValues + 1 .
	
	"If we have received an adequate number of inputs,
	then we can compute the output (Sigmoid) value."
	numOfReceivedValues = numberOfInputs 
		ifFalse: [ ^ self ] .
	
	result := self isInput 
		ifTrue: [ zValue ] ifFalse: [ self sigmoid: zValue ] .
	
	"We reach this point only if this node is not an output node."
	connectionsCache do: [ :assoc | 
		assoc value evaluate: result * assoc key .
		].
]

{ #category : #accessing }
NENode >> id [

	^ id
]

{ #category : #accessing }
NENode >> id: anInteger [
	"Set the numeric ID of the node."
	"This value is the index of the node in an individual."

	id := anInteger .
]

{ #category : #actions }
NENode >> increaseNumberOfInputs [ 
	"Increase the number of signal inputs a node accepts."
	
	numberOfInputs := numberOfInputs + 1 .
]

{ #category : #accessing }
NENode >> innovationNumber [

	^ innovationNumber
]

{ #category : #accessing }
NENode >> innovationNumber: anInteger [

	innovationNumber := anInteger
]

{ #category : #accessing }
NENode >> isBias [
	"Reply #true if the node is the bias node."
	"I.e., its ID equals '1'."
	
	^ self isInput and: [ id = 1 ] 
]

{ #category : #accessing }
NENode >> isInput [ 
	"Reply #true if the node is an input node."
	"Note that symbols are singletons, so uses '==' to compare."
	
	^ kind == #input 
]

{ #category : #accessing }
NENode >> isOutput [ 
	"Reply #true if the node is an output node."
	"Note that symbols are singletons, so uses '==' to compare."
	
	^ kind == #output 
]

{ #category : #accessing }
NENode >> kind [

	^ kind
]

{ #category : #accessing }
NENode >> kind: aSymbol [

	kind := aSymbol
]

{ #category : #accessing }
NENode >> numberOfInputs [

	^ numberOfInputs
]

{ #category : #printing }
NENode >> printOn: stream [ 
	"Reply with a textual representation of a node."
	"For example: 'a NENode<3,1,input>' or 'a NENode<5,205167,hidden>'."
	"The values 3 & 5, above, are the node IDs.  1 & 205167 are innovation numbers."
	"The third value indicates the kind of node."
	
	super printOn: stream .
	stream nextPut: $< .
	
	id ifNotNil: [ stream nextPutAll: id asString ] .
	stream nextPut: $, .
	
	innovationNumber ifNotNil: [ stream nextPutAll: innovationNumber asString ] .
	stream nextPut: $, .
	
	kind ifNotNil: [ stream nextPutAll: kind asString ] .
	stream nextPut: $> .
	
]

{ #category : #actions }
NENode >> resetConnections [ 
	"Remove the connections associated with a node."
	
	connectionsCache := OrderedCollection new.
	zValue := 0 .
	numberOfInputs := 0 .
	numOfReceivedValues := 0 .
	result := 0 .
	self isInput ifTrue: [ numberOfInputs := 1 ] .
]

{ #category : #accessing }
NENode >> result [

	^ result
]

{ #category : #initialization }
NENode >> setAsHidden [
	"Make the node a hidden node."
	
	kind := #hidden .
]

{ #category : #initialization }
NENode >> setAsInput [ 
	"Make the node an input node."
	
	kind := #input .
]

{ #category : #initialization }
NENode >> setAsOutput [
	"Make the node an output node."
	
	kind := #output .
]

{ #category : #actions }
NENode >> sigmoid: z [ 
	"Apply the sigmoid function to the argument."
	
	^ 1 / (1 + z negated exp)
]

{ #category : #configuration }
NENode >> weightOfConnectionWith: aNode [ 
	"Return the weight of the connection to another node."
	
	^ (connectionsCache detect: [ :assoc | 
		assoc value == aNode ] ) key
]
