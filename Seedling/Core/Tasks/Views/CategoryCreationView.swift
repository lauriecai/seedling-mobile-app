//
//  CategoryCreationView.swift
//  Seedling
//
//  Created by Laurie Cai on 5/29/24.
//

import SwiftUI

struct CategoryCreationView: View {
	
	@ObservedObject var viewModel: TasksViewModel
	
	@Environment(\.dismiss) var dismiss
	
	@FocusState private var keyboardFocused: Bool
	
    var body: some View {
		NavigationStack {
			ZStack {
				Color.theme.backgroundPrimary
					.ignoresSafeArea()
				
				ScrollView(showsIndicators: false) {
					VStack(spacing: 15) {
						TextInput(
							inputLabel: "Category Name",
							labelDescription: nil, 
							inputPlaceholder: "e.g. Wishlist",
							text: $viewModel.taskCategoryInput
						)
						.focused($keyboardFocused)
						.onAppear { keyboardFocused.toggle() }
					}
					.padding(.horizontal)
				}
				.navigationTitle("New Category")
				.navigationBarTitleDisplayMode(.inline)
				.navigationBarBackButtonHidden(true)
				.toolbar {
					ToolbarItem(placement: .topBarLeading) { backButton }
					ToolbarItem(placement: .topBarTrailing) { createButton }
				}
				.onAppear {
					FirebaseEventManager.shared.logEvent(name: "CategoryCreationView_appeared")
					viewModel.eraseCategoryNameInput()
				}
			}
		}
    }
}

#Preview {
	CategoryCreationView(viewModel: TasksViewModel())
}

extension CategoryCreationView {
	
	private var createButton: some View {
		Button("Create") {
			FirebaseEventManager.shared.logEvent(name: "createButton_tapped")
			viewModel.addTaskCategory(name: viewModel.taskCategoryInput)
			viewModel.eraseCategoryNameInput()
			dismiss()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(viewModel.taskCategoryInput.isEmpty ? Color.theme.textSecondary.opacity(0.5) : Color.theme.accentGreen)
		.disabled(viewModel.taskCategoryInput.isEmpty)
	}
	
	private var backButton: some View {
		Button {
			FirebaseEventManager.shared.logEvent(name: "backButton_tapped")
			viewModel.resetSelectedCategory()
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
}
