//
//  TaskDraftView.swift
//  Seedling
//
//  Created by Laurie Cai on 5/20/24.
//

import SwiftUI

struct TaskDraftView: View {
	
	@ObservedObject var viewModel: TasksViewModel
	
	var body: some View {
		TaskDraftContent(
			viewModel: viewModel,
			taskDraftViewModel: viewModel.taskDraftViewModel
		)
	}
}

private struct TaskDraftContent: View {
	
	@ObservedObject var viewModel: TasksViewModel
	@ObservedObject var taskDraftViewModel: TaskDraftViewModel
	
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
						
						categoryPickerRow
					}
					.padding(.horizontal)
				}
			}
			.onAppear {
				FirebaseEventManager.shared.logEvent(name: "TaskDraftView_appeared")
			}
			.navigationTitle(taskDraftViewModel.editingExistingTask ? "Edit Task" : "New Task")
			.navigationBarTitleDisplayMode(.inline)
			.navigationBarBackButtonHidden(true)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) { cancelButton }
				ToolbarItem(placement: .topBarTrailing) {
					if taskDraftViewModel.editingExistingTask {
						saveChangesButton
					} else {
						addTaskButton
					}
				}
			}
			.onChange(of: taskDraftViewModel.titleInput) { taskDraftViewModel.taskDetailsEdited = true }
			.onChange(of: taskDraftViewModel.selectedCategory) { taskDraftViewModel.taskDetailsEdited = true }
		}
    }
}

#Preview {
    TaskDraftView(viewModel: TasksViewModel())
}

private extension TaskDraftContent {
	
//	MARK: - Task Draft View
	
	private var taskTitleInput: some View {
		TextEditorInput(
			inputLabel: "Task Description",
			labelDescription: nil,
			inputPlaceholder: "e.g. Fertilize tomatoes",
			accentTheme: true,
			text: $taskDraftViewModel.titleInput
		)
	}
	
	private var categoryPickerRow: some View {
		NavigationLink(destination: CategorySelectionView(viewModel: viewModel, taskDraftViewModel: taskDraftViewModel)) {
			PickerRow(
				prompt: "Category",
				selectedValue: taskDraftViewModel.selectedCategory?.wrappedName ?? "None"
			)
		}
		.buttonStyle(.plain)
	}
	
	private var addTaskButton: some View {
		Button("Add Task") {
			FirebaseEventManager.shared.logEvent(name: "addTaskButton_tapped")
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			
			viewModel.postTaskDraft()
			dismiss()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(taskDraftViewModel.canSave ? Color.theme.accentGreen : Color.theme.textSecondary.opacity(0.5))
		.disabled(!taskDraftViewModel.canSave)
	}
	
	private var saveChangesButton: some View {
		Button("Save") {
			FirebaseEventManager.shared.logEvent(name: "saveChangesButton_tapped")
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			
			if let selectedTask = viewModel.selectedTask {
				viewModel.updateTask(selectedTask)
				viewModel.resetTaskDraft()
			}
			dismiss()
		}
		.font(.handjet(.extraBold, size: 20))
		.foregroundStyle(taskDraftViewModel.taskDetailsEdited ? Color.theme.accentGreen : Color.theme.textSecondary.opacity(0.5))
		.disabled(!taskDraftViewModel.taskDetailsEdited)
	}
	
	private var cancelButton: some View {
		Button("Cancel") {
			FirebaseEventManager.shared.logEvent(name: "cancelButton_tapped")
			dismiss()
			viewModel.cancelTaskDraft()
		}
		.font(.handjet(.medium, size: 20))
		.foregroundStyle(Color.theme.textSecondary)
	}
}
