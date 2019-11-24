//
//  CoreDataManager.swift
//  TrendingVenues
//
//  Created by Dobromir Penev on 23.11.19.
//  Copyright © 2019 Dobromir Penev. All rights reserved.
//

//import Foundation
import CoreData
import UIKit


class CoreDataManager {
    
    static let sharedInstance = CoreDataManager()
    
    lazy var context = getContext()
    
    func getContext() -> NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    func getTrendingVenues() -> [Venue]? {
        let fetchRequest = Venue.fetchRequest() as NSFetchRequest<Venue>
        fetchRequest.fetchLimit = 5
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "address.distance", ascending: true)]
        do {
            return try context.fetch(fetchRequest)
        }
        catch {
            debugPrint(#function + "fail with error \(error.localizedDescription)")
            return nil
        }
    }
    
    func persistDataAndSave(response: [String: Any]?, completion: @escaping (_ didFindVenues: Bool)->()) {
        guard let response = response?["response"] as? [String: Any], let venues = response["venues"] as? [[String: Any]], !venues.isEmpty else {
            print("no venues")
            completion(false)
            return
        }
        deleteAllRecords()
        venues.forEach({ (venue) in
            _ = Venue(fromJson: venue, context: context)
        })
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
        completion(true)
    }
    
    func deleteAllRecords() {
        let deleteFetchVenue = NSFetchRequest<NSFetchRequestResult>(entityName: "Venue")
        let deleteRequestVenue = NSBatchDeleteRequest(fetchRequest: deleteFetchVenue)
        let deleteFetchAddress = NSFetchRequest<NSFetchRequestResult>(entityName: "Address")
        let deleteRequestAddress = NSBatchDeleteRequest(fetchRequest: deleteFetchAddress)
        do {
            try context.execute(deleteRequestVenue)
            try context.execute(deleteRequestAddress)
            try context.save()
        } catch {
            print ("There is an error in deleting records")
        }
    }
}
