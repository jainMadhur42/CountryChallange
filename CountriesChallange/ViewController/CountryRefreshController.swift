//
//  CountryRefreshController.swift
//  CountriesChallange
//
//  Created by Madhur on 04/02/24.
//

import UIKit

public class CountryRefreshController: NSObject {
    
    private(set) lazy var refreshControl: UIRefreshControl = {
        var view = UIRefreshControl()
        view.addTarget(self, action: #selector(load), for: .valueChanged)
        return view
    }()
    
    var loader: CountryLoader
    var onRefresh: (([Country]) -> Void)?
    
    public init(loader: CountryLoader) {
        self.loader = loader
    }
    
    @objc func load() {
        refreshControl.beginRefreshing()
        loader.load { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let countries):
                self.onRefresh?(countries)
            case .failure(let error):
                break
            }
            self.refreshControl.endRefreshing()
        }
    }
}
