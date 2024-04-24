//
//  APIService.swift
//  zamboni
//
//  Created by Stephen Birarda on 2024-04-22.
//

import Foundation

struct EventsResponse : Decodable {
    let data: [Game]
}

struct AccessCodeResponse : Decodable {
    let data: String
}

struct PlayerSettingsReponse : Decodable {
    let streamAccess: String
}

struct StreamManifestResponse : Decodable {
    struct Inner: Decodable {
        let stream: String
    }
    let data: Inner
}

class APIService : NSObject {
    static let shared = APIService()
    
    static let dateFormatter = InitDateFormatter()
    
    private let baseURL = URL(string: "https://nhltv.nhl.com/api")!
    private let userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36"
    private var cachedHasValidToken: Bool? = nil
    private var urlSession: Optional<URLSession> = Optional.none
    
    static func InitDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        
        return dateFormatter
    }
    
    override init() {
        super.init()
        
        configureURLSession()
    }
    
    func hasValidToken(completion: @escaping (Bool) -> Void) {
        if let cachedHasValidToken = cachedHasValidToken {
            completion(cachedHasValidToken)
            return
        }
        
        let url = URL(string: "\(baseURL)/v3/sso/nhl/extend_token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
    
        let task = self.urlSession?.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("Extend token got status code \(httpResponse.statusCode)")
                
                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    self.cachedHasValidToken = true
                    completion(true)
                } else {
                    self.cachedHasValidToken = false
                    completion(false)
                }
            }
        }
        task?.resume()
    }
    
    func refreshProxySettings() {
        configureURLSession()
    }
    
    private func configureURLSession() {
        let configuration = URLSessionConfiguration.default
        
        let proxySettings = SettingsService.shared.proxySettings
        
        if (proxySettings.enabled) {
            var proxyDictionary: [AnyHashable: Any] = [
                "HTTPSEnable": 1
            ]
            
            if let proxyHost = proxySettings.host {
                proxyDictionary.updateValue(proxyHost, forKey:"HTTPSProxy")
            }
            
            if let proxyPort = proxySettings.port {
                proxyDictionary.updateValue(proxyPort, forKey: "HTTPSPort")
            }
            
            if let proxyUsername = proxySettings.username {
                proxyDictionary.updateValue(proxyUsername, forKey: kCFProxyUsernameKey)
            }
            
            if let proxyPassword = proxySettings.password {
                proxyDictionary.updateValue(proxyPassword, forKey: kCFProxyPasswordKey)
            }
            
            configuration.connectionProxyDictionary = proxyDictionary
        }
        
        configuration.httpAdditionalHeaders = [
            "User-Agent": self.userAgent,
            "Accept": "application/json, text/plain, */*",
            "Origin": "https://nhltv.nhl.com"
        ]
        
        self.urlSession = URLSession(configuration: configuration)
    }
    
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "\(self.baseURL)/v3/sso/nhl/login")!
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters = [
            "email": email,
            "password": password
        ]
        
        do {
            // convert parameters to Data and assign dictionary to httpBody of request
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
          } catch let error {
            print(error.localizedDescription)
            return
          }
        
        
        let task = self.urlSession!.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("Login got status code \(httpResponse.statusCode)")
                
                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
        
        task.resume()
    }
     
    func logout() {
        HTTPCookieStorage.shared.cookies?.forEach(HTTPCookieStorage.shared.deleteCookie)
    }
    
    func loadGames(date: PlainDate, daysBack: Int, completion: @escaping (Optional<[Game]>) -> Void) {
        var url = URL(string: "\(baseURL)/v2/events")!
        
        let dateFromString = date.toStartString(daysBack: daysBack)
        let dateToString = date.toEndOfDayString()

        url.append(queryItems: [URLQueryItem(name: "date_time_from", value: dateFromString),
                                URLQueryItem(name: "date_time_to", value: dateToString),
                                URLQueryItem(name: "sort_direction", value: "asc")])
                
        let task = self.urlSession!.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(EventsResponse.self, from: data)
                    completion(Optional.some(result.data))
                } catch {
                    print(error)
                    completion(.none)
                }
            }
        }
        
        task.resume()
    }
    
    func loadStreamManifest(stream: Stream, completion: @escaping (String?) -> Void) {
        getStreamAccessURL(stream: stream, completion: { accessURL in
            if let accessURL = accessURL {
                var request = URLRequest(url: URL(string: accessURL)!)
                request.httpMethod = "POST"
                request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
                
                let task = self.urlSession!.dataTask(with: request) { data, response, error in
                    print(response)
                    
                    if let error = error {
                        print(error.localizedDescription)
                        completion(nil)
                        return
                    }
    
                    if let data = data {
                        print(String(data: data, encoding: .utf8))
                        do {
                            let result = try JSONDecoder().decode(StreamManifestResponse.self, from: data)
                            print(result)
                            completion(Optional.some(result.data.stream))
                        } catch {
                            print(error)
                            completion(.none)
                        }
                    }
                }
                task.resume()
            } else {
                print("Failed to get stream access URL")
            }
        })
    }
    
    func getAuthCode(stream: Stream, completion: @escaping (String?) -> Void) {
        let url = URL(string: "\(baseURL)/v3/contents/\(stream.id)/check-access")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters = ["type": "nhl"]
        
        do {
            // convert parameters to Data and assign dictionary to httpBody of request
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        
        let task = self.urlSession!.dataTask(with: request) { data, response, error in
            print(response)
            
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
                return
            }
            
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(AccessCodeResponse.self, from: data)
                    completion(Optional.some(result.data))
                } catch {
                    print(error)
                    completion(.none)
                }
            }
        }
        task.resume()
    }
    
    func getStreamAccessURL(stream: Stream, completion: @escaping (String?) -> Void) {
        getAuthCode(stream: stream, completion: { authCode in
            if let authCode = authCode {
                let url = URL(string: "\(self.baseURL)/v3/contents/\(stream.id)/player-settings")!
                
                let task = self.urlSession!.dataTask(with: url) { data, response, error in
                    print(response)
                    
                    if let error = error {
                        print(error.localizedDescription)
                        completion(nil)
                        return
                    }
                    
                    if let data = data {
                        do {
                            let result = try JSONDecoder().decode(PlayerSettingsReponse.self, from: data)
                            let authAccessURL = if result.streamAccess.contains("?") {
                                "\(result.streamAccess)&authorization_code=\(authCode)"
                            } else {
                                "\(result.streamAccess)?authorization_code=\(authCode)"
                            }
                            completion(authAccessURL)
                        } catch {
                            print(error)
                            completion(.none)
                        }
                    }
                    
                }
                task.resume()
            } else {
                print("Failed to get auth code")
            }
        })
        
    }
}
