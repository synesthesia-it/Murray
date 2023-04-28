# Murray Demo - Basic SwiftUI example

This project contains a super-basic xcode project with an iOS app made with SwiftUI.

The app only contains an empty `TabView` intended to be used with MVVM pattern (`ObservableObject`)

Goal: Use Murray CLI to quickly scaffold your empty views.

## Pre-requisites
Have 🌱 *[Mint](https://github.com/yonaskolb/mint)* installed on your machine.

Install Murray with `murray install synesthesia-it/murray`

Project was tested with Xcode 14.3. 

## Setup

Just run 
```console
make setup
``` 
the first time you checkout this project.

SwiftFormat and SwiftLint will be installed and used later on by Murray scripts

## Steps

Open the xcodeproj and run the app. You can also check SwiftUI previews and see if they are working.

Run the test target as well - it's empty (for now).

Let's assume you want to add a screen to the tab view, like a `Products` screen with a list of product.

Murray has been setup (in `Murray` folder + `Murrayfile.yml`) to create a View with a ViewModel that will be automatically included in your main tab. How? run
```console
murray run scene Products
```
and double check your xcode project.

You will find:
- a `ProductsView` containing a super basic SwiftUI view (with preview) tied to a single view model
- a `ProductsViewModel` ObservableObject, exposing (for now) a simple `title` property (uppercased)
- a `ProductsViewModelTests` file in the tests folder, checking that your title is uppercased
- the `MainTabViewModel` will expose a `productsViewModel` variable to it's own view
- the `MainTabView` will include the `ProductsView`
- all the new files added to their respective targets
- the entire project linted with SwiftFormat and SwiftLint (with default set of rules for both of them)

As bonus, if you did setup your git properly, you should automatically find a file header (first line with comments) containing your git name and current year.

For more informations, check Murray documentation