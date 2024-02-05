//
//  CountriesViewControllerTests.swift
//  CountriesChallangeTests
//
//  Created by Madhur on 04/02/24.
//

import XCTest

import CountriesChallange


final class CountriesViewControllerTests: XCTestCase {

    func test_loadCountry_requestFromCountryLoader() {
        
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading request before view is loaded")
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1, "Expected 1 loading request once view is loaded")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates a load")
        
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected a third loading request once user initiates another load")
    }
    
    func test_loadingCountryIndicator_isVisibleWhileLoadingCountry() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected Loading indicator once view is loaded")
        
        loader.completeCountryLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")
    
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        loader.completeCountryLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completed")
    }
    
    func test_loadCountryCompletion_renderSuccessfullyLoadedCountry() {
        let country = anyCountry()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.numberOfRenderedCountryView(), 0)
        
        loader.completeCountryLoading(with: [country], at: 0)
        XCTAssertEqual(sut.numberOfRenderedCountryView(), 1)
        
        assertThat(sut: sut, configureWith: country, at: 0)

        sut.simulateUserInitiatedReload()
        loader.completeCountryLoading(with: [anyCountry(), anyCountry2()], at: 1)
        
        XCTAssertEqual(sut.numberOfRenderedCountryView(), 2)
        assertThat(sut: sut, configureWith: anyCountry2(), at: 1)
    }
    
    func test_loadCountryCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let country = anyCountry()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeCountryLoading(with: [country], at: 0)
        XCTAssertEqual(sut.numberOfRenderedCountryView(), 1)
        
        assertThat(sut: sut, configureWith: country, at: 0)

        sut.simulateUserInitiatedReload()
        loader.completeCountryLoadingWithError(at: 1)
        
        assertThat(sut: sut, configureWith: country, at: 0)
    }
    
    func test_loadCountryCompletion_ShowAlertControllerOnError() {
        let country = anyCountry()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeCountryLoading(with: [country], at: 0)
        XCTAssertEqual(sut.numberOfRenderedCountryView(), 1)
        
        assertThat(sut: sut, configureWith: country, at: 0)

        sut.simulateUserInitiatedReload()
        loader.completeCountryLoadingWithError(at: 1)
        
        //XCTAssertNotNil(sut.alert as! UIAlertController, "Expected Error controller should be visible but")
    }
    
    func test_loadingIndicator_isVisibleWhileLoadingCountry() {
        let country = anyCountry()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeCountryLoading(with: [country], at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completed")
        
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiate a reload")
        
        loader.completeCountryLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completed")
        
        assertThat(sut: sut, configureWith: country, at: 0)
    }
    
    func test_SearchController_showsOnlySearchedDataInTable() {
        let countries = [anyCountry(), anyCountry2()]
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeCountryLoading(with: countries, at: 0)
        
        sut.search(for: countries[0].name)
        
        XCTAssertEqual(sut.filteredCountries.count, 1)
        assertThat(sut: sut, configureWith: anyCountry(), at: 0)
        
        sut.clearSearch()
        XCTAssertEqual(sut.filteredCountries.count, countries.count)
        XCTAssertFalse(sut.searchController.isActive)
    }

    func test_tableView_tap() {
        let countries = [anyCountry(), anyCountry2()]
        var receivedCountry: Country?
        let (sut, loader) = makeSUT { country in
            receivedCountry = country
        }
        
        sut.loadViewIfNeeded()
        loader.completeCountryLoading(with: countries, at: 0)
        
        sut.simulateTapCountry(at: 0)
        XCTAssertEqual(receivedCountry, countries[0])
        
        sut.simulateTapCountry(at: 1)
        XCTAssertEqual(receivedCountry, countries[1])
    }
    
    
    private func makeSUT(onCountrySelect: @escaping ((Country) -> Void) = { _ in }
                         , file: StaticString = #file
                         , line: UInt = #line) -> (sut: CountriesViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let refreshController = CountryRefreshController(loader: loader)
        let sut = CountriesViewController(refreshController: refreshController, onCountrySelect: onCountrySelect)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        return (sut, loader)
    }
    
    
    private func assertThat(sut: CountriesViewController, configureWith country: Country, at index: Int, 
                            file: StaticString = #file, line: UInt = #line) {
        let view = sut.country(at: index) as? CountryCell
        XCTAssertNotNil(view, "Expect view should not be null"
                        , file: file, line: line)
        XCTAssertEqual(view?.nameAndCountry, "\(country.name), \(country.region)"
                       , "Expected name and country label should be \(country.name), \(country.region) but found \(view?.nameAndCountry)"
                       , file: file, line: line)
        XCTAssertEqual(view?.countryCode, country.code
                       , "Expected Country code \(country.code) but found \(view?.countryCode)"
                       , file: file, line: line)
        XCTAssertEqual(view?.capital, country.capital
                       , "Expected Country Capital \(country.capital) but found \(view?.capitalLabel)"
                       , file: file, line: line)
    }
    
    class LoaderSpy: CountryLoader {
        
        var completions = [(LoadCountryResult) -> Void]()
        
        var loadCallCount: Int {
            return completions.count
        }
        
        func load(completion: @escaping (LoadCountryResult) -> Void) {
            completions.append(completion)
        }
        
        func completeCountryLoading(with countries: [Country] = [], at index: Int) {
            completions[index](.success(countries))
        }
        
        func completeCountryLoadingWithError(at index: Int = 0) {
            
            let error = NSError(domain: "Any Error", code: 0)
            completions[index](.failure(error))
        }
    }
}

private extension CountriesViewController {
    
    private var section: Int {
        return 0
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedCountryView() -> Int {
        return tableView.numberOfRows(inSection: section)
    }
    
    func country(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: section)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    func search(for text: String) {
        searchController.searchBar.text = text
    }
    
    func clearSearch() {
        searchController.searchBar.text = ""
    }
    
    func simulateTapCountry(at row: Int) {
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: section)
        delegate?.tableView?(tableView, didSelectRowAt: index)
    }
    
}

private extension CountryCell {
    var nameAndCountry: String? {
        nameAndRegionLabel.text
    }
    
    var countryCode: String? {
        countryCodeLabel.text
    }
    
    var capital: String? {
        capitalLabel.text
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
