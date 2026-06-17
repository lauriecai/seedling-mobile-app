//
//  DetailViewModel.swift
//  Seedling
//
//  Created by Laurie Cai on 2/11/24.
//

import CoreData
import Foundation
import UIKit

enum DetailSheet: Identifiable {
	case noteDraft
	case stageDraft
	case photoDraft

	var id: String {
		switch self {
		case .noteDraft: return "noteDraft"
		case .stageDraft: return "stageDraft"
		case .photoDraft: return "photoDraft"
		}
	}
}

class DetailViewModel: ObservableObject {

	let coreDataManager = CoreDataManager.shared
	let fileManager = FileManager()

	// Detail View
	@Published var plant: Plant
	@Published var posts: [PlantPost] = []

	@Published var showingActionMenu: Bool = false
	@Published var activeSheet: DetailSheet?

	// Note draft
	@Published var noteDraftViewModel = NoteDraftViewModel()

	// Stage draft
	@Published var stageDraftViewModel = StageDraftViewModel()

	// Photo draft
	@Published var photoDraftViewModel: PhotoDraftViewModel?

	// Update Stage View (used by EditGeneralDetailsCardView)
	@Published var selectedStage: PlantStage
	@Published var selectedStageIndex: Int
	@Published var plantStageUpdated: Bool = false

	// Plant Details View
	@Published var plantNameInput: String = ""
	@Published var plantVarietyInput: String = ""

	@Published var selectedType: PlantType
	@Published var selectedTypeIndex: Int

	@Published var sunlightRequirementInput: String = ""
	@Published var temperatureRequirementInput: String = ""
	@Published var waterRequirementInput: String = ""
	@Published var humidityRequirementInput: String = ""
	@Published var soilRequirementInput: String = ""
	@Published var fertilizerRequirementInput: String = ""

	@Published var additionalCareNotesInput: String = ""

	@Published var plantGeneralDetailsEdited: Bool = false
	@Published var plantCareRequirementsEdited: Bool = false
	@Published var plantAdditionalCareNotesEdited: Bool = false

	// Detail View Segues
	@Published var showingPlantDetailsView: Bool = false

	// Add Post View Segues
	@Published var showNoteActionSheet: Bool = false
	@Published var selectedNote: Note? = nil

	@Published var showEventActionSheet: Bool = false
	@Published var selectedEvent: Event? = nil

	@Published var showPhotoActionSheet: Bool = false
	@Published var selectedPhoto: Photo? = nil

	// Plant Details Segues
	@Published var editingGeneralDetails: Bool = false
	@Published var editingCareRequirements: Bool = false
	@Published var editingAdditionalCareNotes: Bool = false

	// PhotosPicker Segues
	@Published var showingPhotosPicker: Bool = false

	// Services
	private let photoService = PhotoService()

	init(plant: Plant) {
		self.plant = plant

		let savedPlantStage = PlantStage(rawValue: plant.wrappedStage) ?? .seedling
		selectedStage = savedPlantStage
		selectedStageIndex = PlantStage.allCases.firstIndex(of: savedPlantStage) ?? 0

		let savedPlantType = PlantType(rawValue: plant.wrappedType) ?? .vegetable
		selectedType = savedPlantType
		selectedTypeIndex = PlantType.allCases.firstIndex(of: savedPlantType) ?? 0

		fetchPlantGeneralDetails(for: plant)
	}

//	MARK: - Post functions

	func fetchPosts(for plant: Plant) {
		let notes = fetchNotes(for: plant) ?? []
		let events = fetchEvents(for: plant) ?? []
		let photos = photoService.fetchPhotos(for: plant) ?? []

		let posts = notes.map { PlantPost(type: .note($0)) } +
					events.map { PlantPost(type: .event($0)) } +
					photos.map { PlantPost(type: .photo($0)) }

		self.posts = posts.sorted { $0.timestamp > $1.timestamp }
	}

//	MARK: - Plant functions

	func fetchPlantStage(for plant: Plant) {
		let savedPlantStage = PlantStage(rawValue: plant.wrappedStage) ?? .seedling
		selectedStage = savedPlantStage
		selectedStageIndex = PlantStage.allCases.firstIndex(of: savedPlantStage) ?? 0
	}

	func fetchPlantType(for plant: Plant) {
		let savedPlantType = PlantType(rawValue: plant.wrappedType) ?? .vegetable
		selectedType = savedPlantType
		selectedTypeIndex = PlantType.allCases.firstIndex(of: savedPlantType) ?? 0
	}

