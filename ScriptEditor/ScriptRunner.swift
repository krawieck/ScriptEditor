//
//  ScriptProcess.swift
//  ScriptEditor
//
//  Created by Filip Krawczyk on 29/04/2024.
//

import Foundation

@Observable class ScriptRunner {
    init(fileURL: URL) {
        self.fileURL = fileURL
        
        let ext = fileURL.pathExtension
        let path = fileURL.path()
        
        switch ext {
        case "swift":
            executableURL = URL(fileURLWithPath: "/usr/bin/env")
            arguments = ["swift", path]
            return
            
        case "kts":
            executableURL = URL(fileURLWithPath: "kotlinc")
            arguments = ["-script", path]
            return
        default:
            fatalError("unsupported file type")
        }
    }
    let fileURL: URL
    var isRunning = false
    
    
    var data: Data = Data()
    var dataString: String? {
        String(data: data, encoding: .utf8)
    }
    var exitCode: Int32? = nil
    
    private var executableURL: URL
    private var arguments: [String]
    
    private var process: Process = Process()
    private var stdoutPipe: Pipe = Pipe()
    private var stderrPipe: Pipe = Pipe()
    
    private var stdoutHandler: FileHandle? = nil
    private var stderrHandler: FileHandle? = nil
    
    func run() {
        clear()
        process = Process()
        stdoutPipe = Pipe()
        stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        process.executableURL = executableURL
        process.arguments = arguments
        
        stdoutHandler = stdoutPipe.fileHandleForReading
        stderrHandler = stderrPipe.fileHandleForReading
        
        guard let stdoutHandler else { return }
        guard let stderrHandler else { return }
        
        stdoutHandler.waitForDataInBackgroundAndNotify()
        stderrHandler.waitForDataInBackgroundAndNotify()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable,
                                               object: stdoutHandler, queue: nil) { notification in
            let newData = stdoutHandler.availableData
            self.data.append(newData)
            if !newData.isEmpty {
                stdoutHandler.waitForDataInBackgroundAndNotify()
            } else {
                self.isRunning = false
                self.exitCode = self.process.terminationStatus
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable,
                                               object: stderrHandler, queue: nil) { notification in
            let newData = stderrHandler.availableData
            self.data.append(newData)
            if !newData.isEmpty {
                stderrHandler.waitForDataInBackgroundAndNotify()
            } else {
                self.isRunning = false
                self.exitCode = self.process.terminationStatus
            }
        }
        
        isRunning = true
        try! process.run()
        
        return
    }
    
    func stop() {
        if let stdoutHandler {
            try? stdoutHandler.close()
            self.stdoutHandler = nil
        }
        if let stderrHandler {
            try? stderrHandler.close()
            self.stderrHandler = nil
        }
        process.terminate()
        
        isRunning = false
    }
    
    func clear() {
        data = Data()
        exitCode = nil
    }
}

