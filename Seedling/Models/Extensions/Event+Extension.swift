//
//  Event+Extension.swift
//  Seedling
//
//  Created by Laurie Cai on 6/11/24.
//

import Foundation

extension Event {
	
	public var wrappedTitle: String {
		title ?? ""
	}
	
	public var wrappedTimestamp: Date {
		timestamp ?? Date()
	}

	static let plantAddedEventTitle = "Added to the garden!"

	var isStageUpdateEvent: Bool {
		wrappedTitle != Self.plantAddedEventTitle
	}

}
