//
//  ProfileView.swift
//  GitHubUser
//
//  Created by Palavvi Aggarwal on 10/3/25.
//

import SwiftUI

struct ProfileView: View {
    let user: GitHubUser

    var body: some View {
        VStack(spacing: 12) {
            if #available(iOS 15.0, *) {
                AsyncImage(url: user.avatar_url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 120, height: 120)
                    case .success(let image):
                        image.resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .shadow(radius: 6)
                    case .failure:
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.secondary)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                // Fallback for earlier iOS: show placeholder
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.secondary)
            }

            Text(user.name ?? "No name")
                .font(.title2)
                .fontWeight(.semibold)

            Text("@\(user.login)")
                .foregroundColor(.secondary)
                .font(.subheadline)

            if let bio = user.bio, !bio.isEmpty {
                Text(bio)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            HStack(spacing: 30) {
                VStack {
                    Text("\(user.public_repos)")
                        .font(.headline)
                    Text("Repos")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                VStack {
                    Text("\(user.followers)")
                        .font(.headline)
                    Text("Followers")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: 500)
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.secondarySystemBackground)))
    }
}

