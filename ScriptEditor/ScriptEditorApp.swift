//
//  ScriptEditorApp.swift
//  ScriptEditor
//
//  Created by Filip Krawczyk on 21/04/2024.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

@main
struct ScriptEditorApp: App {
    var body: some Scene {
        DocumentGroup(editing: .itemDocument, migrationPlan: ScriptEditorMigrationPlan.self) {
            ContentView()
        }
    }
}

extension UTType {
    static var itemDocument: UTType {
        UTType(importedAs: "com.example.item-document")
    }
}

struct ScriptEditorMigrationPlan: SchemaMigrationPlan {
    static var schemas: [VersionedSchema.Type] = [
        ScriptEditorVersionedSchema.self,
    ]

    static var stages: [MigrationStage] = [
        // Stages of migration between VersionedSchema, if required.
    ]
}

struct ScriptEditorVersionedSchema: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] = [
        Item.self,
    ]
}
