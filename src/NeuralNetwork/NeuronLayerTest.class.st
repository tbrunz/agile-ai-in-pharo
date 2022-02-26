Class {
	#name : #NeuronLayerTest,
	#superclass : #TestCase,
	#category : #'NeuralNetwork-Tests'
}

{ #category : #tests }
NeuronLayerTest >> testBasic [ 
	| nl output r |
	r := Random seed: 42.
	nl := NeuronLayer new.
	nl initializeNumOfNeurons: 3 numOfWeights: 4 using: r.
	self assert: nl isOutputLayer.
	
	output := nl feed: #(1 2 3 4).
	self assert: output size equals: 3.
	output 
		with: #(0.0370005 0.905126 0.981527 ) 
		do: [ :result :test |
			self assert: (result closeTo: test precision: 0.00001) ]
]

{ #category : #tests }
NeuronLayerTest >> testOutputLayer [
	| nl1 nl2 output random |
	random := Random seed: 42.
	
	nl1 := NeuronLayer new.
	nl1 initializeNumOfNeurons: 3 numOfWeights: 4 using: random.
	nl2 := NeuronLayer new.
	nl2 initializeNumOfNeurons: 4 numOfWeights: 3 using: random.
	
	nl1 nextLayer: nl2.
	self deny: nl1 isOutputLayer.
	self assert: nl2 isOutputLayer.
	
	"nl1 has 4 weights, and needs 4 inputs."
	output := nl1 feed: #(1 2 3 4).
	"nl2 has 4 neurons, so it produces 4 outputs."
	self assert: output size equals: 4.
	output 
		with: #(0.030894 0.9220489 0.52000463 0.2027656) 
		do: [ :result :test |
			self assert: (result closeTo: test precision: 0.0001) ]
	
	
]
