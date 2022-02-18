//
//  CoreDataManager.swift
//  Tawk.To App
//
//  Created by Raghav Kakria on 16/02/22.
//

import UIKit
import CoreData

struct CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tawk_To_App")
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Loading of store failed with: \(error)")
            }
        }
        return container
    }()
    
    // MARK: - Create records
    
    @discardableResult
    func createUserDetails(userImage: String, username: String, usertype: String, id: Int) -> UserDetails? {
        let context = persistentContainer.viewContext
        
        let userDetails = NSEntityDescription.insertNewObject(forEntityName: "UserDetails", into: context) as! UserDetails
        userDetails.userImage = userImage
        userDetails.username = username
        userDetails.userType = usertype
        userDetails.userId = Int64(id)
        
//        if let url = URL(string: userImage) {
//            ImageCaching.shared.loadData(url: url, id: id) { data, error in
//                if let _ = error {
                    if let imageUrl = URL(string: userImage), let data = try? Data(contentsOf: imageUrl) {
                        userDetails.userImageData = data
                    }
//                }
//                else if let data = data {
//                    userDetails.userImageData = data
//                }
//            }
//        }
        
        do {
            try context.save()
            return userDetails
        } catch(let error) {
            print("Failed to insert with: \(error.localizedDescription)")
        }
        return nil
    }
    
    @discardableResult
    
    func updateUserDetails(username: String, followers: Int64, following: Int64, name: String, company: String, blog: String) -> UserDetails? {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<UserDetails>(entityName: "UserDetails")
        fetchRequest.fetchLimit = 1
        let usernamePredicate = NSPredicate(format: "username == %@", username)
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [
            usernamePredicate
        ])
        
        do {
            let details = try context.fetch(fetchRequest)
            if details.count > 0 {
                if let firstDetail = details.first {
                    firstDetail.followers = followers
                    firstDetail.following = following
                    firstDetail.name = name
                    firstDetail.company = company
                    firstDetail.blog = blog
                    try context.save()
                    return firstDetail
                }
            }
        } catch(let error) {
            print("Error fetching detail: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func updateUserNotesData(username: String, notes: String) {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<UserDetails>(entityName: "UserDetails")
        fetchRequest.fetchLimit = 1
        let usernamePredicate = NSPredicate(format: "username == %@", username)
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [
            usernamePredicate
        ])
        
        do {
            let details = try context.fetch(fetchRequest)
            if details.count > 0 {
                if let firstDetail = details.first {
                    firstDetail.notes = notes
                    try context.save()
                }
            }
        } catch(let error) {
            print("Error fetching detail: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fetch Records
    
    func fetchUserDetails() -> [UserDetails]? {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<UserDetails>(entityName: "UserDetails")
        
        do {
            let details = try context.fetch(fetchRequest)
            return details
        } catch(let error) {
            print("Error fetching details: \(error.localizedDescription)")
        }
        return nil
    }
    
    func userAlreadyExists(username: String, id: Int) -> (Bool, UserDetails?) {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<UserDetails>(entityName: "UserDetails")
        fetchRequest.fetchLimit = 1
        let usernamePredicate = NSPredicate(format: "username == %@", username)
//        let idPredicate = NSPredicate(format: "userId == %@", Int64(id))
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [
            usernamePredicate//, idPredicate
        ])
        
        do {
            let details = try context.fetch(fetchRequest)
            if details.count > 0 {
                return (true,details.first)
            }
        } catch(let error) {
            print("Error fetching detail: \(error.localizedDescription)")
        }
        return (false, nil)
    }
    
    // MARK: - Delete Records
    
    func deleteRecords() {
        if let details = self.fetchUserDetails() {
            let context = persistentContainer.viewContext
            
            for detail in details {
                context.delete(detail)
            }
            
            do {
                try context.save()
            } catch(let error) {
                print("Error deleting: \(error.localizedDescription)")
            }
        }
    }
}
