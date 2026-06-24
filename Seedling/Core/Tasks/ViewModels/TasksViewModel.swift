//
//  TasksViewModel.swift
//  Seedling
//
//  Created by Laurie Cai on 6/4/24.
//

import CoreData
import Foundation
import PostHog

@MainActor
class TasksViewModel: ObservableObject {
	
	let manager = CoreDataManager.shared
	
	// Tasks View
	@Published var taskCategories: [TaskCategory] = []
	
	// Task draft
	@Published var taskDraftViewModel = TaskDraftViewModel()
	
	@Published var showingActionSheet: Bool = false
	
	@Published var showingActionSheetForCategory: TaskCategory? = nil
	
	// Category Creation View
	@Published var taskCategoryInput: String = ""
	
	// Segues
	@Published var showingTaskDraftView: Bool = false
	
	@Published var selectedTask: TaskItem? = nil
	
	init() {
		fetchTaskCategories()
		ensureUnassignedCategory()

		taskDraftViewModel.selectDefaultCategory(from: taskCategories)
	}

	/// Guarantees exactly one flagged default category exists. Adopts a legacy
	/// string-named "None" row if present (migration), otherwise creates one.
	private func ensureUnassignedCategory() {
		guard !taskCategories.contains(where: { $0.isDefault }) else { return }

		if let legacy = taskCategories.first(where: { $0.name == "None" }) {
			manager.markCategoryAsDefault(legacy)
		} else {
			manager.addDefaultCategory()
		}
		fetchTaskCategories()
	}
	
	//	MARK: - Task Category functions
	
	func fetchTaskCategories() {
		let request = manager.requestTaskCategories()
		
		do {
			var categories = try manager.context.fetch(request)
			prioritizeUncategorizedTasks(in: &categories)
			
			taskCategories = categories
			if taskDraftViewModel.selectedCategory == nil {
				taskDraftViewModel.selectDefaultCategory(from: taskCategories)
			}
		} catch let error {
			print("Error fetching task categories from Core Data. \(error)")
		}
	}
	
	private func prioritizeUncategorizedTasks(in categories: inout [TaskCategory]) {
		if let defaultIndex = categories.firstIndex(where: { $0.isDefault }) {
			let defaultCategory = categories.remove(at: defaultIndex)

			categories.insert(defaultCategory, at: 0)
		}
	}
	
	func addTaskCategory(name: String) {
		guard !name.isEmpty else { return }

		manager.addTaskCategory(name: name)
		fetchTaskCategories()
	}
	
	func updateTaskCategoryName(taskCategory: TaskCategory, name: String) {
		manager.updateTaskCategory(taskCategory: taskCategory, name: name)
		fetchTaskCategories()
	}
	
	func deleteTaskCategory(taskCategory: TaskCategory) {
		guard !taskCategory.isDefault else { return }

		let fallback = taskCategories.first(where: { $0.isDefault })
		manager.deleteTaskCategory(taskCategory: taskCategory, reassignTasksTo: fallback)
		fetchTaskCategories()
	}
	
	//	MARK: - Task functions
	
	func beginTaskDraft() {
		resetTaskDraft()
		showingTaskDraftView = true
	}
	
	func beginEditingTask(_ task: TaskItem) {
		resetTaskDetailsChangedFlag()
		taskDraftViewModel = TaskDraftViewModel(existingTask: task, categories: taskCategories)
		showingTaskDraftView = true
	}
	
	func cancelTaskDraft() {
		resetTaskDraft()
		showingTaskDraftView = false
	}
	
	func postTaskDraft() {
		guard taskDraftViewModel.canSave else { return }
		taskDraftViewModel.createTask()
		resetTaskDraft()
		eraseCategoryNameInput()
		fetchTaskCategories()
		showingTaskDraftView = false
	}
	
	func updateTask(_ task: TaskItem) {
		taskDraftViewModel.updateTask(task)
		fetchTaskCategories()
	}
	
	func deleteTask(task: TaskItem) {
		PostHogSDK.shared.capture("task_deleted", properties: [
			"category": task.category?.wrappedName ?? "Uncategorized",
			"was_completed": task.isCompleted,
		])
		manager.deleteTask(task: task)
		fetchTaskCategories()
	}
	
	func resetTaskDraft() {
		taskDraftViewModel = TaskDraftViewModel()
		taskDraftViewModel.selectDefaultCategory(from: taskCategories)
	}
	
	func resetTaskDetailsChangedFlag() {
		taskDraftViewModel.taskDetailsEdited = false
	}
	
	func resetSelectedCategory() {
		taskDraftViewModel.selectDefaultCategory(from: taskCategories)
	}
	
	func eraseCategoryNameInput() {
		self.taskCategoryInput = ""
	}
}
