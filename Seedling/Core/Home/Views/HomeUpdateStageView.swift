//
//  HomeUpdateStageView.swift
//  Seedling
//

import SwiftUI

private enum HomeUpdateStageRoute: Hashable {
	case plantSelection
}

struct HomeUpdateStageView: View {

	@ObservedObject var viewModel: HomeViewModel

	var body: some View {
		HomeUpdateStageContent(
			viewModel: viewModel,
			stageDraftViewModel: viewModel.stageDraftViewModel
		)
	}
}

private struct HomeUpdateStageContent: View {

	@ObservedObject var viewModel: HomeViewModel
	@ObservedObject var stageDraftViewModel: StageDraftViewModel

	@State private var navigationPath = NavigationPath()

	var body: some View {
		NavigationStack(path: $navigationPath) {
			ZStack {
				Color.theme.backgroundPrimary
					.ignoresSafeArea()

				ScrollView(showsIndicators: false) {
					VStack(alignment: .leading, spacing: 15) {
						NavigationLink(value: HomeUpdateStageRoute.plantSelection) {
							PickerRow(
								prompt: "Which plant is this for?",
								selectedValue: stageDraftViewModel.plant?.wrappedFullNameLabel ?? "None"
							)
						}
						.buttonStyle(.plain)

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
			.navigationDestination(for: HomeUpdateStageRoute.self) { route in
				switch route {
				case .plantSelection:
					PlantSelectionView(
						plants: viewModel.plants,
						configuration: PlantSelectionConfiguration(allowsNone: true, allowsNewPlant: false),
						selectedPlant: $stageDraftViewModel.plant
					)
					.onDisappear {
						viewModel.handleStageDraftPlantSelection()
					}
				}
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
		.onAppear {
			FirebaseEventManager.shared.logEvent(name: "HomeUpdateStageView_appeared")
		}
	}

	private var saveButton: some View {
		Button("Update Stage") {
			FirebaseEventManager.shared.logEvent(name: "HomeUpdateStage_saveButton_tapped")
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			viewModel.postStageDraft()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(viewModel.canSaveStageDraft ? Color.theme.accentGreen : Color.theme.textSecondary.opacity(0.5))
		.disabled(!viewModel.canSaveStageDraft)
	}
	
	private var cancelButton: some View {
		Button("Cancel") {
			FirebaseEventManager.shared.logEvent(name: "HomeUpdateStage_cancelButton_tapped")
			viewModel.cancelStageDraft()
		}
		.font(.handjet(.medium, size: 20))
		.foregroundStyle(Color.theme.textSecondary)
	}
}
