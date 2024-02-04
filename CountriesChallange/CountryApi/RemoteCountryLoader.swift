//
//  RemoteCountryLoader.swift
//  Countries
//
//  Created by Madhur on 03/02/24.
//

import Foundation

public final class RemoteCountryLoader: CountryLoader {
    private let url: URL
    private let client: HTTPClient
    
    public typealias Result = LoadCountryResult
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                completion(RemoteCountryLoader.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let countries = try CountryMapper.map(data, response: response)
            return .success(countries)
        } catch {
            return .failure(RemoteCountryLoader.Error.invalidData)
        }
    }
    
}
