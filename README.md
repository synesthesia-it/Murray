# Murray

Murray is a set of tools for Skeleton-based software development.

**Skeleton-based** software usually consists of code generated through lots of boilerplate that can't be abstracted and re-used through software architecture principles.

For instance, a classic HTML website always consists of pages with same `head` and `body`, filled with custom data in repeating structures.

Murray defines a common and simple design language made of specifications (JSON specs) and template files, wraps them in structured packages ("Bones") and provides tools for developers to quickly use them in their projects.
Speeding up development process, avoiding annoying and shared coding mistakes and enforcing proper folder structures are some of Murray's main goals.

# In a nutshell

Projects are usually made of groups of boilerplate files that has a fixed structure and part of their contents changing according to some input.

Some examples can be iOS' `UIViewController`, Android's `Activity`, controllers for Web MVC, actions/reducers for React, etc.

These files are always created from scratch in specific subfolders, replaced with some placeholder (in both filename and contents) and then completed with proper context-related implementations.

Murray addresses the first problem (folder structure) with JSON specs and the second one (placeholders) with Stencil templates. 

Stencil templates are text files where everything wrapped around double curly braces (like `{{ this }}`) can be replaced by a key-value pair, where the key is the wrapped word and the value is the actual substitution.
An example template for a `UIViewController` can be

```swift
import UIKit
class {{ name|firstUppercase }}sViewController: UIViewController {

  let {{ name|firstLowercase }}s: [{{ name|firstUppercase }}] = []

  func viewDidLoad() {
    super.viewDidLoad()
  }
}
```

Example execution command (from CLI): `murray bone new viewController product`

When executed by Murray with some parameters, this template will actually render it's context by replacing `name` occurrences with whatever provided, and applying *filters* like uppercase, lowercase, etc.

Rendered result will then be copied to a destination folder according to template's specifications in `BoneItem.json` file with these contents: 

```swift
import UIKit
class ProductsViewController: UIViewController {

  let products: [Product] = []

  func viewDidLoad() {
    super.viewDidLoad()
  }
}
```

Different templates can be rendered sequentially by a single execution, leading to a standardized way of software development.

# Key Features

- Clone a **skeleton** project from a remote repository, customize it with your project name and custom properties and have it ready to run. Murray supports **tags** and **branches** for remote repositories (`@develop` or `@1.0.0`)

- Develop your project with **bones**: template files you design that gets easily integrated in your project structure. If a adding a screen to your app requires 3 new files, you can design them with a template and have Murray resolve them for you and move the result in proper folders.

- Install bones templates from any number of different repositories: share your file templates with your team.

- Automatically add slices of code to already existing files when adding new bones (*example: Add a custom xml tag for your new Activity at the end of the Android manifest.xml when creating an Activity from a custom bone*).

- Easily manage and check your bones environment: see what's available directly from CLI

