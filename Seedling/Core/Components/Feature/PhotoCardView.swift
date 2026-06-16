//
//  PhotoCardView.swift
//  Seedling
//
//  Created by Laurie Cai on 7/2/24.
//

import SwiftUI

struct PhotoCardView: View {
	
	let photo: Photo
	
	@Binding var showActionSheet: Bool
	@Binding var showActionsForPhoto: Photo?
	
    var body: some View {
		VStack(spacing: 0) {
			Image(uiImage: photo.uiImage)
				.resizable()
				.scaledToFit()
			
			VStack(alignment: .leading, spacing: 10) {
				if !photo.wrappedCaption.isEmpty { photoCaption }
				
				timestampAndActionsFooter
			}
			.padding()
		}
		.background(Color.theme.backgroundLight)
		.clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

extension PhotoCardView {
	
	private var photoCaption: some View {
		Text(photo.wrappedCaption)
			.font(.handjet(.medium, size: 20))
			.foregroundStyle(Color.theme.textPrimary)
	}
	
	private var timestampAndActionsFooter: some View {
		HStack {
			timestamp
			Spacer()
			photoActions
		}
	}
	
	private var timestamp: some View {
		HStack {
			Text(photo.wrappedTimestamp.asDateAndTime())
				.font(.handjet(.medium, size: 18))
				.foregroundStyle(Color.theme.textSecondary)
			
			Spacer()
		}
	}
	
	private var photoActions: some View {
		Button {
			showActionSheet = true
			showActionsForPhoto = photo
		} label: {
			MenuKebab()
				.padding(.top, 10)
				.frame(maxHeight: .infinity, alignment: .top)
				.opacity(0.7)
		}
	}
}
