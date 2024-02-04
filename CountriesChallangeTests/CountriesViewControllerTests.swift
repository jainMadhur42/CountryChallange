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
        
        let view = sut.country(at: 0) as? CountryCell
        XCTAssertNotNil(view)
        XCTAssertEqual(view?.nameAndCountry, "\(country.name), \(country.region)")
        XCTAssertEqual(view?.countryCode, country.code)
        XCTAssertEqual(view?.capital, country.capital)
        
        
        sut.simulateUserInitiatedReload()
        loader.completeCountryLoading(with: [anyCountry(), anyCountry2()], at: 1)
        XCTAssertEqual(sut.numberOfRenderedCountryView(), 2)
    }
    
    func test_loadCountryCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let country = anyCountry()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeCountryLoading(with: [country], at: 0)
        XCTAssertEqual(sut.numberOfRenderedCountryView(), 1)
        
        let view = sut.country(at: 0) as? CountryCell
        XCTAssertNotNil(view)
        XCTAssertEqual(view?.nameAndCountry, "\(country.name), \(country.region)")
        XCTAssertEqual(view?.countryCode, country.code)
        XCTAssertEqual(view?.capital, country.capital)
        
        sut.simulateUserInitiatedReload()
        loader.completeCountryLoadingWithError(at: 1)
        
        let view2 = sut.country(at: 0) as? CountryCell
        XCTAssertNotNil(view2)
        XCTAssertEqual(view2?.nameAndCountry, "\(country.name), \(country.region)")
        XCTAssertEqual(view2?.countryCode, country.code)
        XCTAssertEqual(view2?.capital, country.capital)
    }
    
    private func makeSUT(file: StaticString = #file
                         , line: UInt = #line) -> (sut: CountriesViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CountriesViewController(loader: loader)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        return (sut, loader)
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
    
}

private extension CountryCell {
    var nameAndCountry: String? {
        nameAndRegionLabel.text
    }
    
    var countryCode: String? {
        codeLabel.text
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
