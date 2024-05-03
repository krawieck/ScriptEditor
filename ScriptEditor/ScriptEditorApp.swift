//
//  ScriptEditorApp.swift
//  ScriptEditor
//
//  Created by Filip Krawczyk on 21/04/2024.
//

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

@main
struct ScriptEditorApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: ScriptFile()) { file in
            ContentView(file: file.$document, fileURL: file.fileURL)
        }
    }
}

/// inspo: `https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-a-document-based-app-using-filedocument-and-documentgroup
struct ScriptFile: FileDocument {
    static let readableContentTypes = [UTType.sourceCode]
    var content: String = ""

    init(initialContent content: String = "") {
        self.content = content
    }

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            content = String(decoding: data, as: UTF8.self)
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(content.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
