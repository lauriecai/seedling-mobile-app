//
//  DarkOverlay.swift
//  Seedling
//
//  Created by Laurie Cai on 6/3/26.
//

import SwiftUI

struct DarkOverlay: View {

	let onTap: () -> Void

	var body: some View {
		Color.black.opacity(0.30)
			.ignoresSafeArea()
			.onTapGesture {
				onTap()
			}
	}
}
