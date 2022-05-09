"
I represent the main character, Mario, in the MiniMario game.

Most of Mario's behavior is defined in his parent class.
"
Class {
	#name : #MMMario,
	#superclass : #MMAbstractCharacter,
	#category : #MiniMario
}

{ #category : #actions }
MMMario >> beat [ 
	super beat .
	
	"The game ends if Mario reaches the right-most position of the game world."
	self position x = (game size x - 1)
		ifTrue: [ game gameOver ] .
	
	"The game also ends if Mario bumps into a monster."
	game monsters do: [ :monster | 
		(monster position = self position)
			ifTrue: [ game gameOver ]
		].
]
