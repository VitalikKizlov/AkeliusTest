//
//  UnzipService.swift
//  AkeliusTest
//
//  Created by Vitalii Kizlov on 29.11.2023.
//

import Foundation
import ZIPFoundation

protocol UnzipServiceProtocol: AnyObject {
    func downloadAndUnzip(
        from urlString: String,
        toFolder folderName: String,
        completion: @escaping (Result<Void, UnzipService.UnzipServiceError>) -> Void)
}

final class UnzipService: UnzipServiceProtocol {

    enum UnzipServiceError: Error {
        case failedToCreateDirectory
        case deleteZipFailed
        case exctractionFailed
        case failedToMove
        case fileAlreadyExist
    }
    func downloadAndUnzip(
        from urlString: String,
        toFolder folderName: String,
        completion: @escaping (Result<Void, UnzipServiceError>) -> Void)
    {
        guard let url = URL(string: urlString) else { return }
        let session = URLSession.shared
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folderURL = documentsDirectoryURL.appendingPathComponent(folderName, isDirectory: true)
        let fileURL = folderURL.appendingPathComponent(url.lastPathComponent)

        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            debugPrint("Could not create directory: \(error.localizedDescription)")
            completion(.failure(.failedToCreateDirectory))
            return
        }

        if FileManager().fileExists(atPath: folderURL.path) {
            print("File already exists [\(folderURL.path)]")
            completion(.failure(.fileAlreadyExist))
            return
        }

        let task = session.downloadTask(with: url) { (tempLocalURL, response, error) in
            guard let tempLocalURL = tempLocalURL, error == nil else { return }

            do {
                try FileManager.default.moveItem(at: tempLocalURL, to: fileURL)
                debugPrint("ZIP File saved to: \(fileURL.path)")
                do {
                    try FileManager.default.unzipItem(at: fileURL, to: folderURL)
                    try self.copyImageToDocumentsDirectory()

                    do {
                        try FileManager.default.removeItem(at: fileURL)
                        debugPrint("ZIP file deleted at:", fileURL)
                    } catch {
                        debugPrint("Could not delete ZIP file with error: \(error.localizedDescription)", fileURL)
                        completion(.failure(.deleteZipFailed))
                    }
                    debugPrint("Unzip completed!", fileURL)
                    completion(.success(()))
                } catch {
                    debugPrint("Extraction of ZIP archive failed with error:\(error)")
                    completion(.failure(.exctractionFailed))
                }
            } catch {
                debugPrint("Could not move item: \(error.localizedDescription)")
                completion(.failure(.failedToMove))
            }
        }

        task.resume()
    }

    private func copyImageToDocumentsDirectory() throws {
        guard let bundleImageURL = Bundle.main.url(forResource: "cat", withExtension: "jpeg") else {
            print("Error: Image not found in the bundle.")
            return
        }
        
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsDirectoryURL.appendingPathComponent(Constants.folderName).appendingPathComponent("cat.jpeg")

        do {
            try FileManager.default.copyItem(at: bundleImageURL, to: destinationURL)
        } catch {
            print(error.localizedDescription)
        }
    }
}
