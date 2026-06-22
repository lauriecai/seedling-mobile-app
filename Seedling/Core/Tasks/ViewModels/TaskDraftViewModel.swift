//
//  TaskDraftViewModel.swift
//  Seedling
//

import Foundation
import PostHog

@MainActor
class TaskDraftViewModel: ObservableObject {
	
	@Published var titleInput: String = ""
	@Published var selectedCategory: TaskCategory?
	@Published var selectedCategoryIndex: Int = 0
	
	@Published var editingExistingTask: Bool = false
	@Published var taskDetailsEdited: Bool = false
	
	private let coreDataManager = CoreDataManager.shared
	
	var canSave: Bool {
		!titleInput.isEmpty
	}
	
//	MARK: - Init
	
	init() {}
	
	init(existingTask: TaskItem, categories: [TaskCategory]) {
		titleInput = existingTask.wrappedTitle
		selectedCategory = existingTask.category
		selectedCategoryIndex = categories.firstIndex(where: { $0 == existingTask.category }) ?? 0
		editingExistingTask = true
	}
	
//	MARK: - Public Methods
	
	func selectDefaultCategory(from categories: [TaskCategory]) {
		selectedCategory = categories.first(where: { $0.name == "None" })
		selectedCategoryIndex = 0
	}
	
	func createTask() {
		coreDataManager.addTask(categoryName: selectedCategory?.wrappedName ?? "", title: titleInput)
		PostHogSDK.shared.capture("task_created", properties: [
			"category": selectedCategory?.wrappedName ?? "None",
		])
	}
	
	func updateTask(_ task: TaskItem) {
		coreDataManager.updateTask(task: task, title: titleInput, categoryName: selectedCategory?.wrappedName ?? "")
	}
}
