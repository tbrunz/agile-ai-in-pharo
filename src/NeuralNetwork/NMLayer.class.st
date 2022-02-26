"
I represent a layer of a Neural Network implemented using matrices.
"
Class {
	#name : #NMLayer,
	#superclass : #Object,
	#instVars : [
		'w',
		'b',
		'delta',
		'output',
		'next',
		'previous',
		'lr',
		'numExamples'
	],
	#category : #'NeuralNetwork-Matrix'
}

{ #category : #accessing }
NMLayer >> b [

	^ b
]

{ #category : #accessing }
NMLayer >> b: biasVector [

	b := biasVector
]

{ #category : #accessing }
NMLayer >> delta [

	^ delta
]

{ #category : #accessing }
NMLayer >> delta: deltaMatrix [

	delta := deltaMatrix
]

{ #category : #computing }
NMLayer >> feed: inputMatrix [ 
	"Feed the layer with the input matrix."
	"Collect the outputs of the activation function."
	
	output := (w +* inputMatrix + b) 
		collect: [ :value | 1 / (1 + value negated exp) ].
		
	^ output
]

{ #category : #initialization }
NMLayer >> initialize [ 

	super initialize.
	lr := 0.1
]

{ #category : #accessing }
NMLayer >> learningRate [

	^ lr
]

{ #category : #accessing }
NMLayer >> learningRate: aLearningRate [

	lr := aLearningRate
]

{ #category : #accessing }
NMLayer >> next [

	^ next
]

{ #category : #accessing }
NMLayer >> next: aNNLayer [

	next := aNNLayer
]

{ #category : #accessing }
NMLayer >> numExamples [

	^ numExamples
]

{ #category : #accessing }
NMLayer >> numExamples: aNumber [

	numExamples := aNumber
]

{ #category : #initialization }
NMLayer >> numInputs: numberOfInputs numOutputs: numberOfOutputs randomize: randomGenerator [
	"Initalize the NN layer."
	
	w := Matrix newWithRows: numberOfOutputs withColumns: numberOfInputs .
	w randomize: randomGenerator .
	
	b := Matrix newWithRows: numberOfOutputs withColumns: 1.
	b randomize: randomGenerator .
]

{ #category : #accessing }
NMLayer >> output [

	^ output
]

{ #category : #accessing }
NMLayer >> previous [

	^ previous
]

{ #category : #accessing }
NMLayer >> previous: aNNLayer [

	previous := aNNLayer
]

{ #category : #computing }
NMLayer >> update [
	"Update the weights and biases using the delta value."
	
	w := w - ((delta +* previous output transposed) * lr / numExamples) .
	b := b - (delta sumHorizontal * lr / numExamples) .
	
	next ifNotNil: [ next update ]
]

{ #category : #updating }
NMLayer >> update: input [
	"Update the weights and biases using the input value."
	
	w := w - ((delta +* input transposed) * lr / numExamples) .
	b := b - (delta sumHorizontal * lr / numExamples) .
	
	next update
]

{ #category : #accessing }
NMLayer >> w [

	^ w
]

{ #category : #accessing }
NMLayer >> w: weightsMatrix [

	w := weightsMatrix
]
