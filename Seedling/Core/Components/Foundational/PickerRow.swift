//
//  PickerRow.swift
//  Seedling
//

import SwiftUI

struct PickerRow: View {
	
	let prompt: String
	let selectedValue: String
	
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(prompt)
				.font(.handjet(.bold, size: 20))
				.foregroundStyle(Color.theme.textPrimary)
			
			cardContent
		}
	}
	
	private var cardContent: some View {
		HStack {
			Text(selectedValue)
				.font(.handjet(.medium, size: 20))
				.foregroundStyle(Color.theme.textPrimary)
			
			Spacer()
			
			ChevronRight()
				.font(.handjet(.bold, size: 16))
		}
		.padding()
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(Color.theme.backgroundAccent)
		.clipShape(RoundedRectangle(cornerRadius: 10))
	}
}

#Preview(traits: .sizeThatFitsLayout) {
	PickerRow(
		prompt: "Which plant is this for?",
		selectedValue: "None"
	)
	.padding()
}
