//
//  PhotoCapturePermissions.swift
//  Seedling
//

import AVFoundation
import Photos
import UIKit

enum PhotoCapturePermissions {

	static var cameraAuthorized: Bool {
		AVCaptureDevice.authorizationStatus(for: .video) == .authorized
	}

	static var cameraDenied: Bool {
		switch AVCaptureDevice.authorizationStatus(for: .video) {
		case .denied, .restricted:
			return true
		default:
			return false
		}
	}

	/// `.limited` counts as authorized — no Settings banner; in-camera library shows the user's subset.
	static var libraryAuthorizedForPicker: Bool {
		switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
		case .authorized, .limited:
			return true
		default:
			return false
		}
	}

	static var libraryDenied: Bool {
		switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
		case .denied, .restricted:
			return true
		default:
			return false
		}
	}

	static var canPresentCameraPicker: Bool {
		cameraAuthorized && UIImagePickerController.isSourceTypeAvailable(.camera)
	}

	static func resolveCamera() async -> Bool {
		if cameraAuthorized { return true }
		if cameraDenied { return false }
		return await requestCameraAccess()
	}

	private static func requestCameraAccess() async -> Bool {
		await AVCaptureDevice.requestAccess(for: .video)
	}
}
