//
//  FileController.swift
//  TrollBoard
//
//  Created by Анохин Юрий on 03.02.2023.
//

import Foundation

class FileController: ObservableObject {
    func getContentsOfDirectory(url: URL) -> [URL] {
        do {
            return try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        } catch {
            print(error)
            return []
        }
    }
}
