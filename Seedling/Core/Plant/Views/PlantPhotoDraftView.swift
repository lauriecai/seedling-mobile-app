//
//  PlantPhotoDraftView.swift
//  Seedling
//
//  Created by Laurie Cai on 7/2/24.
//

import PostHog
import SwiftUI

struct PlantPhotoDraftView: View {

	@ObservedObject var viewModel: PlantViewModel

	var body: some View {
		if let photoDraftViewModel = viewModel.photoDraftViewModel {
			PlantPhotoDraftContent(
				viewModel: viewModel,
				photoDraftViewModel: photoDraftViewModel
			)
			.onAppear { PostHogSDK.shared.screen("Photo Draft (Plant)") }
		}
	}
}

private struct PlantPhotoDraftContent: View {

	@ObservedObject var viewModel: PlantViewModel
	@ObservedObject var photoDraftViewModel: PhotoDraftViewModel

	@FocusState private var keyboardFocused: Bool

    var body: some View {
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

					photoCaptionInput
						.focused($keyboardFocused)
						.onAppear { keyboardFocused.toggle() }

					Spacer()
				}
				.padding(.horizontal)
			}
		}
		.navigationTitle(photoDraftViewModel.editingExistingImage ? "Edit Caption" : "New Photo")
		.navigationBarTitleDisplayMode(.inline)
		.navigationBarBackButtonHidden(true)
		.toolbar {
			ToolbarItem(placement: .topBarLeading) { cancelButton }
			ToolbarItem(placement: .topBarTrailing) {
				if photoDraftViewModel.editingExistingImage {
					saveChangesButton
				} else {
					addPhotoButton
				}
			}
		}
		.keyboardType(.default)
		.onChange(of: photoDraftViewModel.caption) { photoDraftViewModel.captionEdited = true }
    }
}

private extension PlantPhotoDraftContent {

	var photoCaptionInput: some View {
		TextEditorInput(inputLabel: "Description", labelDescription: "Optional", inputPlaceholder: "Start writing...", accentTheme: true, text: $photoDraftViewModel.caption)
	}

	var addPhotoButton: some View {
		Button("Add Photo") {
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			viewModel.postPhotoDraft()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(Color.theme.accentGreen)
	}

	var saveChangesButton: some View {
		Button("Save") {
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			viewModel.savePhotoEdit()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(photoDraftViewModel.captionEdited ? Color.theme.accentGreen : Color.theme.textSecondary.opacity(0.5))
		.disabled(!photoDraftViewModel.captionEdited)
	}

	var cancelButton: some View {
		Button {
			viewModel.cancelPhotoDraft()
		} label: {
			Text("Cancel")
				.font(.handjet(.medium, size: 20))
		}
		.foregroundStyle(Color.theme.textSecondary)
	}
}
