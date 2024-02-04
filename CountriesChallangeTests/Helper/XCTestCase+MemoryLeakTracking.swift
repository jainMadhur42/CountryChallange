//
//  XCTestCase+MemoryLeakTracking.swift
//  CountriesTests
//
//  Created by Madhur on 04/02/24.
//

import XCTest

extension XCTestCase {
    
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file
                                     , line: UInt = #line) {
        
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potentially memory leak.", file: file, line: line)
        }
    }
    
}
