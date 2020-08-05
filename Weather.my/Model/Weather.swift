//
//  Weather.swift
//  Weather.my
//
//  Created by Денис Андриевский on 04.08.2020.
//  Copyright © 2020 Денис Андриевский. All rights reserved.
//

import Foundation

struct Weather: Codable {
    var main: Main
}

struct Main: Codable {
    var temp: Double
}
