"
I represent a neural network, made up of layers of neurons.
"
Class {
	#name : #NeuralNet,
	#superclass : #Object,
	#instVars : [
		'layers',
		'errors',
		'precisions'
	],
	#category : #'NeuralNetwork-Neurons'
}

{ #category : #configuring }
NeuralNet >> addLayer: aNeuronLayer [ 
	"Add a neuron layer, and link to the already added layers."
	
	layers ifNotEmpty: [ 
		aNeuronLayer previousLayer: layers last.
		layers last nextLayer: aNeuronLayer ].
	layers add: aNeuronLayer 
]

{ #category : #computing }
NeuralNet >> backPropagateError: desiredOutputs [
	"Backward propagate deviations from the desired outputs."
	"Start with the output layer, using the form that passes the desired values."
	"Each layer will recursively call its previous using the no-arg form that propagates."
	
	self outputLayer backPropagateError: desiredOutputs 
]

{ #category : #configuring }
NeuralNet >> configure: numOfInputs hidden: numOfNeurons1 hidden: numOfNeurons2 numOfOutputs: numOfOutputs [
	"Create a neural network with two hidden layers."
	
	| random |
	random := Random seed: 42.
	self addLayer: (NeuronLayer new 
		initializeNumOfNeurons: numOfNeurons1 numOfWeights: numOfInputs using: random).
	self addLayer: (NeuronLayer new 
		initializeNumOfNeurons: numOfNeurons2 numOfWeights: numOfNeurons1 using: random).
	self addLayer: (NeuronLayer new 
		initializeNumOfNeurons: numOfOutputs numOfWeights: numOfNeurons2 using: random).
]

{ #category : #configuring }
NeuralNet >> configure: numOfInputs hidden: numOfNeurons numOfOutputs: numOfOutputs [
	"Create a neural network with only one hidden layer."
	
	| random |
	random := Random seed: 42.
	self addLayer: (NeuronLayer new 
		initializeNumOfNeurons: numOfNeurons numOfWeights: numOfInputs using: random).
	self addLayer: (NeuronLayer new 
		initializeNumOfNeurons: numOfOutputs numOfWeights: numOfNeurons using: random).
]

{ #category : #computing }
NeuralNet >> feed: inputValues [
	"Feed the first hidden layer with the provided inputs."
	"This layer will recursively feed-forward its outputs."
	"The response will be the output of the last hidden layer."
	
	^ layers first feed: inputValues 
]

{ #category : #initialization }
NeuralNet >> initialize [ 
	super initialize .
	layers := OrderedCollection new.
	errors := OrderedCollection new.
	precisions := OrderedCollection new.
]

{ #category : #configuring }
NeuralNet >> learningRate [
	"Get the learning rate; assumes that all layers were set to the same value."
	
	^ layers anyOne learningRate
]

{ #category : #configuring }
NeuralNet >> learningRate: aLearningRate [ 
	"Set the learning rate for all the layers (to the same value)."
	
	layers do: [ :layer | 
		layer learningRate: aLearningRate ]
]

{ #category : #configuring }
NeuralNet >> loadIrisData [ 
	"Load the Iris data set from a CSV file in the cloud."
	
	| irisCSV lines tLines irisData |
	irisCSV := (ZnEasy 
		get: 'https://agileartificialintelligence.github.io/Datasets/iris.csv') 
		contents.
	lines := irisCSV lines.
	lines := lines allButFirst .
	tLines := lines collect: [ :line | 
		| ss |
		ss := line substrings: ','.
		(ss allButLast collect: [ :word | word asNumber ] ) , 
			(Array with: ss last) .
		].
	irisData := tLines collect: [ :row | 
		| name |
		name := #(-1).
		row last = 'setosa' ifTrue: [ name := #(0) ].
		row last = 'versicolor' ifTrue: [ name := #(1) ].
		row last = 'virginica' ifTrue: [ name := #(2) ].
		row allButLast , name ].
	^ irisData
]

{ #category : #configuring }
NeuralNet >> numberOfInputs [ 
	"Respond with the number of inputs (neurons) in the first layer."
	
	^ layers first neurons size
]

{ #category : #configuring }
NeuralNet >> numberOfNeurons [ 
	"Respond with the total number of neurons in the network."
	
	^ (layers collect: #numberOfNeurons) sum
]

{ #category : #configuring }
NeuralNet >> numberOfOutputs [ 
	"Respond with the number of outputs (neurons) in the output layer."
	
	^ self outputLayer numberOfNeurons 
]

{ #category : #configuring }
NeuralNet >> outputLayer [
	
	^ layers last
]

{ #category : #computing }
NeuralNet >> predict: inputs [
	"Make a prediction based on the inputs."
	"The prediction is the largest probability in the output set."
	"Note that Pharo Collections start with '1', so we need to offset the index."
	
	| outputs |
	outputs := self feed: inputs .
	^ (outputs indexOf: (outputs max)) - 1 
]

{ #category : #computing }
NeuralNet >> train: rawTrainingSet numOfEpochs: numOfEpochs [
	"Train the NN using the training set for the number of epochs."
	
	| sumErr outputs expOutput epochPrec thisErr trainingSet |
	trainingSet := Normalization new normalizeData: rawTrainingSet .
	1 to: numOfEpochs do: [ :epoch |
		sumErr := 0.
		epochPrec := 0.
		trainingSet do: [ :row | 
			outputs := self feed: row allButLast.
			expOutput := (1 to: self numberOfOutputs) collect: [ :notUsed | 0 ].
			expOutput at: (row last + 1) put: 1.
			(row last = (self predict: row allButLast))
				ifTrue: [ epochPrec := epochPrec + 1 ].
			thisErr := (1 to: expOutput size) collect: [ :i |
				((expOutput at: i) - (outputs at: i)) squared ].
			sumErr := sumErr + thisErr sum.
			self backPropagateError: expOutput.
			self updateWeight: row allButLast.
			].
		errors add: sumErr.
		precisions add: (epochPrec / trainingSet size) asFloat.
		].
	
]

{ #category : #computing }
NeuralNet >> train: inputs targetOutputs: targetOutputs [ 
	"Train the neural network with a set of inputs and their target outputs."
	
	self feed: inputs.
	self backPropagateError: targetOutputs.
	self updateWeight: inputs 
]

{ #category : #computing }
NeuralNet >> updateWeight: initialInputs [ 
	"Update the weights of all the neurons in all layers, using the initial inputs."
	"This method begins a recursive call to propagate through the layers."
	"(Note that the message below is a *different* message, called on *layers*.)"
	
	layers first updateWeight: initialInputs
]

{ #category : #viewing }
NeuralNet >> viewLearningCurve [
	"Draw the error curve and precision curve."
	
	| b ds |
	errors ifEmpty: [ 
		^ RTView new 
			add: (RTLabel elementOn: 'Should first run the network!');
			yourself 
		].
	b := RTDoubleGrapher new.
	b extent: 500 @ 300.
	
	ds := RTData new.
	ds samplingIfMoreThan: 2000.
	ds noDot; connectColor: Color blue.
	ds points: (errors collectWithIndex: [ :y :i | i -> y ] ).
	ds x: #key; y: #value.
	ds dotShape rectangle color: Color blue.
	b add: ds.
	
	ds := RTData new.
	ds samplingIfMoreThan: 2000.
	ds noDot; connectColor: Color red.
	ds points: (precisions collectWithIndex: [ :y :i | i -> y ] ).
	ds x: #key; y: #value.
	ds dotShape rectangle color: Color red.
	
	b addRight: ds.
	b axisX noDecimal; title: 'Epoch'.
	b axisY title: 'Error'.
	b axisYRight title: 'Precision'; color: Color red.
	
	b title: 'Learning rate ', self learningRate asString.
	
	^ b open
]

{ #category : #viewing }
NeuralNet >> viewLearningCurveIn: composite [ 

	<gtInspectorPresentationOrder: -10>
	composite roassal2 
		title: 'Learning';
		initializeView: [ self viewLearningCurve ]
]

{ #category : #viewing }
NeuralNet >> viewNetwork [
	"Create a graphical image of the network topology."
	
	| b lb |
	b := RTMondrian new.
	b nodes: layers forEach: [ :layer | 
		b shape circle size: 20.
		b nodes: layer neurons.
		b layout verticalLine.
		].
	b shape arrowedLine; withShorterDistanceAttachPoint .
	b edges connectTo: #nextLayer.
	b layout horizontalLine gapSize: 30; center.
	b build.
	
	lb := RTLegendBuilder new.
	lb view: b view.
	lb addText: self numberOfNeurons asString, ' neurons'.
	lb addText: self numberOfInputs asString, ' inputs'.
	lb build.
	
	^ b view
]

{ #category : #viewing }
NeuralNet >> viewNetworkIn: composite [ 

	<gtInspectorPresentationOrder: -5>
	composite roassal2 
		title: 'Network';
		initializeView: [ self viewNetwork ]
]
