# Murray

Murray is a set of tools for Skeleton base software development.

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

Different templates can be rendered sequentially by a single execution, leading to a standardized way of software developmen

## Key Features

- Clone a **skeleton** project from a remote repository, customize it with your project name and custom properties and have it ready to run. Murray supports **tags** and **branches** for remote repositories (`@develop` or `@1.0.0`)

- Develop your project with **bones**: template files you design that gets easily integrated in your project structure. If a adding a screen to your app requires 3 new files, you can design them with a template and have Murray resolve them for you and move the result in proper folders.

- Install bones templates from any number of different repositories: share your file templates with your team.

- Automatically add slices of code to already existing files when adding new bones (*example: Add a custom xml tag for your new Activity at the end of the Android manifest.xml when creating an Activity from a custom bone*).

- Easily manage and check your bones environment: see what's available directly from CLI

- Design your **bones** with **[Stencil](https://github.com/stencilproject/Stencil)**

- Integrate Murray functionalities in any Swift application through **MurrayKit** framework

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

## Key Concepts

#### `Skeleton`

A skeleton is an empty project, containing any type of file and folder.
The Skeleton is a shared starting point for a new project, and should not contain any bone template; in other words, the project should work out of the box as a real project.
To be compatible with Murray, a Skeleton project must contain a `Skeletonspec.json` file in its root folder.

#### `Bone`

A Bone is a piece of boilerplate code splitted into one or more template files. 
A template file is usually NOT working out of the box, but needs to be *resolved* against some kind of context, and then copied into proper folder.

#### `BoneItem`

A BoneItem represents a group of template files that can be resolved and copied into current project.
BoneItems consist in a folder containing a `BoneItem.json` file and any number of template files.


#### `BoneGroup`

A BoneGroup represents a group of BoneItems identified by a key. Such key is used by the CLI to identify the items during an execution.
BoneGroups are simple json objects contained in BoneSpecs, defined by a `name` key and an array of relative paths to BoneItems.

#### `BoneSpec`

A BoneSpec represents a group of templates that can be distributed as a package.
Consists in a folder containing a `BoneSpec.json` file and any number of BoneItem folders.

#### `Murrayfile`

The Murrayfile is located in the root folder in `Murrayfile.json` file and contains basic setup for bones (relative paths to BoneSpecs) and environment context.

#### `SkeletonSpec`

The `Skeletonspec.json` file contains informations needed by the skeleton phase of a project to be converted in an actual project.
It's deleted after proper project creation as it won't be needed anymore.















## Project structure

Murray project is a collection of Swift Packages:

- **MurrayKit**: features all the core features so that they can be included in any Swift Software
- **MurrayCLI**: it's a wrapper for commands (from command line interface). It wraps strings into actual MurrayKit objects and function calls, and defines the actual text commands used by `murray` (and relative documentation)
- **`murray`**: is the actual executable installed on your system. It's a basically empty application that only creates a `Menu` object from MurrayCLI



## Working Demo

A very simple Murray project for iOS can be found [here](https://github.com/stefanomondino/MurrayDemo)

You can automatically generate a project (named *MurrayProject* in this example) from this template by running 

```
murray skeleton new MurrayProject https://github.com/stefanomondino/MurrayDemo@master
```

**Important**: please be sure to have Cocoapods v1.6.1 or higher installed on your system (thanks @bellots).



# Usage

- Create a new skeleton app by cloning any remote repository with a `Skeletonspec.json` file in its root folder.

```
$ murray skeleton new CoolApp <your_remote_repo>
```

Next commands should all be used inside your freshly created project's directory.
(remind to `cd CoolApp` ;) )


Your Skeleton project must declare a `Skeletonspec.json` file in its root folder, containing a list of remote repositories containing **Bones**. 

Example:
```javascript
...
 remoteBones: ["https://github.com/synesthesia-it/Bones@develop"],
 ...
```

If you want to add Bones features to an already existing project, just create a `Skeletonspec.json` file in your root folder by using `murray skeleton scaffold` and edit it by adding one or more Bones repositories.

- Setup your project with

```
$ murray bone setup
```

This will clone all bones repositories in a local folder. You can update them by calling same command again.


- Install a Bone template into your current project

```
$ murray bone new viewSection Product
```

In this particular case, a `viewSection` bone is created in your project by copying all source file related to `viewSection` (one or more, depending on what you wrote in the `Bonespec.json`) by renaming each file replacing the bone placeholder with Product and by parsing internal text contents through Stencil.
See the [Bones](https://github.com/synesthesia-it/Murray/wiki) wiki page for more details.


- List all templates available for current project
```
$ murray bone list
```

# Documentation

See [Wiki](https://github.com/synesthesia-it/Murray/wiki) pages

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
