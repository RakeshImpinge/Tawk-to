//
//  UsersViewController.swift
//  Tawk.To App
//
//  Created by Raghav Kakria on 14/02/22.
//

import UIKit

var gradientColorOne : CGColor = UIColor(white: 0.85, alpha: 1.0).cgColor
var gradientColorTwo : CGColor = UIColor(white: 0.95, alpha: 1.0).cgColor

class UsersViewController: BaseViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var searchBar: UISearchBar = UISearchBar(frame: .zero)
    
    var searchedUsersList = [UserDetails]()
    
    // MARK: - Variables
    
    lazy var usersViewModel: UsersViewModel = {
        return UsersViewModel()
    }()
    
    let loadingIndicatorView = UIView()
    let activityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    var isSearching: Bool = false
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // initialize loader
        self.initializeLoader()
        
        // initialize closures
        self.initializeClosures()
        
        // Show UI
        self.usersViewModel.processUsersData()
        
        // Add search bar to nav bar
        addSearchBarToNavBar()
        
        // Add observer and start notifying net connection
        NotificationCenter.default.addObserver(self, selector: #selector(checkForReachability(_:)), name: NSNotification.Name.reachabilityChanged, object: nil)
        
        do {
            reachability = try Reachability()
            try reachability.startNotifier()
        } catch(let error) {
            print("Error notifying: \(error.localizedDescription)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add observer
        NotificationCenter.default.addObserver(self, selector: #selector(shimmerObserver(_:)), name: NSNotification.Name("ShimmerEffect"), object: nil)
        
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove observer
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ShimmerEffect"), object: nil)
    }
    
    // MARK: - Add Observer
    
    @objc func shimmerObserver(_ notif: NSNotification) {
        if let tableview = notif.userInfo?["tableView"] as? UITableView {
            let cells = tableview.visibleCells
            
            
            for cell in cells {
                if cell is UsersNormalTableViewCell {
                    (cell as! UsersNormalTableViewCell).userAvatarImageView.startAnimatingShimmerEffect()
                    (cell as! UsersNormalTableViewCell).usernameLabel.startAnimatingShimmerEffect()
                    (cell as! UsersNormalTableViewCell).userDetailsLabel.startAnimatingShimmerEffect()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        (cell as! UsersNormalTableViewCell).userAvatarImageView.stopAnimatingShimmerEffect()
                        (cell as! UsersNormalTableViewCell).usernameLabel.stopAnimatingShimmerEffect()
                        (cell as! UsersNormalTableViewCell).userDetailsLabel.stopAnimatingShimmerEffect()
                    }
                }
                
                if cell is UsersNotesTableViewCell {
                    (cell as! UsersNotesTableViewCell).userAvatarImageView.startAnimatingShimmerEffect()
                    (cell as! UsersNotesTableViewCell).usernameLabel.startAnimatingShimmerEffect()
                    (cell as! UsersNotesTableViewCell).userDetailsLabel.startAnimatingShimmerEffect()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        (cell as! UsersNotesTableViewCell).userAvatarImageView.stopAnimatingShimmerEffect()
                        (cell as! UsersNotesTableViewCell).usernameLabel.stopAnimatingShimmerEffect()
                        (cell as! UsersNotesTableViewCell).userDetailsLabel.stopAnimatingShimmerEffect()
                    }
                }
            }
        }
    }
    
    // MARK: - Add search bar to nav bar
    
    func addSearchBarToNavBar() {
        self.searchBar.sizeToFit()
        self.searchBar.placeholder = "search"
        self.searchBar.delegate = self
//        self.searchBar.showsCancelButton = true
        
        self.navigationItem.titleView = self.searchBar
    }
    
    // MARK: - Initialize Loader
    
    func initializeLoader() {
        loadingIndicatorView.frame = UIScreen.main.bounds
        loadingIndicatorView.backgroundColor = .gray
        loadingIndicatorView.alpha = 0.5
        loadingIndicatorView.isHidden = true
        
        activityIndicatorView.center = CGPoint(
                x: UIScreen.main.bounds.size.width / 2,
                y: UIScreen.main.bounds.size.height / 2
        )
        
        activityIndicatorView.color = .white
        activityIndicatorView.hidesWhenStopped = true
        
        loadingIndicatorView.addSubview(activityIndicatorView)
        self.view.addSubview(loadingIndicatorView)
    }
    
    // MARK: - Initialize Closures
    
    func initializeClosures() {
        self.reloadTableViewClosure()
        self.hideShowLoaderClosure()
    }
    
    // MARK: - Initialize Closures
    
    func reloadTableViewClosure() {
        self.usersViewModel.reloadTableViewClosure = { [weak self] () in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name("ShimmerEffect"), object: nil, userInfo: ["tableView":self.tableView as Any])
                self.tableView.reloadData()
            }
        }
    }
    
    func hideShowLoaderClosure() {
        self.usersViewModel.hideShowLoaderClosure = { [weak self] (isShow) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if isShow {
                    self.activityIndicatorView.startAnimating()
                    self.loadingIndicatorView.isHidden = false
                }
                else {
                    self.activityIndicatorView.stopAnimating()
                    self.loadingIndicatorView.isHidden = true
                }
            }
        }
    }
    
    // MARK: - Check for internet connectivity
    
    @objc func checkForReachability(_ notif: Notification) {
        if let reach = notif.object as? Reachability {
            switch reach.connection {
            case .cellular, .wifi:
                if ReachabilityNet().isConnectedToNetwork() {
                    // API call
                    self.usersViewModel.fetchUsersList(id: 0)
                }
            default:
                print("Disconnected")
            }
        }
    }
}

