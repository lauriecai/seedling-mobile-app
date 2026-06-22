//
//  PlantDetailsView.swift
//  Seedling
//
//  Created by Laurie Cai on 5/9/24.
//

import PostHog
import SwiftUI

struct PlantDetailsView: View {
	
	@ObservedObject var viewModel: PlantViewModel
	
	@Environment(\.dismiss) var dismiss
	
    var body: some View {
		ZStack {
			Color.theme.backgroundPrimary
				.ignoresSafeArea()
			
			ScrollView {
				VStack(spacing: 10) {
					generalDetailsCard
					careRequirementsCard
					additionalCareNotesCard
				}
				.padding(.horizontal)
				.padding(.bottom, 110)
			}
		}
		.navigationTitle("Plant Details")
		.navigationBarBackButtonHidden(true)
		.toolbar {
			ToolbarItem(placement: .topBarLeading) { backButton }
		}
		.sheet(isPresented: $viewModel.editingGeneralDetails) { 
			EditGeneralDetailsCardView(viewModel: viewModel)
		}
		.sheet(isPresented: $viewModel.editingCareRequirements) {
			EditCareRequirementsCardView(viewModel: viewModel)
		}
		.sheet(isPresented: $viewModel.editingAdditionalCareNotes) {
			EditAdditionalCareNotesView(viewModel: viewModel)
		}
		.onAppear { PostHogSDK.shared.screen("Plant Details") }
    }
}

extension PlantDetailsView {
	
	private var generalDetailsCard: some View {
		VStack(alignment: .leading, spacing: 15) {
			generalDetailsCardHeader
			generalDetailsCardProperties
		}
		.padding()
		.background(Color.white)
		.clipShape(RoundedRectangle(cornerRadius: 8))
	}
	
	private var generalDetailsCardHeader: some View {
		HStack {
			CardTitle(title: "General")
			Spacer()
			editGeneralDetailsButton
		}	
	}
	
	private var generalDetailsCardProperties: some View {
		VStack(alignment: .leading, spacing: 15) {
			PropertyLabel(label: "Name", value: viewModel.plant.wrappedName)
			PropertyLabel(label: "Variety", value: viewModel.plant.wrappedVariety.isEmpty ? "-" : viewModel.plant.wrappedVariety)
			PropertyLabel(label: "Type", value: viewModel.plant.wrappedType)
			PropertyLabel(label: "Stage", value: viewModel.plant.wrappedStage)
		}
	}
	
