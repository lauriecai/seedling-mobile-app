//
//  AddTaskView.swift
//  Seedling
//
//  Created by Laurie Cai on 5/20/24.
//

import SwiftUI

struct AddTaskView: View {
	
	@ObservedObject var viewModel: TasksViewModel
	
	@Environment(\.dismiss) var dismiss
	
	@FocusState private var keyboardFocused: Bool
	
    var body: some View {
		NavigationStack {
			ZStack {
				Color.theme.backgroundPrimary
					.ignoresSafeArea()
				
				ScrollView(showsIndicators: false) {
					VStack(alignment: .leading, spacing: 15) {
						taskTitleInput
							.focused($keyboardFocused)
							.onAppear { keyboardFocused.toggle() }
						
						categorySelectionButton
					}
					.padding(.horizontal)
				}
			}
			.onAppear {
				FirebaseEventManager.shared.logEvent(name: "AddTaskView_appeared")
			}
			.navigationTitle(viewModel.editingExistingTask ? "Edit Task" : "New Task")
			.navigationBarTitleDisplayMode(.inline)
			.navigationBarBackButtonHidden(true)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) { cancelButton }
				ToolbarItem(placement: .topBarTrailing) {
					if viewModel.editingExistingTask {
						saveChangesButton
					} else {
						addTaskButton
					}
				}
			}
			.onChange(of: viewModel.taskTitleInput) { viewModel.taskDetailsEdited = true }
			.onChange(of: viewModel.selectedCategory) { viewModel.taskDetailsEdited = true }
		}
    }
}

#Preview {
    AddTaskView(viewModel: TasksViewModel())
}

extension AddTaskView {
	
//	MARK: - Add Task View
	
	private var taskTitleInput: some View {
		TextEditorInput(
			inputLabel: "Task Description",
			labelDescription: nil,
			inputPlaceholder: "e.g. Fertilize tomatoes",
			accentTheme: true,
			text: $viewModel.taskTitleInput
		)
	}
	
	private var categorySelectionButton: some View {
		NavigationLink(destination: CategorySelectionView(viewModel: viewModel)) {
			HStack {
				Text("Category")
					.font(.handjet(.bold, size: 20))
					.foregroundStyle(Color.theme.textPrimary)
				
				Spacer()
				
				HStack(spacing: 15) {
					Text(viewModel.selectedCategory?.wrappedName ?? "")
						.font(.handjet(.medium, size: 20))
					
					Text(">")
						.font(.handjet(.bold, size: 22))
				}
				.foregroundStyle(Color.theme.textSecondary)
			}
			.padding()
			.background(Color.theme.backgroundAccent)
			.clipShape(RoundedRectangle(cornerRadius: 8))
		}
	}
	
	private var addTaskButton: some View {
		Button("Add Task") {
			FirebaseEventManager.shared.logEvent(name: "addTaskButton_tapped")
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			
			viewModel.addTask(
				categoryName: viewModel.selectedCategory?.wrappedName ?? "",
				title: viewModel.taskTitleInput)
			
			dismiss()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(viewModel.taskTitleInput.isEmpty ? Color.theme.textSecondary.opacity(0.5) : Color.theme.accentGreen)
		.disabled(viewModel.taskTitleInput.isEmpty)
	}
	
	private var saveChangesButton: some View {
		Button("Save Changes") {
			FirebaseEventManager.shared.logEvent(name: "saveChangesButton_tapped")
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			
			if let selectedTask = viewModel.selectedTask {
				viewModel.updateTask(
					task: selectedTask,
					title: viewModel.taskTitleInput,
					categoryName: viewModel.selectedCategory?.wrappedName ?? ""
				)
				
				viewModel.resetTaskTitleAndCategoryNameInputsAndFlags()
			}
			dismiss()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(viewModel.taskDetailsEdited ? Color.theme.accentGreen : Color.theme.textSecondary.opacity(0.5))
		.disabled(!viewModel.taskDetailsEdited)
	}
	
	private var cancelButton: some View {
		Button("Cancel") {
			FirebaseEventManager.shared.logEvent(name: "cancelButton_tapped")
			dismiss()
			viewModel.resetTaskTitleAndCategoryNameInputsAndFlags()
		}
		.font(.handjet(.medium, size: 20))
		.foregroundStyle(Color.theme.textSecondary)
	}
}