	func updatePlantStage(for plant: Plant) {
		coreDataManager.addStageUpdate(plant: plant, newStage: selectedStage.rawValue)
		fetchPosts(for: plant)
	}

	func toggleActionMenu() {
		showingActionMenu.toggle()
	}

	func closeActionMenu() {
		showingActionMenu = false
	}

//	MARK: - Note draft lifecycle

	func beginNoteDraft() {
		closeActionMenu()
		resetNoteDraft()
		activeSheet = .noteDraft
	}

	func cancelNoteDraft() {
		resetNoteDraft()
		activeSheet = nil
	}

	func postNoteDraft() {
		guard noteDraftViewModel.canSave else { return }
		noteDraftViewModel.createNote(for: plant)
		fetchPosts(for: plant)
		resetNoteDraft()
		activeSheet = nil
	}

	func saveNoteEdit(_ note: Note) {
		updateNote(note)
		closeActionMenu()
		activeSheet = nil
	}

//	MARK: - Stage draft lifecycle

	func beginStageDraft() {
		closeActionMenu()
		stageDraftViewModel = StageDraftViewModel()
		stageDraftViewModel.plant = plant
		stageDraftViewModel.syncSelection(for: plant)
		activeSheet = .stageDraft
	}

	func postStageDraft() {
		guard stageDraftViewModel.canSave else { return }
		stageDraftViewModel.postUpdate()
		fetchPosts(for: plant)
		stageDraftViewModel = StageDraftViewModel()
		activeSheet = nil
	}

	func cancelStageDraft() {
		stageDraftViewModel = StageDraftViewModel()
		activeSheet = nil
	}

//	MARK: - Photo draft lifecycle

	func openPhotoPicker() {
		showingPhotosPicker = true
		closeActionMenu()
	}

	func beginPhotoDraft(image: UIImage) {
		photoDraftViewModel = PhotoDraftViewModel(plant: plant, newImage: image)
		activeSheet = .photoDraft
	}

	func beginEditingPhoto(_ photo: Photo) {
		photoDraftViewModel = PhotoDraftViewModel(plant: plant, existingPhoto: photo)
		activeSheet = .photoDraft
	}

	func postPhotoDraft() {
		guard let photoDraftViewModel else { return }
		photoDraftViewModel.createPhoto(for: plant)
		fetchPosts(for: plant)
		self.photoDraftViewModel = nil
		activeSheet = nil
	}

	func savePhotoEdit() {
		guard let photoDraftViewModel else { return }
		photoDraftViewModel.saveChanges(for: plant)
		fetchPosts(for: plant)
		self.photoDraftViewModel = nil
		activeSheet = nil
	}

	func cancelPhotoDraft() {
		photoDraftViewModel = nil
		activeSheet = nil
	}

	func fetchPlantGeneralDetails(for plant: Plant) {
		plantNameInput = plant.wrappedName
		plantVarietyInput = plant.wrappedVariety
		fetchPlantStage(for: plant)
		fetchPlantType(for: plant)
	}

	func editPlantGeneralDetails(for plant: Plant) {
		coreDataManager.editPlantGeneralDetails(
			for: plant,
			name: plantNameInput,
			variety: plantVarietyInput,
			type: selectedType.rawValue,
			stage: selectedStage.rawValue)
	}

	func resetPlantGeneralDetailsEditedFlag() {
		plantNameInput = ""
		plantGeneralDetailsEdited = false
	}

	func fetchPlantCareRequirements(for plant: Plant) {
		sunlightRequirementInput = plant.wrappedSunlightRequirement
		temperatureRequirementInput = plant.wrappedTemperatureRequirement
		waterRequirementInput = plant.wrappedWaterRequirement
		humidityRequirementInput = plant.wrappedHumidityRequirement
		soilRequirementInput = plant.wrappedSoilRequirement
		fertilizerRequirementInput = plant.wrappedFertilizerRequirement
	}

	func editPlantCareRequirements(for plant: Plant) {
		coreDataManager.editPlantCareRequirements(
			for: plant,
			sunlightRequirement: sunlightRequirementInput,
			temperatureRequirement: temperatureRequirementInput,
			waterRequirement: waterRequirementInput,
			humidityRequirement: humidityRequirementInput,
			soilRequirement: soilRequirementInput,
			fertilizerRequirement: fertilizerRequirementInput
		)
	}

	func resetPlantCareRequirementsEditedFlag() {
		plantCareRequirementsEdited = false
	}