	private var editGeneralDetailsButton: some View {
		Button("Edit") {
			viewModel.resetPlantGeneralDetailsEditedFlag()
			
			viewModel.editingGeneralDetails = true
			viewModel.fetchPlantGeneralDetails(for: viewModel.plant)
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(Color.theme.accentGreen)
	}
	
	private var saveGeneralDetailsButton: some View {
		Button("Save") {
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			if viewModel.plantGeneralDetailsEdited {
				viewModel.editPlantGeneralDetails(for: viewModel.plant)
			}
			viewModel.resetPlantGeneralDetailsEditedFlag()
			dismiss()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(viewModel.plantGeneralDetailsEdited ? Color.theme.accentGreen : Color.theme.textSecondary.opacity(0.5))
		.disabled(!viewModel.plantGeneralDetailsEdited)
	}
	
	private var careRequirementsCard: some View {
		VStack(alignment: .leading, spacing: 15) {
			careRequirementsCardHeader
			careRequirementsCardProperties
		}
		.padding()
		.background(Color.white)
		.clipShape(RoundedRectangle(cornerRadius: 8))
	}
	
	private var careRequirementsCardHeader: some View {
		HStack {
			CardTitle(title: "Care Requirements")
			Spacer()
			editCareRequirementsButton
		}
	}
	
	private var careRequirementsCardProperties: some View {
		VStack(alignment: .leading, spacing: 15) {
			PropertyLabel(iconName: "sun.max", label: "Sunlight", value: viewModel.plant.wrappedSunlightRequirement.isEmpty ? "-" : viewModel.plant.wrappedSunlightRequirement)
			Divider()
			PropertyLabel(iconName: "thermometer.medium", label: "Temperature", value: viewModel.plant.wrappedTemperatureRequirement.isEmpty ? "-" :  viewModel.plant.wrappedTemperatureRequirement)
			Divider()
			PropertyLabel(iconName: "drop", label: "Water", value: viewModel.plant.wrappedWaterRequirement.isEmpty ? "-" :  viewModel.plant.wrappedWaterRequirement)
			Divider()
			PropertyLabel(iconName: "humidity", label: "Humidity", value: viewModel.plant.wrappedHumidityRequirement.isEmpty ? "-" :  viewModel.plant.wrappedHumidityRequirement)
			Divider()
			PropertyLabel(iconName: "button.angledbottom.horizontal.right", label: "Soil", value: viewModel.plant.wrappedSoilRequirement.isEmpty ? "-" :  viewModel.plant.wrappedSoilRequirement)
			Divider()
			PropertyLabel(iconName: "aqi.low", label: "Fertilizer", value: viewModel.plant.wrappedFertilizerRequirement.isEmpty ? "-" :  viewModel.plant.wrappedFertilizerRequirement)
		}
	}
	
	private var saveCareRequirementsButton: some View {
		Button("Save") {
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			if viewModel.plantCareRequirementsEdited {
				viewModel.editPlantCareRequirements(for: viewModel.plant)
			}
			viewModel.resetPlantCareRequirementsEditedFlag()
			dismiss()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(viewModel.plantCareRequirementsEdited ? Color.theme.accentGreen : Color.theme.textSecondary.opacity(0.5))
		.disabled(!viewModel.plantCareRequirementsEdited)
	}
	
	private var editCareRequirementsButton: some View {
		Button("Edit") {
			viewModel.resetPlantCareRequirementsEditedFlag()
			
			viewModel.editingCareRequirements = true
			viewModel.fetchPlantCareRequirements(for: viewModel.plant)
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(Color.theme.accentGreen)
	}
	
	private var additionalCareNotesCard: some View {
		VStack(alignment: .leading, spacing: 15) {
			additionalCareNotesCardHeader
			additionalCareNotes
		}
		.padding()
		.background(Color.white)
		.clipShape(RoundedRectangle(cornerRadius: 8))
	}
	
	private var additionalCareNotesCardHeader: some View {
		HStack {
			CardTitle(title: "Additional Care Notes")
			Spacer()
			editAdditionalCareNotesButton
		}
	}
	
	private var additionalCareNotes: some View {
		Text(viewModel.plant.additionalCareNotes ?? "-")
			.font(.handjet(.medium, size: 20))
			.foregroundStyle(Color.theme.textPrimary)
	}
	
	private var editAdditionalCareNotesButton: some View {
		Button("Edit") {
			viewModel.resetPlantAdditionalCareNotesEditedFlag()

			viewModel.editingAdditionalCareNotes = true
			viewModel.fetchPlantAdditionalCareNotes(for: viewModel.plant)
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(Color.theme.accentGreen)
	}
	
	private var saveAdditionalCareNotesButton: some View {
		Button("Save") {
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			if viewModel.plantAdditionalCareNotesEdited {
				viewModel.editPlantAdditionalCareNotes(for: viewModel.plant)
			}
			viewModel.resetPlantAdditionalCareNotesEditedFlag()
			dismiss()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(viewModel.plantAdditionalCareNotesEdited ? Color.theme.accentGreen : Color.theme.textSecondary.opacity(0.5))
		.disabled(!viewModel.plantAdditionalCareNotesEdited)
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
	
	struct CardTitle: View {
		
		let title: String
		
		var body: some View {
			Text(title)
				.font(.handjet(.extraBold, size: 22))
				.foregroundStyle(Color.theme.textPrimary)
		}
	}
	
	struct PropertyLabel: View {
		
		let iconName: String?
		let label: String
		let value: String
		
		init(label: String, value: String) {
			self.iconName = nil
			self.label = label
			self.value = value
		}
		init(iconName: String, label: String, value: String) {
			self.iconName = iconName
			self.label = label
			self.value = value
		}
		
		var body: some View {
			HStack(alignment: .top, spacing: 10) {
				
				if let image = iconName {
					ZStack {
						Color.theme.textGrey.opacity(0.25)
							.frame(width: 40, height: 40)
							.clipShape(RoundedRectangle(cornerRadius: 8))
						
						Image(systemName: image)
							.resizable()
							.scaledToFit()
							.frame(width: 20, height: 20)
							.foregroundStyle(Color.theme.textPrimary)
					}
				}
				
				VStack(alignment: .leading, spacing: 2) {
					Text(label)
						.font(.handjet(.bold, size: 16))
						.foregroundStyle(Color.theme.textGrey)
					
					Text(value)
						.font(.handjet(.medium, size: 20))
						.foregroundStyle(Color.theme.textPrimary)
				}
			}
		}
	}
}
