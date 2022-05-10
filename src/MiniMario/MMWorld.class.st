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
	#category : #'MiniMario-Game'
}

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

{ #category : #accessing }
MMWorld >> cellAt: aPoint put: value [
	"Set the value of a particular cell."
	
	^ map at: aPoint y at: aPoint x put: value
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

{ #category : #visualization }
MMWorld >> generateUI [ 
	"Build the game's user interface."
	
	| e upperBounds lowerBounds cellSizeInPixels |
	
	"Size of each cell."
	cellSizeInPixels := 25 .
	
	"Create the visual representation of cells."
	view := RTView new.
	upperBounds := self windowSize // 2 .
	lowerBounds := upperBounds negated .
	lowerBounds to: upperBounds do: [ :x |
		lowerBounds to: upperBounds do: [ :y | 
			e := RTBox new size: cellSizeInPixels + 1;
				elementOn: (x @ y) .
			view add: e .
			e translateTo: (x @ y) * cellSizeInPixels 
			]
		].
	
	"Define the actions to be taken when keys are pressed."
	view when: TRKeyDown do: [ :event | 
		"Key D"
		event keyValue = 100 ifTrue: [ mario moveRight ] .
		
		"Key A"
		event keyValue = 97 ifTrue: [ mario moveLeft ] .
		
		"Key W"
		event keyValue = 119 ifTrue: [ mario jump ]
		].
	
	"A beat is performed at each update of the UI."
	view addAnimation: (RTActiveAnimation new 
		intervalInMilliseconds: 30; 
		blockToExecute: [ self beat ] ) .
		
	self refreshView .
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

{ #category : #visualization }
MMWorld >> open [ 
	"Open the UI."
	
	self inspect .
	self generateUI .
	^ view open 
]

{ #category : #visualization }
MMWorld >> refreshView [ 
	"Refresh the UI."
	
	| p t color |
	view ifNil: [ ^ self ] .
	isGameRunning ifFalse: [ ^ self ] .
	
	p := mario position .
	view elements doWithIndex: [ :e :index | 
		t := p + e model .
		
		"Empty cells are blue, platform cells are brown, 
		tube cells are green, cells outside the map are black."
		(self isInMap: t)
			ifTrue: [ 
				(self getCellAt: t) = 0 ifTrue: [ color := Color blue ] .
				(self getCellAt: t) = 1 ifTrue: [ color := Color brown ] .
				(self getCellAt: t) = 2 ifTrue: [ color := Color green ] .
				] 
			ifFalse: [ color := Color black ] .
			
		"Mario is red (of course)."
		e model = (0 @ 0) ifTrue: [ color := Color red ] .
		e trachelShape color: color .
		].
	
	monsters do: [ :monster | 
		t := monster position - p .
		
		"Only monsters that are within the window frame are rendered."
		t x abs < self windowSize ifTrue: [ 
			| cell |
			cell := view elements elementFromModel: t .
			
			"Monsters are orange."
			cell ifNotNil: [ cell trachelShape color: Color orange ]
			]
		].
	
	view signalUpdate .
]

{ #category : #accessing }
MMWorld >> seed: aNumber [ 
	"Create a random number generator with a particular seed."
	
	randomGenerator := Random seed: aNumber .
	self generateMap .
]

{ #category : #visualization }
MMWorld >> showCompleteMap [ 
	"SHow the complete map."
	
	| v cellSizeInPixels color e |
	v := RTView new.
	v @ RTDraggableView .
	
	cellSizeInPixels := 4 .
	
	1 to: self size x do: [ :x | 
		1 to: self size y do: [ :y | 
			color := Color black .
			(self getCellAt: (x @ y) ) = 0 
				ifTrue: [ color := Color blue ] .
			(self getCellAt: (x @ y) ) = 1 
				ifTrue: [ color := Color brown ] .
			(self getCellAt: (x @ y) ) = 2 
				ifTrue: [ color := Color green ] .
			
			e := RTBox new size: cellSizeInPixels + 1;
				color: color;
				elementOn: (x @ y).
			v add: e .
			e translateTo: (x @ y) * cellSizeInPixels 
			]
		].
	
	v open.
]

{ #category : #accessing }
MMWorld >> size [ 

	^ 300 @ 10
]

{ #category : #visualization }
MMWorld >> whatMarioSees [ 
	"Reply with the values of the visible cells."
	
	| result p t upperBounds lowerBounds |
	result := OrderedCollection new.
	p := mario position .
	
	upperBounds := self windowSize // 2 .
	lowerBounds := upperBounds negated .
	
	lowerBounds to: upperBounds do: [ :x | 
		lowerBounds to: upperBounds do: [ :y | 
			t := p + (x @ y) .
			(self isInMap: t)
				ifTrue: [ result add: (self getCellAt: t) ] 
				ifFalse: [ result add: 1 ]
			]
		].
	
	^ result
	
]

{ #category : #visualization }
MMWorld >> windowSize [ 
	"Reply with the number of pixels of a window frame side."
	
	^ 11
]
