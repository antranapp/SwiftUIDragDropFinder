//
//  ContentView.swift
//  FileDragDrop
//
//  Created by An Tran on 25/5/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    var body: some View {
        VStack {
            Text("SwiftUI Drag and Drop Demo")
                .font(.title)
                .padding()
            HStack {
                DragSourceView()
                DropTargetView()
            }
        }
    }
}

struct DragSourceFile: Identifiable {
    let id: UUID = UUID()
    let fileURL: URL
}

struct DragSourceView: View {
    @State private var fileURLs: [DragSourceFile] = []

    var body: some View {
        VStack {
            Text("Drag Files Here")
                .padding()
            List(fileURLs, id: \.id) { file in
                Text(file.fileURL.lastPathComponent)
            }
        }
        .frame(width: 300, height: 300)
        .background(Color.blue.opacity(0.2))
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            handleFileDrop(providers: providers)
        }
        .onDrag {
            // TODO: Find a way to drag multiple files. onDrag is returning a single NSItemProvider atm
            guard let fileURL = fileURLs.first else { return NSItemProvider() }
            return NSItemProvider(item: fileURL.fileURL as NSSecureCoding, typeIdentifier: UTType.fileURL.identifier)
        }
    }

    private func handleFileDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.canLoadObject(ofClass: URL.self) {
                _ = provider.loadObject(ofClass: URL.self) { url, error in
                    DispatchQueue.main.async {
                        if let url = url {
                            self.fileURLs.append(DragSourceFile(fileURL: url))
                        }
                    }
                }
            }
        }
        return true
    }
}

struct DropTargetView: View {
    @State private var droppedFileURLs: [DragSourceFile] = []

    var body: some View {
        VStack {
            Text("Drop Files Here to Print URL")
                .padding()
            List(droppedFileURLs, id: \.id) { file in
                Text(file.fileURL.lastPathComponent)
            }
        }
        .frame(width: 300, height: 300)
        .background(Color.green.opacity(0.2))
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            handleFileDrop(providers: providers)
        }
    }

    private func handleFileDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            if provider.canLoadObject(ofClass: URL.self) {
                _ = provider.loadObject(ofClass: URL.self) { url, error in
                    if let url = url {
//                        print("Dropped file URL: \(url.absoluteString)")
                        droppedFileURLs = [DragSourceFile(fileURL: url)]
                    }
                }
            }
        }
        return true
    }
}