extension UsersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return self.searchedUsersList.count
        }
        else {
            return self.usersViewModel.usersList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearching {
            if self.searchedUsersList[indexPath.row].notes ?? "" == "" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UsersNormalTableViewCell", for: indexPath) as! UsersNormalTableViewCell
                cell.userAvatarImageView.layer.cornerRadius = cell.userAvatarImageView.frame.height / 2
                cell.usernameLabel.text = self.searchedUsersList[indexPath.row].username
                cell.userDetailsLabel.text = self.searchedUsersList[indexPath.row].userType
                cell.lineView.backgroundColor = traitCollection.userInterfaceStyle == .light ? UIColor.gray : UIColor.white
                
                if let data = self.searchedUsersList[indexPath.row].userImageData {
                    DispatchQueue.main.async {
                        cell.userAvatarImageView.image = UIImage(data: data)
                    }
                }
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UsersNotesTableViewCell", for: indexPath) as! UsersNotesTableViewCell
                cell.userAvatarImageView.layer.cornerRadius = cell.userAvatarImageView.frame.height / 2
                cell.usernameLabel.text = self.searchedUsersList[indexPath.row].username
                cell.userDetailsLabel.text = self.searchedUsersList[indexPath.row].userType
                cell.lineView.backgroundColor = traitCollection.userInterfaceStyle == .light ? UIColor.gray : UIColor.white
                
                if let data = self.searchedUsersList[indexPath.row].userImageData {
                    DispatchQueue.main.async {
                        cell.userAvatarImageView.image = UIImage(data: data)
                    }
                }
                return cell
            }
        }
        else {
            if self.usersViewModel.usersList[indexPath.row].notes ?? "" == "" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UsersNormalTableViewCell", for: indexPath) as! UsersNormalTableViewCell
                cell.userAvatarImageView.layer.cornerRadius = cell.userAvatarImageView.frame.height / 2
                cell.usernameLabel.text = self.usersViewModel.usersList[indexPath.row].username
                cell.userDetailsLabel.text = self.usersViewModel.usersList[indexPath.row].userType
                cell.lineView.backgroundColor = traitCollection.userInterfaceStyle == .light ? UIColor.gray : UIColor.white
                
                if let data = self.usersViewModel.usersList[indexPath.row].userImageData {
                    DispatchQueue.main.async {
                        cell.userAvatarImageView.image = UIImage(data: data)
                    }
                }
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UsersNotesTableViewCell", for: indexPath) as! UsersNotesTableViewCell
                cell.userAvatarImageView.layer.cornerRadius = cell.userAvatarImageView.frame.height / 2
                cell.usernameLabel.text = self.usersViewModel.usersList[indexPath.row].username
                cell.userDetailsLabel.text = self.usersViewModel.usersList[indexPath.row].userType
                cell.lineView.backgroundColor = traitCollection.userInterfaceStyle == .light ? UIColor.gray : UIColor.white
                
                if let data = self.usersViewModel.usersList[indexPath.row].userImageData {
                    DispatchQueue.main.async {
                        cell.userAvatarImageView.image = UIImage(data: data)
                    }
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearching {
            if self.searchedUsersList.count > 0 {
                let profileController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
                profileController.userProfileViewModel.userProfile = self.searchedUsersList[indexPath.row]
                self.navigationController?.pushViewController(profileController, animated: true)
            }
        }
        else {
            if self.usersViewModel.usersList.count > 0 {
                let profileController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
                profileController.userProfileViewModel.userProfile = self.usersViewModel.usersList[indexPath.row]
                self.navigationController?.pushViewController(profileController, animated: true)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !self.isSearching {
            let height = scrollView.frame.size.height
            let contentYoffset = scrollView.contentOffset.y
            let distanceFromBottom = scrollView.contentSize.height - contentYoffset
            if distanceFromBottom < height {
                if let id = self.usersViewModel.usersList.last?.userId {
                    if ReachabilityNet().isConnectedToNetwork() {
                        // API call
                        self.usersViewModel.fetchUsersList(id: Int(id))
                    }
                }
            }
        }
    }
}

extension UsersViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.isSearching = false
            
            self.searchedUsersList.removeAll()
            
            self.tableView.reloadData()
        }
        else {
            self.isSearching = true
            
            self.searchedUsersList = self.usersViewModel.usersList.filter({($0.username ?? "").lowercased().prefix(searchText.count) == searchText.lowercased()})
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Search cancel clicked")
    }
}

class UsersNormalTableViewCell: UITableViewCell {
    // MARK: - Outlets
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userDetailsLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
}

class UsersNotesTableViewCell: UITableViewCell {
    // MARK: - Outlets
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userDetailsLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
}

extension UIView {
    // MARK: - Start animating shimmer effect
    
    func startAnimatingShimmerEffect() {
        let gradientLayer = CAGradientLayer()
        /* Allocate the frame of the gradient layer as the view's bounds, since the layer will sit on top of the view. */
        
        gradientLayer.frame = self.bounds
        /* To make the gradient appear moving from left to right, we are providing it the appropriate start and end points.
         Refer to the diagram above to understand why we chose the following points.
         */
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.colors = [gradientColorOne, gradientColorTwo, gradientColorOne]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        
        /* Adding the gradient layer on to the view */
        self.layer.insertSublayer(gradientLayer, at: 0)
        
        let animation = CABasicAnimation(keyPath: "locations")
        
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
    
        animation.repeatCount = .infinity
        animation.duration = 1
        
        gradientLayer.add(animation, forKey: animation.keyPath)
    }
    
    func stopAnimatingShimmerEffect() {
        if let gradiantLayer = self.layer.sublayers?.first as? CAGradientLayer {
            gradiantLayer.removeAllAnimations()
            gradiantLayer.removeFromSuperlayer()
        }
    }
}

