//
//  Country.swift
//  Countries
//
//  Created by Madhur on 03/02/24.
//

import Foundation

public struct Country: Equatable, Codable {
    let capital: String
    let code: String
    let currency: Currency
    let flag: String
    let language: Language
    let name: String
    let region: String
    
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
