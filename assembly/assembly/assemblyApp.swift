//
//  assemblyApp.swift
//  assembly
//
//  Created by Inez Yoon on 2024-04-01.
//

import SwiftUI

@main
struct assemblyApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: assemblyDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
