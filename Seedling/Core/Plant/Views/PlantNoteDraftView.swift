//
//  PlantNoteDraftView.swift
//  Seedling
//
//  Created by Laurie Cai on 2/18/24.
//

import PostHog
import SwiftUI

struct PlantNoteDraftView: View {

	@ObservedObject var viewModel: PlantViewModel

	var body: some View {
		PlantNoteDraftContent(
			viewModel: viewModel,
			noteDraftViewModel: viewModel.noteDraftViewModel
		)
		.onAppear { PostHogSDK.shared.screen("Note Draft (Plant)") }
	}
}

private struct PlantNoteDraftContent: View {

	@ObservedObject var viewModel: PlantViewModel
	@ObservedObject var noteDraftViewModel: NoteDraftViewModel

	@FocusState private var keyboardFocused: Bool

    var body: some View {
		ZStack {
			Color.theme.backgroundPrimary
				.ignoresSafeArea()

			ScrollView(showsIndicators: false) {
				VStack(spacing: 15) {
					notePrompt
					noteTitleInput
						.focused($keyboardFocused)
						.onAppear { keyboardFocused.toggle() }
					noteBodyInput
				}
				.padding(.horizontal)
			}
		}
		.navigationTitle(noteDraftViewModel.editingExistingNote ? "Edit Note" : "New Note")
		.navigationBarTitleDisplayMode(.inline)
		.navigationBarBackButtonHidden(true)
		.toolbar {
			ToolbarItem(placement: .topBarLeading) { cancelButton }
			ToolbarItem(placement: .topBarTrailing) {
				if noteDraftViewModel.editingExistingNote {
					saveChangesButton
				} else {
					addNoteButton
				}
			}
		}
		.keyboardType(.default)
		.onChange(of: noteDraftViewModel.titleInput) { noteDraftViewModel.noteEdited = true }
		.onChange(of: noteDraftViewModel.bodyInput) { noteDraftViewModel.noteEdited = true }
    }
}

private extension PlantNoteDraftContent {

	var notePrompt: some View {
		Text("How's your \(viewModel.plant.wrappedFullNameSentence.lowercased())?")
			.font(.handjet(.extraBold, size: 22))
			.foregroundStyle(Color.theme.textPrimary)
			.frame(maxWidth: .infinity, alignment: .leading)
	}

	var noteTitleInput: some View {
		TextInput(inputLabel: "Title", labelDescription: "Optional", inputPlaceholder: "e.g. It sprouted!", text: $noteDraftViewModel.titleInput)
	}

	var noteBodyInput: some View {
		TextEditorInput(inputLabel: "Description", labelDescription: nil, inputPlaceholder: "Start writing...", accentTheme: true, text: $noteDraftViewModel.bodyInput)
	}

	var addNoteButton: some View {
		Button("Add Note") {
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			viewModel.postNoteDraft()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(noteDraftViewModel.canSave ? Color.theme.accentGreen : Color.theme.textSecondary.opacity(0.5))
		.disabled(!noteDraftViewModel.canSave)
	}

	var saveChangesButton: some View {
		Button("Save") {
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			if let selectedNote = viewModel.selectedNote {
				viewModel.saveNoteEdit(selectedNote)
			}
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(noteDraftViewModel.noteEdited ? Color.theme.accentGreen : Color.theme.textSecondary.opacity(0.5))
		.disabled(!noteDraftViewModel.noteEdited)
	}

	var cancelButton: some View {
		Button {
			viewModel.cancelNoteDraft()
		} label: {
			Text("Cancel")
				.font(.handjet(.medium, size: 20))
		}
		.foregroundStyle(Color.theme.textSecondary)
	}
}
