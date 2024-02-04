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
        refreshControl?.beginRefreshing()
        load()
    }
    
    @objc private func load() {
        loader?.load { _ in }
    }
    
}

final class CountriesViewControllerTests: XCTestCase {

    func test_init_doesNotLoadCountry() {
        
        let (_, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadCountry() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    func test_userInitiatedCountryReload_loadCountry() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_viewDidLoad_hidesLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeCountryLoading()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
    }
    
    func test_userInitiatedCountryReload_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.simulateUserInitiatedReload()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    }
    
    func test_userInitiatedCountryReload_hidesLoadingIndicatorOnLoaderCompeltion() {
        let (sut, loader) = makeSUT()
        
        sut.simulateUserInitiatedReload()
        loader.completeCountryLoading()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
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
        
        func completeCountryLoading() {
            completions[0](.success([]))
        }
    }
}

private extension CountriesViewController {
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
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
