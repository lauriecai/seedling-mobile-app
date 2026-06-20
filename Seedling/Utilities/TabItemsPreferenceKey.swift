//
//  TabItemsPreferenceKey.swift
//  Seedling
//
//  Created by Laurie Cai on 6/6/24.
//

import Foundation
import SwiftUI

struct TabItemsPreferenceKey: PreferenceKey {
	
	static var defaultValue: [TabItem] = []
	
	static func reduce(value: inout [TabItem], nextValue: () -> [TabItem]) {
		value += nextValue()
	}
}

struct TabItemViewModifier: ViewModifier {
	
	let tab: TabItem
	@Binding var selection: TabItem
	
	func body(content: Content) -> some View {
		content
			.opacity(selection == tab ? 1.0 : 0.0)
			.preference(key: TabItemsPreferenceKey.self, value: [tab])
	}
}

extension View {
	
	func tabItem(tab: TabItem, selection: Binding<TabItem>) -> some View {
		modifier(TabItemViewModifier(tab: tab, selection: selection))
	}
}

private struct GardenPopToRootSignalKey: EnvironmentKey {
	static let defaultValue: Int = 0
}

private struct TasksPopToRootSignalKey: EnvironmentKey {
	static let defaultValue: Int = 0
}

extension EnvironmentValues {
	var gardenPopToRootSignal: Int {
		get { self[GardenPopToRootSignalKey.self] }
		set { self[GardenPopToRootSignalKey.self] = newValue }
	}
	
	var tasksPopToRootSignal: Int {
		get { self[TasksPopToRootSignalKey.self] }
		set { self[TasksPopToRootSignalKey.self] = newValue }
	}
}
