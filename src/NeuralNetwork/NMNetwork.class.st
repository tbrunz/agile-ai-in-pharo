"
I represent a Neural Network implemented using matrices.
"
Class {
	#name : #NMNetwork,
	#superclass : #Object,
	#instVars : [
		'layers',
		'errors',
		'randomGenerator'
	],
	#category : #'NeuralNetwork-Matrix'
}

{ #category : #adding }
NMNetwork >> addLayer: aNNLayer [ 
	"Add a neuron layer to the network."
	"Note this is in the form of a double-linked list."
	
	layers ifNotEmpty: [ 
		layers last next: aNNLayer.
		aNNLayer previous: layers last.
		].
	layers add: aNNLayer 
]

{ #category : #computing }
NMNetwork >> backPropagate: trainingSet targets: targets [
	"Compute the error and backward propagate it through the network."
	
	| lastLayer currentLayer dz |
	lastLayer := layers last.
	dz := lastLayer output - targets.
	lastLayer delta: dz.
	
	currentLayer := lastLayer previous.
	[ currentLayer notNil ] whileTrue: [ 
		dz := (currentLayer next w transposed +* dz) 
			multiplyPerElement: 
				(currentLayer output collect: [ :value | 
					value * (1 - value) ]).
		
		currentLayer delta: dz.
		currentLayer := currentLayer previous.
		].
]

{ #category : #computing }
NMNetwork >> computeCost: vector1 and: vector2 [ 
	"Compute the cost function for two provided vectors."
	
	^ ((vector1 - vector2) 
		collect: [ :value | value * value ]) sum
]

{ #category : #configuring }
NMNetwork >> configureInputs: numInputs hidden: numHidden1 hidden: numHidden2 outputs: numOutputs [
	"Configure the neural network with the given parameters."
	"Note that this method creates two hidden layers."
	
	self addLayer: (NMLayer new 
		numInputs: numInputs 
		numOutputs: numHidden1 
		randomize: randomGenerator) .
		
	self addLayer: (NMLayer new 
		numInputs: numHidden1 
		numOutputs: numHidden2 
		randomize: randomGenerator) .
		
	self addLayer: (NMLayer new 
		numInputs: numHidden2 
		numOutputs: numOutputs 
		randomize: randomGenerator) .
]

{ #category : #configuring }
NMNetwork >> configureInputs: numInputs hidden: numHidden outputs: numOutputs [
	"Configure the neural network with the given parameters."
	"Note that this method creates only one hidden layer."
	
	self addLayer: (NMLayer new 
		numInputs: numInputs 
		numOutputs: numHidden  
		randomize: randomGenerator) .
		
	self addLayer: (NMLayer new 
		numInputs: numHidden  
		numOutputs: numOutputs 
		randomize: randomGenerator) .
]

{ #category : #computing }
NMNetwork >> feed: inputs [
	"Feed the network with the inputs, cycling through the layers."
	"Reply with the outputs as a (m x 1) matrix."
	
	| matrix |
	matrix := inputs.
	
	layers do: [ :layer |
		matrix := layer feed: matrix ].
	
	^ matrix
]

{ #category : #initialization }
NMNetwork >> initialize [ 
	"Init the network with a random number generator, but no layers."
	
	super initialize.
	layers := OrderedCollection new.
	randomGenerator := Random seed: 42.
]

{ #category : #configuring }
NMNetwork >> learningRate: aLearningRate [ 
	"Set the learning rate globally (all neurons in all layers)."
	
	layers do: [ :layer |
		layer learningRate: aLearningRate ]
]

{ #category : #configuring }
NMNetwork >> loadIrisData [ 
	"Load the Iris data set from a CSV file in the cloud."
	
	| irisCSV textLines numericLines irisData |
	irisCSV := (ZnEasy 
		get: 'https://agileartificialintelligence.github.io/Datasets/iris.csv') 
		contents.
	textLines := irisCSV lines.
	textLines := textLines allButFirst.  "Drop header line; not data."
	
	"First pass: Convert columns 1..n-1 from text to numbers."
	numericLines := textLines collect: [ :line | 
		| lineWords |
		"Each line should be columns of numbers; but the last is a string name."
		lineWords := line substrings: ','.  "Split on comma into 'words'."
		(lineWords allButLast collect: [ :word | word asNumber ] ) , 
			(Array with: lineWords last).  "Make last word a 1-element array; concat."
		].
	
	"Now convert the last column from a text word to a category number."
	irisData := numericLines collect: [ :row | 
		| name |
		name := #(-1).  "Default if we don't recognize a string."
		
		"Name conversions are all hard-coded...  Numeric values are arbitrary."
		row last = 'setosa' ifTrue: [ name := #(0) ].
		row last = 'versicolor' ifTrue: [ name := #(1) ].
		row last = 'virginica' ifTrue: [ name := #(2) ].
		
		row allButLast , name ].  "Replace last column with a number."
	
	^ irisData
]

{ #category : #computing }
NMNetwork >> predict: inputs [ 
	"Make a prediction, assuming the number of outputs is the same as 
	the number of different values the network can output."
	"Note that Pharo arrays are 1-based, so we need to compensate."
	
	| outputs |
	outputs := self feed: inputs.
	
	^ (outputs asArray indexOf: (outputs max)) - 1
]

{ #category : #computing }
NMNetwork >> trainFor: trainingData numEpochs: numEpochs [
	"Train the network using a labeled data set."
	"The training set must be a collection of arrays."
	"The data need to be labeled with a numeric value."
	
	| trainingSet targets labels numOutputs |
	trainingSet := (Matrix newFromArrays: (trainingData collect: #allButLast)) transposed.
	
	layers do: [ :layer | layer numExamples: trainingData size ].
	
	labels := trainingData collect: #last.
	numOutputs := labels asSet size.
	
	labels := labels collect: [ :row | 
		| expected |
		expected := Array new: numOutputs withAll: 0.
		expected at: row + 1 put: 1.
		expected
		].
	
	targets := (Matrix newFromArrays: labels) transposed.
	
	^ self trainFor: trainingSet targets: targets numEpochs: numEpochs 
]

{ #category : #computing }
NMNetwork >> trainFor: trainingSet targets: targets numEpochs: numEpochs [ 
	"Train the network with a set of training inputs against target outputs."
	
	| cost output |
	"The layers need to know the number of training examples."
	layers do: [ :layer | 
		layer numExamples: targets numCols ].
	
	errors := OrderedCollection new.
	numEpochs timesRepeat: [ 
		output := self feed: trainingSet .
		cost := self computeCost: output and: targets.
		self backPropagate: trainingSet targets: targets.
		self update: trainingSet.
		errors add: cost.
		].
	^ cost
]

{ #category : #updating }
NMNetwork >> update: input [ 
	"Update the weights & biases using the provided input vector."
	
	layers first update: input
]

{ #category : #viewing }
NMNetwork >> viewLearningCurve [ 
	"Visualize the evolution of the error during training."
	
	| b ds |
	errors 
		ifEmpty: [ ^ RTView new 
			add: (RTLabel elementOn: 'Should first run the network');
			yourself.
			].
		
	b := RTGrapher new.
	b extent: 500 @ 300.
	
	ds := RTData new.
	ds samplingIfMoreThan: 2000.
	ds noDot; connectColor: Color blue.
	ds points: (errors collectWithIndex: [ :err :index | index -> err ]).
	ds x: #key.
	ds y: #value.
	ds dotShape rectangle color: Color blue.
	
	b add: ds.
	b axisX noDecimal; title: 'Epoch'.
	b axisY title: 'Error'.
	^ b
]

{ #category : #viewing }
NMNetwork >> viewLearningCurveIn: composite [

	<gtInspectorPresentationOrder: -10>
	composite roassal2 
		title: 'Cost';
		initializeView: [ self viewLearningCurve ]
]
