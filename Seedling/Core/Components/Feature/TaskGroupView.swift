//
//  TaskGroupView.swift
//  Seedling
//
//  Created by Laurie Cai on 5/28/24.
//

import SwiftUI

struct TaskGroupView: View {
	
	let category: TaskCategory
	let viewModel: TasksViewModel
	
	@Binding var showingActionSheet: Bool
	@Binding var selectedTask: TaskItem?
	
	var body: some View {
		VStack(alignment: .leading, spacing: 15) {
			if category.wrappedName != "None" {
				Text(category.wrappedName)
					.font(.handjet(.extraBold, size: 24))
					.foregroundStyle(Color.theme.textPrimary)
			}
			
			VStack(alignment: .leading, spacing: 10) {
				ForEach(category.tasksList, id: \.customHash) { task in
					TaskRowView(
						task: task,
						showActionSheet: $showingActionSheet,
						showActionForTask: $selectedTask
					)
					.onTapGesture {
						UIImpactFeedbackGenerator(style: .light).impactOccurred()
						task.isCompleted.toggle()
						viewModel.fetchTaskCategories()
					}
					
					if task != category.tasksList.last {
						Divider()
					}
				}
			}
		}
	}
}
