//
//  AddNoteView.swift
//  Seedling
//
//  Created by Laurie Cai on 2/18/24.
//

import SwiftUI

struct AddNoteView: View {
	
	@ObservedObject var viewModel: DetailViewModel
	
	@Environment(\.dismiss) var dismiss
	
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
		.onAppear {
			FirebaseEventManager.shared.logEvent(name: "AddNoteView_appeared")
		}
		.navigationTitle(viewModel.editingExistingNote ? "Edit Note" : "New Note")
		.navigationBarTitleDisplayMode(.inline)
		.navigationBarBackButtonHidden(true)
		.toolbar {
			ToolbarItem(placement: .topBarLeading) { cancelButton }
			ToolbarItem(placement: .topBarTrailing) {
				if viewModel.editingExistingNote {
					saveChangesButton
				} else {
					addNoteButton
				}
			}
		}
		.keyboardType(.default)
		.onChange(of: viewModel.noteTitleInput) { viewModel.noteEdited = true }
		.onChange(of: viewModel.noteBodyInput) { viewModel.noteEdited = true }
    }
}

extension AddNoteView {
	
	private var notePrompt: some View {
		Text("How's your \(viewModel.plant.wrappedFullNameSentence.lowercased())?")
			.font(.handjet(.extraBold, size: 22))
			.foregroundStyle(Color.theme.textPrimary)
			.frame(maxWidth: .infinity, alignment: .leading)
	}
	
	private var noteTitleInput: some View {
		TextInput(inputLabel: "Title", labelDescription: "Optional", inputPlaceholder: "e.g. It sprouted!", text: $viewModel.noteTitleInput)
	}
	
	private var noteBodyInput: some View {
		TextEditorInput(inputLabel: "Description", labelDescription: nil, inputPlaceholder: "Start writing...", accentTheme: true, text: $viewModel.noteBodyInput)
	}
	
	private var addNoteButton: some View {
		Button("Add Note") {
			FirebaseEventManager.shared.logEvent(name: "addNoteButton_tapped")
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			if !viewModel.noteBodyInput.isEmpty || !viewModel.noteTitleInput.isEmpty {
				viewModel.addNote(for: viewModel.plant, title: viewModel.noteTitleInput, body: viewModel.noteBodyInput)
			}
			viewModel.showingAddPostOptions = false
			viewModel.resetAddNoteFormInputs()
			dismiss()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(viewModel.noteTitleInput.isEmpty && viewModel.noteBodyInput.isEmpty ? Color.theme.textSecondary.opacity(0.5) : Color.theme.accentGreen)
		.disabled(viewModel.noteTitleInput.isEmpty && viewModel.noteBodyInput.isEmpty)
	}
	
	private var saveChangesButton: some View {
		Button("Save Changes") {
			FirebaseEventManager.shared.logEvent(name: "saveChangesButton_tapped")
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			if let selectedNote = viewModel.selectedNote {
				viewModel.updateNoteTitleAndBody(
					for: selectedNote,
					title: viewModel.noteTitleInput,
					body: viewModel.noteBodyInput
				)
			}
			viewModel.showingAddPostOptions = false
			dismiss()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(viewModel.noteEdited ? Color.theme.accentGreen : Color.theme.textSecondary.opacity(0.5))
		.disabled(!viewModel.noteEdited)
	}
	
	private var cancelButton: some View {
		Button {
			FirebaseEventManager.shared.logEvent(name: "cancelButton_tapped")
			viewModel.showingAddPostOptions = false
			dismiss()
		} label: {
			Text("Cancel")
				.font(.handjet(.medium, size: 20))
		}
		.foregroundStyle(Color.theme.textSecondary)
	}
}


