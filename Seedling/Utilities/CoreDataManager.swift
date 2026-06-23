//
//  CoreDataManager.swift
//  Seedling
//
//  Created by Laurie Cai on 2/1/24.
//

import CoreData
import Foundation
import SwiftUI

class CoreDataManager {
	
	static let shared = CoreDataManager()
	
	let container: NSPersistentContainer
	let context: NSManagedObjectContext
	
	init() {
		container = NSPersistentContainer(name: "Seedling")
		container.loadPersistentStores { _, error in
			if let error {
				print("-----\nError loading Core Data. \(error)")
			}
		}
		
		context = container.viewContext
		context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
	}
	
// 	MARK: - Sort variables

	var sortByNewest: NSSortDescriptor {
		NSSortDescriptor(key: "timestamp", ascending: false)
	}

	var sortByOldest: NSSortDescriptor {
		NSSortDescriptor(key: "timestamp", ascending: true)
	}

	var sortByName: NSSortDescriptor {
		NSSortDescriptor(key: "name", ascending: true)
	}
	
// 	MARK: - Save function
	
	func save() {
		do {
			try context.save()
		} catch let error {
			print("Error saving to Core Data. \(error)")
		}
	}
	
// 	MARK: - Plant functions
	
	func requestPlants() -> NSFetchRequest<Plant> {
		let request = NSFetchRequest<Plant>(entityName: "Plant")
		request.sortDescriptors = [sortByName]
		
		return request
	}
	
	@discardableResult
	func addPlant(name: String, variety: String, stage: String, type: String) -> Plant {
		let newPlant = Plant(context: context)
		newPlant.name = name
		newPlant.variety = variety
		newPlant.stage = stage
		newPlant.type = type
		
		createPlantAddedEvent(for: newPlant)
		
		save()
		return newPlant
	}
	
	func addStageUpdate(plant: Plant, newStage: String) {
		plant.stage = newStage
		createPlantUpdatedEvent(for: plant, newStage: newStage)
		
		save()
	}
	
	func updatePlantNameAndVariety(for plant: Plant, name: String, variety: String) {
		plant.name = name
		plant.variety = variety
		
		save()
	}
	
	func editPlantGeneralDetails(for plant: Plant, name: String, variety: String, type: String, stage: String) {
		plant.name = name
		plant.variety = variety
		plant.type = type
		plant.stage = stage
		
		save()
	}
	
	func editPlantCareRequirements(for plant: Plant, sunlightRequirement: String, temperatureRequirement: String, waterRequirement: String, humidityRequirement: String, soilRequirement: String, fertilizerRequirement: String) {
		plant.sunlightRequirement = sunlightRequirement
		plant.temperatureRequirement = temperatureRequirement
		plant.waterRequirement = waterRequirement
		plant.humidityRequirement = humidityRequirement
		plant.soilRequirement = soilRequirement
		plant.fertilizerRequirement = fertilizerRequirement
		
		save()
	}
	
	func editAdditionalCareNotes(for plant: Plant, additionalCareNotes: String) {
		plant.additionalCareNotes = additionalCareNotes
		save()
	}
	
	func deletePlant(plant: Plant) {
		context.delete(plant)
		save()
	}
	
// 	MARK: - Note functions

	func requestNotes(for plant: Plant? = nil) -> NSFetchRequest<Note> {
		let request = NSFetchRequest<Note>(entityName: "Note")
		request.sortDescriptors = [sortByNewest]
		
		if let plant = plant {
			request.predicate = NSPredicate(format: "plant == %@", plant)
		}
		
		return request
	}
	
	func addNote(for plant: Plant, title: String, body: String) {
		let newNote = Note(context: context)
		newNote.plant = plant
		newNote.timestamp = Date()
		newNote.title = title
		newNote.body = body
		
		save()
	}
	
	func updateNoteTitleAndBody(for note: Note, title: String, body: String) {
		note.title = title
		note.body = body
		
		save()
	}
	
	func deleteNote(note: Note) {
		context.delete(note)
		save()
	}
	
// 	MARK: - Event functions

	func requestEvents(for plant: Plant? = nil) -> NSFetchRequest<Event> {
		let request = NSFetchRequest<Event>(entityName: "Event")
		request.sortDescriptors = [sortByNewest]
		
		if let plant = plant {
			request.predicate = NSPredicate(format: "plant == %@", plant)
		}
		
		return request
	}

	private func createPlantAddedEvent(for plant: Plant) {
		let newEvent = Event(context: context)
		newEvent.plant = plant
		newEvent.timestamp = Date()
		newEvent.title = Event.plantAddedEventTitle
		
		save()
	}

	private func createPlantUpdatedEvent(for plant: Plant, newStage: String) {
		let newEvent = Event(context: context)
		newEvent.plant = plant
		newEvent.timestamp = Date()
		
		let newStage = PlantStage(rawValue: newStage) ?? .seedling
		newEvent.title = "Your \(plant.wrappedFullNameSentence) \(newStage.updateMessage)"
		
		save()
	}
	
	func deleteEvent(event: Event) {
		context.delete(event)
		save()
	}
	
// 	MARK: - Task Category functions
	
	func requestTaskCategories() -> NSFetchRequest<TaskCategory> {
		let request = NSFetchRequest<TaskCategory>(entityName: "TaskCategory")
		request.sortDescriptors = [sortByName]
		
		return request
	}
	
	func addTaskCategory(name: String) {
		let newCategory = TaskCategory(context: context)
		newCategory.name = name
		
		save()
	}
	
	func updateTaskCategory(taskCategory: TaskCategory, name: String) {
		taskCategory.name = name
		save()
	}
	
	func deleteTaskCategory(taskCategory: TaskCategory) {
		context.delete(taskCategory)
		save()
	}
	
//	MARK: - Task functions

	func requestTasks() -> NSFetchRequest<TaskItem> {
		let request = NSFetchRequest<TaskItem>(entityName: "TaskItem")
		request.sortDescriptors = [sortByOldest]

		return request
	}

	func addTask(category: TaskCategory?, title: String, isCompleted: Bool = false) {
		let newTask = TaskItem(context: context)
		newTask.category = category
		newTask.title = title
		newTask.timestamp = Date()

		save()
	}

	func updateTask(task: TaskItem, title: String, category: TaskCategory?) {
		task.title = title
		task.category = category

		save()
	}
	
	func deleteTask(task: TaskItem) {
		context.delete(task)
		save()
	}
	
//	MARK: - Photo functions
	
	func deletePhoto(photo: Photo) {
		context.delete(photo)
		save()
	}
}
