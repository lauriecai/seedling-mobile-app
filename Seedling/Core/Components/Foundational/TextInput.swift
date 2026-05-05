//
//  TextInput.swift
//  Seedling
//
//  Created by Laurie Cai on 2/26/24.
//

import SwiftUI

struct TextInput: View {
	
	let inputLabel: String
	let labelDescription: String?
	
	let inputPlaceholder: String
	
	@Binding var text: String
	
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack {
				Text(inputLabel)
					.font(.handjet(.bold, size: 20))
					.foregroundStyle(Color.theme.textPrimary)
				
				if let description = labelDescription {
					Text("(\(description))")
						.font(.handjet(.regular, size: 18))
						.foregroundStyle(Color.theme.textSecondary)
				}
			}
			
			TextField("", text: $text, prompt: Text(inputPlaceholder).foregroundStyle(Color.theme.textSecondary))
					.font(.handjet(.medium, size: 20))
					.padding(.horizontal)
					.padding(.vertical, 10)
					.foregroundStyle(Color.theme.textPrimary)
					.background(Color.theme.backgroundAccent)
					.clipShape(RoundedRectangle(cornerRadius: 8))
					.autocorrectionDisabled()
		}
	}
}

#Preview(traits: .sizeThatFitsLayout) {
	ZStack {
		Color.theme.backgroundPrimary
			.ignoresSafeArea()
		
		TextInput(inputLabel: "Variety", labelDescription: "Optional", inputPlaceholder: "e.g. Beefsteak, Roma", text: .constant(""))
	}
}
