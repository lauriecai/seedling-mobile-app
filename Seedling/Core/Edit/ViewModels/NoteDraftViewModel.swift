//
//  NoteDraftViewModel.swift
//  Seedling
//

import Foundation

@MainActor
class NoteDraftViewModel: ObservableObject {

	@Published var titleInput: String = ""
	@Published var bodyInput: String = ""

	@Published var editingExistingNote: Bool = false
	@Published var noteEdited: Bool = false

	private let coreDataManager = CoreDataManager.shared

	var canSave: Bool {
		!titleInput.isEmpty || !bodyInput.isEmpty
	}

//	MARK: - Init

	init() {}

	init(existingNote: Note) {
		titleInput = existingNote.wrappedTitle
		bodyInput = existingNote.wrappedBody
		editingExistingNote = true
	}

//	MARK: - Public Methods

	func createNote(for plant: Plant) {
		coreDataManager.addNote(for: plant, title: titleInput, body: bodyInput)
	}

	func updateNote(_ note: Note) {
		coreDataManager.updateNoteTitleAndBody(for: note, title: titleInput, body: bodyInput)
	}
}
