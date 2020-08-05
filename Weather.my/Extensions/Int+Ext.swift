//
//  Int+Ext.swift
//  Weather.my
//
//  Created by Денис Андриевский on 04.08.2020.
//  Copyright © 2020 Денис Андриевский. All rights reserved.
//

import Foundation

extension Int {
    
    func convertedToCurrentUnit() -> Int {
        let unitHelper = UnitHelper()
        if unitHelper.getCurrentUnit() == .fahrenheit {
            return Int(Double(self)*9/5 + 32)
        } else {
            return self
        }
    }
    
}
