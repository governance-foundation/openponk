Class {
	#name : #OPRTOrthogonalAttachPoint,
	#superclass : #OPRTNewRectangleAttachPoint,
	#category : #'OpenPonk-Roassal2-Connection'
}

{ #category : #'as yet unclassified' }
OPRTOrthogonalAttachPoint >> attachPointFor: anEdge from: fromRect to: toRect [

	| fromPoint toPoint |
	anEdge shape points ifEmpty: [ 
		^ super attachPointFor: anEdge from: fromRect to: toRect ].
	toPoint := toRect center.
	((toPoint x between: fromRect left and: fromRect right) xor: [ 
		 toPoint y between: fromRect top and: fromRect bottom ]) ifFalse: [ 
		^ super attachPointFor: anEdge from: fromRect to: toRect ].
	(toPoint x between: fromRect left and: fromRect right) ifTrue: [ 
		fromPoint := (Array
			              with: toPoint x @ fromRect top
			              with: toPoint x @ fromRect bottom) detectMin: [ :each | 
			             each distanceTo: toPoint ] ].
	(toPoint y between: fromRect top and: fromRect bottom) ifTrue: [ 
		fromPoint := (Array
			              with: fromRect left @ toPoint y
			              with: fromRect right @ toPoint y) detectMin: [ :each | 
			             each distanceTo: toPoint ] ].
	^ fromPoint ifNil: [ self error ]
]
