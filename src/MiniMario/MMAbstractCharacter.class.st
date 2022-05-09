"
I represent a abstract character in the MiniMario game.

I am the parent class for Mario and the monsters he should avoid.
"
Class {
	#name : #MMAbstractCharacter,
	#superclass : #Object,
	#instVars : [
		'position',
		'jumpNumSteps',
		'phase',
		'game',
		'isFalling',
		'isJumping'
	],
	#category : #MiniMario
}

{ #category : #actions }
MMAbstractCharacter >> beat [ 
	"Execute a unit of behavior of the MiniMario character."
	
	isJumping ifTrue: [ 
		phase == #goingUp ifTrue: [ self translateBy: (0 @ -1) ] .
		phase == #goingDown ifTrue: [ self translateBy: (0 @ 1) ] .
		jumpNumSteps := jumpNumSteps + 1 .
		jumpNumSteps = 5 ifTrue: [ phase := #goingDown ] .
		jumpNumSteps = 10 ifTrue: [ isJumping := false ]
		].
	
	isJumping ifFalse: [ 
		self isThereAPlatformBelowMe 
			ifTrue: [ 
				self setAsFalling .
				self translateBy: (0 @ 1)
				] 
			ifFalse: [ self SetAsNotFalling ]
		].
]

{ #category : #testing }
MMAbstractCharacter >> canGoToward: aDeltaPosition [ 
	"Reply #true if the character can go in a given direction."
	
	^ (game getCellAt: position + aDeltaPosition) = 0
]

{ #category : #accessing }
MMAbstractCharacter >> game: aWorldGame [
	"Set the world in which the character lives."
	
	game := aWorldGame 
]

{ #category : #initialization }
MMAbstractCharacter >> initialize [ 

	super initialize .
	
	isJumping := false .
	isFalling := true .
	position := (0 @ 0) .
]

{ #category : #testing }
MMAbstractCharacter >> isThereAPlatformBelowMe [ 
	"Reply with #true if there is no platform below the character."
	
	^ (game getCellAt: self position + (0 @ 1)) = 0
]

{ #category : #actions }
MMAbstractCharacter >> jump [ 
	"Make the character jump, but do nothing 
	if it is falling or already jumping."
	
	isJumping ifTrue: [ ^ self ] .
	isFalling ifTrue: [ ^ self ] .
	
	isJumping := true .
	phase := #goingUp .
]

{ #category : #actions }
MMAbstractCharacter >> moveLeft [ 

	self translateBy: (-1 @ 0)
]

{ #category : #actions }
MMAbstractCharacter >> moveRight [

	self translateBy: (1 @ 0)
]

{ #category : #accessing }
MMAbstractCharacter >> position [ 

	^ position
]

{ #category : #accessing }
MMAbstractCharacter >> setAsFalling [ 

	isFalling := true
]

{ #category : #accessing }
MMAbstractCharacter >> setAsNotFalling [ 

	isFalling := false
]

{ #category : #actions }
MMAbstractCharacter >> translateBy: aDeltaPosition [ 
	"Translate the position of the character by a delta, if possible."
	
	(self canGoToward: aDeltaPosition) ifFalse: [ ^ self ] .
	position := position + aDeltaPosition .
]

{ #category : #actions }
MMAbstractCharacter >> translateTo: aPosition [ 
	"Set a position of the character."
	
	position := aPosition
]
