"
A DCController is the parent class to all controller classes.
"
Class {
	#name : #OPController,
	#superclass : #Object,
	#instVars : [
		'model',
		'selectionHolder',
		'diagramController'
	],
	#category : 'OpenPonk-Core-Controllers'
}

{ #category : #accessing }
OPController class >> modelClass [
	^ self new modelClass
]

{ #category : #connecting }
OPController >> addAsSourceFor: aController [
	(self canBeSourceFor: aController)
		ifFalse: [ self error: self class asString , ' cannot be source for ' , aController class asString ].
	aController sourceController: self
]

{ #category : #connecting }
OPController >> addAsTargetFor: aController [
	(self canBeTargetFor: aController)
		ifFalse: [ self error: self class asString , ' cannot be target for ' , aController class asString ].
	aController createModelIn: self model andShowInDiagram: self diagramController
]

{ #category : #accessing }
OPController >> allOwnedElementsInModel: aModel [
	^ #()
]

{ #category : #forms }
OPController >> buildEditorForm: aForm [
	aForm fromMagritteDescriptions: self magritteDescription
]

{ #category : #connecting }
OPController >> canBeSourceFor: aController [
	^ false
]

{ #category : #connecting }
OPController >> canBeTargetFor: aController [
	^ false
]

{ #category : #forms }
OPController >> descriptionAccessor: aSymbol [
	^ MAPluggableAccessor
		read: [ :me | me model perform: aSymbol ]
		write: [ :me :newValue | 
			me model perform: aSymbol asMutator with: newValue.
			self modelChanged ]
]

{ #category : #forms }
OPController >> descriptionName [
	<magritteDescription>
	| accessor |
	accessor := MAPluggableAccessor
		read: [ :me | me model name ]
		write: [ :me :newValue | 
			me model name: newValue.
			self refreshFigure ].
	^ MAStringDescription new
		accessor: accessor;
		label: 'Name';
		priority: 1;
		yourself
]

{ #category : #accessing }
OPController >> diagramController [
	^ diagramController
]

{ #category : #accessing }
OPController >> diagramController: aDiagramController [
	diagramController := aDiagramController
]

{ #category : #figures }
OPController >> figure [
	^ self subclassResponsibility
]

{ #category : #figures }
OPController >> figureDoubleClicked [
	"do nothing by default"
]

{ #category : #'canvas actions' }
OPController >> hideSelectionFeedback [
	"by default do nothing"

	
]

{ #category : #announcements }
OPController >> internalSubscribeTo: aModel [
	aModel announcer when: OPElementRenamed do: [ self refreshFigure ]
]

{ #category : #announcements }
OPController >> internalUnsubscribeFrom: aModel [
	aModel announcer unsubscribe: self
]

{ #category : #accessing }
OPController >> layout [
	^ nil
]

{ #category : #accessing }
OPController >> layout: anObject [
	
]

{ #category : #accessing }
OPController >> model [
	^ model
]

{ #category : #accessing }
OPController >> model: aModel [
	model ifNotNil: [ :m | self internalUnsubscribeFrom: m ].
	model := aModel.
	model ifNotNil: [ :m | self internalSubscribeTo: m ]
]

{ #category : #announcements }
OPController >> modelChanged [
	self figure ifNotNil: [ self refreshFigure ]
]

{ #category : #accessing }
OPController >> modelClass [
	^ self subclassResponsibility
]

{ #category : #figures }
OPController >> refreshFigure [
	self figure trachelShape triggerCallbacksForStep: 0 @ 0.
	self figure signalUpdate
]

{ #category : #deprecated }
OPController >> registerModelEvents: aModel [
	self deprecated: 'use model: and internalSubscribeTo: instead'.
	aModel announcer
		when: OPElementRemoved
		do: [ :event | 
			self diagramController removeControllerOf: event element.
			self diagramController updateView ]
]

{ #category : #deprecated }
OPController >> remove [
	self deprecated: 'Use removeController instead.'.
	model ifNotNil: [ model announcer unsubscribe: self ]
]

{ #category : #destruction }
OPController >> removeController [
	self diagramController ifNil: [ ^ self ].
	self removeOwnedControllers.
	self removeFigure.
	self model: nil.
	self diagramController removeController: self
]

{ #category : #destruction }
OPController >> removeFigure [
	self diagramController deselectAll.
	self figure view ifNotNil: [ self figure remove ]
]

{ #category : #destruction }
OPController >> removeFull [
	self removeModel.
	self removeController.
]

{ #category : #destruction }
OPController >> removeModel [
	^ self subclassResponsibility
]

{ #category : #deprecated }
OPController >> removeModelElement: aModelElement [
	"Remove self as target of aModelElement"
	self deprecated: 'use #removeModel on the proper controller instead.'.

	self subclassResponsibility
]

{ #category : #destruction }
OPController >> removeOwnedControllers [
	(self allOwnedElementsInModel: self model)
		do: [ :each | 
			self diagramController controllers
				detect: [ :ctrl | ctrl model = each ]
				ifFound: #removeController ]
]

{ #category : #construction }
OPController >> renderFigureIn: aView [
	^ self subclassResponsibility
]

{ #category : #figures }
OPController >> saveStateOnDragEndFor: aFigure [
	aFigure when: TRMouseDragEnd do: [ :evt | self diagramController saveState ]
]

{ #category : #'canvas actions' }
OPController >> showAcceptFeedbackFor: aController [
	"Return something that understands #remove, or nil to not show any feedback."

	^ OPAcceptDenyFeedbackBuilder acceptFeedbackFor: self figure
]

{ #category : #'canvas actions' }
OPController >> showDenyFeedbackFor: aController [
	"Return something that understands #remove, or nil to not show any feedback."

	^ OPAcceptDenyFeedbackBuilder denyFeedbackFor: self figure
]

{ #category : #construction }
OPController >> showInDiagram: aDiagramController [
	self subclassResponsibility
]

{ #category : #'canvas actions' }
OPController >> showSelectionFeedback [
	"by default do nothing"

	
]