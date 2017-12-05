tests
testRoundTrip
	| root loaded zipFile |
	root := FileSystem memory root.
	(root / 'dir') ensureCreateDirectory.
	root / 'dir' / 'file.txt' writeStreamDo: [ :stream | stream << 'hello' ].
	zipFile := (FileSystem memory / 'project.zip') ensureCreateFile.
	persistence save: root to: zipFile.
	loaded := persistence loadFrom: zipFile.
	self assert: (loaded / 'dir') isDirectory.
	self assert: (loaded / 'dir' / 'file.txt') isFile.
	self assert: (loaded / 'dir' / 'file.txt') contents equals: 'hello'