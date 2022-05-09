"
I represent the world that the MiniMario characters inhabit.

#map = a large 2D array containing values describing the map. 
	Value 0 indicates an empty cell; 
	Value 1 indicates a brick; 
	Value 2 indicates a tube.
	
#view = a Roassal view of the game.
"
Class {
	#name : #MMWorld,
	#superclass : #Object,
	#instVars : [
		'map',
		'mario',
		'view',
		'monsters',
		'isGameRunning',
		'randomGenerator'
	],
	#category : #MiniMario
}

{ #category : #accessing }
MMWorld >> CellAt: aPoint put: value [
	"Set the value of a particular cell."
	
	^ map at: aPoint y at: aPoint x put: value
]

{ #category : #initialization }
MMWorld >> addBrick: position [
	"Add a brick to a position."
	
	(self isInMap: position)
		ifTrue: [ self cellAt: position put: 1 ] .
]

{ #category : #initialization }
MMWorld >> addMonster: aMonster [
	"Add a monster to the world."
	
	monsters add: aMonster .
	aMonster game: self .
]

{ #category : #initialization }
MMWorld >> addPlatform: position [ 
	"A platform is simply 5 bricks lined up horizontally."
	
	-2 to: 2 do: [ :index | 
		self addBrick: position + (index @ 0) ] .
]

{ #category : #initialization }
MMWorld >> addTube: positionX [ 
	"A tube is like a brick -- Mario cannot go through."
	
	| indexY |
	indexY := self size y - 1 .
	3 timesRepeat: [ 
		self addTubeCell: (positionX @ indexY) .
		indexY := indexY - 1
		].
]

{ #category : #initialization }
MMWorld >> addTubeCell: position [
	"Add a cell representing a tube at a given position."
	
	(self isInMap: position)
		ifTrue: [ self cellAt: position put: 2 ]
]

{ #category : #actions }
MMWorld >> beat [ 
	"The world beat performs a beat on Mario & each monster."
	
	isGameRunning ifFalse: [ ^ self ] .
	monsters do: #beat .
	mario beat .
	self refreshView .
]

{ #category : #actions }
MMWorld >> gameOver [ 
	"End the game..."
	
	isGameRunning := false .
	view ifNil: [ ^ self ] .
	view add: ((RTLabel new color: Color red; text: 'GAME OVER') 
		element translateBy: (0 @ -100) ).
]

{ #category : #initialization }
MMWorld >> generateMap [ 
	"Randomly generate the map used in the world."
	
	map := Array2D rows: self size y columns: self size x element: 0 .
	
	"Place bricks along the upper & lower limits."
	1 to: self size x do: [ :x | 
		self addBrick: (x @ self size y); 
			addBrick: (x @ 1)
		].
	
	"Place bricks along the left & right sides."
	1 to: self size y do: [ :y | 
		self addBrick: (1 @ y);
			addBrick: (self size x @ y)
		].
	
	"The map has 80 platforms ..."
	80 timesRepeat: [ 
		self addPlatform:	(randomGenerator nextInteger: self size x) @ 
			(randomGenerator nextInteger: self size y)
		].
	
	"... and 30 tubes."
	30 timesRepeat: [ 
		self addTube: (randomGenerator nextInteger: self size x) 
		].
]

{ #category : #accessing }
MMWorld >> getCellAt: aPoint [ 
	"Reply with the value of a particular cell."
	
	^ map at: aPoint y at: aPoint x
]

{ #category : #initialization }
MMWorld >> initialize [ 

	super initialize .
	
	self initializeMario .
	
	self seed: 42 .
	self initializeMonsters .
	
	isGameRunning := true .
]

{ #category : #initialization }
MMWorld >> initializeMario [ 
	"Create the Mario character object."
	
	mario := MMMario new.
	mario translateTo: (2 @ 2) .
	mario game: self .
]

{ #category : #initialization }
MMWorld >> initializeMonsters [ 
	"Add a number of monster characters."
	
	monsters := OrderedCollection new.
	10 timesRepeat: [ 
		| monster |
		monster := MMMonster new 
			translateTo: (randomGenerator nextInteger: self size x) @ 2 .
		self addMonster: monster
		]
]

{ #category : #accessing }
MMWorld >> isInMap: position [ 
	"Reply true if the position in within the map."
	
	^ ( (1 @ 1) extent: self size) containsPoint: position
]

{ #category : #accessing }
MMWorld >> mario [ 

	^ mario
]

{ #category : #accessing }
MMWorld >> mario: aMario [ 
	"Set Mario in the game."
	
	mario := aMario .
	mario game: self .
	mario translateTo: (2 @ 2) .
]

{ #category : #accessing }
MMWorld >> monsters [ 

	^ monsters
]

{ #category : #accessing }
MMWorld >> seed: aNumber [ 
	"Create a random number generator with a particular seed."
	
	randomGenerator := Random seed: aNumber .
	self generateMap .
]

{ #category : #accessing }
MMWorld >> size [ 

	^ 300 @ 10
]
