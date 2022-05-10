"
I am able to play the Mario character (rather than a human), as I am steered by a neural network.
"
Class {
	#name : #MMAIMario,
	#superclass : #MMMario,
	#instVars : [
		'neuralNet'
	],
	#category : #'MiniMario-Game'
}

{ #category : #actions }
MMAIMario >> beat [ 
	| actionToPerform |
	super beat .
	
	actionToPerform := neuralNet predict: game whatMarioSees .
	
	actionToPerform = 0 ifTrue: [ self moveLeft ] .
	actionToPerform = 1 ifTrue: [ self moveRight ] .
	actionToPerform = 2 ifTrue: [ self jump ] .
]

{ #category : #accessing }
MMAIMario >> network: aNeuralNetwork [  
	"Set the neural network to be used by AI Mario."
	
	neuralNet := aNeuralNetwork
]
