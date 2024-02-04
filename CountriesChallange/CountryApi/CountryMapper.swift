//
//  CountryMapper.swift
//  Countries
//
//  Created by Madhur on 03/02/24.
//

import Foundation

internal final class CountryMapper {
    
    static func map(_ data: Data, response: HTTPURLResponse) throws -> [Country] {
        guard response.statusCode == 200 else {
            throw RemoteCountryLoader.Error.invalidData
        }
        return try JSONDecoder().decode([Country].self, from: data)
    }
}
