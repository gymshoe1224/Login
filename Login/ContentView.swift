//
//  ContentView.swift
//  Login
//
//  Created by Chris Markiewicz on 3/17/23.
//

import SwiftUI

struct ContentView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Login")) {
                    TextField("Email", text: $email)
                    SecureField("Password", text: $password)
                }
                
                Section {
                    Button(action: {
                        // Send a POST request to your REST API to authenticate the user's credentials
                        authenticateUser(email: email, password: password)
                    }) {
                        Text("Log In")
                    }
                }
            }
            .navigationBarTitle("Login")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func authenticateUser(email: String, password: String) {
        let parameters = ["email": email, "password": password]
        let url = URL(string: "https://your-rest-api.com/login")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                let responseString = String(data: data, encoding: .utf8) ?? ""
                print("Error: \(responseString)")
                errorMessage = "Invalid email or password"
                showingAlert = true
                return
            }

            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let token = json["token"] as? String {
                // Store the JWT securely on the client side, for example using `Keychain` or `UserDefault`
                print("Token: \(token)")
            } else {
                errorMessage = "Unexpected server response"
                showingAlert = true
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
