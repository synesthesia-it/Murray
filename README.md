# Murray

Murray is a CLI written in Swift for skeleton-based software development.

A *skeleton*-based software is generated from a pre-defined structure, usually a fixed set of folders and files that can be compiled and launch out of the box (like the classic `HelloWorld` project).

This kind of software is usually expanded through boilerplate files (*Bones*) that share common *structure* code (class initialization, methods of interfaces that always needs to be implemented, unit test files, etc...)

## Key Features

- Clone a *skeleton* project from a remote repository, customize it with your project name and properties and have it ready to run
- Develop your project with *bones*: template files *you* design that gets easily installed in your structure

# Installation

## Using *[Mint](https://github.com/yonaskolb/mint)*
```
mint install synesthesia-it/Murray
```

## Compiling from source

To compile and install murray, run
```
curl -fsSL https://raw.githubusercontent.com/synesthesia-it/Murray/master/install.sh | sh
```

# Usage

Create a new skeleton app (defaults to [Skeleton](https://github.com/synesthesia-it/Skeleton) )
After proper cloning and, the app's bundle is installed if a Gemfile is available

```
$ murray skeleton new CoolApp
```


Next commands should all be used inside your freshly created project's directory.
(example: `~/XCodeProjects/CoolApp`)

**Warning**

Remember to set your project's schemes to *shared* if you plan to use Fastlane or similar tools

You should create a Bonefile, containg one or more remote repositories with your Bones.
A bone is a set of file templates described by a Bonespec.json
Example:

```
bone "https://github.com/synesthesia-it/Bone"
```

You can then setup your project with

```
$ murray bone install
```

Install a Bone into your current project
In this case, a `viewSection` is created by replacing placeholders inside the template file with `Product`

```
$ murray bone new viewSection Product
```

List all templates available for current project
```
$ murray bone list
```

# Skeletons and Skeletonspec.json
-- TODO

# Bones and Bonespec.json
-- TODO

### Why Murray?

Because we're dealing with Skeleton apps and Bones and we really miss Monkey Island a lot! :)
