# Changelog

## 3.0

Murray has been rewritten from scratch!
We tried to maintain compatibility with the previous structure, however some breaking changes may have occured.

- New configuration file formats now supports YAML and JSON
- MurrayKit completely rewritten in order to be used in graphical applications
- `--preview` option for `murray run` command allows a quick preview about what will be written
- Environment in Murrayfile now supports context resolution
- Dynamic values in contexts now supports current git author, date, time and year and current file path.
  

## 2.2

- Add before and after plugin to BonePaths
- Renamed plugin phases to `before` and `after`

## 2.1

- Shell plugin (#37)
- Recursive resolution of parameters in json strings (#39)
- Bugfix: Absolute url support in Murrayfile packages (#40)
- Bugfix: Bone clone support for repositories with BonePackage.json file in root folder (#41)
- Support for plugin execution before and after each procedure (#44)
- XCodePlugin is now based upon tuist/XcodeProj (written in Swift) rather than Cocoapods/Xcodeproj (written in ruby) (#33)
- Fix folder duplication bug (#34)
- SnakeCase filter (#35)
- Got rid of --param explicit command. (#36)

## 2.0

Completely rewritten version of Murray with new JSON and folder structure. See Readme for more informations.
