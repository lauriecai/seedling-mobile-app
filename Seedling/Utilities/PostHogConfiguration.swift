//
//  PostHogConfiguration.swift
//  Seedling
//

import Foundation
import PostHog

enum PostHogConfiguration {

	static func setupIfConfigured() {
		guard
			let projectToken = Bundle.main.infoPlistString(forKey: "POSTHOG_API_KEY"),
			let host = Bundle.main.infoPlistString(forKey: "POSTHOG_HOST")
		else {
			#if DEBUG
			print("PostHog: skipped setup — missing or invalid POSTHOG_API_KEY / POSTHOG_HOST in Info.plist")
			#endif
			return
		}

		let config = PostHogConfig(projectToken: projectToken, host: host)
		config.captureApplicationLifecycleEvents = true
		config.captureScreenViews = false
		config.sessionReplay = false
		config.surveys = false
		config.rageClickConfig.enabled = false
		config.captureElementInteractions = false
		PostHogSDK.shared.setup(config)

		#if DEBUG
		PostHogSDK.shared.identify("laurie-dev", userProperties: ["is_tester": true])
		#endif
	}
}

private extension Bundle {

	func infoPlistString(forKey key: String) -> String? {
		guard let value = object(forInfoDictionaryKey: key) as? String else { return nil }
		let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty, !trimmed.contains("$(") else { return nil }
		return trimmed
	}
}
