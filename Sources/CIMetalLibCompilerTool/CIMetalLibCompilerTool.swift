//
//  CIMetalLibCompilerTool.swift
//
//
//  Created by dave on 15/10/23.
//

import ArgumentParser
import Foundation
import os

@main
struct CIMetalLibCompilerTool: ParsableCommand {
    @Option(name: .shortAndLong)
    var output: String

    @Argument
    var inputs: [String]

    mutating func run() throws {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        p.arguments = [
            "metallib",
        ]
            + inputs
            + [
                "-cikernel",
                "-o",
                output,
                "-gline-tables-only",
                "-frecord-sources",
            ]
        try p.run()
    }
}
