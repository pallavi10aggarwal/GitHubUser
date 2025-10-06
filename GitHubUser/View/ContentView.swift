//
//  ContentView.swift
//  GitHubUser
//
//  Created by Palavvi Aggarwal on 10/3/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = UserProfileViewModel()
    @State private var showAlert = false

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter GitHub username", text: $vm.usernameInput)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading, 8)

                    Button(action: {
                        vm.fetchUser()
                    }) {
                        Text("Search")
                            .bold()
                    }
                    .disabled(vm.usernameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding(.trailing, 8)
                }
                .padding(.horizontal)

                // Loading state
                if vm.isLoading {
                    ProgressView("Loading...")
                        .padding()
                }

                // Error alert
                Spacer(minLength: 8)

                // Profile display
                if let user = vm.user {
                    ProfileView(user: user)
                        .padding()
                } else {
                    // empty state
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.fill.badge.questionmark")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary)
                        Text("Search GitHub user to see profile")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }

                Spacer()
            }
            .navigationTitle("GitHub Profile")
            .alert(item: $vm.alertMessage) { msg in
                Alert(title: Text("Error"), message: Text(msg), dismissButton: .default(Text("OK")))
            }
        }
    }
}

// helper to let alert accept optional string as Identifiable
private extension Optional where Wrapped == String {
    var wrappedId: String? { self }
}

extension Optional: @retroactive Identifiable where Wrapped == String {
    public var id: String? { self }
}
extension String: @retroactive Identifiable {
    public var id: String { self }
}
