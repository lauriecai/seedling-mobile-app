//
//  EventCardView.swift
//  Seedling
//
//  Created by Laurie Cai on 3/15/24.
//

import SwiftUI

struct EventCardView: View {

	let event: Event
	
	@Binding var showActionSheet: Bool
	@Binding var showActionsForEvent: Event?
	
    var body: some View {
		VStack(alignment: .leading, spacing: 5) {
			eventTitle
			timestampAndActionsFooter
		}
		.padding()
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(Color.theme.backgroundAccent)
		.clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

extension EventCardView {
	
	private var eventTitle: some View {
		Text(event.wrappedTitle)
			.font(.handjet(.bold, size: 20))
			.foregroundStyle(Color.theme.textPrimary)
	}
	
	private var timestampAndActionsFooter: some View {
		HStack {
			timestamp
			Spacer()
			eventActions
		}
	}
	
	private var timestamp: some View {
		HStack {
			Text(event.wrappedTimestamp.asDateAndTime())
				.font(.handjet(.medium, size: 18))
				.foregroundStyle(Color.theme.textSecondary)
			
			Spacer()
		}
	}
	
	private var eventActions: some View {
		Button {
			FirebaseEventManager.shared.logEvent(name: "eventActions_tapped")
			showActionSheet = true
			showActionsForEvent = event
		} label: {
			MenuKebab()
				.padding(.top, 10)
				.frame(maxHeight: .infinity, alignment: .top)
				.opacity(0.7)
		}
	}
}
