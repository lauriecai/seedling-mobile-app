//
//  ButtonCircle.swift
//  Seedling
//
//  Created by Laurie Cai on 2/10/24.
//

import SwiftUI

struct ButtonCircle: View {
	
	let iconName: String
	
	var body: some View {
		Image(iconName)
			.renderingMode(.template)
			.foregroundStyle(Color.theme.textWhite)
			.frame(width: 65, height: 65)
			.background(Color.theme.accentGreen)
			.clipShape(Circle())
	}
}

#Preview(traits: .sizeThatFitsLayout) {
	ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
		Color.white
		
		ButtonCircle(iconName: "icon-plus")
			.padding(.horizontal, 20)
			.padding(.bottom, 20)
	}
}
