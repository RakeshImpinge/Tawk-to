//
//  UsersViewModel.swift
//  Tawk.To App
//
//  Created by Raghav Kakria on 14/02/22.
//

import UIKit

class UsersViewModel {
    
    // MARK: - variables
    
    var usersList = [UserDetails]()
    var reloadTableViewClosure: (()->())?
    var hideShowLoaderClosure: ((_ isShow: Bool)->())?
    
    // MARK: - Fetch Users List
    
    func fetchUsersList(id: Int) {
        let urlString = "https://api.github.com/users?since=\(id)"
        print("URL is : - \(urlString)")
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        self.hideShowLoaderClosure?(true)
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            let decoder = JSONDecoder()
            
            if let data = data {
                do {
//                    if id == 0 {
//                        CoreDataManager.shared.deleteRecords()
//                    }
                    let usersLists = try decoder.decode([UsersListModel].self, from: data)
                    for user in usersLists {
                        let userExistance = CoreDataManager.shared.userAlreadyExists(username: user.login ?? "", id: user.id ?? 0)
                        if !userExistance.0 {
                            CoreDataManager.shared.createUserDetails(userImage: user.avatarUrl ?? "", username: user.login ?? "", usertype: user.type ?? "", id: user.id ?? 0)
                        }
                    }
                    self.processUsersData()
                }catch(let error) {
                    print(error.localizedDescription)
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Process Users Data
    
    func processUsersData() {
        if let usersList = CoreDataManager.shared.fetchUserDetails() {
            self.usersList = usersList
        }
        self.hideShowLoaderClosure?(false)
        self.reloadTableViewClosure?()
    }
}
