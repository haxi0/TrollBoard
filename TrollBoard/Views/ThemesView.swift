//
//  ThemesView.swift
//  TrollBoard
//
//  Created by Анохин Юрий on 02.02.2023.
//

import SwiftUI
import Foundation

struct ThemesView: View {
    @EnvironmentObject var fileController: FileController
    @State var urls: [URL] = []
    var url: URL
    let themer = Theme.shared
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(urls, id: \.self) { url in
                        let pathToImage = String(url.absoluteString.dropFirst((url.scheme?.count ?? -3) + 3))
                        let appName = String(url.lastPathComponent).components(separatedBy: ".png")
                        let app = appName[0]
                        
                        HStack {
                            Image(uiImage: UIImage(contentsOfFile: pathToImage)!)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .cornerRadius(9)
                            VStack {
                                Text(url.lastPathComponent)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Button("Apply") {
                                // this aint really fancy too
                                UIApplication.shared.alert(title: "Working on it", body: "Applying...", withButton: false)
                                
                                themer.prepareIcon(app: app)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {                                        UIApplication.shared.dismissAlert(animated: false)
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        themer.setIcon(app: app)
                                        
                                        UIApplication.shared.confirmAlert(title: "Done", body: "Icon was applied with no errors, it is recommended to respring now to make the icon persist. After respring please reboot!", onOK: {
                                            respring()
                                        }, noCancel: false)
                                    }
                                }
                            }
                            .buttonStyle(ApplyButtonStyle())
                        }
                    }
                }
                .environment(\.defaultMinListRowHeight, 60)
            }
            .toolbar {
                Button {
                    urls = fileController.getContentsOfDirectory(url: url)
                    print(urls)
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .navigationTitle(url.lastPathComponent)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            // not very fancy but
            UIApplication.shared.alert(title: "Working on it", body: "Loading files...", withButton: false)
            grant_full_disk_access() { error in
                print(error?.localizedDescription as Any)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                UIApplication.shared.dismissAlert(animated: false)
                themer.initializeStartup()
                urls = fileController.getContentsOfDirectory(url: url)
            }
        }
    }
}

struct ThemesView_Previews: PreviewProvider {
    static var previews: some View {
        ThemesView(url: URL(string: "/var/mobile/TrollBoard")!)
            .environmentObject(FileController())
    }
}
