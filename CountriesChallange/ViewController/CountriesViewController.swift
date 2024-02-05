//
//  CountriesViewController.swift
//  CountriesChallange
//
//  Created by Madhur on 04/02/24.
//

import UIKit

public final class CountriesViewController: UITableViewController {
    
    private var refreshController: CountryRefreshController?
    var onCountrySelect: ((Country) -> Void)?
    private var allCountries: [Country] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private var countries: [Country] {
        isFiltering ? filteredCountries : allCountries
    }
    
    public var filteredCountries: [Country] = []
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    var isFiltering: Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!isSearchBarEmpty || searchBarScopeIsFiltering)
    }
    
    public lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.autocapitalizationType = .none
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
        return searchController
    }()
    
    public convenience init(refreshController: CountryRefreshController
                            , onCountrySelect: @escaping ((Country) -> Void)) {
        self.init()
        self.refreshController = refreshController
        self.onCountrySelect = onCountrySelect
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let customTableViewCellNib = UINib(nibName: "CountryCell", bundle: nil)
        tableView.register(customTableViewCellNib, forCellReuseIdentifier: CountryCell.identifier)
        
        refreshControl = refreshController?.refreshControl
        refreshController?.load()
        refreshController?.onRefresh = { [weak self] countries in
            guard let self = self else { return }
            self.allCountries = countries
        }
        searchController.hidesNavigationBarDuringPresentation = true
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CountryCell.identifier) as? CountryCell else {
            return UITableViewCell()
        }
        cell.configure(country: countries[indexPath.row])
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onCountrySelect?(countries[indexPath.row])
    }
}

extension CountriesViewController: UISearchResultsUpdating {
    
    public func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        filteredCountries = countries.filter { country in
            if isSearchBarEmpty {
                return true
            } else {
                return country.name.lowercased().contains(searchText) ||
                    country.capital.lowercased().contains(searchText)
            }
        }
        tableView.reloadData()
    }
}
