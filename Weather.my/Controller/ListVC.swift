//
//  ViewController.swift
//  Weather.my
//
//  Created by Денис Андриевский on 26.07.2020.
//  Copyright © 2020 Денис Андриевский. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class ListVC: UIViewController {
    
    private var locations: [Location] = []
    private var currentLocation: CityLocation?
    private var chosenLocation: CityLocation?
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var yourLocationBtn: UIButton!
    
    // MARK: - Instances
    private let unitHelper = UnitHelper()
    private let requestManager = RequestManager()
    private let geocoderHelper = GeocoderHelper()
    private let coreDataManager = CoreDataManager()
    private let locationManager = CLLocationManager()
    private let cache = NSCache<AnyObject, AnyObject>()
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        yourLocationBtn.layer.cornerRadius = 20
        addButton.layer.cornerRadius = 20
        
        locationManager.delegate = self
        
        self.locations = self.coreDataManager.fetchLocations()
        
        // Location Usage Request
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse && CLLocationManager.authorizationStatus() != .authorizedAlways {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.requestLocation()
        }
        
        // Cofiguring tableView
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
    }
    
    // MARK: - Alerts
    private func presentAddLocationAlert() {
        let alertController = UIAlertController(title: "New City", message: nil, preferredStyle: .alert)
        var cityField = UITextField()
        alertController.addTextField { textField in
            cityField = textField
            textField.placeholder = "Type city name"
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { [unowned self] _ in
            guard let text = cityField.text, text != "" else { return }
            self.coreDataManager.addLocation(name: text)
            self.locations = self.coreDataManager.fetchLocations()
            self.tableView.insertRows(at: [IndexPath(row: self.locations.count - 1, section: 0)], with: .fade)
        }
        alertController.addAction(addAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func presentSettingsAlert() {
        let alertController = UIAlertController(title: "Unable to proceed location", message: "Permission denied. Please give us access to your location in settings.", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Go to settings", style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL)
            }
        }
        alertController.addAction(settingsAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true)
    }
    
    private func presentLimitAlert() {
        let alertController = UIAlertController(title: "Oops..", message: "You cannot add more than five cities. It will overload geoserver.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true)
    }
    
    // MARK: - Configuring cache after cell removing
    private func removeCellFromCacheForNumber(_ num: Int) {
        cache.removeObject(forKey: "cell\(num)" as AnyObject)
        for number in num+1...locations.count + 1 {
            if let newObject = cache.object(forKey: "cell\(number)" as AnyObject) {
                cache.setObject(newObject, forKey: "cell\(number-1)" as AnyObject)
            } else {
                cache.removeObject(forKey: "cell\(number-1)" as AnyObject)
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func addbtnPressed(_ sender: UIButton) {
        if locations.count == 5 {
            presentLimitAlert()
        } else {
            presentAddLocationAlert()
        }
    }
    
    @IBAction func yourLocationBtnPressed(_ sender: Any) {
        if let currentLoation = currentLocation {
            self.chosenLocation = currentLoation
            performSegue(withIdentifier: C.locationSegue, sender: self)
        } else {
            if CLLocationManager.authorizationStatus() != .authorizedWhenInUse && CLLocationManager.authorizationStatus() != .authorizedAlways {
                presentSettingsAlert()
            } else {
                let alertController = UIAlertController(title: "Oops..", message: "We haven't finished fetching your geolocation", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertController, animated: true)
            }
        }
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? LocationVC else { return }
        dest.location = chosenLocation
    }
    
}

// MARK: - UITableViewDelegate
extension ListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: nil) { [unowned self] (_, _, _) in
            let objectToDelete = self.locations[indexPath.row]
            self.coreDataManager.delete(objectToDelete)
            self.locations = self.coreDataManager.fetchLocations()
            self.removeCellFromCacheForNumber(indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleteAction.image = #imageLiteral(resourceName: "delete")
        deleteAction.backgroundColor = .white
        let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeActionsConfiguration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cachedLocation = cache.object(forKey: "cell\(indexPath.row)" as AnyObject) as? CityLocation else { return }
        chosenLocation = cachedLocation
        performSegue(withIdentifier: C.locationSegue, sender: self)
    }
    
}

// MARK: - UITableViewDataSource
extension ListVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: C.cityCellIndentifier, for: indexPath) as? CityCell else { return UITableViewCell() }
        if let cachedLocation = cache.object(forKey: "cell\(indexPath.row)" as AnyObject) as? CityLocation {
            cell.cityLabel.text = cachedLocation.city
            cell.countryLabel.text = cachedLocation.country
            if let temperature = Int(cachedLocation.temperature) {
                cell.tempLabel.text = "\(temperature.convertedToCurrentUnit())" + unitHelper.getSymbolForCurrentUnit()
            }
        } else {
            geocoderHelper.getCityForQuery(locations[indexPath.row].name ?? "") { [unowned self] (placemarks, error) in
                guard let placemark = placemarks?.first, error == nil, let location = placemark.location else { return }
                self.geocoderHelper.getCityForLocation(location) { (placemarks, error) in
                    guard let placemark = placemarks?.first, error == nil, let lat = placemark.location?.coordinate.latitude, let lon = placemark.location?.coordinate.longitude else { return }
                    self.requestManager.getWeatherData(lat: lat, lon: lon) { (data, _, error) in
                        guard let data = data, let weather = try? JSONDecoder().decode(Weather.self, from: data) else { return }
                        DispatchQueue.main.async {
                            cell.cityLabel.text = placemark.locality ?? "Unrecognized"
                            cell.countryLabel.text = placemark.country ?? "Unrecognized"
                            let temperature = Int(weather.main.temp-273.15)
                            cell.tempLabel.text = "\(temperature.convertedToCurrentUnit())" + self.unitHelper.getSymbolForCurrentUnit()
                            let citylocation = CityLocation(city: placemark.locality ?? "Unrecognized", country: placemark.country ?? "Unrecognized", coreDataObject: self.locations[indexPath.row], temperature: "\(temperature)", coordinates: placemark.location?.coordinate ?? CLLocationCoordinate2D())
                            self.cache.setObject(citylocation as AnyObject, forKey: "cell\(indexPath.row)" as AnyObject)
                        }
                    }
                }
                
            }
        }
        cell.selectionStyle = .none
        cell.backgroundColor = .white
        return cell
    }
    
}

// MARK: - CLLocationManagerDelegate
extension ListVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status != .authorizedAlways && status != .authorizedWhenInUse) && status != .notDetermined {
            presentSettingsAlert()
        } else {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        geocoderHelper.getCityForLocation(location) { [unowned self] (placemarks, error) in
            guard let placemarks = placemarks, let location = placemarks.first, let coors = location.location?.coordinate, error == nil else { return }
            self.requestManager.getWeatherData(lat: coors.latitude, lon: coors.longitude) { (data, _, error) in
                guard let data = data, error == nil, let weather = try? JSONDecoder().decode(Weather.self, from: data) else { return }
                let temperature = Int(weather.main.temp-273.15)
                self.currentLocation = CityLocation(city: location.locality ?? "", country: location.country ?? "", coreDataObject: nil, temperature: "\(temperature)", coordinates: coors)
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR: \(error.localizedDescription)")
    }
    
}
