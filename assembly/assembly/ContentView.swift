//
//  ContentView.swift
//  assembly
//
//  Created by Inez Yoon on 2024-04-01.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: assemblyDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

#Preview {
    ContentView(document: .constant(assemblyDocument()))
}
