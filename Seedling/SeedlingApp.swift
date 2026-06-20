//
//  SeedlingApp.swift
//  Seedling
//
//  Created by Laurie Cai on 11/27/23.
//

import SwiftUI

@main
struct SeedlingApp: App {
	
	@StateObject private var imagePickerService = ImagePickerService()
	
	@State private var showLaunchView: Bool = true
	
	init() {
		UINavigationBar.appearance().titleTextAttributes = [
			.foregroundColor: UIColor(Color.theme.textPrimary),
			.font: UIFont(name: "Handjet-Bold", size: 24)!
		]
	}
	
    var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(imagePickerService)
		}
    }
}

struct ContentView: View {
	
	@State private var tabSelection: TabItem = TabItem(iconName: "icon-garden", title: "Garden")
	
	var body: some View {
		NavigationContainer(selection: $tabSelection) {
			HomeView()
				.tabItem(tab: TabItem(iconName: "icon-garden", title: "Garden"), selection: $tabSelection)
			
			TasksView()
				.tabItem(tab: TabItem(iconName: "icon-tasks", title: "Tasks"), selection: $tabSelection)
		}
	}
}

struct NavigationContainer<Content: View>: View {
	
	@Binding var selection: TabItem
	let content: Content
	
	@State private var tabs: [TabItem] = []
	@State private var gardenPopToRootSignal = 0
	@State private var tasksPopToRootSignal = 0
	
	init(selection: Binding<TabItem>, @ViewBuilder content: () -> Content) {
		self._selection = selection
		self.content = content()
	}
	
	var body: some View {
		VStack(spacing: 0) {
			ZStack {
				content
					.environment(\.gardenPopToRootSignal, gardenPopToRootSignal)
					.environment(\.tasksPopToRootSignal, tasksPopToRootSignal)
				
				NavigationBar(tabs: tabs, selection: $selection) { tab in
					switch tab {
					case NavigationItem.garden.tabItem:
						gardenPopToRootSignal += 1
					case NavigationItem.tasks.tabItem:
						tasksPopToRootSignal += 1
					default:
						break
					}
				}
			}
		}
		.onPreferenceChange(TabItemsPreferenceKey.self) { value in
			self.tabs = value
		}
	}
}
