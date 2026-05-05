//
//  CategorySelectionCard.swift
//  Seedling
//
//  Created by Laurie Cai on 6/2/24.
//

import SwiftUI

struct CategoryOptionCard: View {
	
	let category: TaskCategory
	
	let isSelected: Bool
	
	@Binding var showActionSheet: Bool
	@Binding var showActionForCategory: TaskCategory?
	
	var body: some View {
		VStack(alignment: .leading, spacing: 5) {
			HStack(spacing: 8) {
				Text(category.wrappedName)
					.font(.handjet(.bold, size: 22))
					.foregroundStyle(Color.theme.textPrimary)
				
				if !category.tasksList.isEmpty {
					Text("\(category.tasksList.count) \(taskString)")
						.font(.handjet(.bold, size: 18))
						.foregroundStyle(Color.theme.textSecondary)
				}
				
				if isSelected {
					TextPill(label: "Selected", backgroundColor: Color.theme.accentYellow)
				}
				
				Spacer()
				
				if category.wrappedName != "None" {
					Button {
						showActionSheet = true
						showActionForCategory = category
					} label: {
						MenuKebab()
							.frame(maxHeight: .infinity)
							.rotationEffect(.degrees(-90))
					}
				}
			}
		}
		.padding()
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(Color.theme.backgroundAccent)
		.overlay(isSelected ? selectedBorder : nil)
		.clipShape(RoundedRectangle(cornerRadius: 8))
	}
}

extension CategoryOptionCard {
	
	private var selectedBorder: some View {
		RoundedRectangle(cornerRadius: 8)
			.stroke(Color.theme.textPrimary, lineWidth: 8)
	}
	
	private var taskString: String {
		category.tasksList.count >= 2 ? "tasks" : "task"
	}
}
//
//struct CardSelectable: View {
//	
//	let title: String
//	let description: String?
//	
//	let accentTheme: Bool
//	
//	let isSelected: Bool
//	
//	let isActionable: Bool
//	
//	let showActionSheetForCategory: TaskCategory
//	@Binding var showActionSheet: Bool
//	
//	init(title: String, description: String?, accentTheme: Bool, isSelected: Bool) {
//		self.title = title
//		self.description = description
//		self.accentTheme = accentTheme
//		self.isSelected = isSelected
//		self.isActionable = false
//		self._showActionSheet = .constant(false)
//		self._showActionSheetForCategory = .constant(nil)
//	}
//	
//	init(title: String, accentTheme: Bool, isSelected: Bool, isActionable: Bool, showActionSheetForCategory: Category, showActionSheet: Binding<Bool>) {
//		self.title = title
//		self.accentTheme = accentTheme
//		self.isSelected = isSelected
//		self.description = nil
//		self.isActionable = isActionable
//		self.showActionSheetForCategory = showActionSheetForCategory
//		self._showActionSheet = showActionSheet
//	}
//	
//	var body: some View {
//		VStack(alignment: .leading, spacing: 5) {
//			HStack(spacing: 8) {
//				Text(title)
//					.font(.handjet(.bold, size: 20))
//					.foregroundStyle(Color.theme.textPrimary)
//				
//				if isSelected {
//					TextPill(label: "Selected", backgroundColor: accentTheme ? Color.theme.accentYellow : Color.theme.accentLightGreen)
//				}
//				
//				if isActionable {
//					Spacer()
//					
//					Button {
//						showActionSheet = true
//					} label: {
//						MenuKebab()
//							.frame(maxHeight: .infinity)
//							.rotationEffect(.degrees(-90))
//					}
//				}
//			}
//			
//			if let description = description {
//				Text(description)
//					.font(.handjet(.medium, size: 18))
//					.foregroundStyle(Color.theme.textPrimary)
//			}
//		}
//		.padding()
//		.frame(maxWidth: .infinity, alignment: .leading)
//		.background(accentTheme ? Color.theme.backgroundAccent : Color.theme.backgroundGrey)
//		.overlay(isSelected ? selectedBorder : nil)
//		.clipShape(RoundedRectangle(cornerRadius: 8))
//	}
//}
//
//#Preview {
//	ScrollView(showsIndicators: false) {
//		VStack {
//			CardSelectable(
//				title: "Seed",
//				description: "A small object from which a new plant can grow.",
//				accentTheme: true,
//				isSelected: true
//			)
//		}
//	}
//}
//
//extension CardSelectable {
//	
//	private var selectedBorder: some View {
//		RoundedRectangle(cornerRadius: 8)
//			.stroke(Color.theme.textPrimary, lineWidth: 8)
//	}
//}
