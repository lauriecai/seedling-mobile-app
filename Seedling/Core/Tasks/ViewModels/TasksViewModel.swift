//
//  TasksViewModel.swift
//  Seedling
//
//  Created by Laurie Cai on 6/4/24.
//

import CoreData
import Foundation

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
		
		if !taskCategories.contains(where: { $0.name == "None" }) {
			manager.addTaskCategory(name: "None")
			fetchTaskCategories()
		}
		
		taskDraftViewModel.selectDefaultCategory(from: taskCategories)
	}
	
	//	MARK: - Task Category functions
	
	func fetchTaskCategories() {
		let request = manager.requestTaskCategories()
		
		do {
			var categories = try manager.context.fetch(request)
			prioritizeNoneCategory(in: &categories)
			
			taskCategories = categories
			if taskDraftViewModel.selectedCategory == nil {
				taskDraftViewModel.selectDefaultCategory(from: taskCategories)
			}
		} catch let error {
			print("Error fetching task categories from Core Data. \(error)")
		}
	}
	
	private func prioritizeNoneCategory(in categories: inout [TaskCategory]) {
		if let noneCategoryIndex = categories.firstIndex(where: { $0.name == "None" }) {
			let noneCategory = categories.remove(at: noneCategoryIndex)
			
			categories.insert(noneCategory, at: 0)
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
		manager.deleteTaskCategory(taskCategory: taskCategory)
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
