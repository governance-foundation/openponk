selection handling
cancelFocus
	focusedElement
		ifNotNil: [ 
			focusedElement announce: DCTRUnfocused.
			focusedElement := nil ]