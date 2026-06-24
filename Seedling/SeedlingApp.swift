//
//  SeedlingApp.swift
//  Seedling
//
//  Created by Laurie Cai on 11/27/23.
//

import PostHog
import SwiftUI

@main
struct SeedlingApp: App {

	@StateObject private var imagePickerService = ImagePickerService()

	init() {
		let posthogProjectToken = "phc_vCP5bbyYKeaZGwbhuTz6Na2JnCppzu8VAYfTbQHasdoq"
		let posthogHost = "https://us.i.posthog.com"

		let config = PostHogConfig(projectToken: posthogProjectToken, host: posthogHost)
		config.captureApplicationLifecycleEvents = true
		config.captureScreenViews = false
		config.sessionReplay = true
		PostHogSDK.shared.setup(config)

		#if DEBUG
		PostHogSDK.shared.identify("laurie-dev", userProperties: ["is_tester": true])
		#endif

		UINavigationBar.appearance().titleTextAttributes = [
			.foregroundColor: UIColor(Color.theme.textPrimary),
			.font: UIFont(name: "Handjet-Bold", size: 24) ?? .systemFont(ofSize: 24, weight: .bold)
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

	@State private var selection: NavigationItem = .home

	var body: some View {
		NavigationContainer(selection: $selection)
			.preferredColorScheme(.light)
	}
}

struct NavigationContainer: View {

	@Binding var selection: NavigationItem

	@State private var gardenPopToRootSignal = 0
	@State private var tasksPopToRootSignal = 0

	var body: some View {
		ZStack {
			Color.theme.backgroundPrimary
				.ignoresSafeArea()

			TabView(selection: $selection) {
				HomeView()
					.tag(NavigationItem.home)
					.toolbar(.hidden, for: .tabBar)

				TasksView()
					.tag(NavigationItem.tasks)
					.toolbar(.hidden, for: .tabBar)
			}

			NavigationBar(selection: $selection) { item in
				switch item {
				case .home:
					gardenPopToRootSignal += 1
				case .tasks:
					tasksPopToRootSignal += 1
				}
			}
		}
		.environment(\.gardenPopToRootSignal, gardenPopToRootSignal)
		.environment(\.tasksPopToRootSignal, tasksPopToRootSignal)
	}
}
