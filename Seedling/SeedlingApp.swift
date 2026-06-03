//
//  SeedlingApp.swift
//  Seedling
//
//  Created by Laurie Cai on 11/27/23.
//

import FirebaseCore
import SwiftUI

@main
struct SeedlingApp: App {
	
	@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
	
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

class AppDelegate: NSObject, UIApplicationDelegate {
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		FirebaseApp.configure()
		return true
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) { }
	
	func applicationWillResignActive(_ application: UIApplication) { }
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
	
	init(selection: Binding<TabItem>, @ViewBuilder content: () -> Content) {
		self._selection = selection
		self.content = content()
	}
	
	var body: some View {
		VStack(spacing: 0) {
			ZStack {
				content
				
				NavigationBar(tabs: tabs, selection: $selection)
			}
		}
		.onPreferenceChange(TabItemsPreferenceKey.self) { value in
			self.tabs = value
		}
	}
}
