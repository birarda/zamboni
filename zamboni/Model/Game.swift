//
//  Game.swift
//  zamboni
//
//  Created by Stephen on 2024-04-23.
//

import Foundation

struct Colors : Decodable {
    let textColor: String
    let primaryColor: String
    let secondaryColor: String
}

struct Team : Decodable {
    let name: String
    let shortName: String
    let logo: URL
    let colors: Colors
}

struct Stream : Decodable {
    let id: Int
    
    struct ContentType : Decodable {
        let id: Int
        let name: String
    }
    
    let contentType: ContentType
    
    struct ClientContentMetadata : Decodable {
        let name: String
    }
    
    let clientContentMetadata: [ClientContentMetadata]
    
    func label() -> String {
        return clientContentMetadata[0].name
    }
    
    func isFullGame() -> Bool {
        return contentType.name.uppercased() == "FULL GAME"
    }
}

extension Stream: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Stream: Equatable {
    static func == (lhs: Stream, rhs: Stream) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Game : Decodable {
    let id: Int
    let startTime: String
    let startTimeET: String
    let endTime: Optional<String>
    let home: Team
    let away: Team
    let streams: [Stream]
    
    private enum CodingKeys: String, CodingKey {
        case id
        case startTime
        case startTimeET
        case endTime
        case home = "homeCompetitor"
        case away = "awayCompetitor"
        case streams = "content"
    }
    
    func startTimeLabel() -> String {
        let parsedDate = APIService.dateFormatter.date(from: self.startTime)!
        let easternTimezone = TimeZone(identifier: "America/New_York")!
        let components = Calendar.current.dateComponents(in: easternTimezone, from: parsedDate)
        
        return "\(components.hour!):\(components.minute! > 10 ? "" : "0")\(components.minute!) ET"
    }
}

extension Game: Equatable {
    static func == (lhs: Game, rhs: Game) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Game: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
