//
//  UserProfileViewController.swift
//  Tawk.To App
//
//  Created by Raghav Kakria on 15/02/22.
//

import UIKit

class UserProfileViewController: BaseViewController {
    // MARK: - Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var blogLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Variables
    
    lazy var userProfileViewModel: UserProfileViewModel = {
        return UserProfileViewModel()
    }()
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // initialize closures
        self.initializeClosures()
                
        // API call
        if ReachabilityNet().isConnectedToNetwork() {
            self.userProfileViewModel.fetchUserProfile(username: self.userProfileViewModel.userProfile.username ?? "")
        }
        
        // Change border color
        self.changeBorderColor(view: self.detailsView, color: traitCollection.userInterfaceStyle == .light ? UIColor.black.cgColor : UIColor.white.cgColor, borderWidth: 1)
        self.changeBorderColor(view: self.notesTextView, color: traitCollection.userInterfaceStyle == .light ? UIColor.black.cgColor : UIColor.white.cgColor, borderWidth: 1)
    }
    
    // MARK: - Change Border Color
    
    func changeBorderColor(view: UIView, color: CGColor, borderWidth: CGFloat) {
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = color
    }
    
    // MARK: - Initialize Closures
    
    func initializeClosures() {
        self.setupUIClosure()
    }
    
    // MARK: - Initialize Closures
    
    func setupUIClosure() {
        self.userProfileViewModel.setupUIClosure = { [weak self] () in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.title = self.userProfileViewModel.userProfile.name ?? ""
//                if let imageUrl = URL(string: self.userProfileViewModel.userProfile.userImage ?? ""), let data = try? Data(contentsOf: imageUrl) {
//                    self.userProfileImageView.image = UIImage(data: data)
//                }
                if let data = self.userProfileViewModel.userProfile.userImageData {
                    self.userProfileImageView.image = UIImage(data: data)
                }
                self.followersLabel.text = "\(self.userProfileViewModel.userProfile.followers)"
                self.followingLabel.text = "\(self.userProfileViewModel.userProfile.following)"
                self.usernameLabel.text = self.userProfileViewModel.userProfile.name
                self.companyNameLabel.text = self.userProfileViewModel.userProfile.company
                self.blogLabel.text = self.userProfileViewModel.userProfile.blog
                
                self.notesTextView.text = self.userProfileViewModel.userProfile.notes
            }
        }
    }
    
    // MARK: - Button Actions
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        self.userProfileViewModel.saveNotesToUser(notesData: self.notesTextView.text)
        self.view.endEditing(true)
    }
}
