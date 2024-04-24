//
//  LoginView.swift
//  zamboni
//
//  Created by Stephen on 2024-04-22.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel = LoginViewModel()
    
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Text("NHL.TV Account")
            Form {
                TextField("Email", text: $viewModel.email).autocorrectionDisabled()
                SecureField("Password", text: $viewModel.password)
            }
            Button (
                action: viewModel.login,
                label: {
                    Text("Login").font(.system(size: 24, weight: .bold, design: .default))
                }
            )
        }
    }
}
