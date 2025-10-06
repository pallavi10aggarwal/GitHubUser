//
//  GitHubAPITests.swift
//  GitHubUserTests
//
//  Created by Palavvi Aggarwal on 10/3/25.
//

import XCTest
@testable import GitHubUser

final class GitHubAPITests: XCTestCase {
    var api: GitHubAPI!

    override func setUp() {
        super.setUp()

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]   // use mock
        let mockSession = URLSession(configuration: config)

        api = GitHubAPI(session: mockSession)  // inject dependency
    }

    override func tearDown() {
        MockURLProtocol.responseData = nil
        MockURLProtocol.error = nil
        MockURLProtocol.statusCode = 200
        api = nil
        super.tearDown()
    }


    func testFetchUser_Success() async {
        let mockJSON = """
        {
          "login": "octocat",
          "name": "The Octocat",
          "bio": "GitHub mascot",
          "public_repos": 10,
          "followers": 200,
          "avatar_url": "https://avatars.githubusercontent.com/u/1"
        }
        """.data(using: .utf8)!

        MockURLProtocol.responseData = mockJSON
        MockURLProtocol.statusCode = 200

        let result = await api.fetchUser(username: "octocat")

        switch result {
        case .success(let user):
            XCTAssertEqual(user.login, "octocat")
            XCTAssertEqual(user.name, "The Octocat")
            XCTAssertEqual(user.public_repos, 10)
            XCTAssertEqual(user.followers, 200)
        case .failure(let error):
            XCTFail("Expected success, got error: \(error)")
        }
    }

    func testFetchUser_NotFound() async {
        MockURLProtocol.responseData = Data()
        MockURLProtocol.statusCode = 404

        let result = await api.fetchUser(username: "ghost")
        switch result {
        case .success:
            XCTFail("Expected notFound error")
        case .failure(let error):
            XCTAssertEqual(error, .notFound)
        }
    }

    func testFetchUser_BadResponse() async {
        MockURLProtocol.responseData = Data()
        MockURLProtocol.statusCode = 500

        let result = await api.fetchUser(username: "octocat")
        switch result {
        case .success:
            XCTFail("Expected badResponse error")
        case .failure(let error):
            if case .badResponse(let code) = error {
                XCTAssertEqual(code, 500)
            } else {
                XCTFail("Expected badResponse, got \(error)")
            }
        }
    }

    func testFetchUser_DecodingFailure() async {
        let badJSON = """
        { "invalid": "json" }
        """.data(using: .utf8)!

        MockURLProtocol.responseData = badJSON
        MockURLProtocol.statusCode = 200

        let result = await api.fetchUser(username: "octocat")
        switch result {
        case .success:
            XCTFail("Expected decoding error")
        case .failure(let error):
            if case .decoding = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Expected decoding error, got \(error)")
            }
        }
    }

    func testFetchUser_NetworkError() async {
        MockURLProtocol.error = URLError(.notConnectedToInternet)

        let result = await api.fetchUser(username: "octocat")
        switch result {
        case .success:
            XCTFail("Expected network error")
        case .failure(let error):
            if case .network(let err) = error {
                XCTAssertTrue(err is URLError)
            } else {
                XCTFail("Expected network error, got \(error)")
            }
        }
    }
}
