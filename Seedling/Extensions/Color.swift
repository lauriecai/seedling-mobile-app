//
//  Color.swift
//  Seedling
//
//  Created by Laurie Cai on 11/28/23.
//

import Foundation
import SwiftUI

extension Color {
	
	static let theme = ColorTheme()
	
}

struct ColorTheme {
	
	let backgroundPrimary = Color("ColorBackgroundPrimary")
	let backgroundSecondary = Color("ColorBackgroundSecondary")
	let backgroundDark = Color("ColorBackgroundDark")
	let backgroundGrey = Color("ColorBackgroundGrey")
	let backgroundLight = Color("ColorBackgroundLight")
	let backgroundAccent = Color("ColorBackgroundAccent")
	
	let textPrimary = Color("ColorTextPrimary")
	let textSecondary = Color("ColorTextSecondary")
	let textLight = Color("ColorTextLight")
	let textWhite = Color("ColorTextWhite")
	let textGrey = Color("ColorTextGrey")
	
	let accentRed = Color("ColorAccentRed")
	let accentGreen = Color("ColorAccentGreen")
	let accentLightGreen = Color("ColorAccentLightGreen")
	let accentYellow = Color("ColorAccentYellow")
	
}