	func fetchPlantAdditionalCareNotes(for plant: Plant) {
		additionalCareNotesInput = plant.wrappedAdditionalCareNotes
	}

	func editPlantAdditionalCareNotes(for plant: Plant) {
		coreDataManager.editAdditionalCareNotes(
			for: plant,
			additionalCareNotes: additionalCareNotesInput
		)
	}

	func resetPlantAdditionalCareNotesEditedFlag() {
		plantAdditionalCareNotesEdited = false
	}

//	MARK: - Note functions

	private func fetchNotes(for plant: Plant) -> [Note]? {
		let request = coreDataManager.requestNotes(for: plant)

		do {
			return try coreDataManager.context.fetch(request)
		} catch let error {
			print("Error fetching notes from Core Data. \(error)")
			return nil
		}
	}

	func deleteNote(note: Note) {
		coreDataManager.deleteNote(note: note)
		fetchPosts(for: plant)
	}

	func updateNote(_ note: Note) {
		noteDraftViewModel.updateNote(note)
		fetchPosts(for: plant)
	}

	func beginEditingNote(_ note: Note) {
		noteDraftViewModel = NoteDraftViewModel(existingNote: note)
		activeSheet = .noteDraft
	}

	func resetNoteDraft() {
		noteDraftViewModel = NoteDraftViewModel()
	}

//	MARK: - Event functions

	private func fetchEvents(for plant: Plant) -> [Event]? {
		let request = coreDataManager.requestEvents(for: plant)

		do {
			return try coreDataManager.context.fetch(request)
		} catch let error {
			print("Error fetching events from Core Data. \(error)")
			return nil
		}
	}

	func deleteEvent(event: Event) {
		coreDataManager.deleteEvent(event: event)
		fetchPosts(for: plant)
	}

//  MARK: - Photo functions

	func deletePhoto() {
		guard let imageUrlString = selectedPhoto?.imageUrlString,
			  let savedPhoto = findExistingPhoto(for: plant) else { return }

		fileManager.deleteImage(id: imageUrlString)
		coreDataManager.deletePhoto(photo: savedPhoto)
		fetchPosts(for: plant)
	}

	private func findExistingPhoto(for plant: Plant) -> Photo? {
		guard let selectedPhoto = selectedPhoto else { return nil }

		let allPhotos = fetchPhotos(for: plant)

		if let existingPhoto = allPhotos?.first(where: { $0.imageUrlString == selectedPhoto.imageUrlString })
		{ return existingPhoto } else { return nil }
	}

	private func fetchPhotos(for plant: Plant) -> [Photo]? {
		photoService.fetchPhotos(for: plant)
	}

//  MARK: - UI functions

	func activateTextFieldEditModeForAll() {
		if !sunlightRequirementInput.isEmpty {
			sunlightRequirementInput = activateTextFieldEditMode(plantProperty: sunlightRequirementInput)
		}

		if !temperatureRequirementInput.isEmpty {
			temperatureRequirementInput = activateTextFieldEditMode(plantProperty: temperatureRequirementInput)
		}

		if !waterRequirementInput.isEmpty {
			waterRequirementInput = activateTextFieldEditMode(plantProperty: waterRequirementInput)
		}

		if !humidityRequirementInput.isEmpty {
			humidityRequirementInput = activateTextFieldEditMode(plantProperty: humidityRequirementInput)
		}

		if !soilRequirementInput.isEmpty {
			soilRequirementInput = activateTextFieldEditMode(plantProperty: soilRequirementInput)
		}

		if !fertilizerRequirementInput.isEmpty {
			fertilizerRequirementInput = activateTextFieldEditMode(plantProperty: fertilizerRequirementInput)
		}
	}

	func removeExtraneousSpaceForAll() {
		sunlightRequirementInput = removeExtraneousSpace(plantProperty: sunlightRequirementInput)

		temperatureRequirementInput = removeExtraneousSpace(plantProperty: temperatureRequirementInput)

		waterRequirementInput = removeExtraneousSpace(plantProperty: waterRequirementInput)

		humidityRequirementInput = removeExtraneousSpace(plantProperty: humidityRequirementInput)

		soilRequirementInput = removeExtraneousSpace(plantProperty: soilRequirementInput)

		fertilizerRequirementInput = removeExtraneousSpace(plantProperty: fertilizerRequirementInput)
	}

	func activateTextFieldEditMode(plantProperty: String) -> String {
		return plantProperty + " "
	}

	func removeExtraneousSpace(plantProperty: String) -> String {
		return plantProperty.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
	}
}
