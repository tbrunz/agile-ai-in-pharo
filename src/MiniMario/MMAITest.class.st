Class {
	#name : #MMAITest,
	#superclass : #TestCase,
	#instVars : [
		'neat'
	],
	#category : #'MiniMario-Tests'
}

{ #category : #tests }
MMAITest >> playAIMario: neuralNet [
	"Train AI Mario on a game, then have him play the game."
	
	| world |
	self assert: (neat notNil) 
		description: 'Must run "testTrainingAIMario" first' .
		
	self assert: (neat currentGeneration > 1) 
		description: 'Must run "testTrainingAIMario" first' .
	
	world := MMWorld new.
	world mario: (MMAIMario new network: neuralNet) .
	world open .
	
	"self assert: (world mario position x) equals: (world size x) ."
]

{ #category : #tests }
MMAITest >> trainAIMario [ 
	| world |

	neat := NEAT new.
	neat numberOfInputs: 121.
	neat numberOfOutputs: 3.
	neat populationSize: 200.
	
	neat fitness: [ :ind | 
		world := MMWorld new.
		world mario: (MMAIMario new network: ind).
		450 timesRepeat: [ world beat ].
		world mario position x
		].
	
	neat numberOfGens: 160.
	neat run.
	
	^ neat result 
]
