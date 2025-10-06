////
////  GitHubAPI.swift
////  GitHubUser
////
////  Created by Palavvi Aggarwal on 10/3/25.
////

import Foundation

enum GitHubAPIError: LocalizedError, Equatable {
    static func == (lhs: GitHubAPIError, rhs: GitHubAPIError) -> Bool {
        return true
    }
    
    case notFound
    case badResponse(statusCode: Int)
    case network(Error)
    case decoding(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "User not found. Please check the username and try again."
        case .badResponse(let code):
            return "Server returned an error (status \(code)). Try again later."
        case .network(let err):
            return "Network error: \(err.localizedDescription)"
        case .decoding:
            return "Failed to decode response."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

actor GitHubAPI {
    private let session: URLSession
    
    static let shared = GitHubAPI() 

    /// Allows injecting a custom URLSession (default: `.shared`)
    init(session: URLSession = .shared) {
        self.session = session
    }
// go on i am succeding i always succeed i am a winner yes i am winner i am a winner in all sphere of my life 
    func fetchUser(username: String) async -> Result<GitHubUser, GitHubAPIError> {
        let urlString = "https://api.github.com/users/\(username)"
        guard let url = URL(string: urlString) else { return .failure(.unknown) }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await session.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                return .failure(.unknown)
            }

            switch http.statusCode {
            case 200:
                do {
                    let decoder = JSONDecoder()
                    let user = try decoder.decode(GitHubUser.self, from: data)
                    return .success(user)
                } catch {
                    return .failure(.decoding(error))
                }
            case 404:
                return .failure(.notFound)
            default:
                return .failure(.badResponse(statusCode: http.statusCode))
            }
        } catch {
            return .failure(.network(error))
        }
    }
}
