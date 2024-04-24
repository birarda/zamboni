//
//  SettingsViewModel.swift
//  zamboni
//
//  Created by Stephen on 2024-04-23.
//

import Foundation

enum LoginState {
    case Unknown
    case LoggedIn
    case LoggedOut
}

class SettingsViewModel : ObservableObject {
    @Published var loginState: LoginState = .Unknown
    
    @Published var proxyEnabled: Bool = false
    @Published var proxyHost: String
    @Published var proxyPort: String
    @Published var proxyUsername: String
    @Published var proxyPassword: String
    
    init() {
        let proxySettings = SettingsService.shared.proxySettings
        proxyEnabled = proxySettings.enabled
        proxyHost = proxySettings.host ?? ""
        proxyPort = proxySettings.port != nil ? String(proxySettings.port!) : ""
        proxyUsername = proxySettings.username ?? ""
        proxyPassword = proxySettings.password ?? ""
    }
    
    func checkLoginState() {
        APIService.shared.hasValidToken { validToken in
            self.loginState = validToken ? .LoggedIn : .LoggedOut
        }
    }
    
    func logout() {
        APIService.shared.logout()
        self.loginState = .LoggedOut
    }
    
    func updateProxySettings() {
        let proxySettings = ProxySettings(
            enabled: proxyEnabled,
            host: proxyHost.isEmpty ? .none : proxyHost,
            port: proxyPort.isEmpty ? .none : Int(proxyPort),
            username: proxyUsername.isEmpty ? .none : proxyUsername,
            password: proxyPassword.isEmpty ? .none : proxyPassword
        )
        
        SettingsService.shared.updateProxySettings(proxySettings: proxySettings)
    }
}
