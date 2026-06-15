//
//  HomeView.swift
//  Seedling
//
//  Created by Laurie Cai on 11/28/23.
//

import PhotosUI
import SwiftUI

struct HomeView: View {
	
	@StateObject private var viewModel = HomeViewModel()
	@EnvironmentObject private var imagePickerService: ImagePickerService
	
	var body: some View {
		NavigationStack {
			ZStack(alignment: .bottomTrailing) {
				Color.theme.backgroundPrimary
					.ignoresSafeArea()
				
				VStack(alignment: .leading, spacing: 15) {
					dateHeader
					
					if viewModel.plants.isEmpty {
						nullState
					} else {
						plantsList
					}
				}
				.padding(.horizontal)
				
				if viewModel.showingActionMenu {
					DarkOverlay { viewModel.closeActionMenu() }
				}

				actionMenuGroup
			}
			.onAppear {
				FirebaseEventManager.shared.logEvent(name: "HomeView_appeared")
				viewModel.fetchPlants()
				viewModel.showingActionMenu = false
			}
			.sheet(item: $viewModel.activeSheet) { sheet in
				homeSheetContent(for: sheet)
			}
			.sheet(isPresented: $viewModel.showingAddPlantView) {
				AddPlantView(viewModel: viewModel, presentation: .standalone)
			}
			.photosPicker(
				isPresented: $viewModel.showingPhotosPicker,
				selection: $imagePickerService.selectedPhotosPickerItem
			)
			.onChange(of: imagePickerService.selectedImage) { _, newImage in
				guard let newImage, imagePickerService.pickerSource == .home else { return }
				viewModel.handlePhotoPickerResult(newImage)
				imagePickerService.clearPickerState()
				viewModel.showingPhotosPicker = false
			}
			.confirmationDialog("Plant Options", isPresented: $viewModel.showingActionSheet) {
				editPlantNameButton
				deletePlantButton
			} message: {
				Text("What do you want to do with this plant?")
			}
			.navigationDestination(for: Plant.self) { plant in
				DetailView(plant: plant)
			}
		}
    }
	
	@ViewBuilder
	private func homeSheetContent(for sheet: HomeSheet) -> some View {
		switch sheet {
		case .addPlant(let presentation):
			AddPlantView(viewModel: viewModel, presentation: presentation) { plant in
				switch presentation {
				case .standalone:
					viewModel.dismissActiveSheet()
				case .fromNoteDraft:
					viewModel.draftAssignedPlant = plant
				case .fromPhotoDraft:
					viewModel.draftAssignedPlant = plant
				}
				viewModel.fetchPlants()
			}
		case .noteDraft:
			HomeNoteDraftView(viewModel: viewModel)
		case .photoDraft:
			HomePhotoDraftView(viewModel: viewModel)
		case .stageDraft:
			HomeStageDraftView(viewModel: viewModel)
		}
	}
}

#Preview {
    HomeView()
		.environmentObject(ImagePickerService())
}

// MARK: - UI

extension HomeView {
	
	private var dateHeader: some View {
		Text(Date().asDayAndDate())
			.font(.handjet(.extraBold, size: 32))
			.foregroundStyle(Color.theme.textPrimary)
			.frame(maxWidth: .infinity, alignment: .leading)
	}
	
	private var nullState: some View {
		VStack(alignment: .center, spacing: 10) {
			Spacer()
			Text("Welcome to the garden")
				.font(.handjet(.extraBold, size: 22))
				.foregroundStyle(Color.theme.textPrimary)
			Text("Let's add your first plant!")
				.font(.handjet(.medium, size: 20))
				.foregroundStyle(Color.theme.textPrimary)
				.padding(.bottom, 40)
			Spacer()
		}
		.frame(maxWidth: .infinity, alignment: .center)
		.multilineTextAlignment(.center)
		.lineSpacing(5)
	}
	
	private var plantsList: some View {
		ScrollView(showsIndicators: false) {
			VStack(spacing: 8) {
				ForEach(viewModel.plants, id: \.self.customHash) { plant in
					NavigationLink(value: plant) {
						PlantCardView(
							plant: plant,
							showActionSheet: $viewModel.showingActionSheet,
							showActionForPlant: $viewModel.selectedPlant
						)
					}
					.simultaneousGesture(
						TapGesture().onEnded {
							FirebaseEventManager.shared.logEvent(name: "PlantCardView_tapped")
							UIImpactFeedbackGenerator(style: .light).impactOccurred()
						}
					)
				}
			}
			.padding(.bottom, 140)
		}
	}
	
	private var actionMenuGroup: some View {
		ActionMenuGroup(
			isExpanded: $viewModel.showingActionMenu,
			onToggle: {
				FirebaseEventManager.shared.logEvent(name: "homeCreateMenuButton_tapped")
				viewModel.showingActionMenu.toggle()
			},
			onAddNote: {
				FirebaseEventManager.shared.logEvent(name: "homeAddNoteButton_tapped")
				viewModel.beginNoteDraft()
			},
			onAddPhoto: {
				FirebaseEventManager.shared.logEvent(name: "homeAddPhotoButton_tapped")
				imagePickerService.prepareForPicker(source: .home)
				viewModel.beginPhotoDraft()
			},
			onUpdateStage: viewModel.canShowUpdateStageAction ? {
				FirebaseEventManager.shared.logEvent(name: "homeUpdateStageButton_tapped")
				viewModel.beginStageDraft()
			} : nil,
			onNewPlant: {
				FirebaseEventManager.shared.logEvent(name: "homeNewPlantButton_tapped")
				viewModel.beginPlantDraft()
			}
		)
	}
	
	private var editPlantNameButton: some View {
		Button("Edit Name and Variety") {
			FirebaseEventManager.shared.logEvent(name: "editPlantNameButton_tapped")
			viewModel.resetPlantDetailsChangedFlag()
			
			if let selectedPlant = viewModel.selectedPlant {
				viewModel.editingExistingPlant = true
				viewModel.showingAddPlantView = true
				viewModel.fetchExistingPlantNameAndVariety(for: selectedPlant)
			}
		}
	}
	
	private var deletePlantButton: some View {
		Button("Delete Plant", role: .destructive) {
			FirebaseEventManager.shared.logEvent(name: "deletePlantButton_tapped")
			if let selectedPlant = viewModel.selectedPlant {
				withAnimation(Animation.bouncy(duration: 0.25, extraBounce: 0.10)) {
					viewModel.deletePlant(plant: selectedPlant)
				}
			}
		}
	}
}
