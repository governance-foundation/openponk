Extension { #name : #TRMorph }

{ #category : #'*OpenPonk-Roassal2' }
TRMorph >> resetShapeBeingPointed [

	| relativePosition ee |
	"Reset the pointed shape - used by OPRTStyledConnection to continue dragging event after the underlying shape has changed."
	relativePosition := self relativePositionFor: eventBeginingDragging.
	shapeBeingPointed := self
		                     shapeWithAction: TRMouseDragging
		                     forPositionInPixels: relativePosition.
	ee := TRMouseDragStart new.
	ee shape: shapeBeingPointed.
	ee position: relativePosition.
	ee canvas: trachelCanvas.
	ee morph: self.
	shapeBeingPointed announce: ee
]
