//
//  PlantPickerRow.swift
//  Seedling
//

import SwiftUI

private enum PlantPickerRoute: Hashable {
	case selection
}

struct PlantPickerRow: View {

	let plants: [Plant]
	let configuration: PlantSelectionConfiguration
	@Binding var selectedPlant: Plant?
	var onPlantSelected: (() -> Void)? = nil
	var onRequestNewPlant: (() -> Void)? = nil

	var body: some View {
		NavigationLink(value: PlantPickerRoute.selection) {
			PickerRow(
				prompt: "Which plant is this for?",
				selectedValue: selectedPlant?.wrappedFullNameLabel ?? "None"
			)
		}
		.buttonStyle(.plain)
		.navigationDestination(for: PlantPickerRoute.self) { _ in
			PlantSelectionView(
				plants: plants,
				configuration: configuration,
				selectedPlant: $selectedPlant,
				onRequestNewPlant: onRequestNewPlant
			)
			.onDisappear { onPlantSelected?() }
		}
	}
}
