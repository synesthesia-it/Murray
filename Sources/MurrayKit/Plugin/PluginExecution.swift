//
//  File.swift
//  
//
//  Created by Stefano Mondino on 23/05/22.
//

import Foundation

public struct PluginExecution<Element: PluginDataContainer> {
    
    public enum Phase {
        case before
        case after
    }
    let element: Element
    let file: WriteableFile?
    let phase: Phase
    private let originalContext: Template.Context

    internal init(element: Element,
                  file: WriteableFile? = nil,
                  context: Template.Context,
                  phase: Phase) {
        self.element = element
        self.file = file
        self.originalContext = context
        self.phase = phase
    }
    
    func context() -> Template.Context {
        let fileContext = ["_path": file?.root.path.appendingPathComponent(file?.path ?? ""),
                           "_root": file?.root.path]
        let all = originalContext.values.merging(fileContext) { original, _ in original }
        return .init(all)
    }
}
