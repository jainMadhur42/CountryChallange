//
//  CountryRefreshController.swift
//  CountriesChallange
//
//  Created by Madhur on 04/02/24.
//

import UIKit

public class CountryRefreshController: NSObject {
    
    var loader: CountryLoader
    var onRefresh: (([Country]) -> Void)?
    var onError: ((Error) -> Void)?
    
    
    private(set) lazy var refreshControl: UIRefreshControl = {
        var view = UIRefreshControl()
        view.addTarget(self, action: #selector(load), for: .valueChanged)
        return view
    }()
    
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
                self.onError?(error)
                break
            }
            self.refreshControl.endRefreshing()
        }
    }
}
