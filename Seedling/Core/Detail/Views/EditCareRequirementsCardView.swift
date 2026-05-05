//
//  EditCareRequirementsCardView.swift
//  Seedling
//
//  Created by Laurie Cai on 5/15/24.
//

import SwiftUI

struct EditCareRequirementsCardView: View {
	
	@ObservedObject var viewModel: DetailViewModel
	
	@Environment(\.dismiss) var dismiss
	
    var body: some View {
		NavigationStack {
			ZStack {
				Color.white.ignoresSafeArea()
				
				ScrollView {
					VStack(alignment: .leading, spacing: 15) {
						header
						textPropertyInput(iconName: "sun.max", propertyName: "Sunlight", propertyValue: $viewModel.sunlightRequirementInput)
						textPropertyInput(iconName: "thermometer.medium", propertyName: "Temperature", propertyValue: $viewModel.temperatureRequirementInput)
						textPropertyInput(iconName: "drop", propertyName: "Water", propertyValue: $viewModel.waterRequirementInput)
						textPropertyInput(iconName: "humidity", propertyName: "Humidity", propertyValue: $viewModel.humidityRequirementInput)
						textPropertyInput(iconName: "button.angledbottom.horizontal.right", propertyName: "Soil", propertyValue: $viewModel.soilRequirementInput)
						textPropertyInput(iconName: "aqi.low", propertyName: "Fertilizer", propertyValue: $viewModel.fertilizerRequirementInput)
					}
					.padding(.horizontal)
					.onAppear {
						FirebaseEventManager.shared.logEvent(name: "EditCareRequirementsCardView_appeared")
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
							viewModel.activateTextFieldEditModeForAll()
						}
					}
				}
			}
			.navigationBarBackButtonHidden(true)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) { cancelButton }
				ToolbarItem(placement: .topBarTrailing) { saveChangesButton }
			}
			.onChange(of: viewModel.sunlightRequirementInput) { viewModel.plantCareRequirementsEdited = true }
			.onChange(of: viewModel.temperatureRequirementInput) { viewModel.plantCareRequirementsEdited = true }
			.onChange(of: viewModel.waterRequirementInput) { viewModel.plantCareRequirementsEdited = true }
			.onChange(of: viewModel.humidityRequirementInput) { viewModel.plantCareRequirementsEdited = true }
			.onChange(of: viewModel.soilRequirementInput) { viewModel.plantCareRequirementsEdited = true }
			.onChange(of: viewModel.fertilizerRequirementInput) { viewModel.plantCareRequirementsEdited = true }
		}
    }
}

extension EditCareRequirementsCardView {
	
	private var header: some View {
		HStack {
			Text("Care Requirements: \(viewModel.plant.wrappedName)")
				.font(.handjet(.extraBold, size: 24))
				.foregroundStyle(Color.theme.textPrimary)
			Spacer()
		}
	}
	
	struct textPropertyInput: View {
		
		let iconName: String
		let propertyName: String
		let propertyValue: Binding<String>
		
		var body: some View {
			VStack(alignment: .leading, spacing: 5) {
				HStack {
					Image(systemName: iconName)
						.resizable()
						.scaledToFit()
						.frame(width: 18, height: 18)
						.foregroundStyle(Color.theme.textPrimary)
						.fontWeight(.bold)
					
					Text(propertyName)
						.font(.handjet(.bold, size: 16))
						.foregroundStyle(Color.theme.textPrimary)
				}
				.padding(.vertical, 5)
				
				TextEditor(text: propertyValue)
					.font(.handjet(.medium, size: 20))
					.scrollContentBackground(.hidden)
					.padding(.horizontal, 12)
					.padding(.vertical, 4)
					.frame(minHeight: 50, maxHeight: .infinity)
					.background(Color.theme.backgroundGrey)
					.foregroundStyle(Color.theme.textPrimary)
					.clipShape(RoundedRectangle(cornerRadius: 8))
			}
		}
	}
	
	private var saveChangesButton: some View {
		Button("Save") {
			FirebaseEventManager.shared.logEvent(name: "saveChangesButton_tapped")
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			if viewModel.plantCareRequirementsEdited {
				viewModel.editPlantCareRequirements(for: viewModel.plant)
			}
			viewModel.removeExtraneousSpaceForAll()
			viewModel.resetPlantCareRequirementsEditedFlag()
			dismiss()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(viewModel.plantCareRequirementsEdited ? Color.theme.accentGreen : Color.theme.textSecondary.opacity(0.5))
		.disabled(!viewModel.plantCareRequirementsEdited)
	}
	
	private var cancelButton: some View {
		Button("Cancel") {
			FirebaseEventManager.shared.logEvent(name: "cancelButton_tapped")
			viewModel.removeExtraneousSpaceForAll()
			viewModel.resetPlantGeneralDetailsEditedFlag()
			dismiss()
		}
		.font(.handjet(.medium, size: 20))
		.foregroundStyle(Color.theme.textGrey)
	}
}
