//
//  EditPhotoMode.swift
//  Seedling
//
//  Created by Laurie Cai on 7/9/24.
//

import Foundation
import SwiftUI

enum EditPhotoMode: Identifiable {
	case create(Plant, UIImage)
	case edit(Plant, Photo)

	var id: String {
		switch self {
		case .create: return "create"
		case .edit: return "edit"
		}
	}
}
