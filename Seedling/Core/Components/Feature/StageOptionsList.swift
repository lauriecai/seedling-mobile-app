//
//  StageSelectionList.swift
//  Seedling
//
//  Created by Laurie Cai on 5/28/24.
//

import SwiftUI

struct StageOptionsList<T>: View where T: Hashable & RawRepresentable & Definable, T.RawValue == String {
	
	let items: [T]
	
	let accentTheme: Bool

	let selectedPillLabel: String
	@Binding var selectedItem: T
	@Binding var selectedItemIndex: Int
	
	var body: some View {
		ScrollView(showsIndicators: false) {
			VStack(alignment: .leading, spacing: 10) {
				ForEach(Array(items.enumerated()), id: \.1) { index, item in
					CardSelectable(
						title: item.rawValue,
						description: item.definition,
						accentTheme: accentTheme,
						isSelected: index == selectedItemIndex
					)
					.onTapGesture {
						FirebaseEventManager.shared.logEvent(name: "CardSelectable_tapped")
						selectedItem = item
						selectedItemIndex = index
					}
				}
			}
		}
	}
}

#Preview {
	StageOptionsList(
		items: PlantStage.allCases,
		accentTheme: true,
		selectedPillLabel: "Selected",
		selectedItem: .constant(.seedling),
		selectedItemIndex: .constant(2)
	)
}
