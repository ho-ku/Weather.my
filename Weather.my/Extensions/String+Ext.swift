//
//  String+Ext.swift
//  Weather.my
//
//  Created by Денис Андриевский on 02.08.2020.
//  Copyright © 2020 Денис Андриевский. All rights reserved.
//

import Foundation

extension String {
    
    func withoutSpaces() -> String {
        var final = ""
        for el in self {
            final += el == " " ? String("") : String(el)
        }
        return final
    }
    
}
