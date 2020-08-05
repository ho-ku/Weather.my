//
//  RecommendationGenerator.swift
//  Weather.my
//
//  Created by Денис Андриевский on 04.08.2020.
//  Copyright © 2020 Денис Андриевский. All rights reserved.
//

import Foundation

class RecommendationGenerator {
    
    class func generateRecomendation(for temp: Int) -> String {
        switch temp {
        case 20...:
            return "It's warm here"
        case 10..<20:
            return "Wear a coat"
        case 0..<10:
            return "Wear a jacket"
        default:
            return "It's really cold here"
        }
    }
    
}
