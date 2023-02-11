//
//  Functions.swift
//  test
//
//  Created by Анохин Юрий on 25.01.2023.
//

import Foundation
import UIKit

func overwriteFileWithDataImpl(originPath: String, backupName: String, replacementData: Data) -> Bool {
#if false
    let documentDirectory = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    )[0].path
    
    let pathToRealTarget = originPath
    let originPath = documentDirectory + backupName
    let origData = try! Data(contentsOf: URL(fileURLWithPath: pathToRealTarget))
    try! origData.write(to: URL(fileURLWithPath: originPath))
#endif
    
    // open and map original font
    let fd = open(originPath, O_RDONLY | O_CLOEXEC)
    if fd == -1 {
        print("Could not open target file")
        UIApplication.shared.alert(title: "Error", body: "Could not open target file!", withButton: true)
        return false
    }
    defer { close(fd) }
    // check size of font
    let originalFileSize = lseek(fd, 0, SEEK_END)
    guard originalFileSize >= replacementData.count else {
        print("File too big")
        UIApplication.shared.alert(title: "Error", body: "File too big! Compress it please.", withButton: true)
        return false
    }
    lseek(fd, 0, SEEK_SET)
    
    // Map the font we want to overwrite so we can mlock it
    let fileMap = mmap(nil, replacementData.count, PROT_READ, MAP_SHARED, fd, 0)
    if fileMap == MAP_FAILED {
        print("Failed to map")
        UIApplication.shared.alert(title: "Error", body: "Failed to map!", withButton: true)
        return false
    }
    // mlock so the file gets cached in memory
    guard mlock(fileMap, replacementData.count) == 0 else {
        print("Failed to mlock")
        UIApplication.shared.alert(title: "Error", body: "Failed to mlock!", withButton: true)
        return true
    }
    
    // for every 16k chunk, rewrite
    print(Date())
    for chunkOff in stride(from: 0, to: replacementData.count, by: 0x4000) {
        print(String(format: "%lx", chunkOff))
        let dataChunk = replacementData[chunkOff..<min(replacementData.count, chunkOff + 0x4000)]
        var overwroteOne = false
        for _ in 0..<2 {
            let overwriteSucceeded = dataChunk.withUnsafeBytes { dataChunkBytes in
                return unaligned_copy_switch_race(
                    fd, Int64(chunkOff), dataChunkBytes.baseAddress, dataChunkBytes.count)
            }
            if overwriteSucceeded {
                overwroteOne = true
                break
            }
            print("try again?!")
        }
        guard overwroteOne else {
            print("Failed to overwrite")
            UIApplication.shared.alert(title: "Error", body: "Failed to overwrite!", withButton: true)
            return false
        }
    }
    print(Date())
    return true
}
