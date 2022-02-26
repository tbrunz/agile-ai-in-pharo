"
I am an abstract neuron Activation Function.
"
Class {
	#name : #ActivationFunction,
	#superclass : #Object,
	#category : #'NeuralNetwork-Neurons'
}

{ #category : #'accessing - delegated' }
ActivationFunction >> derivative: output [
	^ self subclassResponsibility 
]

{ #category : #'accessing - delegated' }
ActivationFunction >> eval: z [
	^ self subclassResponsibility 
]
