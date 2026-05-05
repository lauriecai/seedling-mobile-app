//
//  TaskRowView.swift
//  Seedling
//
//  Created by Laurie Cai on 5/22/24.
//

import SwiftUI

struct TaskRowView: View {
	
	let task: TaskItem

	@Binding var showActionSheet: Bool
	@Binding var showActionForTask: TaskItem?
	
    var body: some View {
		HStack(alignment: .top) {
			taskItem
			Spacer()
			taskActions
		}
		.background(Color.theme.backgroundPrimary)
    }
}

extension TaskRowView {
	
	private var taskItem: some View {
		HStack(alignment: .top, spacing: 12) {
			if task.isCompleted { checkedBox } else { uncheckedBox }
			
			Text(task.wrappedTitle)
				.font(.handjet(.medium, size: 20))
				.foregroundStyle(Color.theme.textPrimary)
				.padding(.top, 1)
				.strikethrough(task.isCompleted ? true : false)
				.opacity(task.isCompleted ? 0.40 : 1.0)
		}
	}
	
	private var uncheckedBox: some View {
		RoundedRectangle(cornerRadius: 4)
			.frame(width: 24, height: 24)
			.foregroundStyle(Color.theme.backgroundAccent)
	}
	
	private var checkedBox: some View {
		ZStack(alignment: .center) {
			RoundedRectangle(cornerRadius: 4)
				.frame(width: 24, height: 24)
				.foregroundStyle(Color.theme.backgroundAccent)
			
			Image("icon-checkmark")
				.frame(width: 10, height: 9)
				.foregroundStyle(Color.theme.textPrimary)
		}
		.opacity(0.40)
	}
	
	private var taskActions: some View {
		Button {
			FirebaseEventManager.shared.logEvent(name: "taskActions_tapped")
			showActionSheet = true
			showActionForTask = task
		} label: {
			MenuKebab()
				.frame(maxHeight: .infinity)
				.rotationEffect(.degrees(-90))
		}
	}
}
