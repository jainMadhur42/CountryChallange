//
//  URLSessionHttpClient.swift
//  Countries
//
//  Created by Madhur on 04/02/24.
//

import Foundation

public class URLSessionHttpClient: HTTPClient {
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpectedValueRepresentation: Error { }
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data
                        , let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnexpectedValueRepresentation()))
            }
        }.resume()
    }
}
