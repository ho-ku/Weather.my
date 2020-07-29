//
//  CityLocation.swift
//  Weather.my
//
//  Created by Денис Андриевский on 28.07.2020.
//  Copyright © 2020 Денис Андриевский. All rights reserved.
//

import Foundation
import CoreLocation

struct CityLocation {
    var city: String
    var country: String
    var coreDataObject: Location
    var temperature: String
    var coordinates: CLLocationCoordinate2D
}
