//
//  LocalProfile.swift
//  VEIL
//
//  Created by reema aljohani on 5/30/26.
//

import Foundation
import SwiftData

@Model
final class LocalProfile {
    var id: UUID
    var displayName: String
    var avatarName: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        displayName: String,
        avatarName: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.displayName = displayName
        self.avatarName = avatarName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    func updateDisplayName(_ newName: String) {
        self.displayName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.updatedAt = Date()
    }

    func updateAvatarName(_ newAvatarName: String?) {
        self.avatarName = newAvatarName
        self.updatedAt = Date()
    }
}
