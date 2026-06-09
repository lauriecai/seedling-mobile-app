//
//  HomeEditPhotoView.swift
//  Seedling
//

import SwiftUI

private enum HomeAddPhotoRoute: Hashable {
	case plantSelection
	case addPlant
}

struct HomeEditPhotoView: View {
	
	@ObservedObject var viewModel: HomeViewModel
	
	var body: some View {
		if let photoDraftViewModel = viewModel.photoDraftViewModel {
			HomeEditPhotoContent(
				viewModel: viewModel,
				photoDraftViewModel: photoDraftViewModel
			)
		}
	}
}

private struct HomeEditPhotoContent: View {
	
	@ObservedObject var viewModel: HomeViewModel
	@ObservedObject var photoDraftViewModel: EditPhotoViewModel
	
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
						
						NavigationLink(value: HomeAddPhotoRoute.plantSelection) {
							PickerRow(
								prompt: "Which plant is this for?",
								selectedValue: viewModel.draftAssignedPlant?.wrappedFullNameLabel ?? "None"
							)
						}
						.buttonStyle(.plain)
						
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
			.navigationDestination(for: HomeAddPhotoRoute.self) { route in
				switch route {
				case .plantSelection:
					PlantSelectionView(
						plants: viewModel.plants,
						configuration: PlantSelectionConfiguration(allowsNone: true, allowsNewPlant: true),
						selectedPlant: $viewModel.draftAssignedPlant,
						onRequestNewPlant: { navigationPath.append(HomeAddPhotoRoute.addPlant) }
					)
				case .addPlant:
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
		.onAppear {
			FirebaseEventManager.shared.logEvent(name: "HomeEditPhotoView_appeared")
		}
	}
	
	private var addPhotoButton: some View {
		Button("Add Photo") {
			FirebaseEventManager.shared.logEvent(name: "HomeAddPhoto_saveButton_tapped")
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			viewModel.postPhotoDraft()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(viewModel.canSavePhotoDraft ? Color.theme.accentGreen : Color.theme.textSecondary.opacity(0.5))
		.disabled(!viewModel.canSavePhotoDraft)
	}
	
	private var cancelButton: some View {
		Button("Cancel") {
			FirebaseEventManager.shared.logEvent(name: "HomeAddPhoto_cancelButton_tapped")
			viewModel.cancelPhotoDraft()
		}
		.font(.handjet(.medium, size: 20))
		.foregroundStyle(Color.theme.textSecondary)
	}
}
