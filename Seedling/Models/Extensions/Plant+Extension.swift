//
//  Plant+Extension.swift
//  Seedling
//
//  Created by Laurie Cai on 6/11/24.
//

import Foundation

extension Plant {
	
	public var wrappedName: String {
		name ?? ""
	}
	
	public var wrappedVariety: String {
		variety ?? ""
	}
	
	public var wrappedFullNameLabel: String {
		if !wrappedVariety.isEmpty {
			return "\(wrappedName): \(wrappedVariety)"
		} else {
			return "\(wrappedName)"
		}
	}
	
	public var wrappedFullNameSentence: String {
		if !wrappedVariety.isEmpty {
			return "\(wrappedVariety) \(wrappedName)".lowercased()
		} else {
			return "\(wrappedName)".lowercased()
		}
	}

	public var wrappedType: String {
		type ?? ""
	}
	
	public var wrappedStage: String {
		stage ?? ""
	}
	
	public var wrappedSunlightRequirement: String {
		sunlightRequirement ?? ""
	}
	
	public var wrappedWaterRequirement: String {
		waterRequirement ?? ""
	}
	
	public var wrappedTemperatureRequirement: String {
		temperatureRequirement ?? ""
	}
	
	public var wrappedHumidityRequirement: String {
		humidityRequirement ?? ""
	}
	
	public var wrappedSoilRequirement: String {
		soilRequirement ?? ""
	}
	
	public var wrappedFertilizerRequirement: String {
		fertilizerRequirement ?? ""
	}
	
	public var wrappedAdditionalCareNotes: String {
		additionalCareNotes ?? ""
	}
}
