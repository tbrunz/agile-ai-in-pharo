"
I represent an artificial neuron (perceptron).

I transform a float input to a float output using a linear transform:

z := x*w + b

followed by an activation function.

"
Class {
	#name : #Neuron,
	#superclass : #Object,
	#instVars : [
		'weights',
		'bias',
		'learningRate',
		'activationFunction',
		'output',
		'delta'
	],
	#category : #'NeuralNetwork-Neurons'
}

{ #category : #accessing }
Neuron >> activationFunction [

	^ activationFunction
]

{ #category : #accessing }
Neuron >> activationFunction: aBlock [

	activationFunction := aBlock
]

{ #category : #computing }
Neuron >> adjustBias [ 
	bias := bias + (learningRate * delta)
]

{ #category : #computing }
Neuron >> adjustDeltaWith: anError [ 
	
	delta := anError * (activationFunction derivative: output)
]

{ #category : #computing }
Neuron >> adjustWeightWithInputs: inputs [ 

	inputs withIndexDo: [ :anInput :index | 
		weights 
			at: index 
			put: ((weights at: index) + (learningRate * delta * anInput)) 
		]
]

{ #category : #accessing }
Neuron >> bias [
	"Get the bias for the neuron's output."
	"Replies with a float."	
			
	^ bias
]

{ #category : #accessing }
Neuron >> bias: biasScalar [
	"Set the bias for the neuron's output."
	"Takes a float."	
			
	bias := biasScalar  
]

{ #category : #accessing }
Neuron >> delta [

	^ delta
]

{ #category : #computing }
Neuron >> feed: inputs [
	"Compute the feed forward value."	
			
	| z |
	z := (inputs with: weights collect: [ :x :w | 
		x * w ] ) sum + bias.
	
	output := activationFunction eval: z.
	^ output
]

{ #category : #accessing }
Neuron >> initialize [ 
	"Set the learning rate."	
			
	super initialize .
	learningRate := 0.1.
	self sigmoid
]

{ #category : #accessing }
Neuron >> learningRate [

	^ learningRate
]

{ #category : #accessing }
Neuron >> learningRate: aFloat [

	learningRate := aFloat
]

{ #category : #accessing }
Neuron >> numOfWeights [ 
	"Reply with the number of weights the neuron contains."
	
	^ weights size
]

{ #category : #accessing }
Neuron >> output [

	^ output
]

{ #category : #configuring }
Neuron >> sigmoid [
	"Use the sigmoid activation function for this neuron."
	
	activationFunction := SigmoidAF new
]

{ #category : #configuring }
Neuron >> step [
	"Use the step activation function for this neuron."
	
	activationFunction := StepAF new
]

{ #category : #computing }
Neuron >> train: inputs desiredOutput: target [
	"Run one training epoch to adjust weights & bias."
	
	| diff output delta |
	output := self feed: inputs.
	diff := target - output.
	delta := diff * (activationFunction derivative: output).
	inputs withIndexDo: [ :anInput :index | 
			weights at: index put: 
				((weights at: index) +  
				(learningRate * delta * anInput)) 
			].
	bias := bias + (learningRate * delta)
]

{ #category : #accessing }
Neuron >> weights [
	"Get the weights for the neuron's inputs."
	"Replies with an array of floats."	
			
	^ weights
]

{ #category : #accessing }
Neuron >> weights1: anObject [

	weights := anObject
]

{ #category : #accessing }
Neuron >> weights: weightArray [
	"Set the weights for the neuron's inputs."
	"Takes an array of floats."	
	
	weights := weightArray copy
]
