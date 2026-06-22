//
//  HomeView.swift
//  Seedling
//
//  Created by Laurie Cai on 11/28/23.
//

import PhotosUI
import PostHog
import SwiftUI

struct HomeView: View {
	
	@StateObject private var viewModel = HomeViewModel()
	@EnvironmentObject private var imagePickerService: ImagePickerService
	@Environment(\.gardenPopToRootSignal) private var gardenPopToRootSignal
	
	@State private var navigationPath = NavigationPath()
	
	var body: some View {
		NavigationStack(path: $navigationPath) {
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
				viewModel.fetchPlants()
				viewModel.showingActionMenu = false
				PostHogSDK.shared.screen("Home")
			}
			.sheet(item: $viewModel.activeSheet) { sheet in
				switch sheet {
				case .addPlant(let presentation):
					AddPlantView(viewModel: viewModel, presentation: presentation) { plant in
						switch presentation {
						case .standalone:
							viewModel.dismissActiveSheet()
						case .fromNoteDraft, .fromPhotoDraft:
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
			.sheet(isPresented: $viewModel.showingCameraPicker) {
				CameraImagePickerView(
					isPresented: $viewModel.showingCameraPicker,
					libraryAccessDenied: viewModel.cameraLibraryAccessDenied,
					onImagePicked: { image in
						viewModel.beginPhotoDraft(image: image)
					}
				)
			}
			.photosPicker(
				isPresented: $viewModel.showingPhotosPicker,
				selection: $imagePickerService.selectedPhotosPickerItem
			)
			.onChange(of: imagePickerService.selectedImage) { _, newImage in
				guard let newImage, imagePickerService.pickerSource == .home else { return }
				viewModel.beginPhotoDraft(image: newImage)
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
				PlantView(plant: plant)
			}
			.onChange(of: gardenPopToRootSignal) { _, _ in
				navigationPath = NavigationPath()
			}
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
				viewModel.toggleActionMenu()
			},
			onAddNote: {
				viewModel.beginNoteDraft()
			},
			onAddPhoto: {
				viewModel.routeAddPhoto(imagePickerService: imagePickerService)
			},
			onUpdateStage: viewModel.canShowUpdateStageAction ? {
				viewModel.beginStageDraft()
			} : nil,
			onNewPlant: {
				viewModel.beginPlantDraft()
			}
		)
	}
	
	private var editPlantNameButton: some View {
		Button("Edit Name and Variety") {
			viewModel.resetPlantDetailsChangedFlag()
			
			if let selectedPlant = viewModel.selectedPlant {
				viewModel.editingExistingPlant = true
				viewModel.activeSheet = .addPlant(.standalone)
				viewModel.fetchExistingPlantNameAndVariety(for: selectedPlant)
			}
		}
	}
	
	private var deletePlantButton: some View {
		Button("Delete Plant", role: .destructive) {
			if let selectedPlant = viewModel.selectedPlant {
				withAnimation(Animation.bouncy(duration: 0.25, extraBounce: 0.10)) {
					viewModel.deletePlant(plant: selectedPlant)
				}
			}
		}
	}
}
