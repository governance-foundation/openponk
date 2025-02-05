Class {
	#name : #OPDiagramElement,
	#superclass : #Object,
	#instVars : [
		'modelElements',
		'owningElement',
		'targetEdges',
		'sourceEdges',
		'sharedStyle',
		'localStyle',
		'ownedElements',
		'roassalShape'
	],
	#category : #'OpenPonk-Core-DiagramInterchange'
}

{ #category : #rendering }
OPDiagramElement class >> forModelElement: anObject [

	^ self new
		  modelElement: anObject;
		  yourself
]

{ #category : #rendering }
OPDiagramElement class >> in: anOwner [

	^ self new
		  owningElement: anOwner;
		  yourself
]

{ #category : #rendering }
OPDiagramElement class >> in: anOwner forModelElement: anObject [

	^ self new
		  modelElement: anObject;
		  owningElement: anOwner;
		  yourself
]

{ #category : #testing }
OPDiagramElement class >> isAbstract [
	^ self = OPDiagramElement
]

{ #category : #rendering }
OPDiagramElement class >> renderForController: aController [

	^ self new
		  modelElement: aController model;
		  renderIn: aController diagramController canvas;
		  yourself
]

{ #category : #'ston-core' }
OPDiagramElement class >> stonAllInstVarNames [

	"Override to encode my instances using a custom set of instance variables or to define their order."

	^ #( #modelElements #owningElement #targetEdges #sourceEdges
	     #sharedStyle #localStyle #ownedElements )
]

{ #category : #'as yet unclassified' }
OPDiagramElement >> addedByMouseClickTo: aPoint [

	"Do nothing by default. The given point is position where user clicked by mouse in order to create the element. If the shape was not added by a mouse click, this method is not called. May be overriden to translate to that position or react in any other way."

	
]

{ #category : #'as yet unclassified' }
OPDiagramElement >> allOwnedShapesPositionableByUser [

	self isRendered ifFalse: [ ^ #(  ) ].
	^ self ownedElements flatCollect: #allOwnedShapesPositionableByUser
]

{ #category : #'as yet unclassified' }
OPDiagramElement >> allShapesPositionableByUser [

	^ self topMostOwningElement allOwnedShapesPositionableByUser
]

{ #category : #accessing }
OPDiagramElement >> canvas [

	^ roassalShape canvas
]

{ #category : #initialization }
OPDiagramElement >> createOwnedElementsWithoutController [

	"Might be overriden to add owned diagram elements that have no controller that would create them, for example labels. Make sure these do not exist yet (that could produce them multiple times)"

	
]

{ #category : #'instance creation' }
OPDiagramElement >> fromSton: stonReader [

	stonReader parseMapDo: [ :instVarName :value | 
		instVarName = #modelElements
			ifTrue: [ 
				self modelElements: (value collect: [ :each | 
						 OPModelObjectReference withUUID: ([ UUID fromString: each ]
								  on: Error
								  do: [ each ]) ]) ]
			ifFalse: [ self instVarNamed: instVarName asString put: value ] ]
]

{ #category : #initialization }
OPDiagramElement >> initialize [

	super initialize.
	modelElements := #(  ).
	ownedElements := SRToManyLink
		                 on: self
		                 slot: #ownedElements
		                 oppositeSlot: #owningElement.
	sourceEdges := SRToManyLink
		               on: self
		               slot: #sourceEdges
		               oppositeSlot: #source.
	targetEdges := SRToManyLink
		               on: self
		               slot: #targetEdges
		               oppositeSlot: #target
]

{ #category : #testing }
OPDiagramElement >> isPositionableByUser [

	^ false
]

{ #category : #rendering }
OPDiagramElement >> isRendered [

	^ roassalShape isNotNil and: [ roassalShape isInACanvas ]
]

{ #category : #rendering }
OPDiagramElement >> isRenderedWithOwnedElements [

	^ self isRendered and: [ 
		  self ownedElements allSatisfy: [ :each | 
			  each isRenderedWithOwnedElements ] ]
]

{ #category : #testing }
OPDiagramElement >> isSelectable [

	^ roassalShape isSelectable
]

{ #category : #accessing }
OPDiagramElement >> localStyle [
	^ localStyle
]

{ #category : #accessing }
OPDiagramElement >> localStyle: aStyle [

	localStyle ifNotNil: [ localStyle removedFromStyledElement: self ].
	(localStyle := aStyle) addedAsLocalToStyledElement: self.
	self styleChanged.
]

{ #category : #accessing }
OPDiagramElement >> model [

	self
		deprecated: 'Use #modelElement instead'
		transformWith: '`@receiver model' -> '`@receiver modelElement'.
	^ self modelElement
]

{ #category : #initialization }
OPDiagramElement >> modelChanged [

	self isRendered ifTrue: [ self updateRenderFromModel ]
]

{ #category : #accessing }
OPDiagramElement >> modelElement [

	^ self ownModelElement ifNil: [ self owningElement ifNotNil: #modelElement ]
		  
]

{ #category : #accessing }
OPDiagramElement >> modelElement: anObject [

	anObject ifNil: [ ^ self modelElements: #(  ) ].
	self modelElements: { anObject }
]

{ #category : #accessing }
OPDiagramElement >> modelElements [

	^ modelElements
]

{ #category : #accessing }
OPDiagramElement >> modelElements: aCollection [

	(self owningElement isNotNil and: [ 
		 aCollection includes: self owningElement modelElement ]) ifTrue: [ 
		aCollection size > 1 ifTrue: [ 
			self error: 'Cannot have same modelElement as owningElement has' ].
		^ self modelElement: nil ].

	modelElements := aCollection
]

{ #category : #testing }
OPDiagramElement >> movesWithOtherShape [

	^ false
]

{ #category : #accessing }
OPDiagramElement >> ownModelElement [

	^ self modelElements ifEmpty: [ nil ] ifNotEmpty: #first
]

{ #category : #initialization }
OPDiagramElement >> ownedElement: aShape renderedIn: aCanvas [

	self isRendered ifTrue: [ 
		self
			assert: roassalShape canvas = aCanvas
			description:
			'Reusing same diagram element for 2 canvases not allowed'.
		^ self owningElement ifNotNil: [ :owner | 
			  owner ownedElement: aShape renderedIn: aCanvas ] ].
	self renderIn: aCanvas
]

{ #category : #accessing }
OPDiagramElement >> ownedElements [
	^ ownedElements
]

{ #category : #accessing }
OPDiagramElement >> ownedElements: aCollection [

	ownedElements
		removeAll;
		addAll: aCollection
]

{ #category : #accessing }
OPDiagramElement >> owningElement [
	^ owningElement
]

{ #category : #accessing }
OPDiagramElement >> owningElement: aDiagramElement [

	(aDiagramElement isNotNil and: [ 
		 self modelElements includes: aDiagramElement modelElement ]) 
		ifTrue: [ 
			self modelElements size > 1 ifTrue: [ 
				self error: 'Cannot have same modelElement as owningElement has' ].
			self modelElement: nil ].
	owningElement := SRToOneLink
		                 on: self
		                 slot: #owningElement
		                 oppositeSlot: #ownedElements
		                 updateFrom: owningElement
		                 to: aDiagramElement
]

{ #category : #removing }
OPDiagramElement >> remove [

	[ self ownedElements isNotEmpty ] whileTrue: [
		self ownedElements anyOne remove ].
	self removeRender.
	self owningElement: nil
]

{ #category : #removing }
OPDiagramElement >> removeRender [

	self ownedElements do: #removeRender.
	roassalShape ifNil: [ ^ self ].
	roassalShape remove.
	roassalShape := nil
]

{ #category : #rendering }
OPDiagramElement >> renderBasicShape [

	"should render a simple shape without any interactivity and complexity (for example for outlining the shape when being created before it is fully added)"

	^ self subclassResponsibility
]

{ #category : #rendering }
OPDiagramElement >> renderBasicShapeIn: aCanvas [

	self isRendered ifTrue: [ 
		roassalShape canvas = aCanvas ifFalse: [ 
			self error:
				'Reusing same diagram element for 2 canvases not allowed' ].
		^ self ].
	roassalShape := self renderBasicShape.
	roassalShape model: self.
	aCanvas add: roassalShape.
	^ roassalShape
]

{ #category : #rendering }
OPDiagramElement >> renderIn: aCanvas [

	self isRendered ifTrue: [ ^ self ].
	self renderBasicShapeIn: aCanvas.
	self renderShapeDetails.
	self createOwnedElementsWithoutController.
	self ownedElements do: [ :each | each renderIn: aCanvas ].
	self updateRenderFromModel.
	self updateRenderFromSelf.
	self owningElement ifNotNil: [ :element | 
		element ownedElement: self renderedIn: self canvas ].
	^ roassalShape
]

{ #category : #rendering }
OPDiagramElement >> renderShapeDetails [

	"Should render details of a shape created by renderBasicShape. This method is there to add interactivity and complexity like adding labels, actions on click etc. that have no own diagram elements (that labels usually have!)."

	"do nothing by default"

	
]

{ #category : #serialization }
OPDiagramElement >> resolveAllModelElements: aDictionary [

	self resolveModelElements: aDictionary.
	self ownedElements do: [ :each | 
		each resolveAllModelElements: aDictionary ]
]

{ #category : #serialization }
OPDiagramElement >> resolveModelElements: aDictionary [

	self modelElements: (self modelElements collect: [ :each | 
			 each modelObjectFrom: aDictionary ])
]

{ #category : #rendering }
OPDiagramElement >> roassalShape [

	^ roassalShape
]

{ #category : #accessing }
OPDiagramElement >> sharedStyle [
	^ sharedStyle ifNil: [ self owningElement ifNotNil: #sharedStyle ]
]

{ #category : #accessing }
OPDiagramElement >> sharedStyle: aStyle [

	sharedStyle ifNotNil: [ sharedStyle removedFromStyledElement: self ].
	(sharedStyle := aStyle) addedAsSharedToStyledElement: self.
	self styleChanged.
]

{ #category : #accessing }
OPDiagramElement >> sourceEdges [
	^ sourceEdges
]

{ #category : #accessing }
OPDiagramElement >> sourceEdges: aCollection [
	sourceEdges
		removeAll;
		addAll: aCollection
]

{ #category : #'ston persistence' }
OPDiagramElement >> stonOn: stonWriter [

	stonWriter writeObject: self streamMap: [ :dictionary | 
		self class stonAllInstVarNames do: [ :each | 
			| value |
			value := self instVarNamed: each.
			each = #modelElements ifTrue: [ 
				value := modelElements collect: [ :eachModelElement | 
					         eachModelElement uuid asString ] ].
			(value isKindOf: SRToManyLink) ifTrue: [ 
				value := Array withAll: value ].
			value ifNotNil: [ dictionary at: each asSymbol put: value ] ] ]
]

{ #category : #initialization }
OPDiagramElement >> stonPostReferenceResolution [

	"Hook that is called when references were resolved processing this object or one of its sub objects. This will most probably influence hash values. Override to take appropriate action."

	ownedElements := (SRToManyLink
		                  on: self
		                  slot: #ownedElements
		                  oppositeSlot: #owningElement)
		                 addAll: ownedElements;
		                 yourself.
	sourceEdges := (SRToManyLink
		                on: self
		                slot: #sourceEdges
		                oppositeSlot: #source)
		               addAll: sourceEdges;
		               yourself.
	targetEdges := (SRToManyLink
		                on: self
		                slot: #targetEdges
		                oppositeSlot: #target)
		               addAll: targetEdges;
		               yourself
]

{ #category : #'instance creation' }
OPDiagramElement >> stonProcessSubObjects: block [

	"Execute block to (potentially) change each of my subObjects.
	In general, all instance and indexable variables are processed.
	Overwrite when necessary. Not used when #stonContainSubObjects returns false."

	self class stonAllInstVarNames do: [ :each | 
		self
			instVarNamed: each
			put: (block value: (self instVarNamed: each)) ]
]

{ #category : #initialization }
OPDiagramElement >> styleChanged [

	self isRendered ifTrue: [ self updateRenderFromStyles ]
]

{ #category : #accessing }
OPDiagramElement >> stylePropertyNamed: aName ifAbsent: aBlock [

	| nameSymbol |
	nameSymbol := aName asSymbol.
	self localStyle ifNotNil: [ :style | 
		style at: nameSymbol ifPresent: [ :value | ^ value ] ].
	self sharedStyle ifNotNil: [ :style | 
		style at: nameSymbol ifPresent: [ :value | ^ value ] ].
	self owningElement ifNotNil: [ :owner | 
		^ owner stylePropertyNamed: nameSymbol ifAbsent: aBlock ].
	^ aBlock value
]

{ #category : #accessing }
OPDiagramElement >> stylePropertyNamed: aName put: aValue [

	self localStyle ifNil: [ self localStyle: OPDIOpenPonkStyle new ].
	self localStyle at: aName asSymbol put: aValue
]

{ #category : #initialization }
OPDiagramElement >> supportsColorChange [

	^ (self respondsTo: #color) and: [ self respondsTo: #color: ]
]

{ #category : #accessing }
OPDiagramElement >> targetEdges [
	^ targetEdges
]

{ #category : #accessing }
OPDiagramElement >> targetEdges: aCollection [
	targetEdges
		removeAll;
		addAll: aCollection
]

{ #category : #initialization }
OPDiagramElement >> topMostOwningElement [

	^ self owningElement
		  ifNil: [ self ]
		  ifNotNil: [ :owner | owner topMostOwningElement ]
]

{ #category : #initialization }
OPDiagramElement >> updateFromRender [

	self ownedElements do: #updateFromRender
]

{ #category : #rendering }
OPDiagramElement >> updateRenderFromModel [

	self ownedElements select: #isRendered thenDo: #updateRenderFromModel.
	self updateRenderFromStyles
]

{ #category : #rendering }
OPDiagramElement >> updateRenderFromSelf [

	self isRendered ifFalse: [ ^ self ].
	self ownedElements do: #updateRenderFromSelf.
	roassalShape signalUpdate
]

{ #category : #initialization }
OPDiagramElement >> updateRenderFromStyles [

	"do nothing by default"

	
]
