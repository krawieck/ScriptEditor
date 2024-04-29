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
    
    var isRunning: Bool {
        process?.isRunning ?? false
    }
    @State var sidebarIsShown: Bool = true
    
    @State var error: LocalizedError? = nil
    @State var errorIsPresented = false
    
    @State var process: ScriptRunner?
    
    var body: some View {
        TextEditor(text: $file.content)
            .fontDesign(.monospaced)
            .toolbarRole(.editor)
            .toolbar {
                if let exitCode = process?.exitCode {
                    if exitCode == 0 {
                        Label("Success", systemImage: "checkmark.circle")
                            .foregroundStyle(.green)
                            .help("exit code: \(exitCode)")
                    } else {
                        Label("Error", systemImage: "xmark.circle")
                            .foregroundStyle(.red)
                            .help("exit code: \(exitCode)")
                    }
                }
                if isRunning {
                    ProgressView()
                        .controlSize(.small)
                }
            }
            .inspector(isPresented: $sidebarIsShown) {
                ScrollView {
                    Text(process?.dataString ?? "<output will show up here>")
                        .textSelection(.enabled)
                        .monospaced()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        
                }
                
                .toolbar {
                    Button(action: start) {
                        Label("Start", systemImage: "play.fill")
                    }
                    Button(action: stop) {
                        Label("Stop", systemImage: "stop.fill")
                    }.disabled(!isRunning)
                    Spacer()
                    Button(action: toggleSidebar) {
                        Label("Toggle running window", systemImage: "apple.terminal.fill")
                    }
                }
                .inspectorColumnWidth(min: 300, ideal: 500, max: 700) // TODO: use GeometryReader to make max 1/2 of the width of the window
            }//.alert(isPresented: $errorIsPresented, error: error, actions: {}) // TODO: error alert when the file doesnt have the supported format
    }
    
    private func toggleSidebar() {
        sidebarIsShown.toggle()
        
    }
    
    private func save() {
        // TODO: can i do it some other way?
        NSApp.sendAction(#selector(NSDocument.save(_:)), to: nil, from: nil)
    }
    
    private func start() {
        save()
        
        if let fileURL {
            process = ScriptRunner(fileURL: fileURL)
            process!.run()
        }
    }
    
    private func stop() {
        if let process {
            process.stop()
        }
        
    }
}

#Preview {
    ContentView(file: .constant(ScriptFile(initialContent: "textt")))
}
