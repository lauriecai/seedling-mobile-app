//
//  HomeNoteDraftView.swift
//  Seedling
//

import PostHog
import SwiftUI

private enum HomeNoteDraftRoute: Hashable {
	case addPlant
}

struct HomeNoteDraftView: View {

	@ObservedObject var viewModel: HomeViewModel

	var body: some View {
		HomeNoteDraftContent(
			viewModel: viewModel,
			noteDraftViewModel: viewModel.noteDraftViewModel
		)
		.onAppear { PostHogSDK.shared.screen("Note Draft (Home)") }
	}
}

private struct HomeNoteDraftContent: View {

	@ObservedObject var viewModel: HomeViewModel
	@ObservedObject var noteDraftViewModel: NoteDraftViewModel

	@State private var navigationPath = NavigationPath()
	@FocusState private var keyboardFocused: Bool

	var body: some View {
		NavigationStack(path: $navigationPath) {
			ZStack {
				Color.theme.backgroundPrimary
					.ignoresSafeArea()

				ScrollView(showsIndicators: false) {
					VStack(spacing: 15) {
						PlantPickerRow(
							plants: viewModel.plants,
							configuration: PlantSelectionConfiguration(allowsNone: true, allowsNewPlant: true),
							selectedPlant: $viewModel.draftAssignedPlant,
							onRequestNewPlant: { navigationPath.append(HomeNoteDraftRoute.addPlant) }
						)

						TextInput(
							inputLabel: "Title",
							labelDescription: "Optional",
							inputPlaceholder: "e.g. It sprouted!",
							text: $noteDraftViewModel.titleInput
						)
						.focused($keyboardFocused)
						.onAppear { keyboardFocused = true }

						TextEditorInput(
							inputLabel: "Description",
							labelDescription: "Optional",
							inputPlaceholder: "Start writing...",
							accentTheme: true,
							text: $noteDraftViewModel.bodyInput
						)
					}
					.padding(.horizontal)
				}
			}
			.navigationTitle("New Note")
			.navigationBarTitleDisplayMode(.inline)
			.navigationBarBackButtonHidden(true)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) { cancelButton }
				ToolbarItem(placement: .topBarTrailing) { addNoteButton }
			}
			.navigationDestination(for: HomeNoteDraftRoute.self) { _ in
				AddPlantView(
					viewModel: viewModel,
					presentation: .fromNoteDraft,
					onPlantCreated: { plant in
						viewModel.draftAssignedPlant = plant
						viewModel.fetchPlants()
						navigationPath = NavigationPath()
					}
				)
			}
		}
	}

	private var addNoteButton: some View {
		Button("Add Note") {
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			viewModel.postNoteDraft()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(viewModel.canSaveNoteDraft ? Color.theme.accentGreen : Color.theme.textSecondary.opacity(0.5))
		.disabled(!viewModel.canSaveNoteDraft)
	}

	private var cancelButton: some View {
		Button("Cancel") {
			viewModel.cancelNoteDraft()
		}
		.font(.handjet(.medium, size: 20))
		.foregroundStyle(Color.theme.textSecondary)
	}
}
