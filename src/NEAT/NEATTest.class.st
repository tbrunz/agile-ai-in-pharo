Class {
	#name : #NEATTest,
	#superclass : #TestCase,
	#instVars : [
		'dataSet'
	],
	#category : #'NEAT-Tests'
}

{ #category : #running }
NEATTest >> setUp [
	super setUp.
	
	dataSet := #( 
		#(0 0 0) 
		#(0 1 1) 
		#(1 0 1) 
		#(1 1 0) ).
]

{ #category : #tests }
NEATTest >> testXOR [ 
	| neat diff |
	neat := NEAT new .
	neat numberOfInputs: 2 .
	neat numberOfOutputs: 1 .
	neat fitness: [ :ind | 
		| score |
		score := 0 .
		dataSet do: [ :tuple | 
			diff := (ind evaluate: tuple allButLast) first - tuple last .
			score := score + (diff * diff)
			].
		(score / -4) asFloat
		].
	neat numberOfGens: 180 .
	neat run.
]
