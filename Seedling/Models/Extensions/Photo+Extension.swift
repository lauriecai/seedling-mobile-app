//
//  Photo+Extension.swift
//  Seedling
//
//  Created by Laurie Cai on 6/27/24.
//

import Foundation
import SwiftUI

extension Photo {
	
	var wrappedCaption: String {
		caption ?? ""
	}
	
	var wrappedTimestamp: Date {
		timestamp ?? Date()
	}
	
	var wrappedImageUrlString: String {
		imageUrlString ?? ""
	}
	
	var uiImage: UIImage {
		if let cached = ImageCache.shared.image(for: wrappedImageUrlString) {
			return cached
		}

		if !wrappedImageUrlString.isEmpty,
		   let image = FileManager.default.fetchImage(id: wrappedImageUrlString) {
			ImageCache.shared.insert(image, for: wrappedImageUrlString)
			return image
		} else {
			return UIImage(systemName: "photo")! // need placeholder
		}
	}
}