- Design your templates with **[Stencil](https://github.com/stencilproject/Stencil)**

- Integrate Murray functionalities in any Swift application through **MurrayKit** framework

- [WIP] MurrayStudio: a graphical user interface for improved editing and management.

# Installation

## MacOS

#### Using *[Mint](https://github.com/yonaskolb/mint)*


```
mint install synesthesia-it/Murray
```
Note: please ensure you're using at least Mint v0.12 (Swift 5)

#### Compiling from source (latest version from *master* branch)

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

## Linux (*experimental*, tested on Ubuntu 18)

Install Swift compiler ([guide](https://gist.github.com/Azoy/8c47629fa160878cf359bf7380aaaaf9) here)
then

```
sudo apt-get install libdispatch-dev
clone murray https://github.com/synesthesia-it/Murray/tree/develop
cd Murray
touch LinuxMain.swift
swift build -c release
copy .build/x86_64-unknow-linux/releas /opt/
alias murray='/opt/Murray/murray'
```

(credits to @beppenmk)

# Key Concepts

## Skeleton

A skeleton is an empty project, containing any type of file and folder.
The Skeleton is a shared starting point for a new project, and should not contain any bone template; in other words, the project should work out of the box as a real project.
To be compatible with Murray, a Skeleton project must contain a `Skeletonspec.json` file in its root folder.

## Bone

A Bone is a piece of boilerplate code splitted into one or more template files. 
A template file is usually NOT working out of the box, but needs to be *resolved* against some kind of context, and then copied into proper folder.

Bones structure can be represented with this diagram

![diagram](docs/diagram.svg)

## BoneItem

A BoneItem represents a group of template files that can be resolved and copied into current project.
BoneItems consist in a folder containing a `BoneItem.json` file and any number of template files.

`BoneItem.json` fields are: 

- `name`: a name identifying current item.
- `paths`: an array of path objects, made by a `from` and a `to` string value. 
  `from` represents a folder or a file relative to BoneItem.json itself and containing some template that needs to be copied into target project.
  `to` represents target folder path, relative to project's root (the one containing the `Murrayfile.json` file.)
  Both `from` and `to` paths are *resolved* against provided context, meaning that every Stencil placeholder will be converted in context value, if available.
- `parameters`: an array of objects representing all the keys expected by templates. Each object must contain a `name` string parameter (the actual name used in the template) and an optional `isRequired` boolean flag.
    If a `required` parameter is not found in provided context, the execution will stop with an error.
- `replacements`: an array of `replacements` associated to current item. See `Replacement` for more informations.
- `plugins`: an object where the key represents the name of a pre-installed plugin, and its object counterpart is strictly plugin-dependent. See `Plugin` section for more informations.

Example:

  ```json
  { 
    "name": "viewController",
    "paths": [{ 
    "from": "ViewController.template.swift",
    "to": "Sources/ViewControllers/{{ name|firstUppercase}}/{{ name|firstUppercase }}ViewController.swift"
   }],
    "replacements": [],
    "parameters": [
      {
        "name": "name",
        "isRequired": true
      }
    ],
    "plugins": {
      "xcode": { "targets": ["App"] }
    }
   }
  ```

## BoneProcedure

A **Procedure** is a sequence of items resolved and installed in target project across a single execution. The procedure is identified by the `name` parameter.

## BonePackage

A **Package** is a group of items and procedures that can be shipped through git or zips and reused across different projects.
It should contain a json file representing it's structure (default name: `BonePackage.json`) and any number of folders including Items.
`BonePackage.json` fields are: 

- `name`: a name identifying the package. 
- `description`: a description string explaining the package's main purpose. Will be printed by CLI commands
- `procedures`: an array of **BoneProcedure** objects.

Example:

```json
{
  "description" : "A package for quick MVVM scaffolding.",
  "procedures" : [
    {
      "items" : [
        "viewModel\/BoneItem.json",
        "viewController\/BoneItem.json",
        "model\/BoneItem.json"
      ],
      "description" : "Creates an group of Model, ViewController and ViewModel",
      "name" : "section"
    }
  ],
  "name" : "MVVM"
}

```

## Murrayfile

The Murrayfile is located in the root folder in `Murrayfile.json` file and contains basic setup for bones (relative paths to BoneSpecs) and environment context.
`Murrayfile.json` fields are: 

- `packages`: an array of paths relative to Murrayfile folder pointing to a `BonePackage.json` file
- `environment`: an object representing a shared context for each resolution. Can contain simple data such `author` name, `packageName` and similar, or more complex array/objects that will be handled by templates.

Example: 

```json
{
  "packages" : [
    "Murray/MVC/BonePackage.json"
  ],
  "environment" : {
    "author": "Stefano Mondino",
    "company": "Synesthesia",
    "target": "App"
  }
}
```

## SkeletonSpec

The `Skeletonspec.json` file contains informations needed by the skeleton phase of a project to be converted in an actual project.
It's deleted after proper project creation as it won't be needed anymore.

Example (for non-xcode users: `Skeleton.xcodeproj` is actually a folder.): 

```json
{
        "scripts": [
        "sh install.sh"
        ],
        "initGit": true,
        "folders" : [{
            "from": "Skeleton.xcodeproj",
            "to": "{{ name|firstUppercase }}.xcodeproj"
        }],
        "files": [
        {
            "from": "Test.swift",
            "to": "{{ name|firstUppercase }}.swift"
        }]
}
```

## Template resolution

The conversion of a template into a proper project file, by replacing every placeholder with context values.
Templates follows [Stencil](https://github.com/stencilproject/Stencil) syntax and rules

## Context

A key-value map/dictionary containing value that will be replaced in templates during resolution.
Context is made of **environment** values (static values) and execution values explicitly derived from CLI commands.
Example: in an Android application, an environmnent value can be the main `packageName` used by the app, while an execution value can be the `name` of the activity being created.
Environment values are set inside the `Murrayfile.json` file, in the `environment` json field. In templates, just use the same key used in the Murrayfile.

## Replacements

Replacements are special strings or file templates that won't create a new file when resolved, but will append their contents in a specific part of some already-existing file.
Replacements are declared at Item level, and should be used with normal templates to ensure that project will still be "valid" after an execution.

Example: in Android development, developers can declare an `Activity` to create a new screen of the app. Creating a template for an Activity is surely a great fit for Murray, but Android requires every new Activity to be declared in a common xml file (the `AndroidManifest.xml`). By placing a template file inside the Item (with the xml node syntax) and a comment inside the XML, Murray can look for the placeholder, replace it with the template string and add back the placeholder again.

## Available filters

Murray provides custom filters for Stencil templates:

- `firstUppercase` and `firstLowercase` are useful for class names and variable names in code templates: you can input some generic name like `product` and convert it into `Product` when it should be used in class names or viceversa.
- `snakeCase` is useful to convert camelcase words into snake case. Example: `thisIsAWord` becomes  `this_is_a_word`

Filters can be chained: 
```
{{ name | snakeCase | uppercase }}
```
converts name from `thisIsAWord` into `THIS_IS_A_WORD`

## Plugins

A `Plugin` is composed by custom code that may be executed in a specific moment during the pipeline.
For example, a specific item may need some bash command to be executed every time a resolution happened (== after a group of file templates have been resolved and copied to final destination folder).

A common use case, for iOS/Xcode projects, is having a new file creted by a bone item to be automatically added to proper .xcodeproj structure and target.

Other platforms may need some custom code to be executed to clean/rebuild the entire project, depending on how the programming language/framework is designed.

Murray currently defines two custom plugins: XCode and Shell

### XCode Plugin

The XCode plugin is executed if the `plugins` node in an item contains a `xcode` object with a `targets` array of targets names.
Example in a specific BoneItem.json: 

```json
"plugins": {
    "xcode": {
        "targets": ["MyApp", "MyAppTVOS"]
    }
}
```

In the above example, every bone Item created by the execution will add created files to the "MyApp" target and the "MyAppTVOS" target. 

### Shell Plugin

The Shell plugin will execute shell commands before and/or after each item creation

Allowed parameters:
`beforeItem`: array of shell commands (strings) that will be executed right before a single item resolution
`afterItem`: array of shell commands (strings) that will be executed right after an item has been resolved and copied to destination

> Shell commands will be executed from the project root folder. 

Example: 

```json
plugins: {
    "shell": {
        "beforeItem": ["echo Hello", "ls -la"],
        "afterItem": ["make project"]
    }
}
```


# CLI - Usage

Murray exposes a simple Command Line Interface.
Every command can be run with `--help` flag for descriptive help and with `--verbose` to display more output and debug purposes.

By running 

```bash
$ murray
```

you get a list of macrocommands: `skeleton`, `bone` and `scaffold`

## Skeleton

A set of commands to interact with skeletons

- `new` - Create a new skeleton app by cloning any remote repository with a `Skeletonspec.json` file in its root folder. This command will clone your remote repository/copy your local repository in a subfolder of current folder with provided name.
Command will fail if subfolder is already existing or if provided repository does not contain a `Skeletonspec.json`.

```bash
$ murray skeleton new YourCustomProjectName git@github.com:stefanomondino/somerepo@develop
```
```bash
$ murray skeleton new AnotherCustomProjectName ../SkeletonFolder@develop
```

## Bone

A set of commands to interact with bones

All `bone` subcommands must be run from your project root folder. Such folder should also contain a valid `Murrayfile.json`

- `clone` - Clones a remote repository containing a bone Package. You should specify the `git` address (remote or local) to clone the package from, and an optional local subfolder to clone it into (defaults to `.murray` hidden folder).

```bash
$ murray bone clone ../SomeLocalPackageGitFolder@master MurrayBones
```

- `list` - Prints out every available `procedure` by flatting available packages. 

```bash
$ murray bone list
```

- `new` - Executes an available procedure. Requires a `name` parameter (the procedure `name`, as printed out from `murray bone list`), a `mainPlaceholder` value (the `name` parameter in context). 
Optional parameters are `--context` (a valid JSON string containing the context).
By providing the  `--` , you can add a variadic list of strings at the end of the command that will be used inside templates in additions to provided name and environment values from Murrayfile.
Each string must be a key-value pair separated by a colon, example `"author:stefano mondino"`.

```bash
$ murray bone new viewModel Product -- "company:Synesthesia" "author:stefano mondino"
```
The example above will resolve templates by replacing `name` with `Product`, `company` with `Synesthesia` and `author` with `stefano mondino`.

## Scaffold

A set of commands to create Murray structures from scratch.

All `scaffold` subcommands must be run from your project root folder. Such folder should also contain a valid `Murrayfile.json` (with the exceptions of `murrayfile` and `skeleton` commands).

- `murrayfile`: creates a new empty `Murrayfile.json` 

```bash
$ murray scaffold murrayfile
```

- `skeleton`: creates a new empty `Skeletonspec.json` 

```bash
$ murray scaffold skeleton
```

- `package`: creates a new Package named `name` in specified local `path` and adds it to current Murrayfile. An optional `--description` string parameter may be provided to describe the new Package in list commands.
```bash
$ murray scaffold package MVC ./MurrayBones --description "A package to manage MVC in iOS applications"
```

- `item`: creates a new Item inside a Package. Requires a `package` parameter that must match an existing package in project folder, a `name` used to uniquely identify the item inside the package and a list of file names that will be use to generate empty files for your templates.
Note: created items will **NOT** added to any procedure. See `scaffold procedure` for that.
```bash
$ murray scaffold item MVC ViewController "ViewController.template.swift" "ViewController.template.xib"
```
```bash
$ murray scaffold item MVC Model "Model.template.swift"
```

- `procedure`: creates inside a `package` a new procedure identified by `name` by adding provided list of `items`. If target package already contains a procedure with provided name, the items will be added to the existing one. An optional `--description` option may be provided to better describe the procedure in lists.
```bash
$ murray scaffold procedure MVC screen ViewController Model --description "Creates a new screen in the app with a ViewController class and xib and a Model"
```


# FAQ

#### I'm a Swift developer. Why shoud I use this instead of Sourcery?
---------------
[Sourcery](https://github.com/krzysztofzablocki/Sourcery) is a great software that somehow handles templates as well, but is meant to handle only Swift code and project by actually *compiling* templates in different scenarios.
Murray doesn't compile or interpret your code, it doesn't even know what programming language you're actually using. It's aimed to project's structure and boilerplate reuse across projects through git repos

#### Why Murray? Who is Murray?
---------------
  Because we're dealing with Skeleton apps and Bones and we miss Monkey Island a lot! :) We hope this tool is not as much annoying as its original counterpart!

#### Who's behind Murray?
------------
![Syn](https://synesthesia.it/wp-content/themes/synesthesia/dist/img/syn_sm.png)

**Murray** is entirely developed and open-sourced by [Synesthesia](https://www.synesthesia.it)

We're currently using it for **iOS** and **Android** projects.
