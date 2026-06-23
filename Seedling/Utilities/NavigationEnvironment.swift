//
//  NavigationEnvironment.swift
//  Seedling
//
//  Created by Laurie Cai on 6/6/24.
//
//  Pop-to-root environment keys, read by HomeView (garden) and TasksView (tasks).

import SwiftUI

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
