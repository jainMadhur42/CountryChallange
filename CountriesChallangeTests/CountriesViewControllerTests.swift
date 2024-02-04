//
//  CountriesViewControllerTests.swift
//  CountriesChallangeTests
//
//  Created by Madhur on 04/02/24.
//

import XCTest
import UIKit
import CountriesChallange

final class CountriesViewController: UIViewController {
    
    private var loader: CountryLoader?
    
    convenience init(loader: CountryLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader?.load { _ in }
    }
    
}

final class CountriesViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        
        let loader = LoaderSpy()
        _ = CountriesViewController(loader: loader)
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadFeed() {
        let loader = LoaderSpy()
        let sut = CountriesViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    class LoaderSpy: CountryLoader {
        
        private(set) var loadCallCount = 0
        
        func load(completion: @escaping (LoadCountryResult) -> Void) {
            loadCallCount += 1
        }
    }
}
