//
//  ContentView.swift
//  ScriptEditor
//
//  Created by Filip Krawczyk on 21/04/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Binding var file: ScriptFile
    var fileURL: URL?
    
    @State var isRunning: Bool = false
    @State var sidebarIsShown: Bool = true
    
    var body: some View {
        TextEditor(text: $file.content)
            .fontDesign(.monospaced)
            .toolbarRole(.editor)
            .toolbar {
                Button(action: start, label: {
                    Label("Start", systemImage: "play.fill")
                })
                Button(action: stop, label: {
                    Label("Stop", systemImage: "stop.fill")
                }).disabled(true)
                
            
               
                
            }.inspector(isPresented: $sidebarIsShown) {
                Text("hello :)")
                    .toolbar {
                        Spacer()
                        Button(action: toggleSidebar) {
                            Label("Toggle running window", systemImage: "apple.terminal.fill")
                        }
                    }
                    .inspectorColumnWidth(min: 300, ideal: 500, max: 700) // TODO: use GeometryReader to make max 1/2 of the width of the window
            }
    }

    private func toggleSidebar() {
        sidebarIsShown.toggle()
        
    }
    
    private func save() {
        NSApp.sendAction(#selector(NSDocument.save(_:)), to: nil, from: nil)
    }
    
    private func start() {
//        save()
        if let fileURL {
            let ext = fileURL.pathExtension
            
            
        }
        // save
        // if kotlin then ... else if swift then ... else ...wtf?
    }
    
    private func stop() {
        
    }
    
    private func addItem() {
//        withAnimation {
//            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
//        }
    }

    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(items[index])
//            }
//        }
    }
}

#Preview {
    ContentView(file: .constant(ScriptFile(initialContent: "textt")))
        
//        .modelContainer(for: Item.self, inMemory: true)
}
