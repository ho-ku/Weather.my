//
//  RequestManager.swift
//  Weather.my
//
//  Created by Денис Андриевский on 02.08.2020.
//  Copyright © 2020 Денис Андриевский. All rights reserved.
//

import Foundation

class RequestManager {
    
    private let unsplashAccessKey = "HNAMH2uo7gEa60gLXd85x3iZ9_7ostEjO5sfUapzRGg"
    private let weatherAPIKey = "546a093201984c9047f31129e06ccef2"
    
    // MARK: - Getting photo by Unsplah API
    private func requestPhotoURL(query: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let urlString = "https://api.unsplash.com/search/photos?client_id=\(unsplashAccessKey)&query=\(query)"
        guard let url = URL(string: urlString) else { return }
        let dataTask = URLSession(configuration: .default).dataTask(with: url, completionHandler: completionHandler)
        dataTask.resume()
    }
    
    func getPhoto(query: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        requestPhotoURL(query: query.lowercased().withoutSpaces()) { (data, _, error) in
            guard error == nil, let data = data, let imageObjects = try? JSONDecoder().decode(CityImageObject.self, from: data), let firstObject = imageObjects.results.first else { return }
            let urlString = firstObject.urls.full
            guard let url = URL(string: urlString) else { return }
            let dataTask = URLSession(configuration: .default).dataTask(with: url, completionHandler: completionHandler)
            dataTask.resume()
        }
    }
    
    // MARK: - Getting weather by OpenWeatherMap
    func getWeatherData(lat: Double, lon: Double, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(weatherAPIKey)"
        guard let url = URL(string: urlString) else { return }
        let dataTask = URLSession(configuration: .default).dataTask(with: url, completionHandler: completionHandler)
        dataTask.resume()
    }
}
