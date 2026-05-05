//
//  TextEditorInput.swift
//  Seedling
//
//  Created by Laurie Cai on 2/28/24.
//

import SwiftUI

struct TextEditorInput: View {
	
	let inputLabel: String?
	let labelDescription: String?
	
	let inputPlaceholder: String
	
	let accentTheme: Bool
	
	@Binding var text: String
	
	@FocusState private var inputFocused: Bool
	
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			if let header = inputLabel {
				HStack {
					Text(header)
						.font(.handjet(.bold, size: 20))
						.foregroundStyle(Color.theme.textPrimary)
					
					if let description = labelDescription {
						Text("(\(description))")
							.font(.handjet(.regular, size: 18))
							.foregroundStyle(Color.theme.textSecondary)
					}
				}
			}
			
			ZStack {
				TextEditor(text: $text)
					.font(.handjet(.medium, size: 20))
					.scrollContentBackground(.hidden)
					.padding(.horizontal, 11)
					.padding(.top, 6)
					.padding(.bottom, 12)
					.background(accentTheme ? Color.theme.backgroundAccent : Color.theme.backgroundGrey)
					.foregroundStyle(Color.theme.textPrimary)
					.frame(height: 200)
					.clipShape(RoundedRectangle(cornerRadius: 8))
					.focused($inputFocused)
				
				if text.isEmpty {
					Text(inputPlaceholder)
						.font(.handjet(.medium, size: 20))
						.foregroundStyle(accentTheme ? Color.theme.textSecondary : Color.theme.textGrey)
						.frame(maxWidth: .infinity, maxHeight: 200, alignment: .topLeading)
						.padding(.horizontal)
						.padding(.vertical, 14)
						.onTapGesture {
							inputFocused.toggle()
						}
				}
			}
		}
	}
}

#Preview {
	TextEditorInput(inputLabel: "How's your plant doing?", labelDescription: nil, inputPlaceholder: "Start writing...", accentTheme: true, text: .constant(""))
}
