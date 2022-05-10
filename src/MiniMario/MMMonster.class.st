"
I represent a monster character in the MiniMario game.
"
Class {
	#name : #MMMonster,
	#superclass : #MMAbstractCharacter,
	#instVars : [
		'movingLeft',
		'pauseCounter'
	],
	#category : #'MiniMario-Game'
}

{ #category : #actions }
MMMonster >> beat [ 
	"A monster alternates going to the left and to the right."
	
	super beat .
	
	"Use #pauseCounter to slow down the movement of the monster."
	"This makes the MiniMario game playable by a human."
	pauseCounter := pauseCounter + 1 .
	pauseCounter < 10 ifTrue: [ ^ self ] .
	pauseCounter := 0 .
	
	movingLeft 
		ifTrue: [ (self canGoToward: (-1 @ 0) )  
			ifFalse: [ movingLeft := false ] ]
		ifFalse: [ (self canGoToward: (1 @ 0) ) 
			ifFalse: [ movingLeft := true ] ].
	
	movingLeft 
		ifTrue: [ self moveLeft ] 
		ifFalse: [ self moveRight ] .
]

{ #category : #initialization }
MMMonster >> initialize [ 

	super initialize .
	movingLeft := true .
	pauseCounter := 0 .
]
