//
//  SettingsTVC.swift
//  Weather.my
//
//  Created by Денис Андриевский on 29.07.2020.
//  Copyright © 2020 Денис Андриевский. All rights reserved.
//

import UIKit

class SettingsTVC: UITableViewController {
    
    private var currentUnit: Unit = .celsium
    
    // MARK: - IBOutlets
    @IBOutlet weak var unitSegmentedControl: UISegmentedControl!
    
    // MARK: - Instances
    private let unitHelper = UnitHelper()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.currentUnit = unitHelper.getCurrentUnit() ?? .celsium
        updateUI()
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }
    
    private func updateUI() {
        self.unitSegmentedControl.selectedSegmentIndex = self.currentUnit == .celsium ? 0 : 1
    }
    
    // MARK: - IBActions
    @IBAction func unitSegmentedControlDidChanged(_ sender: Any) {
        unitHelper.setUnit(currentUnit == .celsium ? .fahrenheit : .celsium)
        self.currentUnit = unitHelper.getCurrentUnit() ?? .celsium
        updateUI()
    }
    

}
