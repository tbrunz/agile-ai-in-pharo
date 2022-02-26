Class {
	#name : #NeuralNetTest,
	#superclass : #TestCase,
	#category : #'NeuralNetwork-Tests'
}

{ #category : #tests }
NeuralNetTest >> testBasic [ 
	| nn |
	nn := NeuralNet new.
	nn configure: 2 hidden: 2 numOfOutputs: 1.
	self assert: ((nn feed: #(1 3)) anyOne closeTo: 0.6745388 precision: 0.0000001).
	self assert: nn numberOfOutputs equals: 1.
]

{ #category : #tests }
NeuralNetTest >> testXOR [
	| n |
	n := NeuralNet new.
	n configure: 2 hidden: 3 numOfOutputs: 1.
	
	20000 timesRepeat: [ 
		n train: #(0 0) targetOutputs: #(0).
		n train: #(0 1) targetOutputs: #(1).
		n train: #(1 0) targetOutputs: #(1).
		n train: #(1 1) targetOutputs: #(0).
		].
	
	self assert: (n feed: #(0 0)) first < 0.1.
	self assert: (n feed: #(0 1)) first > 0.9.
	self assert: (n feed: #(1 0)) first > 0.9.
	self assert: (n feed: #(1 1)) first < 0.1.
]
