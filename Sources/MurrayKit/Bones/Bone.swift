//
//  Template.swift
//  MurrayCore
//
//  Created by Stefano Mondino on 12/07/18.
//

import Foundation
import Files
import ShellOut

public final class Bone {
    public typealias Context = [String: Any]
    public static let murrayTemplatesFolderName = ".murray"
    public static let murrayLocalTemplatesFolderName = "MurrayTemplates"

    var boneName: String
    var name: String
    var context: Context
    let listName: String
    public init(boneName: String, mainPlaceholder: String? = nil, context: Context = [:]) throws {

        let splits = boneName.components(separatedBy: ".")
        if splits.count > 1, let listName = splits.first {
            self.listName = listName
            self.boneName = splits.dropFirst().joined(separator: ".")
        } else {
            self.listName = ""
            self.boneName = boneName
        }

        let placeholderName: String? = mainPlaceholder ?? context["name"] as? String
        guard let name = placeholderName else {
            throw Error.missingMainPlaceholder
        }
        var context = context
        context["name"] = name
        self.name = name
        self.context = context
    }
}
