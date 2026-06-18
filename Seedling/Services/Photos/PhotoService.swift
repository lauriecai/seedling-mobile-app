//
//  PhotoService.swift
//  Seedling
//
//  Created by Laurie Cai on 6/27/24.
//

import CoreData
import Foundation

// MARK: - Description
// Responsible for photo CRUD operations

enum PhotoService {

//	MARK: - Public Methods

	static func fetchPhotos(for plant: Plant) -> [Photo]? {
		let request = requestPhotos(for: plant)

		do {
			return try CoreDataManager.shared.context.fetch(request)
		} catch {
			print("Error fetching images. \(error.localizedDescription)")
			return []
		}
	}

	static func createPhoto(for plant: Plant, caption: String) -> Photo {
		let newPhoto = Photo(context: CoreDataManager.shared.context)
		newPhoto.plant = plant
		newPhoto.imageUrlString = UUID().uuidString
		newPhoto.timestamp = Date()
		newPhoto.caption = caption

		return newPhoto
	}

//	MARK: - Private Methods

	private static func requestPhotos(for plant: Plant) -> NSFetchRequest<Photo> {
		let request = NSFetchRequest<Photo>(entityName: "Photo")

		request.sortDescriptors = [CoreDataManager.shared.sortByNewest]
		request.predicate = NSPredicate(format: "plant == %@", plant)

		return request
	}
}
