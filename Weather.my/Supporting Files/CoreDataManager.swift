//
//  CoreDataManager.swift
//  Weather.my
//
//  Created by Денис Андриевский on 26.07.2020.
//  Copyright © 2020 Денис Андриевский. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager {
    
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    private let managedContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    func addLocation(name: String) {
        guard let appDelegate = appDelegate, let managedContext = managedContext else { return }
        let newLocation = Location(entity: Location.entity(), insertInto: managedContext)
        newLocation.name = name
        appDelegate.saveContext()
    }
    
    func fetchLocations() -> [Location] {
        let fetchRequest = NSFetchRequest<Location>(entityName: "Location")
        guard let managedContext = managedContext else { return [] }
        guard let results = try? managedContext.fetch(fetchRequest) else { return [] }
        return results
    }
    
    func delete(_ location: Location) {
        guard let appDelegate = appDelegate, let managedContext = managedContext else { return }
        managedContext.delete(location)
        appDelegate.saveContext()
    }
    
    func add(note: String, to location: Location) {
        guard let appDelegate = appDelegate else { return }
        location.note = note
        appDelegate.saveContext()
    }
    
    
}
