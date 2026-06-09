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
	case addNote
	case addPhoto
	case updateStage
	
	var id: String {
		switch self {
		case .addPlant(let presentation):
			return "addPlant-\(presentation.id)"
		case .addNote:
			return "addNote"
		case .addPhoto:
			return "addPhoto"
		case .updateStage:
			return "updateStage"
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
	@Published var noteTitleInput: String = ""
	@Published var noteBodyInput: String = ""
	@Published var draftAssignedPlant: Plant?
	
	// Photo draft
	@Published var photoDraftViewModel: EditPhotoViewModel?
	
	// Stage draft
	@Published var stageDraftPlant: Plant?
	@Published var stageDraftSelectedStage: PlantStage = .seed
	@Published var stageDraftSelectedStageIndex: Int = 0
	@Published var stageDraftUpdated: Bool = false
	
	var canShowUpdateStageAction: Bool {
		!plants.isEmpty
	}
	
	var canSaveNoteDraft: Bool {
		(!noteTitleInput.isEmpty || !noteBodyInput.isEmpty) && draftAssignedPlant != nil
	}
	
	var canSavePhotoDraft: Bool {
		photoDraftViewModel != nil && draftAssignedPlant != nil
	}
	
	var canSaveStageDraft: Bool {
		stageDraftPlant != nil && stageDraftUpdated
	}
	
//	MARK: - Home actions
	
	func openAddPlantFromMenu() {
		closeActionMenu()
		resetAddPlantFormInputsAndFlags()
		activeSheet = .addPlant(.standalone)
	}
	
	func openAddNoteFromMenu() {
		closeActionMenu()
		resetNoteDraft()
		activeSheet = .addNote
	}
	
	func openAddPhotoFromMenu() {
		closeActionMenu()
		resetPhotoDraft()
		showingPhotosPicker = true
	}
	
	func openUpdateStageFromMenu() {
		closeActionMenu()
		resetStageDraft()
		activeSheet = .updateStage
	}
	
	func handlePhotoPickerResult(_ image: UIImage) {
		photoDraftViewModel = EditPhotoViewModel(newImage: image)
		activeSheet = .addPhoto
	}
	
	func closeActionMenu() {
		showingActionMenu = false
	}
	
	func dismissActiveSheet() {
		activeSheet = nil
	}
	
//	MARK: - Plant functions
	
	func fetchPlants() {
		PerformanceManager.shared.startTrace(name: "home_vm_fetch_plants")
		let request = manager.requestPlants()
		
		defer {
			PerformanceManager.shared.stopTrace(name: "home_vm_fetch_plants")
		}
		
		do {
			plants = try manager.context.fetch(request)
			PerformanceManager.shared.setValue(name: "home_vm_fetch_plants", value: plants.count, metric: "number_of_plants")
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
		noteTitleInput = ""
		noteBodyInput = ""
		draftAssignedPlant = nil
	}

	func cancelNoteDraft() {
		resetNoteDraft()
		dismissActiveSheet()
	}

	func saveNoteDraft() {
		guard let plant = draftAssignedPlant else { return }
		manager.addNote(for: plant, title: noteTitleInput, body: noteBodyInput)
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

	func savePhotoDraft() {
		guard let plant = draftAssignedPlant, let photoDraftViewModel else { return }
		photoDraftViewModel.createPhoto(for: plant)
		resetPhotoDraft()
		fetchPlants()
		dismissActiveSheet()
	}
	
	func resetStageDraft() {
		stageDraftPlant = nil
		stageDraftSelectedStage = .seed
		stageDraftSelectedStageIndex = 0
		stageDraftUpdated = false
	}

	func cancelStageDraft() {
		resetStageDraft()
		dismissActiveSheet()
	}

	func saveStageDraft() {
		guard let plant = stageDraftPlant else { return }
		manager.addStageUpdate(plant: plant, newStage: stageDraftSelectedStage.rawValue)
		resetStageDraft()
		fetchPlants()
		dismissActiveSheet()
	}
	
	func syncStageDraftSelection(for plant: Plant) {
		let savedPlantStage = PlantStage(rawValue: plant.wrappedStage) ?? .seedling
		stageDraftSelectedStage = savedPlantStage
		stageDraftSelectedStageIndex = PlantStage.allCases.firstIndex(of: savedPlantStage) ?? 0
		stageDraftUpdated = false
	}
	
	func handleStageDraftPlantSelection() {
		guard let plant = stageDraftPlant else { return }
		syncStageDraftSelection(for: plant)
	}
	
	private func resetNameAndVarietyTextFields() {
		plantNameInput = ""
		plantVarietyInput = ""
	}
}
