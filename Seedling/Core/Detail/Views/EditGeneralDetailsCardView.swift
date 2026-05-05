//
//  EditGeneralCardView.swift
//  Seedling
//
//  Created by Laurie Cai on 5/15/24.
//

import SwiftUI

struct EditGeneralDetailsCardView: View {
	
	@ObservedObject var viewModel: DetailViewModel
	
	@Environment(\.dismiss) var dismiss
	
    var body: some View {
		NavigationStack {
			ZStack {
				Color.white.ignoresSafeArea()
				
				ScrollView {
					VStack(alignment: .leading, spacing: 15) {
						header
						textPropertyInput(propertyName: "Name", propertyValue: $viewModel.plantNameInput)
						textPropertyInput(propertyName: "Variety", propertyValue: $viewModel.plantVarietyInput)
						typeSelectionRow
						stageSelectionList
					}
					.padding(.horizontal)
				}
			}
			.onAppear {
				FirebaseEventManager.shared.logEvent(name: "EditGeneralDetailsCardView_appeared")
			}
			.navigationBarBackButtonHidden(true)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) { cancelButton }
				ToolbarItem(placement: .topBarTrailing) { saveChangesButton }
			}
			.onChange(of: viewModel.plantNameInput) { viewModel.plantGeneralDetailsEdited = true }
			.onChange(of: viewModel.plantVarietyInput) { viewModel.plantGeneralDetailsEdited = true }
			.onChange(of: viewModel.selectedType) { viewModel.plantGeneralDetailsEdited = true }
			.onChange(of: viewModel.selectedStage) {
				viewModel.plantGeneralDetailsEdited = true
				viewModel.plantStageUpdated = true
			}
		}
    }
}

extension EditGeneralDetailsCardView {
	
	private var header: some View {
		HStack {
			Text("General")
				.font(.handjet(.extraBold, size: 24))
				.foregroundStyle(Color.theme.textPrimary)
			Spacer()
		}
	}
	
	private var typeSelectionRow: some View {
		VStack(alignment: .leading, spacing: 5) {
			Text("Type")
				.font(.handjet(.bold, size: 16))
				.foregroundStyle(Color.theme.textGrey)
			
			ButtonPillRow(rowLabel: nil, items: PlantType.allCases, accentTheme: false, selectedItem: $viewModel.selectedType, selectedIndex: $viewModel.selectedTypeIndex)
		}
	}
	
	private var stageSelectionList: some View {
		VStack(alignment: .leading, spacing: 5) {
			Text("Stage")
				.font(.handjet(.bold, size: 16))
				.foregroundStyle(Color.theme.textGrey)
			
			StageOptionsList(
				items: PlantStage.allCases,
				accentTheme: false,
				selectedPillLabel: "Selected",
				selectedItem: $viewModel.selectedStage,
				selectedItemIndex: $viewModel.selectedStageIndex
			)
		}
	}
	
	struct textPropertyInput: View {
		
		let propertyName: String
		let propertyValue: Binding<String>
		
		var body: some View {
			VStack(alignment: .leading, spacing: 5) {
				Text(propertyName)
					.font(.handjet(.bold, size: 16))
					.foregroundStyle(Color.theme.textGrey)
				
				TextField("", text: propertyValue)
					.font(.handjet(.medium, size: 20))
					.padding(.horizontal)
					.padding(.vertical, 10)
					.foregroundStyle(Color.theme.textPrimary)
					.background(Color.theme.backgroundGrey)
					.clipShape(RoundedRectangle(cornerRadius: 8))
					.autocorrectionDisabled()
			}
		}
	}
	
	private var saveChangesButton: some View {
		Button("Save") {
			FirebaseEventManager.shared.logEvent(name: "saveChangesButton_tapped")
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			
			if viewModel.plantGeneralDetailsEdited {
				viewModel.editPlantGeneralDetails(for: viewModel.plant)
			}
			
			if viewModel.plantStageUpdated {
				viewModel.updatePlantStage(for: viewModel.plant)
			}
			
			viewModel.resetPlantGeneralDetailsEditedFlag()
			dismiss()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(viewModel.plantGeneralDetailsEdited ? Color.theme.accentGreen : Color.theme.textSecondary.opacity(0.5))
		.disabled(!viewModel.plantGeneralDetailsEdited)
	}
	
	private var cancelButton: some View {
		Button("Cancel") {
			FirebaseEventManager.shared.logEvent(name: "cancelButton_tapped")
			viewModel.resetPlantGeneralDetailsEditedFlag()
			dismiss()
		}
		.font(.handjet(.medium, size: 20))
		.foregroundStyle(Color.theme.textGrey)
	}
}
