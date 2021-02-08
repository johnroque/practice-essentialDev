//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by John Roque Jorillo on 2/8/21.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { (_, _, error) in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
   
    // MARK: - Subclass mocking
//    func test_getFromURL_createsDataTaskWithURL() {
//        let url = URL(string: "http://any-url.com")!
//        let session = URLSessionSpy()
//        let sut = URLSessionHTTPClient(session: session)
//
//        sut.get(from: url)
//
//        XCTAssertEqual(session.receivedURLs, [url])
//    }
    
//    func test_getFromURL_resumeDataTaskWithURL() {
//        let url = URL(string: "http://any-url.com")!
//        let session = URLSessionSpy()
//
//        let task = URLSessionDataTaskSpy()
//        session.stub(url: url, task: task)
//
//        let sut = URLSessionHTTPClient(session: session)
//
//        sut.get(from: url) { _ in }
//
//        XCTAssertEqual(task.resumeCallCount, 1)
//    }
    
    func test_getFromURL_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequests()
        let url = URL(string: "http://any-url.com")!
//        let session = URLSessionSpy()
        
//        let task = URLSessionDataTaskSpy()
//        session.stub(url: url, task: task)
        
        let error = NSError(domain: "any error", code: 1)
        URLProtocolStub.stub(url: url, error: error)
        
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "Wait for completion")
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.code, error.code)
                XCTAssertEqual(receivedError.domain, error.domain)
            default:
                XCTFail("Expected failure with lerror \(error), got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopInteceptingRequests()
//        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    // URLProtocol
    private class URLProtocolStub: URLProtocol {
        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            let error: Error?
        }
        
        static func stub(url: URL, error: Error? = nil) {
            stubs[url] = Stub(error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInteceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs.removeAll()
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
    }
    
    // Subclass mocking
//    private class URLSessionSpy: URLSession {
//        var receivedURLs = [URL]()
//
//        private var stubs = [URL: Stub]()
//
//        private struct Stub {
//            let task: URLSessionDataTask
//            let error: Error?
//        }
//
//        func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
//            stubs[url] = Stub.init(task: task, error: error)
//        }
//
//        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
//            receivedURLs.append(url)
//            guard let stub = stubs[url] else {
//                fatalError("Couln't find stub for \(url)")
//            }
//
//            completionHandler(nil, nil, stub.error)
//            return stub.task
//        }
//    }
//
//    private class FakeURLSessionDataTask: URLSessionDataTask {
//        override func resume() {
//
//        }
//    }
//    private class URLSessionDataTaskSpy: URLSessionDataTask {
//        var resumeCallCount = 0
//
//        override func resume() {
//            resumeCallCount += 1
//        }
//    }
}

