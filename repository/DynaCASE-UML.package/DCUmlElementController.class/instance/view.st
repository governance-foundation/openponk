accessing
view
	^ view ifNil: [ view := viewBlock value ]