selection handling
viewElementClicked: anElement
	selectedItemType = #form
		ifTrue: [ 
			| controller |
			controller := diagramController findControllerByView: anElement.
			self formModel editController: controller ].
	selectedItemType = #delete
		ifTrue: [ 
			| controller |
			controller := diagramController findControllerByView: anElement.
			diagram remove: controller model.
			self cancelSelection ].
	selectedItemType = #edge
		ifTrue: [ 
			selectedItem
				ifNotNil: [ 
					selectedElement
						ifNil: [ 
							selectedElement := anElement.
							interactiveLine := (DCInteractiveLine lineInfo: selectedItem lineInfo from: selectedElement on: diagramController)
								attachTo: selectedElement.
							self statusModel text: 'Click on the second of two elements to connect them.' ]
						ifNotNil: [ 
							| relation fromElement toElement relationController |
							fromElement := (diagramController findControllerByView: selectedElement) model.
							toElement := (diagramController findControllerByView: anElement) model.
							relation := selectedItem from: fromElement to: toElement.
							diagram add: relation.
							diagramController updateView.
							relationController := diagramController findControllerByModel: relation.
							relationController view
								when: TRMouseLeftClick
								do: [ :event | self viewEdgeClicked: relationController view	"event element" ].
							self cancelSelection.
							self statusModel text: '' ] ] ]