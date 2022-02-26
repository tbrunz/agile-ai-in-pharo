Class {
	#name : #PerceptronTest,
	#superclass : #TestCase,
	#category : #'NeuralNetwork-Tests'
}

{ #category : #computing }
PerceptronTest >> digitalComparator: inputs [
	"Model a digital comparator circuit."
	"Return an array of 3 booleans."	
			
	| not and nor a b notA notB aGb aEb aLb |
	a := inputs first.
	b := inputs second.
	and := self newNeuron weights: #( 1  1); bias: -1.5.
	not := self newNeuron weights: #( -1 );  bias:  0.5.
	nor := self newNeuron weights: #(-1 -1); bias:  0.5.
	notA := not feed: { a }.
	notB := not feed: { b }.
	aLb := and feed: { notA . b }.
	aGb := and feed: { a . notB }.
	aEb := nor feed: { aGb . aLb }.
	^ { aGb . aEb . aLb }
]

{ #category : #'instance creation' }
PerceptronTest >> newNeuron [
	"Reply with a new Neuron instance that uses the Step AF."	
			
	^ Neuron new step
]

{ #category : #tests }
PerceptronTest >> testAND [ 
	"Test a Boolean AND gate neuron."	
			
	| p |
	p := self newNeuron.
	p weights: #(1 1).
	p bias: -1.5.
	
	self assert: (p feed: #(0 0)) equals: 0.
	self assert: (p feed: #(0 1)) equals: 0.
	self assert: (p feed: #(1 0)) equals: 0.
	self assert: (p feed: #(1 1)) equals: 1.
]

{ #category : #tests }
PerceptronTest >> testDigitalComparator [	
	"Test the digital comparator method."	
			
	self assert: (self digitalComparator: #(0 0)) equals: #(0 1 0).	
	self assert: (self digitalComparator: #(0 1)) equals: #(0 0 1).	
	self assert: (self digitalComparator: #(1 0)) equals: #(1 0 0).	
	self assert: (self digitalComparator: #(1 1)) equals: #(0 1 0).
]

{ #category : #tests }
PerceptronTest >> testNOR [ 
	"Test a Boolean NOR gate neuron."	
			
	| p |
	p := self newNeuron.
	p weights: #(-1 -1).
	p bias: 0.5.
	
	self assert: (p feed: #(0 0)) equals: 1.
	self assert: (p feed: #(0 1)) equals: 0.
	self assert: (p feed: #(1 0)) equals: 0.
	self assert: (p feed: #(1 1)) equals: 0.
]

{ #category : #tests }
PerceptronTest >> testNOT [ 
	"Test a Boolean NOT gate neuron."	
			
	| p |
	p := self newNeuron.
	p weights: #(-1).
	p bias: 0.5.
	
	self assert: (p feed: #(0)) equals: 1.
	self assert: (p feed: #(1)) equals: 0.
]

{ #category : #tests }
PerceptronTest >> testOR [ 
	"Test a Boolean OR gate neuron."	
			
	| p |
	p := self newNeuron.
	p weights: #(1 1).
	p bias: -0.5.
	
	self assert: (p feed: #(0 0)) equals: 0.
	self assert: (p feed: #(0 1)) equals: 1.
	self assert: (p feed: #(1 0)) equals: 1.
	self assert: (p feed: #(1 1)) equals: 1.
]

{ #category : #tests }
PerceptronTest >> testSmallExample [
	"Simple test of a simple perceptron."	
			
	| p result |
	p := self newNeuron .
	p weights: #(1 2).
	p bias: -2.
	
	result := p feed: #(5 2).
	self assert: result equals: 1
]

{ #category : #tests }
PerceptronTest >> testTrainingAND [
	"Train & test a neuron to compute boolean AND."	
			
	| p |
	p := self newNeuron .
	p weights: #(-1 -1).
	p bias: 2.
	
	40 timesRepeat: [ 
		p train: #(0 0) desiredOutput: 0.
		p train: #(0 1) desiredOutput: 0.
		p train: #(1 0) desiredOutput: 0.
		p train: #(1 1) desiredOutput: 1.
		].
	self assert: ((p feed: #(0 0)) closeTo: 0 precision: 0.1).
	self assert: ((p feed: #(0 1)) closeTo: 0 precision: 0.1).
	self assert: ((p feed: #(1 0)) closeTo: 0 precision: 0.1).
	self assert: ((p feed: #(1 1)) closeTo: 1 precision: 0.1).
]

{ #category : #tests }
PerceptronTest >> testTrainingNOT [
	"Train & test a neuron to compute boolean NOT."	
			
	| p |
	p := self newNeuron .
	p weights: #(-1).
	p bias: 2.
	
	40 timesRepeat: [ 
		p train: #(0) desiredOutput: 1.
		p train: #(1) desiredOutput: 0.
		].
	self assert: (p feed: #(0)) equals: 1.
	self assert: (p feed: #(1)) equals: 0.
]

{ #category : #tests }
PerceptronTest >> testTrainingOR [	
	"Train & test a neuron to compute boolean OR."	
			
	| p |
	p := self newNeuron .
	p weights: #(-1 -1).
	p bias: 2.
	
	40 timesRepeat: [ 
		p train: #(0 0) desiredOutput: 0.
		p train: #(0 1) desiredOutput: 1.
		p train: #(1 0) desiredOutput: 1.
		p train: #(1 1) desiredOutput: 1.
		].
	self assert: (p feed: #(0 0)) equals: 0.
	self assert: (p feed: #(0 1)) equals: 1.
	self assert: (p feed: #(1 0)) equals: 1.
	self assert: (p feed: #(1 1)) equals: 1.
]

{ #category : #tests }
PerceptronTest >> testWrongFeeds [	
	"Test a case where feed & weights sizes are different."	
			
	| p |
	p := self newNeuron .
	p weights: #(-1).
	p bias: 0.5.
	
	self should: [ p feed: #(1 1) ] raise: Error
]
