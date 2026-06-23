//
//  ImageCache.swift
//  Seedling
//
//  Created by Laurie Cai on 6/23/26.
//

import UIKit

// MARK: - Description
// In-memory cache for decoded photo images, keyed by imageUrlString.
// Avoids re-reading and re-decoding JPEGs from disk on every render.

final class ImageCache {

	static let shared = ImageCache()

	private let cache = NSCache<NSString, UIImage>()

	private init() {}

	func image(for key: String) -> UIImage? {
		guard !key.isEmpty else { return nil }
		return cache.object(forKey: key as NSString)
	}

	func insert(_ image: UIImage, for key: String) {
		guard !key.isEmpty else { return }
		cache.setObject(image, forKey: key as NSString)
	}

	func remove(for key: String) {
		cache.removeObject(forKey: key as NSString)
	}
}
