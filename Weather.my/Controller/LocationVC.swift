//
//  LocationVC.swift
//  Weather.my
//
//  Created by Денис Андриевский on 02.08.2020.
//  Copyright © 2020 Денис Андриевский. All rights reserved.
//

import UIKit

class LocationVC: UIViewController {
    
    var location: CityLocation!
    
    // MARK: - IBOutlets
    @IBOutlet weak var cityImageView: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var recommendationLabel: UILabel!
    @IBOutlet weak var noteView: UITextView!
    
    // MARK: - Instances
    private let requestManager = RequestManager()
    private let unitHelper = UnitHelper()
    private var coreDataManager = CoreDataManager()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        requestManager.getPhoto(query: location.city) { [weak self] (data, _, error) in
            guard error == nil, let imageData = data, let image = UIImage(data: imageData), let self = self else { return }
            DispatchQueue.main.async {
                self.cityImageView.image = image
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveNote()
    }
    
    private func saveNote() {
        guard let object = location.coreDataObject else { return }
        coreDataManager.add(note: noteView.text, to: object)
    }
    
    private func configureUI() {
        cityNameLabel.text = location.city
        countryNameLabel.text = location.country
        if let temperature = Int(location.temperature) {
            temperatureLabel.text = "\(temperature.convertedToCurrentUnit())" + unitHelper.getSymbolForCurrentUnit()
            recommendationLabel.text = RecommendationGenerator.generateRecomendation(for: temperature)
        }
        noteView.layer.cornerRadius = 10
        if location.coreDataObject == nil {
            noteView.isHidden = true
        } else if let note = location.coreDataObject?.note {
            noteView.text = note
        }
        noteView.delegate = self
    }

}

extension LocationVC: UITextViewDelegate {
    
    // Dismiss keyboard on return key
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
}
