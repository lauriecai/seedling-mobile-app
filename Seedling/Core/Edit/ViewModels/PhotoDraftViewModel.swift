//
//  PhotoDraftViewModel.swift
//  Seedling
//
//  Created by Laurie Cai on 7/2/24.
//

import Foundation
import SwiftUI

class PhotoDraftViewModel: ObservableObject {
	
	@Published var plant: Plant?
	@Published var image: UIImage
	@Published var caption: String = ""
	
	@Published var captionEdited: Bool = false
	
	var imageUrlString: String?
	var editingExistingImage: Bool { imageUrlString != nil }
	
	let coreDataManager = CoreDataManager.shared
	let fileManager = FileManager()
	
	let photoService = PhotoService()
	
//	MARK: - Init
	
	init(newImage: UIImage) {
		self.plant = nil
		self.image = newImage
	}
	
	init(plant: Plant, newImage: UIImage) {
		self.plant = plant
		self.image = newImage
	}
	
	init(plant: Plant, existingPhoto: Photo) {
		self.plant = plant
		self.image = existingPhoto.uiImage
		self.caption = existingPhoto.wrappedCaption
		self.imageUrlString = existingPhoto.wrappedImageUrlString
	}
	
//	MARK: - Public Methods
	
	func createPhoto(for plant: Plant) {
		let newPhoto = photoService.createPhoto(for: plant, caption: caption)
		
		coreDataManager.save()
		fileManager.saveImage(id: newPhoto.wrappedImageUrlString, image: image)
	}
	
	func saveChanges(for plant: Plant) {
		guard let imageUrlString,
			  let savedPhoto = findExistingPhoto(for: plant) else { return }
		
		savedPhoto.caption = caption
		
		coreDataManager.save()
		fileManager.saveImage(id: imageUrlString, image: image)
	}
	
//	MARK: - Private Methods
	
	private func findExistingPhoto(for plant: Plant) -> Photo? {
		let allPhotos = fetchPhotos(for: plant)
		
		if let existingPhoto = allPhotos?.first(where: { $0.imageUrlString == imageUrlString })
		{ return existingPhoto } else { return nil }
	}
	
	private func fetchPhotos(for plant: Plant) -> [Photo]? {
		photoService.fetchPhotos(for: plant)
	}
}
