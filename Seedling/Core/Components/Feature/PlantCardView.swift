//
//  PlantCardView.swift
//  Seedling
//
//  Created by Laurie Cai on 11/28/23.
//

import SwiftUI

struct PlantCardView: View {
	
	let plant: Plant
	
	@Binding var showActionSheet: Bool
	@Binding var showActionForPlant: Plant?
	
    var body: some View {
		VStack(spacing: 0) {
			plantContent
			shadow
		}
		.clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

extension PlantCardView {
	
	private var plantContent: some View {
		HStack(alignment: .center) {
			plantNameAndStage
			Spacer()
			plantActions
		}
		.padding(.horizontal)
		.padding(.vertical, 10)
		.background(Color.theme.backgroundSecondary)
	}
	
	private var plantNameAndStage: some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(plant.wrappedVariety.isEmpty ? plant.wrappedName : "\(plant.wrappedName): \(plant.wrappedVariety)")
				.font(.handjet(.bold, size: 22))
				.foregroundStyle(Color.theme.textPrimary)
				.lineLimit(1)
				.truncationMode(.tail)
			
			HStack(alignment: .center) {
				Text(plant.wrappedStage)
					.font(.handjet(.medium, size: 18))
					.foregroundStyle(Color.theme.textPrimary)
				
				Spacer()
			}
		}
	}
	
	private var plantActions: some View {
		HStack(alignment: .center, spacing: 30) {
			ChevronRight()
				.font(.handjet(.bold, size: 20))
			moreOptions
		}
		.padding(.leading, 8)
	}
	
	private var shadow: some View {
		Rectangle()
			.frame(height: 8)
			.foregroundStyle(Color.theme.textSecondary).opacity(0.40)
	}

	private var moreOptions: some View {
		Button {
			showActionSheet = true
			showActionForPlant = plant
		} label: {
			MenuKebab()
				.frame(maxHeight: .infinity)
				.rotationEffect(.degrees(-90))
		}
	}
	
}
