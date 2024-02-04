//
//  Country.swift
//  Countries
//
//  Created by Madhur on 03/02/24.
//

import Foundation

public struct Country: Equatable, Codable {
    public let capital: String
    public let code: String
    public let currency: Currency
    public let flag: String
    public let language: Language
    public let name: String
    public let region: String
    
    public init(capital: String, code: String, currency: Currency, flag: String, language: Language, name: String, region: String) {
        self.capital = capital
        self.code = code
        self.currency = currency
        self.flag = flag
        self.language = language
        self.name = name
        self.region = region
    }
    
}
