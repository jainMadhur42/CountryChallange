//
//  Currency.swift
//  Countries
//
//  Created by Madhur on 03/02/24.
//

import Foundation

public struct Currency: Equatable, Codable {
    public let code: String
    public let name: String
    public let symbol: String?
    
    public init(code: String, name: String, symbol: String?) {
        self.code = code
        self.name = name
        self.symbol = symbol
    }
 }
