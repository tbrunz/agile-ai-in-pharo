"
I represent a layer of neurons in a neural network.
"
Class {
	#name : #NeuronLayer,
	#superclass : #Object,
	#instVars : [
		'previousLayer',
		'nextLayer',
		'neurons'
	],
	#category : #'NeuralNetwork-Neurons'
}

{ #category : #computing }
NeuronLayer >> backPropagateError [
	"Back propagate the output error to adjust weights & biases."
	"This is a recursive method, which acts only on the *hidden* layers."
	"(The recursion begins with the output layer, invoked by the NN object.)"
	
	neurons doWithIndex: [ :neuron :j | 
		| thisError | 
		thisError := 0.0. 
		self nextLayer neurons do: [ :nextNeuron | 
			thisError := thisError + ((nextNeuron weights at: j) * nextNeuron delta) 
			].
		neuron adjustDeltaWith: thisError 
		].
	
	self previousLayer notNil 
		ifTrue: [ self previousLayer backPropagateError ].
]

{ #category : #computing }
NeuronLayer >> backPropagateError: desiredOutput [
	"Back propagate the output error to adjust weights & biases."
	"This is a recursive method, starting with the output layer (here)."
	"Continue the back propagation by calling the previous layer."
	"Each layer calls the no-argument form, until we reach the first layer."
	
	neurons with: desiredOutput do: [ :neuron :target | 
		| thisError | 
		thisError := target - neuron output. 
		neuron adjustDeltaWith: thisError 
		].
	
	"Note that the 'nil' check is just in case there aren't any hidden layers!"
	self previousLayer notNil 
		ifTrue: [ self previousLayer backPropagateError ].
]

{ #category : #computing }
NeuronLayer >> feed: layerInputs [ 
	"Feed the neuron layer with a set of inputs; generate outputs."
	"This is a recursive method (a la Functional Programming)."
	"Note that each neuron in my layer receives the entire set of inputs."
	"I.e., I am part of a 'fully-connected' neural network."
	
	| layerOutputs |
	layerOutputs := neurons collect: [ :n | 
		n feed: layerInputs ] as: Array.
	
	^ self isOutputLayer 
		ifTrue: [ layerOutputs ]
		ifFalse: [ nextLayer feed: layerOutputs ]
]

{ #category : #initialization }
NeuronLayer >> initializeNumOfNeurons: numOfNeurons numOfWeights: numOfWeights using: randomNumGen [ 
	"Create a set of neurons for, and initialize, a neuron layer."
	
	| weights |
	neurons := (1 to: numOfNeurons) collect: [ :i | 
		weights := (1 to: numOfWeights) collect: [ :ii |
			randomNumGen next * 4 - 2
			].
		Neuron new 
			sigmoid;
			weights: weights;
			bias: (randomNumGen next * 4 - 2)
		].
	self learningRate: 0.1
]

{ #category : #computing }
NeuronLayer >> isOutputLayer [
	"Respond with True if I am the network's output layer."
	"This is the case if I have no 'nextLayer' (i.e., container is nil)."
	
	^ self nextLayer isNil
]

{ #category : #accessing }
NeuronLayer >> learningRate [
	"Get the learning rate for a neurons in my layer (assumed the same for all)."
	
	self assert: [ neurons notEmpty ] 
		description: 'learningRate should be invoked only after configuring the layer'.
	^ neurons anyOne learningRate
]

{ #category : #accessing }
NeuronLayer >> learningRate: aLearningRate [
	"Set the learning rate for all neurons in my layer (to be the same)."
	"Note that this method should not be called until my neurons have been created."
	
	self assert: [ neurons notEmpty ] 
		description: 'learningRate: should be invoked only after configuring the layer'.
	neurons do: [ :n | n learningRate: aLearningRate ]
]

{ #category : #accessing }
NeuronLayer >> neurons [

	^ neurons
]

{ #category : #accessing }
NeuronLayer >> nextLayer [

	^ nextLayer
]

{ #category : #accessing }
NeuronLayer >> nextLayer: aNeuronLayer [

	nextLayer := aNeuronLayer
]

{ #category : #computing }
NeuronLayer >> numberOfNeurons [
	"Respond with the number of neurons in my layer."
	
	^ neurons size
]

{ #category : #accessing }
NeuronLayer >> previousLayer [

	^ previousLayer
]

{ #category : #accessing }
NeuronLayer >> previousLayer: aNeuronLayer [

	previousLayer := aNeuronLayer
]

{ #category : #computing }
NeuronLayer >> updateWeight [
	"Update the weights of the neurons in this layer, using the initialInputs."
	"Note that this message applies to all hidden layers except the first."
	"The first hidden layer calls this method; the remaining layers are called recursively."
	
	| inputs |
	inputs := self previousLayer neurons collect: #output.
	self updateWeight: inputs
]

{ #category : #computing }
NeuronLayer >> updateWeight: initialInputs [ 
	"Update the weights of the neurons in this layer, using the initialInputs."
	"Note that this message applies to all hidden layers."
	"This method is called on the first hidden layer directly, by the NN."
	"It is then called recursively in conjunction with 'updateWeight'."
	
	| inputs |
	inputs := initialInputs.
	neurons do: [ :n |
		n adjustWeightWithInputs: inputs.
		n adjustBias 
		].
	self nextLayer ifNotNil: [ 
		self nextLayer updateWeight ]
]
