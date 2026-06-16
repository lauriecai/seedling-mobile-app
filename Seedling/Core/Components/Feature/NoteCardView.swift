//
//  NoteCardView.swift
//  Seedling
//
//  Created by Laurie Cai on 2/18/24.
//

import SwiftUI

struct NoteCardView: View {
	
	let note: Note
	
	@Binding var showActionSheet: Bool
	@Binding var showActionsForNote: Note?
	
    var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			
			if !note.wrappedTitle.isEmpty { noteTitle }
			if !note.wrappedBody.isEmpty { noteDescription }
			
			timestampAndActionsFooter
		}
		.padding()
		.background(Color.theme.backgroundLight)
		.clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

extension NoteCardView {
	
	private var noteTitle: some View {
		Text(note.wrappedTitle)
			.font(.handjet(.bold, size: 22))
			.foregroundStyle(Color.theme.textPrimary)
	}
	
	private var noteDescription: some View {
		Text(note.wrappedBody)
			.font(.handjet(.medium, size: 20))
			.foregroundStyle(Color.theme.textPrimary)
	}
	
	private var timestampAndActionsFooter: some View {
		HStack {
			timestamp
			Spacer()
			noteActions
		}
	}
	
	private var timestamp: some View {
		HStack {
			Text(note.wrappedTimestamp.asDateAndTime())
				.font(.handjet(.medium, size: 18))
				.foregroundStyle(Color.theme.textSecondary)
			
			Spacer()
		}
	}
	
	private var noteActions: some View {
		Button {
			showActionSheet = true
			showActionsForNote = note
		} label: {
			MenuKebab()
				.padding(.top, 10)
				.frame(maxHeight: .infinity, alignment: .top)
				.opacity(0.7)
		}
	}
}
