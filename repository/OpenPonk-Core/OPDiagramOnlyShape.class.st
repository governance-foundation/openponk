Class {
	#name : #OPDiagramOnlyShape,
	#superclass : #OPShape,
	#traits : 'OPTDIBorderColoredAsStroke - {#updateRenderFromStyles}',
	#classTraits : 'OPTDIBorderColoredAsStroke classTrait',
	#instVars : [
		'uuid'
	],
	#category : #'OpenPonk-Core-CommonElements'
}

{ #category : #accessing }
OPDiagramOnlyShape class >> neoJsonMapping: mapper [

	mapper
		for: self do: [ :mapping | 
			mapping mapInstVars: self stonAllInstVarNames.
			(mapping mapInstVar: #uuid) valueSchema: UUID.
			mapping
				mapProperty: #className
				getter: [ :object | object className ]
				setter: [ :object :value | 
					object assert: object className = value ] ];
		for: UUID customDo: [ :mapping | 
			mapping
				encoder: [ :uuid | uuid asString ];
				decoder: [ :string | 
					[ UUID fromString: string ]
						on: Error
						do: [ string ] ] ]
]

{ #category : #'ston-core' }
OPDiagramOnlyShape class >> stonAllInstVarNames [

	"Override to encode my instances using a custom set of instance variables or to define their order."

	^ super stonAllInstVarNames , #( #uuid )
]

{ #category : #accessing }
OPDiagramOnlyShape >> announcer [

	^ roassalShape ifNotNil: #announcer
]

{ #category : #accessing }
OPDiagramOnlyShape >> initialize [

	super initialize.
	uuid := UUID new
]

{ #category : #accessing }
OPDiagramOnlyShape >> modelElements [

	^ { self }
]

{ #category : #accessing }
OPDiagramOnlyShape >> modelElements: aCollection [

	(aCollection noneSatisfy: [ :any | any ~= self ]) ifTrue: [ ^ self ].
	self shouldNotImplement
]

{ #category : #accessing }
OPDiagramOnlyShape >> strokeColor: aColor [

	"ignore for now"
]

{ #category : #rendering }
OPDiagramOnlyShape >> updateRenderFromModel [

	"do nothing - there is no model"
]

{ #category : #accessing }
OPDiagramOnlyShape >> uuid [

	^ uuid
]
