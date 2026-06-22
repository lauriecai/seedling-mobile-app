//
//  NoteDraftViewModel.swift
//  Seedling
//

import Foundation
import PostHog

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
		PostHogSDK.shared.capture("note_created", properties: [
			"plant_name": plant.wrappedName,
			"has_title": !titleInput.isEmpty,
			"has_body": !bodyInput.isEmpty,
		])
	}

	func updateNote(_ note: Note) {
		coreDataManager.updateNoteTitleAndBody(for: note, title: titleInput, body: bodyInput)
		PostHogSDK.shared.capture("note_edited", properties: [
			"has_title": !titleInput.isEmpty,
			"has_body": !bodyInput.isEmpty,
		])
	}
}
