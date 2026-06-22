//
//  CameraImagePickerView.swift
//  Seedling
//
//  UIImagePickerController is discouraged for .photoLibrary on iOS 14+ (use PhotosPicker).
//  For .camera there is no SwiftUI replacement — this wrapper is intentional until AVFoundation custom UI.
//

import PostHog
import SwiftUI
import UIKit

struct CameraImagePickerView: View {

	@Binding var isPresented: Bool
	let libraryAccessDenied: Bool
	let onImagePicked: (UIImage) -> Void

	var body: some View {
		ZStack(alignment: .top) {
			CameraImagePickerRepresentable(
				isPresented: $isPresented,
				onImagePicked: onImagePicked
			)
			.ignoresSafeArea()

			if libraryAccessDenied {
				libraryAccessBanner
			}
		}
		.onAppear { PostHogSDK.shared.screen("Camera Image Picker") }
	}

	private var libraryAccessBanner: some View {
		VStack(spacing: 8) {
			Text("To choose existing photos, allow Photos access in Settings.")
				.font(.handjet(.medium, size: 14))
				.foregroundStyle(Color.theme.textPrimary)
				.multilineTextAlignment(.center)

			Button("Open Settings") {
				guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
				UIApplication.shared.open(url)
			}
			.font(.handjet(.extraBold, size: 16))
			.foregroundStyle(Color.theme.accentGreen)
		}
		.padding()
		.background(Color.theme.backgroundAccent.opacity(0.95))
		.clipShape(RoundedRectangle(cornerRadius: 12))
		.padding()
	}
}

private struct CameraImagePickerRepresentable: UIViewControllerRepresentable {

	@Binding var isPresented: Bool
	let onImagePicked: (UIImage) -> Void

	func makeCoordinator() -> Coordinator {
		Coordinator(parent: self)
	}

	func makeUIViewController(context: Context) -> UIImagePickerController {
		let picker = UIImagePickerController()
		picker.sourceType = .camera
		picker.cameraDevice = .rear
		picker.delegate = context.coordinator
		return picker
	}

	func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

	final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
		let parent: CameraImagePickerRepresentable

		init(parent: CameraImagePickerRepresentable) {
			self.parent = parent
		}

		func imagePickerController(
			_ picker: UIImagePickerController,
			didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
		) {
			if let image = info[.originalImage] as? UIImage {
				parent.onImagePicked(image)
			}
			parent.isPresented = false
		}

		func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
			parent.isPresented = false
		}
	}
}
