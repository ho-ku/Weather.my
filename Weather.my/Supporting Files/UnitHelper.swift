//
//  UnitHelper.swift
//  Weather.my
//
//  Created by Денис Андриевский on 29.07.2020.
//  Copyright © 2020 Денис Андриевский. All rights reserved.
//

import Foundation

class UnitHelper {
    
    // MARK: - Instances
    private let defaults = UserDefaults.standard
    
    func getCurrentUnit() -> Unit? {
        guard let value = defaults.value(forKey: C.currentUnit) as? String else { return nil }
        switch value {
        case Unit.celsium.rawValue:
            return .celsium
        case Unit.fahrenheit.rawValue:
           return .fahrenheit
        default:
            return nil
        }
    }
    
    func setUnit(_ new: Unit) {
        defaults.set(new.rawValue, forKey: C.currentUnit)
    }
    
    func getSymbolForCurrentUnit() -> String {
        return (getCurrentUnit() == nil) ? "°C" : getCurrentUnit() == .celsium ? "°C" : "°F"
    }
    
}
