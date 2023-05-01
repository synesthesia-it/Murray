# Murray

[![Swift](https://github.com/synesthesia-it/Murray/actions/workflows/tests.yml/badge.svg)](https://github.com/synesthesia-it/Murray/actions/workflows/tests.yml)

**Murray** is a command-line integrator of template files into projects.

It helps developers to quickly scaffold new features into any kind of project based on their own templates, folder structure and naming conventions.

It's written in **Swift** but it's compatible with any text-based project.

The templating language is [Stencil](https://github.com/stencilproject/Stencil) with [StencilSwiftKit](https://github.com/SwiftGen/StencilSwiftKit) additions.

# A real-life example

Let's say you have to create some feature for your software - let's actually call it `Feature`. We can imagine it as a *screen* for your application, and you'll need to create later on different screens with the same structure but a different base name (`Feature` may become `Product` or `User` or really anything).

Let's also say that you are following the MVC (Model View Controller) pattern and you are using Swift as programming language.

It's almost certain that you will end up creating 3 different files: 
- the `Feature.swift` file containing the model 
- the `FeatureController.swift` file containing the controller
- the `FeatureView.swift` file with the view.

If you are also following TDD (or just unit testing your software), you will probably also need a `FeatureTests.swift` file somewhere.

On top of that, you will probably will have to instantiate at least the controller somewhere by writing `FeatureController()` in a very specific part of your existing code.

The idea behind Murray is to run in a terminal a command like
```shell
murray run screen Feature 
```
to find all the files you need in the proper place (example: a `Scenes/Feature` folder), already pre-compiled with some boilerplate (ex: `struct Feature: Codable {}`) and all the links already in place so that you can quickly start developing your... features.

# Installation (macOS)

## Using 🌱 *[Mint](https://github.com/yonaskolb/mint)* (recommended)

```
mint install synesthesia-it/Murray
```

## Compiling from source (latest version from *main* branch)

```
curl -fsSL https://raw.githubusercontent.com/synesthesia-it/Murray/master/install.sh | sh
```

## Make

If you want to try Murray and compile it directly from code, you can use `make`. 
This is especially useful for contribution to the project.

> Make sure you've installed Homebrew on your machine.

`make build` will build a release version of Murray and copy the executable file it in `/usr/local/bin` folder 

`make setup` will properly setup the environment and generate the XCode project

`make lint` will ensure code is properly written by following the Swiftlint standard


# Key Concepts

**Murray** is based around the concept of **Skeleton** - a starting point for any kind of project given a pre-defined architecture (example: an HTML5 project with Bootstrap, an iOS project with MVVM/MVC/TCA/whatever, a React Native starting project template) that is goin to be extended with small parts of boilerplate code that need to be created in specific subfolders in a consistent way - we call them **Bones**.  The idea is to have precompiled files ready in place and edit it accoring to your needs. 
> Murray doesn't interpret your file contents after it's created, it's completely language agnostic.

You put together one or more bones into a **Procedure**, which is a command with a name that "installs" Bones into your project. You provide a **Context** to the procedure, containing a bunch of variables that will be used to transform your template file into the final one.

## Template

A template is a text file containing a mix of final code structure and variables that will be solved. A template is built around a *templating language*, and Murray uses [Stencil](https://github.com/stencilproject/Stencil)

A basic example (for a SwiftUI project) can be:
```swift
import SwiftUI

struct {{name|firstUppercase}}View: View {
    @ObservedObject var viewModel: {{name|firstUppercase}}ViewModel
    var body: some View {
        Text("{{name}} is cool!")
    }
}
```

When provided with a *context* containing a variable called `name`, all the placeholders contained within the `{{}}` symbols will be replaced with that variable name. If `name` value were `murray`, the result would be

```swift
import SwiftUI

struct MurrayView: View {
    @ObservedObject var viewModel: MurrayViewModel
    var body: some View {
        Text("murray is cool!")
    }
}
```
Stencil provides a "basic" templating experience; to enhance the capabilities and create more complex templates, Murray also implement [StencilSwiftKit](https://github.com/SwiftGen/StencilSwiftKit) extensions. Check both documentation for template usage.

## Context

A **context** is a key-value map (a *dictionary*) containing variables that will be replaced in templates.

It can be provided through command line (local context - it changes with every invocation according to your need) and provide some global defaults defined in the main `Murrayfile`.

Context is also enriched with some dynamic values like current time/date/year, the current git author, file path, etc. so that every created template may render something like

```swift
// {{_filename._to}} - {{_author}} © {{_year}}
```
rendered as 
```swift
// Murray.swift - Stefano Mondino - © 2023
```

## Package

A package is a group of procedures and bones that may easily be redistributed across different teams and/or people.
Most common use case scenario involves a single package containing all the procedure for current skeleton, but there may be some cases where packages could be mixed and/or extended.

A package is contained in a folder, so it's easy to move around (zip or git subfolder)

## Configuration files

Murray supports either YAML or JSON for configuration file.

The main entry-point is the **Murrayfile** in the project's root, containing the environment hashmap and the list of included packages (as paths relative to the project's root).

Every package configuration file contains the list of supported **procedures**, each one linking to a list of one or more **bones**

Every bone has a a configuration file listing the new files that will be created when the procedure including current bone is ran, and some other options. See below for further details

# CLI commands

Every command has a `--help` option explaining proper usage of selected command.

## List
`murray list` returns a complete list of all available procedures by joining the packages contained in your Murrayfile.

Example with two packages:
```console
foo@bar:~$ murray list
Package.procedureA
Package.procedureB
Package.procedureC
AnotherPackage.procedureA
```

> You can use the name of the procedure in following `run` executions; if two different packages have the same name, prepend the package name to the procedure's name

## Run
`murray run <procedureName> <name>` runs selected procedure.
If context requires more than the `name` parameter, add a key-value list of parameters with `parameter:value` syntax

Example (let's assume that `procedureA` requires a `name` and a `module` parameter in context):
```console
foo@bar:~$ murray run procedureA test module:MyModule
```
Options: 
- `--verbose`: enables full logging 
- `--preview`: skip any file creation and provides a list of file that will be created/modified by current execution 

## Scaffold 

`murray scaffold <type>` creates the basic configuration structure for Murray components.

Every command creating a new configuration file accepts an optional `--format` parameter, accepting either `yml` or `json` for contents data structure. Murray default format is YAML.

### Skeleton

```console
foo@bar:~$ murray scaffold skeleton --format yml
```

Creates a new Skeletonfile in current folder. 

### Murrayfile
```console
foo@bar:~$ murray scaffold murrayfile --format yml
```

Creates an empty Murrayfile in current folder.

### Package
```console
foo@bar:~$ murray scaffold Package <packageName> --format yml --folder ".Murray"
```

Creates a new package called `packageName` in specified folder. When not specified, folder is a new directory called `Murray` (relative to the Murrayfile)

### Bone 
```console
foo@bar:~$ murray scaffold bone <packageName> <name> <files> --format yml --skipProcedure
```

Creates a new bone named `name` in package named `packageName`.
You can provide a list of file names (separated by spaces) that will be created empty inside the bone's folder.

> The file format for the bone configuration file will be the same as the containing package.

Example (given that `MyPackage` is the package name): 

```console
foo@bar:~$ murray scaffold bone MyPackage CustomBone FileA.swift.stencil FileB.swift.stencil`
```

will create a new bone inside MyPackage, containing the configuration file and two empty template files.

The `--skipProcedure` parameter skips the creation of a new procedure inside the Package configuration containing the new item. Defaults to `false` (meaning that - if set to `true` - you will need to manually add a new procedure to your package by editing the configuration file).


### Procedure
```console
murray scaffold procedure <packageName> <name> <boneNames>
```
Appends a new procedure to package named `packageName`, containing bones (separated by spaces) named `boneNames`. The name of the procedure will be called `name`.

Example (given that `MyPackage` is the package name and it already contains bones named `CustomBone` and `AnotherBone`):

```console
murray scaffold procedure MyPackage MyProcedure CustomBone AnotherBone
```

will create a procedure named `MyProcedure` containing `CustomBone` and `AnotherBone`. They will be executed in this exact order.

You can then call `murray run MyProcedure Test` to use it in your project.

# Plugins

Developers may need to perform some tasks befor or after some key moments in `murray run` execution. 
These moments are usually:
- before or after every new file defined by an item is created
- before or after a replacement
- before or after an item is executed
- before or after a specific procedure is ran
- before or after **every** procedure is ran

> **Before** and **after** are called **phases** and every plugin may or may not support them both.

MurrayKit exposes the context of `Plugin` to ensure allow every (Swift) developer to easy integrate custom behavior inside executions. Every `Plugin` may have its own parameters that will be used at the right time.

To declare a plugin for an item / procedure / global execution, you need to add a dictionary node named `plugins` containing the name of the plugin you need to use and its own parameters. (see below for examples)

> Currently every plugin must be compiled with Murray sources. Dynamic plugins are in the roadmap.

Murray ships with 2 plugins: `Xcode` and `Shell`

## Xcode Plugin

The xcode plugin allows users to automatically add new files to a specific target in your Xcode project. 

It only supports the **after** phase (it would be pointless to add a specific file to your Xcode project before it's created).

The accepted parameters are: 
- `targets`: an array of targets to add the current file to.
- `projectPath`: (optional) the path (relative to the Murrayfile folder) containing the xcode project. When not specified, it will use the first `xcodeproj` found in the Murrayfile folder. This is useful for modular projects with multiple xcodeprojs.

See the Examples folder for a demo.

## Shell Plugin

The shell plugin executes any shell command before or after the current item execution.
It could be used at any level (replacement, file, procedure or globally).
The accepted parameters are:
- `before`: an array of commands to be run before the current element execution
- `after`: an array of commands to be run after the currente element execution

A common use case scenario could be running a linter (ex: `swiftlint --fix` or `swiftformat`) after every execution, to ensure that files created or edited by murray execution are still well formatted according to your logic

Projects using XcodeGen or Tuist may run either `xcodegen` or `tuist generate` to recreate the xcode project. This is usually a better approach than the Xcode Plugin for projects that are already supporting project generation.

Example in Murrayfile:
```yml
...
plugins:
  shell:
    after: 
    - "swiftformat"
    - "swiftlint --fix"
    - "tuist generate"
```


# Configuration files

## Murrayfile

The Murrayfile contains the list of packages supported by current project and the environment. It also supports plugins that will be executed before or after any procedure.

The environment contains a base context that will be available in every Stencil template during the execution (either in code files or configuration files).

You can also recursively reference other environment variables.

> Avoid creating "variable loops" in the environment.

Parameters:
- `packages`: a list of paths to the packages configuration files (relative to the Murrayfile) 
- `plugins`: the plugin data
- `environment`: a dictionary containing a context available to all executions.
- `mainPlaceholder`: (optional) the name of the main placeholder used in every template. Defaults to `name`.

Example (YAML):
```yaml
packages:
- "Murray/MyPackage/MyPackage.yml
- "Murray/AnotherPackage/AnotherPackage.yml
plugins:
  shell:
    after: 
    - "make"
environment: 
  company: Synesthesia
  paths:
    sources: "Sources"
    module: "{{paths.sources}}/{{module}}"
    tests: "Tests"
```

## PackageFile

Contains the definition of a package and its procedures.

Parameters:
- `name`: the name of the package
- `description`: a readable description of the package, briefly explaining what it does.
- `procedures`: an array of procedures, each containing:
  - `name`: the name of the procedure, used in the `murray run` command
  - `description`: (optional) a readable description of the procedure, briefly explaining what it does. It will be shown in `murray list`.
  - `plugins`: the plugin data
  - `items`: paths to the bones configuration files, relative to the current Package configuration file. You can combine as many as you want (they will be executed following provided order).

Example (YAML):
```yaml
name: MyPackage
description: Some meaningful description
procedures:
- name: ProcedureA
  description: I'm sure this will be meaningful to you
  items: 
  - BoneA/bone.yml
- name: ProcedureB
  description: I'm sure this will be meaningful to you
  items: 
  - BoneB/bone.yml
- name: ProcedureC
  description: I'm sure this will be meaningful to you
  items: 
  - BoneA/bone.yml
  - BoneB/bone.yml
```

## BoneFile

Contains the definition of a single Bone. A bone is a combination of new files and replacements in existing files. 
While probably pointless, a bone can be completely empty (or only contain plugin data.)

Parameters:
- `name`: the name of the bone. It's used to scaffold new procedures.
- `description`:  a readable description of the bone, briefly explaining what it does.
- `parameters`: a list of parameters accepted by current bone. Each one is defined by
  - `name`: the name of the parameters. 
  - `isRequired`: a boolean value that will require the presence of this parameter in every execution containing this bone, throwing an error when missing
- `plugins`: plugin data
- `paths`: an array of paths definitions for every **new** file that will be created by this bone. Each one is defined by:
  - `from`: a path to a file or a folder relative to current bone configuration file. When pointing to a folder, it will resolve all contained files against provided context.
  - `to`: the destination path (relative **to the Murrayfile**) where this template (or folder) will be resolved into. It supports context resolution (meaning that it may contain stencil templates). 
  - `plugins`: plugin data for this path file/folder
- `replacements`: an array of replacements that will be sequentially executed. Each one is defined by: 
  - `destination`: destination file path (relative to Murrayfile) containing the file where the replacement will take place
  - `placeholder`: a line of text that will be searched inside the `destination`, and replaced by the `text` or the `source` contents. The placeholder is always added back after the replacement.
  - `text`: (optional) a small amount of text that will be placed right before the `placeholder` in the `destination` file. For large amount of replacement texts use `source`
  - `source`: (optional) a path to a file (relative to the bone) containing a resolvable text that will be placed in the `destination` file right before the `placeholder`. For small replacements use the `text` property instead. Please note that at least one between `text` and `source` is required. When both of them are specified, `source` is always used.

Example (YAML):
```yaml
name: sceneViewModel
parameters: []
paths:
- from: ViewModel.swift.stencil
  to: "{{paths.scenes}}/{{name|firstUppercase}}/{{name|firstUppercase}}ViewModel.swift"
  plugins:
    xcode: 
      targets: ["{{mainTarget}}"]
- from: ViewModelTests.swift.stencil
  to: "{{paths.tests}}/{{name|firstUppercase}}/{{name|firstUppercase}}ViewModel.swift"
  plugins:
    xcode: 
      targets: ["{{mainTestTarget}}"]
description: A scene view model with tests
replacements: 
- destination: "MurrayDemo/MainTabViewModel.swift"
  placeholder: "// murray: viewModel"
  text: "let {{name|firstLowercase}}ViewModel = {{name|firstUppercase}}ViewModel()\n"
```