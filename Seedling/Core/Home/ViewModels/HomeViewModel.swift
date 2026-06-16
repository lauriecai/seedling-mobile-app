//
//  HomeViewModel.swift
//  Seedling
//
//  Created by Laurie Cai on 2/1/24.
//

import CoreData
import Foundation
import UIKit

enum HomeSheet: Identifiable {
	case addPlant(AddPlantPresentation)
	case noteDraft
	case photoDraft
	case stageDraft
	
	var id: String {
		switch self {
		case .addPlant(let presentation):
			return "addPlant-\(presentation.id)"
		case .noteDraft:
			return "noteDraft"
		case .photoDraft:
			return "photoDraft"
		case .stageDraft:
			return "stageDraft"
		}
	}
}

enum AddPlantPresentation: Identifiable {
	case standalone
	case fromNoteDraft
	case fromPhotoDraft
	
	var id: String {
		switch self {
		case .standalone: return "standalone"
		case .fromNoteDraft: return "note"
		case .fromPhotoDraft: return "photo"
		}
	}
	
	var usesBackButton: Bool {
		switch self {
		case .standalone:
			return false
		case .fromNoteDraft, .fromPhotoDraft:
			return true
		}
	}
	
	var resetsFormOnDismiss: Bool {
		switch self {
		case .standalone:
			return true
		case .fromNoteDraft, .fromPhotoDraft:
			return false
		}
	}
}

class HomeViewModel: ObservableObject {
	
	let manager = CoreDataManager.shared
	
	// Home View
	@Published var plants: [Plant] = []
	@Published var showingActionMenu: Bool = false
	@Published var activeSheet: HomeSheet?
	@Published var showingPhotosPicker: Bool = false
	
	// Add Plant View
	@Published var plantNameInput: String = ""
	@Published var plantVarietyInput: String = ""
	
	@Published var selectedStage: PlantStage = .seed
	@Published var selectedStageIndex: Int = 0
	
	@Published var selectedType: PlantType = .vegetable
	@Published var selectedTypeIndex: Int = 0
	
	@Published var editingExistingPlant: Bool = false
	@Published var plantDetailsEdited: Bool = false
	
	// Plant card actions
	@Published var showingAddPlantView: Bool = false
	@Published var selectedPlant: Plant? = nil
	@Published var showingActionSheet: Bool = false
	
	// Note draft
	@Published var noteDraftViewModel = NoteDraftViewModel()
	@Published var draftAssignedPlant: Plant?

	// Photo draft
	@Published var photoDraftViewModel: PhotoDraftViewModel?

	// Stage draft
	@Published var stageDraftViewModel = StageDraftViewModel()

	var canShowUpdateStageAction: Bool {
		!plants.isEmpty
	}

	var canSaveNoteDraft: Bool {
		noteDraftViewModel.canSave && draftAssignedPlant != nil
	}

	var canSavePhotoDraft: Bool {
		photoDraftViewModel != nil && draftAssignedPlant != nil
	}

	var canSaveStageDraft: Bool {
		stageDraftViewModel.canSave
	}
	
//	MARK: - Home actions
	
	func beginPlantDraft() {
		closeActionMenu()
		resetAddPlantFormInputsAndFlags()
		activeSheet = .addPlant(.standalone)
	}
	
	func beginNoteDraft() {
		closeActionMenu()
		resetNoteDraft()
		activeSheet = .noteDraft
	}
	
	func beginPhotoDraft() {
		closeActionMenu()
		resetPhotoDraft()
		showingPhotosPicker = true
	}
	
	func beginStageDraft() {
		closeActionMenu()
		resetStageDraft()
		activeSheet = .stageDraft
	}
	
	func handlePhotoPickerResult(_ image: UIImage) {
		photoDraftViewModel = PhotoDraftViewModel(newImage: image)
		activeSheet = .photoDraft
	}
	
	func closeActionMenu() {
		showingActionMenu = false
	}
	
	func dismissActiveSheet() {
		activeSheet = nil
	}
	
//	MARK: - Plant functions
	
	func fetchPlants() {
		let request = manager.requestPlants()
		
		do {
			plants = try manager.context.fetch(request)
		} catch let error {
			print("Error fetching plants from Core Data. \(error)")
		}
	}
	
	@discardableResult
	func addPlant(name: String, variety: String, stage: String, type: String) -> Plant {
		let newPlant = manager.addPlant(name: name, variety: variety, stage: stage, type: type)
		resetAddPlantFormInputsAndFlags()
		fetchPlants()
		return newPlant
	}
	
	func deletePlant(plant: Plant) {
		manager.deletePlant(plant: plant)
		fetchPlants()
	}
	
	func updatePlantNameAndVariety(for plant: Plant, name: String, variety: String) {
		manager.updatePlantNameAndVariety(for: plant, name: name, variety: variety)
		fetchPlants()
	}
	
	func fetchExistingPlantNameAndVariety(for plant: Plant) {
		plantNameInput = plant.wrappedName
		plantVarietyInput = plant.wrappedVariety
	}
	
	func resetAddPlantFormInputsAndFlags() {
		resetNameAndVarietyTextFields()
		editingExistingPlant = false
		selectedStage = .seed
		selectedStageIndex = 0
		
		selectedType = .vegetable
		selectedTypeIndex = 0
	}
	
	func resetPlantDetailsChangedFlag() {
		plantDetailsEdited = false
	}
	
//	MARK: - Draft lifecycle
	
	func resetNoteDraft() {
		noteDraftViewModel = NoteDraftViewModel()
		draftAssignedPlant = nil
	}

	func cancelNoteDraft() {
		resetNoteDraft()
		dismissActiveSheet()
	}

	func postNoteDraft() {
		guard let plant = draftAssignedPlant else { return }
		noteDraftViewModel.createNote(for: plant)
		resetNoteDraft()
		fetchPlants()
		dismissActiveSheet()
	}
	
	func resetPhotoDraft() {
		photoDraftViewModel = nil
		draftAssignedPlant = nil
	}

	func cancelPhotoDraft() {
		resetPhotoDraft()
		dismissActiveSheet()
	}

	func postPhotoDraft() {
		guard let plant = draftAssignedPlant, let photoDraftViewModel else { return }
		photoDraftViewModel.createPhoto(for: plant)
		resetPhotoDraft()
		fetchPlants()
		dismissActiveSheet()
	}
	
	func resetStageDraft() {
		stageDraftViewModel = StageDraftViewModel()
	}

	func cancelStageDraft() {
		resetStageDraft()
		dismissActiveSheet()
	}

	func postStageDraft() {
		stageDraftViewModel.postUpdate()
		resetStageDraft()
		fetchPlants()
		dismissActiveSheet()
	}

	func handleStageDraftPlantSelection() {
		stageDraftViewModel.handlePlantSelection()
	}
	
	private func resetNameAndVarietyTextFields() {
		plantNameInput = ""
		plantVarietyInput = ""
	}
}
