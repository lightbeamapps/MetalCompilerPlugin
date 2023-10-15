//
//  File.swift
//  
//
//  Created by dave on 15/10/23.
//

import Foundation
import os
import PackagePlugin

@main
struct CIMetalPlugin: BuildToolPlugin {
    func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
        var paths: [Path] = []
        target.directory.walk { path in
            if path.pathExtension == "ci.metal" {
                paths.append(path)
            }
        }
        Diagnostics.remark("Running...")
        
        let buildCIMetalCommands: [PackagePlugin.Command] = try paths.map({ path -> PackagePlugin.Command in
            
            let kernelName = path.url.lastPathComponent
            let outputName = "\(kernelName).metallib"
            
            Diagnostics.remark(outputName)
            
            return .buildCommand(
                    displayName: kernelName,
                    executable: try context.tool(named: "CIMetalCompilerTool").path,
                    arguments: [
                        "--output", context.pluginWorkDirectory.appending([outputName]).string,
                    ]
                    + [path.string],
                    environment: [:],
                    inputFiles: [path],
                    outputFiles: [
                        context.pluginWorkDirectory.appending([outputName]),
                    ]
                )
        })
        
        let buildCIMetalLibCommands: [PackagePlugin.Command] = try paths.map({ path -> PackagePlugin.Command in
            
            let libName = path.url.deletingPathExtension().lastPathComponent
            let inputName = "\(libName).air"
            let outputName = "\(libName).metallib"
            
            Diagnostics.remark(inputName)
            
            return .buildCommand(
                    displayName: inputName,
                    executable: try context.tool(named: "CIMetalLibCompilerTool").path,
                    arguments: [
                        "--output", context.pluginWorkDirectory.appending([outputName]).string,
                    ]
                    + [path.string],
                    environment: [:],
                    inputFiles: [path],
                    outputFiles: [
                        context.pluginWorkDirectory.appending([outputName]),
                    ]
                )
        })
        
        return buildCIMetalCommands + buildCIMetalLibCommands
    }
}

extension Path {
    func walk(_ visitor: (Path) -> Void) {
        let errorHandler = { (_: URL, _: Swift.Error) -> Bool in
            true
        }
        guard let enumerator = FileManager().enumerator(at: url, includingPropertiesForKeys: nil, options: [], errorHandler: errorHandler) else {
            fatalError()
        }
        for url in enumerator {
            guard let url = url as? URL else {
                fatalError()
            }
            let path = Path(url.path)
            visitor(path)
        }
    }

    var url: URL {
        URL(fileURLWithPath: string)
    }

    var pathExtension: String {
        url.pathExtension
    }
}
