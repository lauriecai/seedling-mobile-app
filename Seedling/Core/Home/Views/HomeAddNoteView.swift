//
//  HomeAddNoteView.swift
//  Seedling
//

import SwiftUI

private enum HomeAddNoteRoute: Hashable {
	case plantSelection
	case addPlant
}

struct HomeAddNoteView: View {
	
	@ObservedObject var viewModel: HomeViewModel
	
	@State private var navigationPath = NavigationPath()
	@FocusState private var keyboardFocused: Bool
	
	var body: some View {
		NavigationStack(path: $navigationPath) {
			ZStack {
				Color.theme.backgroundPrimary
					.ignoresSafeArea()
				
				ScrollView(showsIndicators: false) {
					VStack(spacing: 15) {
						NavigationLink(value: HomeAddNoteRoute.plantSelection) {
							PickerRow(
								prompt: "Which plant is this for?",
								selectedValue: viewModel.draftAssignedPlant?.wrappedFullNameLabel ?? "None"
							)
						}
						.buttonStyle(.plain)
						
						TextInput(
							inputLabel: "Title",
							labelDescription: "Optional",
							inputPlaceholder: "e.g. It sprouted!",
							text: $viewModel.noteTitleInput
						)
						.focused($keyboardFocused)
						.onAppear { keyboardFocused = true }
						
						TextEditorInput(
							inputLabel: "Description",
							labelDescription: "Optional",
							inputPlaceholder: "Start writing...",
							accentTheme: true,
							text: $viewModel.noteBodyInput
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
			.navigationDestination(for: HomeAddNoteRoute.self) { route in
				switch route {
				case .plantSelection:
					PlantSelectionView(
						plants: viewModel.plants,
						configuration: PlantSelectionConfiguration(allowsNone: true, allowsNewPlant: true),
						selectedPlant: $viewModel.draftAssignedPlant,
						onRequestNewPlant: { navigationPath.append(HomeAddNoteRoute.addPlant) }
					)
				case .addPlant:
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
		.onAppear {
			FirebaseEventManager.shared.logEvent(name: "HomeAddNoteView_appeared")
		}
	}
	
	private var addNoteButton: some View {
		Button("Add Note") {
			FirebaseEventManager.shared.logEvent(name: "HomeAddNote_saveButton_tapped")
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			viewModel.postNoteDraft()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(viewModel.canSaveNoteDraft ? Color.theme.accentGreen : Color.theme.textSecondary.opacity(0.5))
		.disabled(!viewModel.canSaveNoteDraft)
	}
	
	private var cancelButton: some View {
		Button("Cancel") {
			FirebaseEventManager.shared.logEvent(name: "HomeAddNote_cancelButton_tapped")
			viewModel.cancelNoteDraft()
		}
		.font(.handjet(.medium, size: 20))
		.foregroundStyle(Color.theme.textSecondary)
	}
}
