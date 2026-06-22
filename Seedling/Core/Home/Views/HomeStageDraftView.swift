//
//  HomeStageDraftView.swift
//  Seedling
//

import PostHog
import SwiftUI

struct HomeStageDraftView: View {

	@ObservedObject var viewModel: HomeViewModel

	var body: some View {
		HomeStageDraftContent(
			viewModel: viewModel,
			stageDraftViewModel: viewModel.stageDraftViewModel
		)
		.onAppear { PostHogSDK.shared.screen("Stage Draft (Home)") }
	}
}

private struct HomeStageDraftContent: View {

	@ObservedObject var viewModel: HomeViewModel
	@ObservedObject var stageDraftViewModel: StageDraftViewModel

	var body: some View {
		NavigationStack {
			ZStack {
				Color.theme.backgroundPrimary
					.ignoresSafeArea()

				ScrollView(showsIndicators: false) {
					VStack(alignment: .leading, spacing: 15) {
						PlantPickerRow(
							plants: viewModel.plants,
							configuration: PlantSelectionConfiguration(allowsNone: true, allowsNewPlant: false),
							selectedPlant: $stageDraftViewModel.plant,
							onPlantSelected: { viewModel.handleStageDraftPlantSelection() }
						)

						if stageDraftViewModel.plant != nil {
							Text("Select a new stage:")
								.font(.handjet(.extraBold, size: 22))
								.foregroundStyle(Color.theme.textPrimary)
								.frame(maxWidth: .infinity, alignment: .leading)

							StageOptionsList(
								items: PlantStage.allCases,
								accentTheme: true,
								selectedPillLabel: "Selected",
								selectedItem: $stageDraftViewModel.selectedStage,
								selectedItemIndex: $stageDraftViewModel.selectedStageIndex
							)
						}
					}
					.padding()
				}
			}
			.navigationTitle("Update Stage")
			.navigationBarTitleDisplayMode(.inline)
			.navigationBarBackButtonHidden(true)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) { cancelButton }
				ToolbarItem(placement: .topBarTrailing) { saveButton }
			}
			.onChange(of: stageDraftViewModel.selectedStage) { _, newStage in
				guard let plant = stageDraftViewModel.plant else {
					stageDraftViewModel.updated = false
					return
				}
				let currentStage = PlantStage(rawValue: plant.wrappedStage) ?? .seedling
				stageDraftViewModel.updated = newStage != currentStage
			}
		}
	}

	private var saveButton: some View {
		Button("Update Stage") {
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			viewModel.postStageDraft()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(viewModel.canSaveStageDraft ? Color.theme.accentGreen : Color.theme.textSecondary.opacity(0.5))
		.disabled(!viewModel.canSaveStageDraft)
	}

	private var cancelButton: some View {
		Button("Cancel") {
			viewModel.cancelStageDraft()
		}
		.font(.handjet(.medium, size: 20))
		.foregroundStyle(Color.theme.textSecondary)
	}
}
