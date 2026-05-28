//
//  ChevronRight.swift
//  Seedling
//
//  Created by Laurie Cai on 9/24/24.
//

import SwiftUI

struct ChevronRight: View {
    var body: some View {
		Image(systemName: "chevron.right")
			.foregroundStyle(Color.theme.textSecondary)
    }
}

#Preview {
    ChevronRight()
}
