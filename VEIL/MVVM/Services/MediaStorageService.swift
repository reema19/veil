//
//  MediaStorageService.swift
//  VEIL
//
//  Created by reema aljohani on 5/30/26.
//


import Foundation
import UIKit

final class MediaStorageService {

    static let shared = MediaStorageService()

    private init() {}

    private var documentsDirectory: URL {
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
    }

    // MARK: - Shared Media URL

    func mediaURL(fileName: String) -> URL {
        documentsDirectory.appendingPathComponent(fileName)
    }

    // MARK: - Save Photo

    func savePhoto(_ image: UIImage) throws -> String {

        let fileName = "photo-\(UUID().uuidString).jpg"
        let url = documentsDirectory.appendingPathComponent(fileName)

        guard let data = image.jpegData(compressionQuality: 0.85) else {
            throw NSError(
                domain: "MediaStorage",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Could not convert UIImage to JPEG data."]
            )
        }

        try data.write(to: url, options: [.atomic])

        return fileName
    }

    // MARK: - Load Photo

    func loadPhoto(fileName: String) -> UIImage? {

        let url = documentsDirectory.appendingPathComponent(fileName)

        guard let data = try? Data(contentsOf: url) else {
            return nil
        }

        return UIImage(data: data)
    }

    // MARK: - Save Audio

    func moveAudioToDocuments(
        temporaryURL: URL
    ) throws -> String {

        let fileName = "audio-\(UUID().uuidString).m4a"
        let destinationURL = documentsDirectory.appendingPathComponent(fileName)

        try FileManager.default.moveItem(
            at: temporaryURL,
            to: destinationURL
        )

        return fileName
    }

    // MARK: - Audio URL

    func audioURL(
        fileName: String
    ) -> URL {

        documentsDirectory.appendingPathComponent(fileName)
    }
}
