//
//  SettingsView.swift
//  zamboni
//
//  Created by Stephen on 2024-04-23.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel = SettingsViewModel()
    
    @State var showLoginSheet: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("NHL.TV Account")) {
                switch viewModel.loginState {
                case .Unknown:
                    ProgressView().frame(maxWidth: .infinity, alignment: .center)
                case .LoggedIn:
                    Button(action: viewModel.logout, label: {
                        Text("Logout")
                    })
                case .LoggedOut:
                    Button(action: {
                        showLoginSheet = true
                    }, label: {
                        Text("Login")
                    }).sheet(isPresented: $showLoginSheet) {
                        LoginView(isPresented: $showLoginSheet)
                    }
                }
            }.task {
                viewModel.checkLoginState()
            }
            
            Section(header: Text("HTTPS Proxy")) {
                Toggle(isOn: $viewModel.proxyEnabled, label: {
                    Text("Enable Proxy")
                }).onSubmit {
                    viewModel.updateProxySettings()
                }
            }
            
            if viewModel.proxyEnabled {
                Section(header: Text("Proxy Connection")) {
                    LabeledContent {
                        TextField("Proxy Host", text: $viewModel.proxyHost)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .disabled(!viewModel.proxyEnabled)
                            .onSubmit {
                                viewModel.updateProxySettings()
                            }
                    } label: {
                        Text("Host")
                    }
                    
                    LabeledContent {
                        TextField("Proxy Port", text: $viewModel.proxyPort)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .disabled(!viewModel.proxyEnabled)
                            .onSubmit {
                                viewModel.updateProxySettings()
                            }
                    } label: {
                        Text("Port")
                    }
                }
                
                Section(header: Text("Proxy Auth")) {
                    LabeledContent {
                        TextField("Proxy Username", text: $viewModel.proxyUsername)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .disabled(!viewModel.proxyEnabled)
                            .onSubmit {
                                viewModel.updateProxySettings()
                            }
                    } label: {
                        Text("Username")
                    }
                    
                    LabeledContent {
                        SecureField("Proxy Password", text: $viewModel.proxyPassword).onSubmit {
                            viewModel.updateProxySettings()
                        }
                    } label: {
                        Text("Password")
                    }
                }
            }
        }
    }
}


