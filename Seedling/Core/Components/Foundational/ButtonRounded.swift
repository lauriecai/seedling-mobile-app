//
//  ButtonRounded.swift
//  Seedling
//
//  Created by Laurie Cai on 3/20/24.
//

import SwiftUI

struct ButtonRounded: View {
	
	enum Style {
		case light
		case green
		
		var foregroundColor: Color {
			switch self {
			case .light: Color.theme.accentGreen
			case .green: Color.theme.textWhite
			}
		}
		
		var backgroundColor: Color {
			switch self {
			case .light: Color.theme.backgroundLight
			case .green: Color.theme.accentGreen
			}
		}
	}
	
	let iconName: String?
	let text: String
	let style: Style
	init(text: String, style: Style = .light) {
		self.text = text
		self.iconName = nil
		self.style = style
	}

	init(iconName: String, text: String, style: Style = .light) {
		self.iconName = iconName
		self.text = text
		self.style = style
	}
	
    var body: some View {
		HStack(spacing: 12) {
			if let iconName = iconName {
				Image(systemName: iconName)
					.bold()
			}
			
			Text(text)
				.font(.handjet(.bold, size: 20))
				.frame(height: 65)
		}
		.frame(height: 65)
		.padding(.horizontal, 20)
		.foregroundStyle(style.foregroundColor)
		.background(style.backgroundColor)
		.clipShape(
			RoundedRectangle(cornerRadius: 100)
		)
		.shadow(color: .black.opacity(0.10), radius: 5, x: 0, y: 5)
    }
}

#Preview {
	ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
		Color.theme.backgroundPrimary
			.ignoresSafeArea()
		
		VStack(alignment: .trailing, spacing: 20) {
			VStack(alignment: .trailing, spacing: 12) {
				ButtonRounded(iconName: "pencil", text: "Add Note")
				ButtonRounded(iconName: "photo.fill", text: "Add Photo")
				ButtonRounded(iconName: "sparkles", text: "Update Stage")
			}
			
			ButtonCircle(iconName: "icon-plus")
		}
		.padding(.horizontal, 20)
		.padding(.bottom, 20)
	}
}
