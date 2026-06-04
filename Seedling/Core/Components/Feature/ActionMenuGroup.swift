//
//  ActionMenuGroup.swift
//  Seedling
//
//  Created by Laurie Cai on 6/3/26.
//

import SwiftUI
import UIKit

struct ActionMenuGroup: View {

	@Binding var isExpanded: Bool
	let onToggle: () -> Void
	let onAddNote: () -> Void
	let onAddPhoto: () -> Void
	let onUpdateStage: (() -> Void)?
	let onNewPlant: (() -> Void)?

	var body: some View {
		VStack(alignment: .trailing, spacing: 20) {
			if isExpanded {
				VStack(alignment: .trailing, spacing: 12) {
					ButtonRounded(iconName: "pencil", text: "Add Note")
						.onTapGesture {
							UIImpactFeedbackGenerator(style: .light).impactOccurred()
							onAddNote()
						}

					ButtonRounded(iconName: "photo", text: "Add Photo")
						.onTapGesture {
							UIImpactFeedbackGenerator(style: .light).impactOccurred()
							onAddPhoto()
						}

					if let onUpdateStage {
						ButtonRounded(iconName: "sparkles", text: "Update Stage")
							.onTapGesture {
								UIImpactFeedbackGenerator(style: .light).impactOccurred()
								onUpdateStage()
							}
					}

					if let onNewPlant {
						ButtonRounded(iconName: "plus", text: "New Plant", style: .green)
							.onTapGesture {
								UIImpactFeedbackGenerator(style: .light).impactOccurred()
								onNewPlant()
							}
					}
				}
			}

			toggleButton
		}
		.padding(.horizontal, 20)
		.padding(.bottom, 85)
	}
}

extension ActionMenuGroup {

	private var toggleButton: some View {
		ButtonCircle(iconName: "icon-plus")
			.frame(width: 65, height: 65)
			.onTapGesture {
				UIImpactFeedbackGenerator(style: .light).impactOccurred()
				withAnimation(Animation.bouncy(duration: 0.25, extraBounce: 0.10)) {
					onToggle()
				}
			}
			.rotationEffect(isExpanded ? .degrees(45) : .degrees(0))
	}
}
