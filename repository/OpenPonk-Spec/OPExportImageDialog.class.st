Class {
	#name : #OPExportImageDialog,
	#superclass : #StFBSaveFileDialog,
	#instVars : [
		'zoomLabel',
		'zoomText',
		'zoomPercentageLabel'
	],
	#category : #'OpenPonk-Spec-Dialogs'
}

{ #category : #'as yet unclassified' }
OPExportImageDialog class >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: (SpPanedLayout newLeftToRight
				   positionOfSlider: 200;
				   add: #bookmarksTreeTable;
				   add: #fileNavigationSystem;
				   yourself);
		  add: (SpBoxLayout newLeftToRight
				   add: SpNullPresenter new;
				   add: #zoomLabel expand: false;
				   add: #zoomText expand: false;
				   add: #zoomPercentageLabel expand: false;
				   yourself)
		  expand: false;
		  yourself
]

{ #category : #actions }
OPExportImageDialog >> confirmed [

	| zoomNumber file |
	file := self selectedEntry.
	file ifNil: [ ^ self ].
	zoomNumber := (NumberParser
		               parse: zoomText text
		               onError: [ 
		               TRCamera basicNew defaultCameraScale * 100 ]) / 100.
	zoomNumber < 0.01 ifTrue: [ 
		zoomNumber := TRCamera basicNew defaultCameraScale ].

	okAction cull: file cull: zoomNumber
]

{ #category : #actions }
OPExportImageDialog >> connectPresenters [

	super connectPresenters.
	self initializeZoom
]

{ #category : #actions }
OPExportImageDialog >> initializePresenters [

	super initializePresenters.
	(zoomLabel := self newLabel) label: 'Zoom: '.
	zoomText := self newTextInput.
	(zoomPercentageLabel := self newLabel) label: ' %'
]

{ #category : #initialization }
OPExportImageDialog >> initializeZoom [

	zoomText
		text: '100';
		whenTextChangedDo: [ :text | 
			| digits |
			digits := text select: #isDigit.
			zoomText text: (digits first: (4 min: digits size)) ]
]

{ #category : #accessing }
OPExportImageDialog >> zoomLabel [

	^ zoomLabel
]

{ #category : #accessing }
OPExportImageDialog >> zoomPercentageLabel [

	^ zoomPercentageLabel
]

{ #category : #accessing }
OPExportImageDialog >> zoomText [

	^ zoomText
]
