//
//  PlantPost.swift
//  Seedling
//
//  Created by Laurie Cai on 4/4/24.
//

import CoreData
import Foundation

struct PlantPost: Identifiable {
	
	let type: CoreDataEntityType
	
	var timestamp: Date {
		switch type {
		case .event(let event):
			event.wrappedTimestamp
		case .note(let note):
			note.wrappedTimestamp
		case .photo(let photo):
			photo.wrappedTimestamp
		}
	}
	
	var id: NSManagedObjectID {
		switch type {
		case .event(let event): event.objectID
		case .note(let note): note.objectID
		case .photo(let photo): photo.objectID
		}
	}
}

enum CoreDataEntityType {
	case event(Event)
	case note(Note)
	case photo(Photo)
}
