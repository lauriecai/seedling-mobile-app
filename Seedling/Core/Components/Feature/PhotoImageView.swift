//
//  PhotoImageView.swift
//  Seedling
//
//  Created by Laurie Cai on 6/23/26.
//

import SwiftUI

// MARK: - Description
// Loads a photo's image off the main thread and caches the decoded result.
// Shows a placeholder until the image is ready, so scrolling never blocks
// on disk reads or JPEG decoding.

struct PhotoImageView: View {

	let imageId: String

	@State private var image: UIImage?

	var body: some View {
		Group {
			if let image {
				Image(uiImage: image)
					.resizable()
					.scaledToFit()
			} else {
				Rectangle()
					.fill(Color.theme.backgroundLight)
					.aspectRatio(4 / 3, contentMode: .fit)
			}
		}
		.task(id: imageId) { await load() }
	}

	private func load() async {
		if let cached = ImageCache.shared.image(for: imageId) {
			image = cached
			return
		}

		let id = imageId
		let loaded = await Task.detached(priority: .userInitiated) {
			FileManager.default.fetchImage(id: id)
		}.value

		guard let loaded else { return }
		ImageCache.shared.insert(loaded, for: id)
		image = loaded
	}
}
