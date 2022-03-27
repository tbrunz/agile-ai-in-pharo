Class {
	#name : #NeuralNetTest,
	#superclass : #TestCase,
	#instVars : [
		'dataXOR',
		'dataBinary'
	],
	#category : #'NeuralNetwork-Tests'
}

{ #category : #running }
NeuralNetTest >> setUp [
	super setUp.
	
	"Create a data set for an XOR test."
	dataXOR := { 
		{ 0 . 0 . 0 } .
		{ 0 . 1 . 1 } .
		{ 1 . 0 . 1 } .
		{ 1 . 1 . 0 } .
		} .
		
	"Create a data set for a binary test."
	dataBinary := { 
		{ 0 . 0 . 0 . 0 } .
		{ 0 . 0 . 1 . 1 } .
		{ 0 . 1 . 0 . 2 } .
		{ 0 . 1 . 1 . 3 } .
		{ 1 . 0 . 0 . 4 } .
		{ 1 . 0 . 1 . 5 } .
		{ 1 . 1 . 0 . 6 } .
		{ 1 . 1 . 1 . 7 } .
		} .
]

{ #category : #tests }
NeuralNetTest >> testBasic [ 
	| nn |
	nn := NeuralNet new.
	nn configure: 2 hidden: 2 numOfOutputs: 1.
	
	self assert: ((nn feed: #(1 3)) anyOne closeTo: 0.6745388 precision: 0.0000001).
	self assert: nn numberOfOutputs equals: 1.
]

{ #category : #tests }
NeuralNetTest >> testGABinary [
	| g n |
	n := NeuralNet new.
	n configure: 3 hidden: 5 numOfOutputs: 8 .
	
	g := GAEngine new.
	g populationSize: 500.
	"g mutationRate: 0.01."
	g endForMaxNumberOfGenerations: 100.
	g crossoverOperator: (GAConstrainedCrossoverOperation new 
		possibleCutPoints: n getPossibleCutpoints) .
	g numberOfGenes: n numberOfParameters .
	g createGeneBlock: [ :randGen :index :ind | 
		randGen next * 10 - 5 ] .
	g fitnessBlock: [ :genes | 
		| result |
		n setWeightsAndBiases: genes .
		result := (dataBinary collect: [ :row | 
			(n predict: row allButLast) = row last ] ) 
				select: #yourself .
		(result size / dataBinary size) round: 4 .
		].
	g run.
	g visualize open .
	
	"Test the result by instantiating the NN & making a prediction."
	n := NeuralNet new.
	n configure: 3 hidden: 5 numOfOutputs: 8 .
	n setWeightsAndBiases: g result .
	self assert: (n predict: #(1 1 0) ) equals: 6 .
]

{ #category : #tests }
NeuralNetTest >> testGAIrisDataset [ 

	| g n irisCSV lines irisData |
	irisCSV := (ZnEasy get: 
		'https://agileartificialintelligence.github.io/Datasets/iris.csv') 
			contents .
	
	"Convert all but last columns into numbers in an array."
	lines := irisCSV lines allButFirst collect: [ :line | 
		| subStr |
		subStr := line substrings: ','. 
		(subStr allButLast collect: 
			[ :word | word asNumber ] ) , { subStr last } 
		].
	
	"Convert the name in the last column into a number (index)."
	irisData := lines collect: [ :row | 
		| line |
		row last = 'setosa' ifTrue: [ line := #( 0 ) ] .
		row last = 'versicolor' ifTrue: [ line := #( 1 ) ] .
		row last = 'virginica' ifTrue: [ line := #( 2 ) ] .
		row allButLast , line
		].
	
	n := NeuralNet new.
	n configure: 4 hidden: 6 numOfOutputs: 3 .
	
	g := GAEngine new.
	g populationSize: 50.
	g endForMaxNumberOfGenerations: 30.
	g crossoverOperator: (GAConstrainedCrossoverOperation new 
		possibleCutPoints: n getPossibleCutpoints) .
	g numberOfGenes: n numberOfParameters .
	g createGeneBlock: [ :randGen :index :ind | randGen next * 10 - 5 ] .
	g fitnessBlock: [ :genes | 
		| result |
		n setWeightsAndBiases: genes .
		result := (irisData collect: [ :row | 
			(n predict: row allButLast) = row last ] ) 
				select: #yourself .
		(result size / irisData size) asFloat round: 4 .
		].
	g run.
	g visualize open.
]

{ #category : #tests }
NeuralNetTest >> testGAXOR [
	| g n |
	n := NeuralNet new.
	n configure: 2 hidden: 3 numOfOutputs: 2 .
	
	g := GAEngine new.
	g populationSize: 500.
	g mutationRate: 0.01.
	g endForMaxNumberOfGenerations: 30.
	g crossoverOperator: (GAConstrainedCrossoverOperation new 
		possibleCutPoints: n getPossibleCutpoints) .
	g numberOfGenes: n numberOfParameters .
	g createGeneBlock: [ :randGen :index :ind | 
		randGen next * 10 - 5 ] .
	g fitnessBlock: [ :genes | 
		| result |
		n setWeightsAndBiases: genes .
		result := (dataXOR collect: [ :row | 
			(n predict: row allButLast) = row last ] ) 
				select: #yourself .
		(result size / 4) round: 4 .
		].
	g run.
	g visualize open .
	
	"Test the result by instantiating the NN & making a prediction."
	n := NeuralNet new.
	n configure: 2 hidden: 3 numOfOutputs: 2 .
	n setWeightsAndBiases: g result .
	self assert: (n predict: #(1 0) ) equals: 1 .
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
