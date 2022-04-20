"
I am the main entry point for using NEAT to evolve neural networks.
"
Class {
	#name : #NEAT,
	#superclass : #Object,
	#instVars : [
		'configuration',
		'population',
		'populationSize',
		'numberOfInputs',
		'numberOfOutputs',
		'logs',
		'fitness',
		'randomGenerator',
		'speciation',
		'numberOfGens',
		'shouldUseElitism'
	],
	#category : #'NEAT-Core'
}

{ #category : #action }
NEAT >> buildInitialPopulation [ 
	"Randomly build the initial population."
	
	population := OrderedCollection new.
	
	populationSize timesRepeat: [ | ind | 
		ind := NEIndividual new.
		ind randomGenerator: randomGenerator .
		numberOfInputs timesRepeat: [ ind addInputNode ] .
		numberOfOutputs timesRepeat: [ ind addOutputNode ] .
		population add: ind
		]
]

{ #category : #action }
NEAT >> computeFitnesses [ 
	"Compute the fitness value for each individual."
	
	population do: [ :ind | 
		ind computeFitness: fitness 
		]
]

{ #category : #action }
NEAT >> crossoverBetween: ind1 and: ind2 [ 
	"Perform a genetic crossover operation between two individuals."
	"Reply with a new individual."
	
	^ ind1 fitness > ind2 fitness 
		ifTrue: [ NECrossoverOperation new performOn: ind1 and: ind2 ] 
		ifFalse: [ NECrossoverOperation new performOn: ind2 and: ind1 ]
]

{ #category : #accessing }
NEAT >> crossoverRate [ 
	"Reply with the crossover rate."
	
	| t |
	t := configuration detect: [ :assoc | 
		assoc key isKindOf: NECrossoverOperation ]
		ifNone: [ ^ 0 ] .
		
	^ t value
	
]

{ #category : #accessing }
NEAT >> currentGeneration [
	"Reply with the current generation."
	
	^ logs size
	
]

{ #category : #configuration }
NEAT >> defaultConfiguration [ 
	"Make the algorithm use a default configuration."
	
	self resetConfiguration .
	
	self for: NEConnectionWeightMutationOperation prob: 0.2 .
	self for: NEAddConnectionMutationOperation prob: 0.2 .
	self for: NEAddNodeMutationOperation prob: 0.01 .
	self for: NECrossoverOperation prob: 0.2 .
]

{ #category : #action }
NEAT >> doLog [ 
	"Create a log object that summarizes the generation."
	
	| log |
	log := NELog new.
	log generation: logs size .
	log speciation: speciation .
	log minFitness: (population collect: #fitness) min .
	log maxFitness: (population collect: #fitness) max .
	log avgFitness: ((population collect: #fitness) average asFloat round: 3) .
	log bestIndividual: self result .
	logs add: log .
]

{ #category : #action }
NEAT >> doMutate: anIndividual [ 
	"Perform a mutation on the individual."
	"Must be provided with a *copy* of the individual."
	
	configuration do: [ :cAssoc | 
		(cAssoc key isKindOf: NEAbstractMutationOperation) 
			ifTrue: [ randomGenerator next <= cAssoc value 
					ifTrue: [ cAssoc key randomGenerator: randomGenerator; 
						performOn: anIndividual ]
				]
		]
]

{ #category : #configuration }
NEAT >> doNotUseElitism [ 
	"Do not use 'elitism' when generating a new population."
	
	shouldUseElitism := false
]

{ #category : #action }
NEAT >> doSpeciation [ 
	"Perform the speciation algorithm."
	
	speciation := NESpeciation new.
	speciation process: population .
]

{ #category : #configuration }
NEAT >> doUseElitism [ 
	"Use 'elitism' when generating a new population."
	
	shouldUseElitism := true
]

{ #category : #accessing }
NEAT >> fitness: oneArgBlock [
	"Set a one-argument block for the fitness function."
	"The block must return a numeric value; the higher 
	the value, the more fit the individual is."

	fitness := oneArgBlock
]

{ #category : #configuration }
NEAT >> for: anOperationClass prob: probability [ 
	"Set the probability for a genetic operation to be applied."
	
	"First, check to see if we have an existing config for the operation."
	configuration do: [ :assoc | 
		(assoc key isKindOf: anOperationClass) 
			ifTrue: [ assoc value: probability .
				^ self ]
		].
	
	"If not, then we can simply add it."
	configuration add: anOperationClass new -> probability .
]

{ #category : #viewing }
NEAT >> gtInspectorNumberOfSpeciesIn: composite [ 
	
	<gtInspectorPresentationOrder: -10>
	
	composite roassal2 
		title: '#Species';
		initializeView: [ self visualizeNumberOfSpecies ]
]

{ #category : #viewing }
NEAT >> gtInspectorViewIn: composite [ 
	
	<gtInspectorPresentationOrder: -10>
	
	composite roassal2 
		title: 'Fitness';
		initializeView: [ self visualizeFitness ]
]

{ #category : #initialization }
NEAT >> initialize [ 

	super initialize .
	self defaultConfiguration .
	
	"By default, configure for two inputs and one bias."
	numberOfInputs := 2.
	numberOfOutputs := 1.
	
	populationSize := 150.
	randomGenerator := Random seed: 42.
	
	logs := OrderedCollection new.
	numberOfGens := 10.
	
	self doUseElitism .
]

{ #category : #accessing }
NEAT >> numberOfGens: anInteger [

	numberOfGens := anInteger
]

{ #category : #accessing }
NEAT >> numberOfInputs: anInteger [

	numberOfInputs := anInteger
]

{ #category : #accessing }
NEAT >> numberOfOutputs: anInteger [

	numberOfOutputs := anInteger
]

{ #category : #accessing }
NEAT >> populationSize: anInteger [

	populationSize := anInteger
]

{ #category : #configuration }
NEAT >> releaseHistory [
	"Release the memory consumed by the historical logs."
	
	logs allButLast do: #release .
]

{ #category : #configuration }
NEAT >> resetConfiguration [ 
	"Reset the configuration of the algorithm."
	"A configuration is defined as a set of 
	probabilities for each genetic operation."
	
	configuration := OrderedCollection new.
]

{ #category : #action }
NEAT >> result [ 
	"Reply with the result of the algorithm, i.e., 
	the fittest neural network."
	
	| winner |
	winner := population first .
	population do: [ :ind | 
		winner fitness < ind fitness 
			ifTrue: [ winner := ind ]
		].
	
	^ winner
]

{ #category : #action }
NEAT >> run [ 
	"Run the NEAT algorithm."
	
	self buildInitialPopulation .
	self doSpeciation .
	self computeFitnesses .
	self doLog .
	self runFor: numberOfGens .
]

{ #category : #action }
NEAT >> runFor: numOfGens [ 
	"Run the NEAT algorithm for a given number of generations."
	
	'Running the NEAT algorithm'
		displayProgressFrom: 1 to: numOfGens during: [ :bar | 
			1 to: numOfGens do: [ :x | 
				bar value: x .
				self runOneGeneration
				]
			]
]

{ #category : #action }
NEAT >> runOneGeneration [ 
	"Run the evolution algorithm for one generation."
	
	| newPopulation ind1 ind2 newInd numOfIndsToCreate |
	"Create the species."
	self doSpeciation .
	
	"We have an empty new population..."
	newPopulation := OrderedCollection new.
	
	"The number of individuals to create is #populationSize, or #populationSize - 1."
	numOfIndsToCreate := 
		(shouldUseElitism and: [ self currentGeneration > 1 ] )
			ifTrue: [ | eli best |
				best := self result .
				eli := best copy .
				eli fitness: best fitness .
				newPopulation add: eli .
				populationSize - 1 ] 
			ifFalse: [ populationSize ] .
			
	"The new population is then built."
	numOfIndsToCreate timesRepeat: [ 
		"Should we do a crossover.. or not?"
		randomGenerator next <= self crossoverRate 
			ifTrue: [ 
				"If yes, combine two selected elements."
				ind1 := self selectIndividual .
				ind2 := self selectIndividual: ind1 species individuals .
				newInd := self crossoverBetween: ind1 and: ind2
				] 
			ifFalse: [ 
				"If no, then simply copy a selected individual."
				newInd := self selectIndividual copy
				] .
		
		"We perform the mutation on the new individual."
		self doMutate: newInd .
		
		"Add it to the population."
		newPopulation add: newInd .
		
		"Compute its fitness value."
		newInd computeFitness: fitness .
		].
	
	"The old population is replaced by the new population."
	population := newPopulation .
	self doLog
]

{ #category : #action }
NEAT >> selectIndividual [
	"Select an individual from the population 
	using the tournament selection algorithm."
	
	^ self selectIndividual: population
]

{ #category : #action }
NEAT >> selectIndividual: someIndividuals [
	"Use the tournament selection algorithm 
	to pick the best individual."
	
	| ind k winner |
	winner := someIndividuals atRandom: randomGenerator .
	
	"We have already picked the winner; we need 4 more individuals."
	k := 4 .
	k timesRepeat: [ 
		ind := winner species individuals atRandom: randomGenerator .
		winner fitness < ind fitness 
			ifTrue: [ winner := ind ]
		].
	
	"Reply with the winner of the tournament."
	^ winner
]

{ #category : #viewing }
NEAT >> visualizeFitness [ 
	"Visualize the max, min, and average fitness for each generation."
	
	| g d |
	g := RTGrapher new.
	
	"Min fitness"
	d := RTData new.
	d label: 'Minimum Fitness' .
	d noDot; connectColor: Color red.
	d points: logs.
	d y: #minFitness .
	g add: d.
	
	"Max fitness"
	d := RTData new.
	d label: 'Maximum Fitness' .
	d noDot; connectColor: Color blue.
	d points: logs.
	d y: #maxFitness .
	g add: d.
	
	"Average fitness"
	d := RTData new.
	d label: 'Average Fitness' .
	d noDot; connectColor: Color green.
	d points: logs.
	d y: #avgFitness .
	g add: d.
	
	g axisX noDecimal; title: 'Generation' .
	g axisY title: 'Fitness' .
	g legend addText: 'Fitness Evolution' .
	^ g
]

{ #category : #viewing }
NEAT >> visualizeNumberOfSpecies [ 
	"Visualize the evolution of the number of species."
	
	| g d |
	g := RTGrapher new.
	d := RTData new.
	d points: logs.
	d y: #numberOfSpecies .
	g add: d.
	
	g axisX title: 'Generation'; noDecimal .
	g axisY title: '# of Species' .
	^ g
]
