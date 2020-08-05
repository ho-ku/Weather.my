//
//  CityImageObject.swift
//  Weather.my
//
//  Created by Денис Андриевский on 02.08.2020.
//  Copyright © 2020 Денис Андриевский. All rights reserved.
//

import Foundation

struct CityImageObject: Codable {
    var results: [Result]
}

struct Result: Codable {
    var urls: URLObject
}

struct URLObject: Codable {
    var full: String
}
