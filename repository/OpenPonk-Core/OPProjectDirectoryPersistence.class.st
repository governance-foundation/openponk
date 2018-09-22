"
My job is to store a project with all the plugins into a provided directory.
"
Class {
	#name : #OPProjectDirectoryPersistence,
	#superclass : #Object,
	#category : 'OpenPonk-Core-Persistence'
}

{ #category : #accessing }
OPProjectDirectoryPersistence >> exporter [
	^ 'OpenPonk'
]

{ #category : #accessing }
OPProjectDirectoryPersistence >> exporterVersion [
	^ OPVersion version
]

{ #category : #writing }
OPProjectDirectoryPersistence >> modelReferencesToJson: models [
	| references |
	references := models asArray
		collect: [ :each | 
			| plugin |
			plugin := OPPluginRegistry default pluginFor: each.
			{'uuid' -> each uuid asString.
			'plugin' -> plugin className.
			'pluginVersion' -> plugin version} asDictionary ].
	^ STON toJsonStringPretty: references
]

{ #category : #writing }
OPProjectDirectoryPersistence >> projectToJson: aProject [
	^ STON
		toJsonStringPretty:
			{'project'
				->
					{'name' -> aProject name.
					'uuid' -> aProject uuid asString} asDictionary.
			'exporter'
				->
					{'exporter' -> self exporter.
					'exporterVersion' -> self exporterVersion.
					'timestamp' -> DateAndTime now truncated asString} asDictionary} asDictionary
]

{ #category : #saving }
OPProjectDirectoryPersistence >> removeModelsNotIn: aCollection from: aFolder [
	| toDelete ids |
	ids := aCollection collect: [ :each | each uuid asString ].
	toDelete := aFolder children reject: [ :each | ids includes: each basename ].
	toDelete
		do: [ :each | 
			each files do: #delete.
			each delete ]
]

{ #category : #saving }
OPProjectDirectoryPersistence >> saveMemento: aMemento to: aRoot with: aSerializer [
	| folder |
	folder := aRoot / aMemento uuid asString.
	folder ensureCreateDirectory.
	aSerializer saveMemento: aMemento to: folder
]

{ #category : #saving }
OPProjectDirectoryPersistence >> saveMementos: aCollection to: aFolder [
	aCollection
		do: [ :each | 
			self
				saveMemento: each
				to: aFolder / 'models'
				with: (OPPluginRegistry default pluginFor: each model) serializerClass new ]
]

{ #category : #saving }
OPProjectDirectoryPersistence >> saveProject: aProject to: aFolder [
	aFolder ensureCreateDirectory.
	(aFolder / 'models') ensureCreateDirectory.
	(aFolder / '.history' / 'models') ensureCreateDirectory.
	(aFolder / 'project.json')
		ensureDelete;
		writeStreamDo: [ :stream | stream << (self projectToJson: aProject) ].
	(aFolder / 'models.json')
		ensureDelete;
		writeStreamDo: [ :stream | stream << (self modelReferencesToJson: aProject models) ]
]

{ #category : #'public - saving' }
OPProjectDirectoryPersistence >> saveProject: aProject withMementos: aCollection to: aFolder [
	self saveProject: aProject to: aFolder asFileReference.
	self removeModelsNotIn: aCollection from: aFolder / 'models'.
	self saveMementos: aCollection to: aFolder asFileReference
]