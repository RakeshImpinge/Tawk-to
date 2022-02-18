//
//  UserProfileViewModel.swift
//  Tawk.To App
//
//  Created by Raghav Kakria on 15/02/22.
//

import UIKit

class UserProfileViewModel {
    // MARK: - variables
    
    var userProfile = UserDetails()
    var setupUIClosure: (()->())?
    
    // MARK: - Fetch User Profile
    
    func fetchUserProfile(username: String) {
        let urlString = "https://api.github.com/users/\(username)"
        print("URL is : - \(urlString)")
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            let decoder = JSONDecoder()
            
            if let data = data {
                do {
                    let userProfile = try decoder.decode(UsersListModel.self, from: data)
                    let userExistance = CoreDataManager.shared.userAlreadyExists(username: self.userProfile.username ?? "", id: Int(self.userProfile.userId))
                    if userExistance.0 {
                        self.userProfile = CoreDataManager.shared.updateUserDetails(username: self.userProfile.username ?? "", followers: Int64(userProfile.followers ?? 0), following: Int64(userProfile.following ?? 0), name: userProfile.name ?? "", company: userProfile.company ?? "", blog: userProfile.blog ?? "") ?? UserDetails()
                    }
                    self.setupUIClosure?()
                }catch(let error) {
                    print(error.localizedDescription)
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Save notes to user
    
    func saveNotesToUser(notesData: String) {
        CoreDataManager.shared.updateUserNotesData(username: self.userProfile.username ?? "", notes: notesData)
    }
}
