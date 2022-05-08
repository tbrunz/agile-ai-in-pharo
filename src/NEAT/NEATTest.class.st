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
NEATTest >> testIrisDataSet [

	| irisCSV lines textLines irisData neat diff |
	
	"We first prepare the data."	
	irisCSV := (ZnEasy 
		get: 'https://agileartificialintelligence.github.io/Datasets/iris.csv') 
			contents .
	lines := irisCSV lines .
	lines := lines allButFirst .
	textLines := lines collect: [ :line | 
		| subStrs |
		subStrs := line substrings: ',' .
		(subStrs allButLast collect: [ :word | word asNumber ] ) , 
			(Array with: subStrs last)
		].
	irisData := textLines collect: [ :row | 
		| line |
		row last = 'setosa' ifTrue: [ line := #( 0 ) ] .
		row last = 'versicolor' ifTrue: [ line := #( 1 ) ] .
		row last = 'virginica' ifTrue: [ line := #( 2 ) ] .
		row allButLast, line
		].
	
	"Run the NEAT algorithm."
	neat := NEAT new.
	neat numberOfInputs: 4 .
	neat numberOfOutputs: 3 .
	neat fitness: [ :ind | 
		| score | 
		score := 0 .
		irisData do: [ :tuple | 
			diff := (ind predict: tuple allButLast) - tuple last .
			score := score + (diff * diff)
			].
		(score / -4) asFloat
		].
	
	neat numberOfGens: 180. 
	neat run .
	
	neat visualize open .
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
	
	self assert: (neat result evaluate: #(1 1) ) first closeTo: 0  precision: 0.01 .
	
	"neat visualizeFitness open .
	neat visualizeNumberOfSpecies open .	"
]
