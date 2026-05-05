//
//  StageCardView.swift
//  Seedling
//
//  Created by Laurie Cai on 5/1/24.
//

import SwiftUI

struct CardSelectable: View {
	
	let title: String
	let description: String?
	
	let accentTheme: Bool
	
	let isSelected: Bool
	
    var body: some View {
		VStack(alignment: .leading, spacing: 5) {
			HStack(spacing: 8) {
				Text(title)
					.font(.handjet(.bold, size: 22))
					.foregroundStyle(Color.theme.textPrimary)
				
				if isSelected {
					TextPill(label: "Selected", backgroundColor: accentTheme ? Color.theme.accentYellow : Color.theme.accentLightGreen)
				}
			}
			
			if let description = description {
				Text(description)
					.font(.handjet(.medium, size: 18))
					.foregroundStyle(Color.theme.textPrimary)
			}
		}
		.padding()
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(accentTheme ? Color.theme.backgroundAccent : Color.theme.backgroundGrey)
		.overlay(isSelected ? selectedBorder : nil)
		.clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
	ScrollView(showsIndicators: false) {
		VStack {
			CardSelectable(
				title: "Seed",
				description: "A small object from which a new plant can grow.", 
				accentTheme: true,
				isSelected: true
			)
		}
	}
}

extension CardSelectable {
	
	private var selectedBorder: some View {
		RoundedRectangle(cornerRadius: 8)
			.stroke(Color.theme.textPrimary, lineWidth: 8)
	}
}
