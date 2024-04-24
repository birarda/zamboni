//
//  SettingsService.swift
//  zamboni
//
//  Created by Stephen on 2024-04-23.
//

import Foundation

struct ProxySettings : Codable {
    var enabled: Bool
    var host: String?
    var port: Int?
    var username: String?
    var password: String?
}

class SettingsService : NSObject {
    static let shared = SettingsService()
    
    private let proxySettingsKey: String = "kProxySettings"
    private(set) var proxySettings: ProxySettings = ProxySettings(enabled: false)
    
    override init() {
        super.init()
        loadSettings()
    }
    
    func loadSettings() {
        loadProxySettings()
    }
    
    func loadProxySettings() {
        let userDefaults = UserDefaults.standard
        if let proxyData = userDefaults.object(forKey: proxySettingsKey) as? Data,
           let proxySettings = try? JSONDecoder().decode(ProxySettings.self, from: proxyData) {
            self.proxySettings = proxySettings
        }
    }
    
    func storeProxySettings() {
        let userDefaults = UserDefaults.standard
        if let proxyData = try? JSONEncoder().encode(proxySettings) {
            userDefaults.set(proxyData, forKey: proxySettingsKey)
        }
    }
    
    func updateProxySettings(proxySettings: ProxySettings) {
        self.proxySettings = proxySettings
        storeProxySettings()
        APIService.shared.refreshProxySettings()
    }
}


