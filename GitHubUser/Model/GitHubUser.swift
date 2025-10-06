//
//  GitHubUser.swift
//  GitHubUser
//
//  Created by Palavvi Aggarwal on 10/3/25.
//

import Foundation

struct GitHubUser: Codable {
    let login: String
    let name: String?
    let avatar_url: URL?
    let bio: String?
    let public_repos: Int
    let followers: Int
}

