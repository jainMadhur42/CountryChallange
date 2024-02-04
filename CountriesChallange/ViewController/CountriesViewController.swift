//
//  CountriesViewController.swift
//  CountriesChallange
//
//  Created by Madhur on 04/02/24.
//

import Foundation
import UIKit

public final class CountriesViewController: UITableViewController {
    
    private var loader: CountryLoader?
    private var tableModel = [Country]()
    
    public convenience init(loader: CountryLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] result in
            switch result {
            case .success(let countries):
                self?.tableModel = countries
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
            case .failure(let error):
                break
            }
            
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = CountryCell()
        cell.configure(country: cellModel)
        return cell
    }
    
}
