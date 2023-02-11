//
//  AppSearch.swift
//  TrollBoard
//
//  Created by Анохин Юрий on 05.02.2023.
//

import Foundation

class Apps {
    static var shared = Apps()
    
    func AppInstalled(_ BundleID: String, _ InstalledApps: [AppItem]) -> Bool {
        for app in InstalledApps {
            if app.BundleID == BundleID {
                return true
            }
        }
        return false
    }
    
    //Usage: AppFromBundleID("http://com.apple.AppStore", InstalledApps)!.BundlePath
    func AppFromBundleID(_ BundleID: String, _ InstalledApps: [AppItem]) -> AppItem? {
        for app in InstalledApps {
            if app.BundleID == BundleID {
                return app
            }
        }
        return nil
    }
    
    func AllInstalledApps() -> [AppItem] {
        do {
            var Apps: [AppItem] = []
            for app in try FileManager.default.contentsOfDirectory(atPath: "/var/containers/Bundle/Application") {
                if let AppBundle = try FileManager.default.contentsOfDirectory(atPath: "/var/containers/Bundle/Application/\(app)").filter({$0.hasSuffix(".app")}).first {
                    let InfoPlist = NSDictionary(contentsOfFile: "/var/containers/Bundle/Application/\(app)/\(AppBundle)/Info.plist")!
                    Apps.append(AppItem(BundleID: InfoPlist.value(forKey: "CFBundleIdentifier") as! String, BundlePath: "/var/containers/Bundle/Application/\(app)/\(AppBundle)", Version: GetAppVersionFromInfoPlist(InfoPlist), Name: GetAppNameFromInfoPlist(InfoPlist), System: false))
                }
            }
            for app in try FileManager.default.contentsOfDirectory(atPath: "/Applications") {
                if app.hasSuffix(".app") {
                    if FileManager.default.fileExists(atPath: "/Applications/\(app)/Info.plist") {
                        let InfoPlist = NSDictionary(contentsOfFile: "/Applications/\(app)/Info.plist")!
                        Apps.append(AppItem(BundleID: InfoPlist.value(forKey: "CFBundleIdentifier") as! String, BundlePath: "/Applications/\(app)", Version: GetAppVersionFromInfoPlist(InfoPlist), Name: GetAppNameFromInfoPlist(InfoPlist), System: true))
                    }
                }
            }
            return Apps.sorted(by: { $0.Name.localizedLowercase < $1.Name.localizedLowercase } )
        } catch {
            print(error)
            return []
        }
    }
    
    func GetAppNameFromInfoPlist(_ Plist: NSDictionary) -> String {
        let PlistKeys = Plist.allKeys as! [String]
        if PlistKeys.contains("CFBundleDisplayName") {
            return Plist.value(forKey: "CFBundleDisplayName") as! String
        } else if PlistKeys.contains("CFBundleName") {
            return Plist.value(forKey: "CFBundleName") as! String
        } else if PlistKeys.contains("CFBundleExecutable") {
            return Plist.value(forKey: "CFBundleExecutable") as! String
        }
        return ""
    }
    
    func GetAppVersionFromInfoPlist(_ Plist: NSDictionary) -> String {
        let PlistKeys = Plist.allKeys as! [String]
        if PlistKeys.contains("CFBundleShortVersionString") {
            return Plist.value(forKey: "CFBundleShortVersionString") as! String
        } else if PlistKeys.contains("CFBundleVersion") {
            return Plist.value(forKey: "CFBundleVersion") as! String
        }
        return ""
    }
    
    struct AppItem: Hashable, Identifiable {
        var id: String {
            return BundleID
        }
        var BundleID: String
        var BundlePath: String
        var Version: String
        var Name: String
        var System: Bool
    }
}
