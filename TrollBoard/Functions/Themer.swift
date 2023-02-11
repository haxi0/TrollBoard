//
//  Theme.swift
//  TrollBoard
//
//  Created by Анохин Юрий on 02.02.2023.
//

import Foundation
import AssetCatalogWrapper // santander ♡

class Theme {
    static var shared = Theme()
    let fm = FileManager.default
    let apps = Apps.shared
    
    func searchIcon(path: String) -> String {
        var toReturn = ""
        let enumerator = FileManager.default.enumerator(atPath: path)
        let filePaths = enumerator?.allObjects as! [String]
        let iconFilePaths = filePaths.filter{$0.contains("60x60@2x.png")}
        
        for iconFilePath in iconFilePaths {
            toReturn = "\(path)/\(iconFilePath)"
        }
        
        return toReturn
    }
    
    func copyFileDocumentsDirectory(file: String, fileName: String) {
        let pathToDocuments = String(getDocumentsDirectory().absoluteString.dropFirst((getDocumentsDirectory().scheme?.count ?? -3) + 3))
        
        do {
            if fm.fileExists(atPath: pathToDocuments.appending(fileName)) {
                try fm.removeItem(atPath: pathToDocuments.appending(fileName))
                try fm.copyItem(atPath: file, toPath: pathToDocuments.appending(fileName))
            } else {
                try fm.copyItem(atPath: file, toPath: pathToDocuments.appending(fileName))
            }
        } catch {
            UIApplication.shared.alert(title: "Error", body: "Failed to copy files directory!", withButton: true)
        }
    }
    
    func initializeStartup() {
        if fm.fileExists(atPath: "/var/mobile/TrollBoard/") {
            print("TrollBoard folder exists.")
        } else {
            do {
                try fm.createDirectory(atPath: "/var/mobile/TrollBoard", withIntermediateDirectories: false)
            } catch {
                UIApplication.shared.alert(title: "Error", body: "Failed to initialize at startup!", withButton: true)
            }
        }
    }
    
    
    func getDocumentsDirectory() -> URL { // i love hacking with swift
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func deleteIconAssets() throws {
        let tempAssetDir = getDocumentsDirectory().appendingPathComponent("Assets.car")
        
        let (catalog, renditionsRoot) = try AssetCatalogWrapper.shared.renditions(forCarArchive: tempAssetDir)
        for rendition in renditionsRoot {
            let type = rendition.type
            guard type == .icon else { continue }
            let renditions = rendition.renditions
            for rend in renditions {
                do {
                    try catalog.removeItem(rend, fileURL: tempAssetDir)
                } catch {
                    UIApplication.shared.alert(title: "Error", body: "Failed to edit Assets.car file!", withButton: true)
                }
            }
        }
    }
    
    func prepareIcon(app: String) {
        let InstalledApps = apps.AllInstalledApps()
        
        do {
            // .car stuff
            copyFileDocumentsDirectory(file: apps.AppFromBundleID(app, InstalledApps)!.BundlePath.appending("/Assets.car"), fileName: "Assets.car")
            try deleteIconAssets()
        } catch {
            UIApplication.shared.alert(title: "Error", body: "Failed to prepare Assets.car file!", withButton: true)
        }
    }
    
    func setIcon(app: String) {
        do {
            let imageData = try Data(contentsOf: URL(fileURLWithPath: "/var/mobile/TrollBoard/\(app).png"))
            try resizeAndSaveImage(imageData: imageData, path: "/var/mobile/TrollBoard/\(app).png")
            
            let InstalledApps = apps.AllInstalledApps()
            let origCount = try Data(contentsOf: URL(fileURLWithPath: searchIcon(path: apps.AppFromBundleID(app, InstalledApps)!.BundlePath)))
            let imageDataCompressed = try UIImage(contentsOfFile: "/var/mobile/TrollBoard/\(app).png")!.resizeToApprox(allowedSizeInBytes: origCount.count)
            let assetsData = try Data(contentsOf: getDocumentsDirectory().appendingPathComponent("Assets.car"))
            
            overwriteFileWithDataImpl(originPath: searchIcon(path: apps.AppFromBundleID(app, InstalledApps)!.BundlePath), backupName: "originIcon", replacementData: imageDataCompressed)
            overwriteFileWithDataImpl(originPath: apps.AppFromBundleID(app, InstalledApps)!.BundlePath.appending("/Assets.car"), backupName: "originAssets", replacementData: assetsData)
        } catch {
            UIApplication.shared.alert(title: "Error", body: "Failed to set AppIcon and Assets.car file! This error might have occured because the original icon of the app is TOO small. (1kb or lower)", withButton: true)
        }
    }
}
