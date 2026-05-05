//
//  AddPlantView.swift
//  Seedling
//
//  Created by Laurie Cai on 2/9/24.
//

import SwiftUI

struct AddPlantView: View {
	
	@EnvironmentObject private var viewModel: HomeViewModel
	
	@Environment(\.dismiss) var dismiss
	
	@FocusState private var keyboardFocused: Bool
	
    var body: some View {
		NavigationStack {
			ZStack {
				Color.theme.backgroundPrimary
					.ignoresSafeArea()
				
				ScrollView(showsIndicators: false) {
					VStack(spacing: 15) {
						plantTextInput
							.focused($keyboardFocused)
							.onAppear { keyboardFocused.toggle() }
						
						plantVarietyInput
						
						if !viewModel.editingExistingPlant {
							plantStageSelection
							plantTypeSelection
						}
					}
					.padding(.horizontal)
				}
				.onAppear {
					FirebaseEventManager.shared.logEvent(name: "AddPlantView_appeared")
				}
				.navigationTitle(viewModel.editingExistingPlant ? "Edit Plant" : "New Plant")
				.navigationBarTitleDisplayMode(.inline)
				.navigationBarBackButtonHidden(true)
				.toolbar {
					ToolbarItem(placement: .topBarLeading) { cancelButton }
					ToolbarItem(placement: .topBarTrailing) {
						if viewModel.editingExistingPlant {
							saveChangesButton
						} else {
							addPlantButton
						}
					}
				}
				.onChange(of: viewModel.plantNameInput) { viewModel.plantDetailsEdited = true }
				.onChange(of: viewModel.plantVarietyInput) { viewModel.plantDetailsEdited = true }
				.keyboardType(.default)
				.autocorrectionDisabled()
			}
		}
	}
}

#Preview {
    AddPlantView()
}

extension AddPlantView {
	
	private var plantTextInput: some View {
		TextInput(inputLabel: "Name", labelDescription: nil, inputPlaceholder: "e.g. Tomato", text: $viewModel.plantNameInput)
	}
	
	private var plantVarietyInput: some View {
		TextInput(inputLabel: "Variety", labelDescription: "Optional", inputPlaceholder: "e.g. Beefsteak, Roma", text: $viewModel.plantVarietyInput)
	}
	
	private var plantStageSelection: some View {
		VStack(alignment: .leading, spacing: 8) {
			ButtonPillRow(rowLabel: "Stage", items: PlantStage.allCases, accentTheme: true, selectedItem: $viewModel.selectedStage, selectedIndex: $viewModel.selectedStageIndex)
			
			selectedPlantStageDefinition
		}
	}
	
	private var selectedPlantStageDefinition: some View {
		Text(viewModel.selectedStage.definition)
			.font(.handjet(.medium, size: 18))
			.foregroundStyle(Color.theme.textSecondary)
	}
	
	private var plantTypeSelection: some View {
		VStack(alignment: .leading, spacing: 10) {
			ButtonPillRow(rowLabel: "Type", items: PlantType.allCases, accentTheme: true, selectedItem: $viewModel.selectedType, selectedIndex: $viewModel.selectedTypeIndex)
		}
	}
	
	private var addPlantButton: some View {
		Button("Add Plant") {
			FirebaseEventManager.shared.logEvent(name: "addPlantButton_tapped")
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			viewModel.addPlant(
				name: viewModel.plantNameInput,
				variety: viewModel.plantVarietyInput,
				stage: viewModel.selectedStage.rawValue,
				type: viewModel.selectedType.rawValue
			)
			dismiss()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(viewModel.plantNameInput.isEmpty ? Color.theme.textSecondary.opacity(0.5) : Color.theme.accentGreen)
		.disabled(viewModel.plantNameInput.isEmpty)
	}
	
	private var saveChangesButton: some View {
		Button("Save Changes") {
			FirebaseEventManager.shared.logEvent(name: "saveChangesButton_tapped")
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			
			if let selectedPlant = viewModel.selectedPlant {
				viewModel.updatePlantNameAndVariety(
					for: selectedPlant,
					name: viewModel.plantNameInput,
					variety: viewModel.plantVarietyInput
				)
				
				viewModel.resetAddPlantFormInputsAndFlags()
			}
			dismiss()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(viewModel.plantDetailsEdited ? Color.theme.accentGreen : Color.theme.textSecondary.opacity(0.5))
		.disabled(!viewModel.plantDetailsEdited)
	}
	
	private var cancelButton: some View {
		Button("Cancel") {
			FirebaseEventManager.shared.logEvent(name: "cancelButton_tapped")
			viewModel.resetAddPlantFormInputsAndFlags()
			dismiss()
		}
		.font(.handjet(.medium, size: 20))
		.foregroundStyle(Color.theme.textSecondary)
	}
}
