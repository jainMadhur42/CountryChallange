//
//  CountryLoader.swift
//  Countries
//
//  Created by Madhur on 03/02/24.
//

import Foundation
 
public protocol CountryLoader {
    
    typealias LoadCountryResult = Result<[Country], Error>
    
    func load(completion: @escaping (LoadCountryResult) -> Void)
}
