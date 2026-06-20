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
	var onTabDoubleTap: (TabItem) -> Void = { _ in }
	
	@State private var lastTabTap: (tab: TabItem, date: Date)?
	
	var body: some View {
		VStack {
			Spacer()
			HStack(spacing: 140) {
				ForEach(tabs, id: \.self) { tab in
					tabView(tab: tab)
						.onTapGesture {
							handleTabTap(tab)
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
	
	private func handleTabTap(_ tab: TabItem) {
		let now = Date()
		
		if let lastTabTap,
		   lastTabTap.tab == tab,
		   selection == tab,
		   now.timeIntervalSince(lastTabTap.date) < 0.35 {
			self.lastTabTap = nil
			UIImpactFeedbackGenerator(style: .medium).impactOccurred()
			onTabDoubleTap(tab)
			return
		}
		
		lastTabTap = (tab, now)
		UIImpactFeedbackGenerator(style: .light).impactOccurred()
		switchToTab(tab: tab)
	}
}

struct TabItem: Hashable {
	let iconName: String
	let title: String
}
