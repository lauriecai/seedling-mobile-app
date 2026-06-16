//
//  PlantSelectionView.swift
//  Seedling
//

import SwiftUI

struct PlantSelectionConfiguration {
	let allowsNone: Bool
	let allowsNewPlant: Bool
}

struct PlantSelectionView: View {
	
	let plants: [Plant]
	let configuration: PlantSelectionConfiguration
	@Binding var selectedPlant: Plant?
	var onRequestNewPlant: (() -> Void)?
	
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		ZStack {
			Color.theme.backgroundPrimary
				.ignoresSafeArea()
			
			ScrollView(showsIndicators: false) {
				VStack(alignment: .leading, spacing: 10) {
					if configuration.allowsNone {
						noneRow
					}
					
					ForEach(plants, id: \.customHash) { plant in
						plantRow(for: plant)
					}
				}
				.padding()
			}
		}
		.navigationTitle("Plants")
		.navigationBarTitleDisplayMode(.inline)
		.navigationBarBackButtonHidden(true)
		.toolbar {
			ToolbarItem(placement: .topBarLeading) { backButton }
			if configuration.allowsNewPlant {
				ToolbarItem(placement: .topBarTrailing) { newPlantButton }
			}
		}
	}
	
	private var noneRow: some View {
		CardSelectable(
			title: "None",
			description: nil,
			accentTheme: true,
			isSelected: selectedPlant == nil
		)
		.onTapGesture {
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			selectedPlant = nil
			dismiss()
		}
	}
	
	private func plantRow(for plant: Plant) -> some View {
		CardSelectable(
			title: plant.wrappedFullNameLabel,
			description: plant.wrappedStage,
			accentTheme: true,
			isSelected: selectedPlant?.objectID == plant.objectID
		)
		.onTapGesture {
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			selectedPlant = plant
			dismiss()
		}
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
	
	private var newPlantButton: some View {
		Button("New Plant") {
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			onRequestNewPlant?()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(Color.theme.accentGreen)
	}
}
