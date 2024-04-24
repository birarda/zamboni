//
//  LoginViewModel.swift
//  zamboni
//
//  Created by Stephen on 2024-04-22.
//

import Foundation

class LoginViewModel : ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    
    func login() {
        APIService.shared.login(email: self.email, password: self.password) { loggedIn in
            
        }
    }
}
