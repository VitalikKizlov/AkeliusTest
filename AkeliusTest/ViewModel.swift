//
//  ViewModel.swift
//  AkeliusTest
//
//  Created by Vitalii Kizlov on 29.11.2023.
//

import Foundation
import Combine

final class ViewModel {

    struct URLSettings {
        let fileURL: URL
        let folderURL: URL
    }

    private let unzipService = UnzipService()
    private let urlSettingsSubject = PassthroughSubject<URLSettings, Never>()
    lazy var urlSettingsPublisher = urlSettingsSubject.eraseToAnyPublisher()

    // MARK: - Public

    func startDownloading() {
        let url = "https://pstaticlanguage.blob.core.windows.net/consumer-kit/simplified-wrapper.v1.zip"

        unzipService.downloadAndUnzip(from: url, toFolder: Constants.folderName) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.proceedUnzipFiles()
            case .failure(let error):
                print("failure \(error.localizedDescription)")
                if error == .fileAlreadyExist {
                    self.proceedUnzipFiles()
                }
            }
        }
    }

    // MARK: - Private

    private func proceedUnzipFiles() {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let path = "\(Constants.folderName)/\(Constants.unzipFolderName)"
        let folderURL = documentsDirectoryURL.appendingPathComponent(path, isDirectory: true)

        do {
            let items = try FileManager.default.contentsOfDirectory(atPath: folderURL.relativePath)

            for item in items where item == "index.html" {
                print("Found \(item)")
                let fileURL = folderURL.appendingPathComponent(item)
                print("Found \(item) at \(fileURL)")

                let settings = URLSettings(fileURL: fileURL, folderURL: folderURL)
                self.urlSettingsSubject.send(settings)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
