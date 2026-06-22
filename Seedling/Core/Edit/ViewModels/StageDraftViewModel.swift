//
//  StageDraftViewModel.swift
//  Seedling
//

import Foundation
import PostHog

@MainActor
class StageDraftViewModel: ObservableObject {

	@Published var plant: Plant?
	@Published var selectedStage: PlantStage = .seed
	@Published var selectedStageIndex: Int = 0
	@Published var updated: Bool = false

	private let coreDataManager = CoreDataManager.shared

	var canSave: Bool {
		plant != nil && updated
	}

//	MARK: - Init

	init() {}

//	MARK: - Public Methods

	func syncSelection(for plant: Plant) {
		let savedStage = PlantStage(rawValue: plant.wrappedStage) ?? .seedling
		selectedStage = savedStage
		selectedStageIndex = PlantStage.allCases.firstIndex(of: savedStage) ?? 0
		updated = false
	}

	func handlePlantSelection() {
		guard let plant else { return }
		syncSelection(for: plant)
	}

	func postUpdate() {
		guard let plant else { return }
		coreDataManager.addStageUpdate(plant: plant, newStage: selectedStage.rawValue)
		PostHogSDK.shared.capture("plant_stage_updated", properties: [
			"plant_name": plant.wrappedName,
			"plant_type": plant.wrappedType,
			"new_stage": selectedStage.rawValue,
		])
	}
}
