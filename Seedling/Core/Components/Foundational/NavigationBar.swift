//
//  NavigationBar.swift
//  Seedling
//
//  Created by Laurie Cai on 3/5/24.
//

import SwiftUI

enum NavigationItem: CaseIterable {
	case garden, tasks
	
	var tabItem: TabItem {
		switch self {
		case .garden:
			return TabItem(iconName: "icon-garden", title: "Garden")
		case .tasks:
			return TabItem(iconName: "icon-tasks", title: "Tasks")
		}
	}
}

struct NavigationBar: View {
	
	let tabs: [TabItem]
	@Binding var selection: TabItem
	
	var body: some View {
		VStack {
			Spacer()
			HStack(spacing: 140) {
				ForEach(tabs, id: \.self) { tab in
					tabView(tab: tab)
						.onTapGesture {
							UIImpactFeedbackGenerator(style: .light).impactOccurred()
							switchToTab(tab: tab)
						}
				}
			}
			.frame(maxWidth: .infinity)
			.background(Color.theme.backgroundDark.ignoresSafeArea(edges: .bottom))
		}
	}
}

#Preview {
	NavigationBar(
		tabs: [
			NavigationItem.garden.tabItem,
			NavigationItem.tasks.tabItem
],
		selection: .constant(NavigationItem.garden.tabItem)
	)
}

extension NavigationBar {
	
	private func tabView(tab: TabItem) -> some View {
		VStack(spacing: 2) {
			Image(tab.iconName)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.colorMultiply(selection == tab ? Color.theme.accentLightGreen : Color.theme.textLight)
				.frame(width: 28, height: 28)
			
			Text(tab.title)
				.font(.handjet(.bold, size: 16))
				.foregroundStyle(selection == tab ? Color.theme.accentLightGreen : Color.theme.textLight)
		}
		.padding(.vertical, 10)
	}
	
	private func switchToTab(tab: TabItem) {
		selection = tab
	}
}

struct TabItem: Hashable {
	let iconName: String
	let title: String
}
