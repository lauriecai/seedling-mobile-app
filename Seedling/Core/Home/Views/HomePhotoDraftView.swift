//
//  HomePhotoDraftView.swift
//  Seedling
//

import PostHog
import SwiftUI

private enum HomePhotoDraftRoute: Hashable {
	case addPlant
}

struct HomePhotoDraftView: View {

	@ObservedObject var viewModel: HomeViewModel

	var body: some View {
		if let photoDraftViewModel = viewModel.photoDraftViewModel {
			HomePhotoDraftContent(
				viewModel: viewModel,
				photoDraftViewModel: photoDraftViewModel
			)
			.onAppear { PostHogSDK.shared.screen("Photo Draft (Home)") }
		}
	}
}

private struct HomePhotoDraftContent: View {

	@ObservedObject var viewModel: HomeViewModel
	@ObservedObject var photoDraftViewModel: PhotoDraftViewModel

	@State private var navigationPath = NavigationPath()
	@FocusState private var keyboardFocused: Bool

	var body: some View {
		NavigationStack(path: $navigationPath) {
			ZStack {
				Color.theme.backgroundPrimary
					.ignoresSafeArea()

				ScrollView(showsIndicators: false) {
					VStack(spacing: 15) {
						Image(uiImage: photoDraftViewModel.image)
							.resizable()
							.scaledToFit()
							.clipShape(RoundedRectangle(cornerRadius: 8))
							.frame(maxHeight: 300)

						PlantPickerRow(
							plants: viewModel.plants,
							configuration: PlantSelectionConfiguration(allowsNone: true, allowsNewPlant: true),
							selectedPlant: $viewModel.draftAssignedPlant,
							onRequestNewPlant: { navigationPath.append(HomePhotoDraftRoute.addPlant) }
						)

						TextEditorInput(
							inputLabel: "Description",
							labelDescription: "Optional",
							inputPlaceholder: "Start writing...",
							accentTheme: true,
							text: $photoDraftViewModel.caption
						)
						.focused($keyboardFocused)
					}
					.padding(.horizontal)
				}
			}
			.navigationTitle("New Photo")
			.navigationBarTitleDisplayMode(.inline)
			.navigationBarBackButtonHidden(true)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) { cancelButton }
				ToolbarItem(placement: .topBarTrailing) { addPhotoButton }
			}
			.navigationDestination(for: HomePhotoDraftRoute.self) { _ in
				AddPlantView(
					viewModel: viewModel,
					presentation: .fromPhotoDraft,
					onPlantCreated: { plant in
						viewModel.draftAssignedPlant = plant
						viewModel.fetchPlants()
						navigationPath = NavigationPath()
					}
				)
			}
		}
	}

	private var addPhotoButton: some View {
		Button("Add Photo") {
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			viewModel.postPhotoDraft()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(viewModel.canSavePhotoDraft ? Color.theme.accentGreen : Color.theme.textSecondary.opacity(0.5))
		.disabled(!viewModel.canSavePhotoDraft)
	}

	private var cancelButton: some View {
		Button("Cancel") {
			viewModel.cancelPhotoDraft()
		}
		.font(.handjet(.medium, size: 20))
		.foregroundStyle(Color.theme.textSecondary)
	}
}
