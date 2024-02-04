//
//  HTTPClient.swift
//  CountriesTests
//
//  Created by Madhur on 03/02/24.
//

import Foundation


public protocol HTTPClient {
    
    typealias HTTPClientResult = Result<(Data, HTTPURLResponse), Error>
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
