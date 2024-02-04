//
//  URLSessionHttpClientTests.swift
//  CountriesTests
//
//  Created by Madhur on 04/02/24.
//

import XCTest
import CountriesChallange


final class URLSessionHttpClientTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequest()
    }
    
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromURL_PerformGETRequestWithURL() {
        
        let url = anyUrl()
        let exp = expectation(description: "wait for request")
        
        URLProtocolStub.observeRequestes { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSut().get(from: url, completion: { _ in })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        
        let requestError = anyError()
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)! as NSError
        
        XCTAssertEqual(receivedError.code, requestError.code)
        XCTAssertEqual(receivedError.localizedDescription, requestError.localizedDescription)
    }
    
    
    func test_getFromURL_failsOnAllInvalidRepresentation() {
        
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    func test_getFromUrl_successOnHttpURLResponseWithData() async {
        
        let data = anyData()
        let response = anyHTTPURLResponse()
        let receivedValues = resultValuesFor(data: data, response: response, error: nil)!
        XCTAssertEqual(receivedValues.data, data)
        XCTAssertEqual(receivedValues.response?.url, response.url)
        XCTAssertEqual(receivedValues.response?.statusCode, response.statusCode)
    }
    
    
    func test_getFromUrl_succeedWithEmptyDataOnHttpURLResponseWithData() async {
        
        let response = anyHTTPURLResponse()
        let emptyData = Data()
        let receivedValues = resultValuesFor(data: nil, response: response, error: nil)!
        XCTAssertEqual(receivedValues.data, emptyData)
        XCTAssertEqual(receivedValues.response?.url, response.url)
        XCTAssertEqual(receivedValues.response?.statusCode, response.statusCode)
    }

    
    // MARK: Helper
    
    private func makeSut(file: StaticString = #file, line: UInt = #line) -> URLSessionHttpClient {
        let sut = URLSessionHttpClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func anyUrl() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    private func anyData() -> Data {
        return Data("anyData".utf8)
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "Test", code: 1)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyUrl(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyUrl(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?
                                , file: StaticString = #file
                                 , line: UInt = #line) -> (data: Data?, response: HTTPURLResponse?)? {
        let result = resultFor(data: data, response: response, error: error)
        switch result {
        case let .success(data, response):
            return (data, response)
        default:
            XCTFail("Expected success, got \(result)", file: file, line: line)
            return nil
        }
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?
                                , file: StaticString = #file
                                , line: UInt = #line) -> Error? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure, got \(result)", file: file, line: line)
            return nil
        }
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?
                                   , file: StaticString = #file
                           , line: UInt = #line) -> HTTPClient.HTTPClientResult? {
        
        let sut = makeSut(file: file, line: line)
        URLProtocolStub.stub(data: data, response: response, error: error)
        let exp = expectation(description: "wait for completion")
        
        var receivedResult: HTTPClient.HTTPClientResult?
        sut.get(from: anyUrl()) { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    private class URLProtocolStub: URLProtocol {
        
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let error: Error?
            let data: Data?
            let response: URLResponse?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(error: error, data: data, response: response)
        }
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocolStub.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        static func observeRequestes(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
    }
    
}
