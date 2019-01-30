# Murray

Murray is a CLI written in Swift for skeleton-based software development.

**Skeleton-based** software usually consists of code generated through lots of boilerplate that can't be abstracted and re-used through clever architecture.

For instance, a classic HTML website always consists of pages with same `head` and `body`, filled with custom data in repeating structures.

**Murray** purpose is to standardize any development pipeline in order to speed-up development, reduce unsafe copy-pasting from/to different projects and eventually give order in codebases  without focusing on a single development platform.

## Key Features

- Clone a **skeleton** project from a remote repository, customize it with your project name and custom properties and have it ready to run

- Develop your project with **bones**: template files *you* design that gets easily integrated in your project structure

- Install bones templates from any number of different repositories: share your file templates with your team.

- Easily manage and check your bones environment: see what's available directly from CLI

- Design your **bones** with **[Stencil](https://github.com/stencilproject/Stencil)**

- Integrate Murray functionalities in any Swift application through **MurrayKit** framework

# Quick examples

Single-file template in Swift for iOS named `listViewController` in file BonesViewController (placeholder keyword in filename is `Bone`):

```swift
import UIKit
class {{ name|firstUppercase }}sViewController: UIViewController {

  // Not quite sure what this empty {{ name }} array should do in a real project , but it's here anyway to show how you can self-document your code with comments.
  let {{ name|firstLowercase }}s: [{{ name|firstUppercase }}] = []

  func viewDidLoad() {
    super.viewDidLoad()
  }
}

```
from terminal, execute
```
murray bone new listViewController Product
```

resulting in file `ProductsViewController` with contents:

```swift
import UIKit
class ProductsViewController: UIViewController {

  // Not quite sure what this empty Product array should do in a real project , but it's here anyway to show how you can self-document your code with comments.
  let products: [Product] = []

  func viewDidLoad() {
    super.viewDidLoad()
  }
}

```

automatically moved to predefined custom folder and also installed in XCode project.

See [Wiki](https://github.com/synesthesia-it/Murray/wiki) for more examples.



# Installation

## MacOS

#### Using *[Mint](https://github.com/yonaskolb/mint)*
```
mint install synesthesia-it/Murray
```

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

# Usage

Create a new skeleton app by cloning any remote repository with a `Skeletonspec.json` file in its root folder.

```
$ murray skeleton new CoolApp --git <your_remote_repo>
```

Next commands should all be used inside your freshly created project's directory.
(remind to `cd CoolApp` ;) )


Create a Bonefile, containg one or more remote repositories with your Bones.

Example:
```
bone "https://github.com/synesthesia-it/Bone"
```

A bone is a set of file templates described by a `Bonespec.json`

Setup your project with

```
$ murray bone setup
```

Install a Bone into your current project

```
$ murray bone new viewSection Product
```

In this particular case, a `viewSection` bone is created in your project by copying all source file related to `viewSection` (one or more, depending on what you wrote in the `Bonespec.json`) by renaming each file replacing the bone placeholder with Product and by parsing internal text contents through Stencil.
See the [Bones](https://github.com/synesthesia-it/Murray/wiki) wiki page for more details.


List all templates available for current project
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
