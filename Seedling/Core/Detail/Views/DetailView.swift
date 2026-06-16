//
//  DetailView.swift
//  Seedling
//
//  Created by Laurie Cai on 2/11/24.
//

import PhotosUI
import SwiftUI

struct DetailView: View {

	@StateObject private var viewModel: DetailViewModel

	@EnvironmentObject var imagePickerService: ImagePickerService

	@Environment(\.dismiss) var dismiss

//	MARK: - Init
	init(plant: Plant) {
		_viewModel = StateObject(wrappedValue: DetailViewModel(plant: plant))
	}

//	MARK: - View
	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			Color.theme.backgroundPrimary
				.ignoresSafeArea()

			postsList

			if viewModel.showingActionMenu { DarkOverlay { viewModel.closeActionMenu() } }

			actionMenuGroup
		}
		.navigationTitle(viewModel.plant.wrappedFullNameLabel)
		.navigationBarTitleDisplayMode(.inline)
		.navigationBarBackButtonHidden(true)
		.toolbar {
			ToolbarItem(placement: .topBarLeading) { backButton }
			ToolbarItem(placement: .topBarTrailing) { detailsButton }
		}
		.onAppear {
			viewModel.fetchPosts(for: viewModel.plant)
			viewModel.showingActionMenu = false
		}
		.sheet(item: $viewModel.activeSheet) { sheet in
			switch sheet {
			case .noteDraft:
				NavigationView {
					DetailNoteDraftView(viewModel: viewModel)
				}
			case .stageDraft:
				NavigationView {
					DetailStageDraftView(viewModel: viewModel)
				}
			case .photoDraft:
				NavigationView {
					DetailPhotoDraftView(viewModel: viewModel)
				}
			}
		}
		.photosPicker(isPresented: $viewModel.showingPhotosPicker, selection: $imagePickerService.selectedPhotosPickerItem)
		.onChange(of: imagePickerService.selectedImage) { _, newImage in
			guard let newImage, imagePickerService.pickerSource == .detail else { return }
			viewModel.beginPhotoDraft(image: newImage)
			imagePickerService.clearPickerState()
			viewModel.showingPhotosPicker = false
		}
		.navigationDestination(isPresented: $viewModel.showingPlantDetailsView) {
			PlantDetailsView(viewModel: viewModel)
		}
    }
}

// MARK: - UI

extension DetailView {

	private var postsList: some View {
		ScrollView(showsIndicators: false) {
			VStack(alignment: .leading, spacing: 10) {
				ForEach(viewModel.posts) { post in
					switch post.type {
					case .event(let event):
						eventCard(for: event)
							.confirmationDialog("Post Options", isPresented: $viewModel.showEventActionSheet) {
								deleteEventButton
							} message: {
								Text("What do you want to do with this post?")
							}
					case .note(let note):
						noteCard(for: note)
							.confirmationDialog("Post Options", isPresented: $viewModel.showNoteActionSheet) {
								editNoteButton
								deleteNoteButton
							} message: {
								Text("What do you want to do with this post?")
							}
					case .photo(let photo):
						photoCard(for: photo)
							.confirmationDialog("Post Options", isPresented: $viewModel.showPhotoActionSheet) {
								 editCaptionButton
								 deletePhotoButton
							} message: {
								Text("What do you want to do with this post?")
							}
					}
				}
			}
			.padding(.top, 7)
			.padding(.horizontal)
			.padding(.bottom, 160)
		}
	}

	private func eventCard(for event: Event) -> EventCardView {
		EventCardView(event: event, showActionSheet: $viewModel.showEventActionSheet, showActionsForEvent: $viewModel.selectedEvent)
	}

	private var deleteEventButton: some View {
		Button("Delete Post", role: .destructive) {
			if let selectedEvent = viewModel.selectedEvent {
				withAnimation(Animation.bouncy(duration: 0.25, extraBounce: 0.10)) {
					viewModel.deleteEvent(event: selectedEvent)
				}
			}
		}
	}

	private var editCaptionButton: some View {
		Button("Edit Caption") {
			if let selectedPhoto = viewModel.selectedPhoto {
				viewModel.beginEditingPhoto(selectedPhoto)
			}
		}
	}

	private var deletePhotoButton: some View {
		Button("Delete Post", role: .destructive) {
			withAnimation(Animation.bouncy(duration: 0.25, extraBounce: 0.10)) {
				viewModel.deletePhoto()
			}
		}
	}

	private func noteCard(for note: Note) -> NoteCardView {
		NoteCardView(note: note, showActionSheet: $viewModel.showNoteActionSheet, showActionsForNote: $viewModel.selectedNote)
	}

	private var editNoteButton: some View {
		Button("Edit note") {
			if let selectedNote = viewModel.selectedNote {
				viewModel.beginEditingNote(selectedNote)
			}
		}
	}

	private var deleteNoteButton: some View {
		Button("Delete Post", role: .destructive) {
			if let selectedNote = viewModel.selectedNote {
				withAnimation(Animation.bouncy(duration: 0.25, extraBounce: 0.10)) {
					viewModel.deleteNote(note: selectedNote)
				}
			}
		}
	}

	private func photoCard(for photo: Photo) -> PhotoCardView {
		PhotoCardView(photo: photo, showActionSheet: $viewModel.showPhotoActionSheet, showActionsForPhoto: $viewModel.selectedPhoto)
	}

	private var actionMenuGroup: some View {
		ActionMenuGroup(
			isExpanded: $viewModel.showingActionMenu,
			onToggle: {
				viewModel.showingActionMenu.toggle()
			},
			onAddNote: {
				viewModel.beginNoteDraft()
			},
			onAddPhoto: {
				imagePickerService.prepareForPicker(source: .detail)
				viewModel.showingPhotosPicker.toggle()
				viewModel.closeActionMenu()
			},
			onUpdateStage: {
				viewModel.beginStageDraft()
			},
			onNewPlant: nil
		)
	}

	private var backButton: some View {
		Button {
			dismiss()
		} label: {
			HStack(spacing: 5) {
				Image(systemName: "chevron.left")
					.font(.handjet(.medium, size: 18))
				Text("Back")
					.font(.handjet(.medium, size: 20))
			}
			.foregroundStyle(Color.theme.textSecondary)
		}
	}

	private var detailsButton: some View {
		Button {
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			viewModel.showingPlantDetailsView.toggle()
		} label: {
			Text("Details")
				.font(.handjet(.extraBold, size: 20))
				.foregroundStyle(Color.theme.accentGreen)
		}
	}
}
