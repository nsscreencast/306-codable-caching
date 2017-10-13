//
//  ViewController.swift
//  Top Repos
//
//  Created by Ben Scheirman on 10/11/17.
//  Copyright © 2017 NSScreencast. All rights reserved.
//

import UIKit

class RepositoryListViewController: UITableViewController {

    let client = GitHubClient.shared
    var repositories: [Repository] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(fetchRepositories), for: .valueChanged)
        
        fetchRepositories()
    }
    
    @objc private func fetchRepositories() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        client.searchRepositories(term: "topic:swift") { result in
            self.refreshControl?.endRefreshing()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            switch result {
            case .success(let repositories):
                self.repositories = repositories
                self.tableView.reloadData()
            case .error(let e):
                print(e)
                self.displayError(e)
            }
        }
    }

    private func displayError(_ error: Error) {
        let alert = UIAlertController(title: nil, message: "Error loading repositories", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { action in
            self.fetchRepositories()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "contributorsSegue":
            let destination = segue.destination as! ContributorListViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destination.repository = repositories[indexPath.row]
            }
        default:
            break
        }
    }
    
    // MARK: - UITableViewDatasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RepositoryCell.self), for: indexPath) as! RepositoryCell
        
        let repo = repositories[indexPath.row]
        updateCell(cell, withRepo: repo)
        
        return cell
    }
    
    private func updateCell(_ cell: RepositoryCell, withRepo repo: Repository) {
        cell.nameLabel.text = repo.name
        cell.descriptionLabel.text = repo.description
        cell.starsLabel.text = "⭐️ \(repo.stargazersCount)"
        cell.forksLabel.text = "🍴 \(repo.forksCount)"
    }
}

