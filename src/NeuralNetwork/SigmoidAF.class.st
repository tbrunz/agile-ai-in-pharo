"
I am a neuron Activation Function in the form of a Sigmoid Curve.
"
Class {
	#name : #SigmoidAF,
	#superclass : #ActivationFunction,
	#category : #'NeuralNetwork-Neurons'
}

{ #category : #'accessing - delegated' }
SigmoidAF >> derivative: output [
	^ output * (1 - output) 
]

{ #category : #'accessing - delegated' }
SigmoidAF >> eval: z [
	^ 1 / (1 + z negated exp) 
]
