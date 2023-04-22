//
//  File.swift
//  Wrapper for the `Files` library
//
//  Created by Stefano Mondino on 30/01/22.
//

import Files
import Foundation

public struct File: Hashable {
    private let file: Files.File

    public var parent: Folder? {
        guard let parent = file.parent else { return nil }
        return .init(parent)
    }

    public var name: String { file.name }
    public var nameExcludingExtension: String { file.nameExcludingExtension }
    public var `extension`: String? { file.extension }
    public var path: String { file.path }

    init(_ file: Files.File) {
        self.file = file
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }

    public func path(relativeTo folder: Folder) -> String {
        file.path(relativeTo: folder.folder)
    }

    public func readAsString() throws -> String {
        do {
            return try file.readAsString()
        } catch {
            throw Errors.unreadableFile(file.path)
        }
    }

    public func read() throws -> Data {
        do {
            return try file.read()
        } catch {
            throw Errors.unreadableFile(file.path)
        }
    }

    public func write(_ string: String, encoding: String.Encoding = .utf8) throws {
        do {
            return try file.write(string, encoding: encoding)
        } catch {
            throw Errors.unwriteableFile(file.path)
        }
    }

    public func delete() throws {
        do {
            try file.delete()
        } catch {
            throw Errors.deleteFile(path)
        }
    }
}

public struct Folder: Hashable {
    fileprivate let folder: Files.Folder

    public var path: String { folder.path }
    public var name: String { folder.name }
    public var files: [File] {
        folder.files.map { .init($0) }
    }

    public var subfolders: [Folder] {
        folder.subfolders.map { .init($0) }
    }

    public static var current: Folder {
        .init(Files.Folder.current)
    }

    public static var home: Folder {
        .init(Files.Folder.home)
    }

    public static var temporary: Folder {
        .init(Files.Folder.temporary)
    }

    fileprivate init(_ folder: Files.Folder) {
        self.folder = folder
    }

    public init(path: String) throws {
        do {
            folder = try .init(path: path)
        } catch {
            throw Errors.folderLocationError(path)
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }

    @discardableResult
    public func copy(to folder: Folder) throws -> Folder {
        do {
            return try Folder(self.folder.copy(to: folder.folder))
        } catch {
            throw Errors.copyFolder(folder.path)
        }
    }

    @discardableResult
    public func moveContents(to folder: Folder, includeHidden: Bool = false) throws -> Folder {
        do {
            try self.folder.moveContents(to: folder.folder, includeHidden: includeHidden)
            return folder
        } catch {
            throw Errors.moveFolder(folder.path)
        }
    }

    @discardableResult
    public func createSubfolderIfNeeded(withName name: String) throws -> Folder {
        do {
            return try Folder(folder.createSubfolderIfNeeded(at: name))
        } catch {
            throw Errors.createFolder(name)
        }
    }

    public func delete() throws {
        do {
            try folder.delete()
        } catch {
            throw Errors.deleteFolder(path)
        }
    }

    public func file(named name: String) throws -> File {
        do {
            let file = try folder.file(named: name)
            return .init(file)
        } catch {
            throw Errors.fileLocationError(path.appendingPathComponent(name))
        }
    }

    public func file(at path: String) throws -> File {
        do {
            let file = try folder.file(at: path)
            return .init(file)
        } catch {
            throw Errors.fileLocationError(self.path.appendingPathComponent(path))
        }
    }

    public func path(relativeTo to: Folder) -> String {
        folder.path(relativeTo: to.folder)
    }

    @discardableResult
    public func createFileIfNeeded(at path: String,
                                   contents: @autoclosure () -> Data? = nil) throws -> File {
        do {
            return try .init(folder.createFileIfNeeded(at: path, contents: contents()))

        } catch {
            throw Errors.unwriteableFile(self.path.appendingPathComponent(path))
        }
    }

    public func subfolder(at path: String) throws -> Folder {
        do {
            return try .init(folder.subfolder(at: path))
        } catch {
            throw Errors.folderLocationError(path.appendingPathComponent(path))
        }
    }

    public func subfolder(named name: String) throws -> Folder {
        do {
            return try .init(folder.subfolder(named: name))
        } catch {
            throw Errors.folderLocationError(path.appendingPathComponent(name))
        }
    }

    public var parent: Folder? {
        guard let value = folder.parent else { return nil }
        return .init(value)
    }
}

extension Folder {
    func firstFile(named names: [String]) throws -> File {
        guard let file: File = names
            .lazy
            .compactMap({ try? file(named: $0) })
            .first
        else {
            throw Errors.fileLocationError(path)
        }
        return file
    }
}
