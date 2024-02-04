//
//  CountriesViewControllerTests.swift
//  CountriesChallangeTests
//
//  Created by Madhur on 04/02/24.
//

import XCTest
import UIKit
import CountriesChallange

final class CountriesViewController: UITableViewController {
    
    private var loader: CountryLoader?
    
    convenience init(loader: CountryLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { _ in }
    }
    
}

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
        
        func completeCountryLoading(at index: Int) {
            completions[index](.success([]))
        }
    }
}

private extension CountriesViewController {
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
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
