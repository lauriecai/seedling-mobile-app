//
//  NavigationBar.swift
//  Seedling
//
//  Created by Laurie Cai on 3/5/24.
//

import SwiftUI

enum NavigationItem: CaseIterable, Identifiable {
	case home, tasks

	var id: Self { self }

	var iconName: String {
		switch self {
		case .home: return "icon-garden"
		case .tasks: return "icon-tasks"
		}
	}

	var title: String {
		switch self {
		case .home: return "Garden"
		case .tasks: return "Tasks"
		}
	}
}

struct NavigationBar: View {

	@Binding var selection: NavigationItem
	var onTabReselect: (NavigationItem) -> Void = { _ in }

	@State private var lastTap: (item: NavigationItem, date: Date)?

	var body: some View {
		VStack {
			Spacer()
			HStack(spacing: 140) {
				ForEach(NavigationItem.allCases) { item in
					tabView(item)
						.onTapGesture {
							handleTap(item)
						}
				}
			}
			.frame(maxWidth: .infinity)
			.background(Color.theme.backgroundDark.ignoresSafeArea(edges: .bottom))
		}
	}
}

#Preview {
	NavigationBar(selection: .constant(.home))
}

extension NavigationBar {

	private func tabView(_ item: NavigationItem) -> some View {
		VStack(spacing: 2) {
			Image(item.iconName)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.colorMultiply(selection == item ? Color.theme.accentLightGreen : Color.theme.textLight)
				.frame(width: 28, height: 28)

			Text(item.title)
				.font(.handjet(.bold, size: 16))
				.foregroundStyle(selection == item ? Color.theme.accentLightGreen : Color.theme.textLight)
		}
		.padding(.vertical, 10)
	}

	private func handleTap(_ item: NavigationItem) {
		let now = Date()

		if let lastTap,
		   lastTap.item == item,
		   selection == item,
		   now.timeIntervalSince(lastTap.date) < 0.35 {
			self.lastTap = nil
			UIImpactFeedbackGenerator(style: .medium).impactOccurred()
			onTabReselect(item)
			return
		}

		lastTap = (item, now)
		UIImpactFeedbackGenerator(style: .light).impactOccurred()
		selection = item
	}
}
