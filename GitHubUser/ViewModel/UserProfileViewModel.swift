//
//  UserProfileViewModel.swift
//  GitHubUser
//
//  Created by Palavvi Aggarwal on 10/3/25.
//

import Foundation
import Combine

@MainActor
final class UserProfileViewModel: ObservableObject {
    @Published var usernameInput: String = ""
    @Published var user: GitHubUser? = nil
    @Published private(set) var isLoading: Bool = false
    @Published var alertMessage: String? = nil
    
    
    
    private let api: GitHubAPIProtocol

       init(api: GitHubAPIProtocol = GitHubAPI.shared) {
           self.api = api
       }


    
    func fetchUser() {
        let username = usernameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !username.isEmpty else {
            alertMessage = "Please enter a GitHub username."
            return
        }

        isLoading = true
        user = nil
        alertMessage = nil

        Task {
            let result = await GitHubAPI.shared.fetchUser(username: username)
            isLoading = false

            switch result {
            case .success(let fetchedUser):
                self.user = fetchedUser
            case .failure(let apiError):
                self.alertMessage = apiError.errorDescription ?? "Failed to fetch user."
            }
        }
    }

    func clear() {
        user = nil
        usernameInput = ""
        alertMessage = nil
    }
}

protocol GitHubAPIProtocol {
    func fetchUser(username: String) async -> Result<GitHubUser, GitHubAPIError>
}

extension GitHubAPI: GitHubAPIProtocol {}
