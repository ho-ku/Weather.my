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
    private var currentLocation: CLLocation?
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var yourLocationBtn: UIButton!
    
    // MARK: - Instances
    private let geocoderHelper = GeocoderHelper()
    private let coreDataManager = CoreDataManager()
    private var locationManager = CLLocationManager()
    
    // MARK: - Lifecycle
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
    
    // MARK: - IBActions
    @IBAction func addbtnPressed(_ sender: UIButton) {
        presentAddLocationAlert()
    }
    @IBAction func yourLocationBtnPressed(_ sender: Any) {
        if let currentLoation = currentLocation {
            print(currentLoation.coordinate)
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
    
}

// MARK: - UITableViewDelegate
extension ListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == locations.count {
            return 60
        }
        return 200
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: nil) { [unowned self] (_, _, _) in
            let objectToDelete = self.locations[indexPath.row]
            self.coreDataManager.delete(objectToDelete)
            self.locations = self.coreDataManager.fetchLocations()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleteAction.image = #imageLiteral(resourceName: "delete")
//        if let image = #imageLiteral(resourceName: "delete").cgImage {
//            deleteAction.image = ImageWithoutRender(cgImage: image)
//        }
        deleteAction.backgroundColor = .white
        let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeActionsConfiguration
    }
    
}

// MARK: - UITableViewDataSource
extension ListVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: C.cityCellIndentifier, for: indexPath) as? CityCell else { return UITableViewCell() }
        geocoderHelper.getCityForQuery(locations[indexPath.row].name ?? "") { (placemarks, error) in
            guard let placemark = placemarks?.first, error == nil else { return }
            DispatchQueue.main.async {
                cell.cityLabel.text = placemark.locality ?? "Unrecognized"
                cell.countryLabel.text = placemark.country ?? "Unrecognized"
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
            guard let placemarks = placemarks, let location = placemarks.first, error == nil else { return }
            self.currentLocation = location.location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR: \(error.localizedDescription)")
    }
    
}
