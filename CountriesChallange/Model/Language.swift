//
//  Language.swift
//  Countries
//
//  Created by Madhur on 03/02/24.
//

import Foundation

public struct Language: Equatable, Codable {
    let code: String?
    let name: String
    
    public init(code: String?, name: String) {
        self.code = code
        self.name = name
    }
}
