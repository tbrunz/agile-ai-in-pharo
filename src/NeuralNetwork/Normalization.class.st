"
I represent the normalization of a 2D array.

I am row-first oriented, and I ignore the last column of the matrix.
"
Class {
	#name : #Normalization,
	#superclass : #Object,
	#category : #'NeuralNetwork-Neurons'
}

{ #category : #normalizing }
Normalization >> normalizeData: trainingDataWithOutputs [ 
	"Normalize the training data provided."
	
	| numColumns min max |
	numColumns := trainingDataWithOutputs first size - 1.
	min := OrderedCollection new.
	max := OrderedCollection new.
	1 to: numColumns do: [ :index | 
		| column |
		column := trainingDataWithOutputs collect: [ :row | row at: index ].
		min add: column min.
		max add: column max.
		].
	^ self normalizeData: trainingDataWithOutputs min: min max: max
]

{ #category : #normalizing }
Normalization >> normalizeData: trainingDataWithOutputs min: minValues max: maxValues [
	"Normalize the training data using the min/max values provided."
	
	| numColumns min max result |
	numColumns := trainingDataWithOutputs first size - 1.
	result := OrderedCollection new.
	trainingDataWithOutputs do: [ :row | 
		| norm value |
		norm := OrderedCollection new.
		1 to: numColumns do: [ :index | 
			value := row at: index.
			min := minValues at: index.
			max := maxValues at: index.
			norm add: ((value - min) / (max - min)) asFloat.
			].
		norm add: row last.
		result add: norm asArray.
		].
	^ result asArray
]
