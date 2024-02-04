//
//  Helper.swift
//  CountriesTests
//
//  Created by Madhur on 03/02/24.
//
import Foundation
import CountriesChallange

func anyCountry() -> Country {
    return Country(capital: "Delhi"
                          , code: "+91"
                          , currency: Currency(code: "INR", name: "Rupee", symbol: "Inr")
                          , flag: "tri color"
                          , language: Language(code: "hn", name: "Hindhi")
                          , name: "India"
                          , region: "Asia")
}

func anyCountry2() -> Country {
    return Country(capital: "Tokyo"
                          , code: "+91"
                          , currency: Currency(code: "YEN", name: "YEN", symbol: "Yen")
                          , flag: "tri color"
                          , language: Language(code: "jp", name: "Japanese")
                          , name: "Japan"
                          , region: "Asia")
}


func anyCountryData() -> Data {
    return try! JSONEncoder().encode([anyCountry(), anyCountry2()])
}



