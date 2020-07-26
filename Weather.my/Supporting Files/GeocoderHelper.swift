//
//  GeocoderHelper.swift
//  Weather.my
//
//  Created by Денис Андриевский on 26.07.2020.
//  Copyright © 2020 Денис Андриевский. All rights reserved.
//

import Foundation
import CoreLocation

class GeocoderHelper {
    
    // MARK: - Makes request for city
    func getCityForQuery(_ query: String, completionHandler: @escaping CLGeocodeCompletionHandler) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(query, completionHandler: completionHandler)
    }
    
    func getCityForLocation(_ location: CLLocation, completionHandler: @escaping CLGeocodeCompletionHandler) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: completionHandler)
    }
    
}
