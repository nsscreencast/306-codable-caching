//
//  File.swift
//  Top Repos
//
//  Created by Ben Scheirman on 10/11/17.
//  Copyright © 2017 NSScreencast. All rights reserved.
//

import UIKit

class ContributorListViewController : UITableViewController {
    
    let client = GitHubClient.shared
    var repository: Repository!
    var collaborators: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = repository.name
        fetchCollaborators()
    }
    
    @objc private func fetchCollaborators() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        client.fetchContributors(repository: repository) { result in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            switch result {
            case .success(let collaborators):
                self.collaborators = collaborators
                self.tableView.reloadData()
            case .error(let e):
                print(e)
                self.displayError(e)
            }
        }
    }
    
    private func displayError(_ error: Error) {
        let alert = UIAlertController(title: nil, message: "Error loading contributors", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { action in
            self.fetchCollaborators()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDatasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collaborators.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let collaborator = collaborators[indexPath.row]
        cell.textLabel?.text = collaborator.login
        
        return cell
    }

}
