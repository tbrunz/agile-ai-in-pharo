Class {
	#name : #NormalizationTest,
	#superclass : #TestCase,
	#category : #'NeuralNetwork-Tests'
}

{ #category : #tests }
NormalizationTest >> testEmptyError [
	
	self should: [ Normalization new normalizeData: #( ) ] raise: Error.
]

{ #category : #tests }
NormalizationTest >> testError [
	
	self should: [ Normalization new normalizeData: #( #(10 5 1) ) ] raise: Error.
]

{ #category : #tests }
NormalizationTest >> testSimpleNormalization [ 
	
	| input normed | 
	input := #( #(10 5 1) #(2 6 0) ).
	normed := Normalization new normalizeData: input.
	self assert: normed equals: #( #(1.0 0.0 1.0) #(0.0 1.0 0.0) ).
]
