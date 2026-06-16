//
//  DetailStageDraftView.swift
//  Seedling
//
//  Created by Laurie Cai on 5/1/24.
//

import SwiftUI

struct DetailStageDraftView: View {

	@ObservedObject var viewModel: DetailViewModel

	var body: some View {
		DetailStageDraftContent(
			viewModel: viewModel,
			stageDraftViewModel: viewModel.stageDraftViewModel
		)
	}
}

private struct DetailStageDraftContent: View {

	@ObservedObject var viewModel: DetailViewModel
	@ObservedObject var stageDraftViewModel: StageDraftViewModel

	var body: some View {
		ZStack {
			Color.theme.backgroundPrimary
				.ignoresSafeArea()

			VStack {
				updateStagePrompt

				StageOptionsList(
					items: PlantStage.allCases,
					accentTheme: true,
					selectedPillLabel: "Selected",
					selectedItem: $stageDraftViewModel.selectedStage,
					selectedItemIndex: $stageDraftViewModel.selectedStageIndex
				)
			}
			.padding()
		}
		.navigationTitle("Update Stage")
		.navigationBarTitleDisplayMode(.inline)
		.navigationBarBackButtonHidden(true)
		.onAppear {
			FirebaseEventManager.shared.logEvent(name: "DetailStageDraftView_appeared")
		}
		.toolbar {
			ToolbarItem(placement: .topBarLeading) { cancelButton }
			ToolbarItem(placement: .topBarTrailing) { saveChangesButton }
		}
		.onChange(of: stageDraftViewModel.selectedStage) { _, newStage in
			guard let plant = stageDraftViewModel.plant else {
				stageDraftViewModel.updated = false
				return
			}
			let currentStage = PlantStage(rawValue: plant.wrappedStage) ?? .seedling
			stageDraftViewModel.updated = newStage != currentStage
		}
	}
}

private extension DetailStageDraftContent {

	var updateStagePrompt: some View {
		Text("Select a new stage:")
			.font(.handjet(.extraBold, size: 22))
			.foregroundStyle(Color.theme.textPrimary)
			.frame(maxWidth: .infinity, alignment: .leading)
	}

	var saveChangesButton: some View {
		Button("Save") {
			FirebaseEventManager.shared.logEvent(name: "saveChangesButton_tapped")
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			viewModel.postStageDraft()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(stageDraftViewModel.updated ? Color.theme.accentGreen : Color.theme.textSecondary.opacity(0.5))
		.disabled(!stageDraftViewModel.updated)
	}

	var cancelButton: some View {
		Button {
			FirebaseEventManager.shared.logEvent(name: "cancelButton_tapped")
			viewModel.cancelStageDraft()
		} label: {
			Text("Cancel")
				.font(.handjet(.medium, size: 20))
				.foregroundStyle(Color.theme.textSecondary)
		}
	}
}
