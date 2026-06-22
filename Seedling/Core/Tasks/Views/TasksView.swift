//
//  TasksView.swift
//  Seedling
//
//  Created by Laurie Cai on 5/21/24.
//

import PostHog
import SwiftUI

struct TasksView: View {
	
	@StateObject private var viewModel = TasksViewModel()
	@Environment(\.tasksPopToRootSignal) private var tasksPopToRootSignal
	
	@State private var navigationPath = NavigationPath()
	
    var body: some View {
		NavigationStack(path: $navigationPath) {
			ZStack(alignment: .bottomTrailing) {
				Color.theme.backgroundPrimary
					.ignoresSafeArea()
				
				VStack(alignment: .leading, spacing: 20) {
					tasksHeader
					
					if viewModel.taskCategories.count <= 1 {
						nullState
					} else {
						tasksList
					}
				}
				.padding(.horizontal)
				
				addTaskButton
			}
			.onAppear {
				viewModel.fetchTaskCategories()
				PostHogSDK.shared.screen("Tasks")
			}
			.sheet(isPresented: $viewModel.showingTaskDraftView) {
				NavigationView {
					TaskDraftView(viewModel: viewModel)
				}
			}
			.confirmationDialog("Task Options", isPresented: $viewModel.showingActionSheet) {
				editTaskButton
				deleteTaskButton
			} message: {
				Text("What do you want to do with this task?")
			}
			.onChange(of: tasksPopToRootSignal) { _, _ in
				navigationPath = NavigationPath()
			}
		}
    }
}

#Preview {
    TasksView()
}

extension TasksView {
	
	private var tasksHeader: some View {
		Text("Tasks")
			.font(.handjet(.extraBold, size: 32))
			.foregroundStyle(Color.theme.textPrimary)
			.frame(maxWidth: .infinity, alignment: .leading)
	}
	
	private var nullState: some View {
		VStack(alignment: .center, spacing: 10) {
			Spacer()
			Text("Keep track of your tasks")
				.font(.handjet(.extraBold, size: 22))
				.foregroundStyle(Color.theme.textPrimary)
			Text("Add one to get started!")
				.font(.handjet(.medium, size: 20))
				.foregroundStyle(Color.theme.textPrimary)
				.padding(.bottom, 40)
			Spacer()
		}
		.frame(maxWidth: .infinity, alignment: .center)
		.multilineTextAlignment(.center)
		.lineSpacing(5)
	}
	
	private var tasksList: some View {
		ScrollView(showsIndicators: false) {
			VStack(alignment: .leading, spacing: 25) {
				ForEach(viewModel.taskCategories, id: \.customHash) { category in
					if !category.tasksList.isEmpty {
						TaskGroupView(
							category: category,
							viewModel: viewModel,
							showingActionSheet: $viewModel.showingActionSheet,
							selectedTask: $viewModel.selectedTask
						)
					}
				}
			}
			.padding(.bottom, 100)
		}
	}
	
	private var addTaskButton: some View {
		ButtonCircle(iconName: "icon-plus")
			.frame(width: 65, height: 65)
			.padding(.trailing, 20)
			.padding(.bottom, 85)
			.onTapGesture {
				UIImpactFeedbackGenerator(style: .light).impactOccurred()
				viewModel.beginTaskDraft()
			}
	}
	
	private var editTaskButton: some View {
		Button("Edit Task") {
			viewModel.resetTaskDetailsChangedFlag()
			
			if let selectedTask = viewModel.selectedTask {
				viewModel.beginEditingTask(selectedTask)
			}
		}
	}
	
	private var deleteTaskButton: some View {
		Button("Delete Task", role: .destructive) {
			if let selectedTask = viewModel.selectedTask {
				withAnimation(Animation.bouncy(duration: 0.25, extraBounce: 0.10)) {
					viewModel.deleteTask(task: selectedTask)
				}
			}
		}
	}
}
