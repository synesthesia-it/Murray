//
//  Utilities+Mocks.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 13/01/2020.
//

import Foundation
import Files

import MurrayKit

public struct Mocks {
    
    public struct Murrayfile {
        
        public static func simple(specPath: String = "Murray/Simple/Simple.json") -> String {
            return  """
                {
                    "environment": {
                        "author": "Stefano Mondino"
                    },
                    "specPaths": ["\(specPath)"]
                }
                """
        }
    }
    
    public struct BoneSpec {
        public static var simple: String {
            return """
                {
                    "name": "simple",
                    "description": "Simple bone spec for testing purposes",
                    "groups": [\(Mocks.BoneGroup.simple)]
                }
            """
        }
        public static func singleGroup(named name: String, items:[String]) -> String {
            return """
                {
                    "name": "singleGroup",
                    "description": "Simple bone spec for testing purposes",
            "groups": [\(Mocks.BoneGroup.group(named: name, items: items))]
                }
            """
        }
    }
    
    public struct BoneGroup {
        public static func group(named name: String, items: [String] ) -> String {
            return """
                    {
                        "name": "\(name)",
                        "description": "custom description",
                        "items": \(items.map{"\($0.firstUppercased())/\($0.firstUppercased()).json"})
                    }
                    """
        }
        public static var simple: String {

            return  """
                {
                    "name": "simpleGroup",
                    "description": "custom description",
                    "items": ["SimpleItem/SimpleItem.json"]
                }
            """
        }
    }
    
    public struct BoneItem {
        public static let placeholderFileContents = "This is a test\n\(placeholder)\n\nEnjoy"
        public static let placeholder = "//Murray Placeholder"
        public static let placeholderFilePath = "Sources/Files/Default/Test.swift"
        public static let placeholderFilePath2 = "Sources/Files/Default/Test2.swift"
        public static var simple: String { """
               {
                   "name": "simpleItem",
                    "description": "custom description",
                   "paths": [
                       { "from": "Bone.swift",
                         "to": "Sources/Files/{{ name }}/{{ name }}.swift"
                       }
                   ],
                   "replacements": [
                        {
                            "text": "{{ name }}",
                            "placeholder": "\(placeholder)",
                            "destination": "\(placeholderFilePath)"
                        },
                        {
                            "text": "{{ name }}",
                            "source": "Replacement.swift",
                            "placeholder": "\(placeholder)",
                            "destination": "\(placeholderFilePath2)"
                        }
                    ],
                    "plugins": {
                        "xcode": {
                                "targets": ["App"]
                            }
                    },
                   "parameters": [
                       {
                       "name": "name",
                       "isRequired": true
                       },
                       {
                       "name": "type"
                       }
                   ]
               }
               """
        }
        public static func customBone(named name: String) -> String { """
            {
                "name": "\(name)",
            
                "description": "custom description",
                "paths": [
                    { "from": "Bone.swift",
                        "to": "Sources/Files/\(name.firstUppercased())/{{name|firstUppercase}}.swift"
                    },
                    { "from": "Bone.xib",
                      "to": "Sources/Files/\(name.firstUppercased())/{{name|firstUppercase}}.xib"
                    }
                ],
                "plugins": {
                    "xcode": {
                            "targets": ["App"]
                        }
                },
                "parameters": [
                    {
                    "name": "name",
                    "isRequired": true
                    },
                    {
                    "name": "type"
                    }
                ]
            }
            """ }
    }
}

public extension Mocks {
    struct Scenario {
        public static func simple(from root: Folder) throws {
            
            let xcode = try root.createSubfolderIfNeeded(at: "Test.xcodeproj")
            try xcode.createFileIfNeeded(at: "project.pbxproj").write(testPBX)
            let murrayFile = ConcreteFile(contents: Mocks.Murrayfile.simple(), folder: root, path: BonePath(from: "Murrayfile.json", to: ""))
            murrayFile.createSource()
            
            let boneSpec = ConcreteFile(contents: Mocks.BoneSpec.simple, folder: root, path: BonePath(from: "Murray/Simple/Simple.json", to: ""))
            boneSpec.createSource()
            
            let simpleItem = ConcreteFile(contents: Mocks.BoneItem.simple, folder: root, path: BonePath(from: "Murray/Simple/SimpleItem/SimpleItem.json", to: ""))
            simpleItem.createSource()
            
            let simpleFile = ConcreteFile(contents: "{{name}}Test", folder: root, path: BonePath(from: "Murray/Simple/SimpleItem/Bone.swift", to: ""))
            simpleFile.createSource()
            
            let replacementFile = ConcreteFile(contents: Mocks.BoneItem.placeholderFileContents, folder: root, path: BonePath(from: Mocks.BoneItem.placeholderFilePath, to: ""))
            replacementFile.createSource()
            let replacementFile2 = ConcreteFile(contents: Mocks.BoneItem.placeholderFileContents, folder: root, path: BonePath(from: Mocks.BoneItem.placeholderFilePath2, to: ""))
            replacementFile2.createSource()
            
            let templateFile = ConcreteFile(contents: "testing {{ name }} in place\n", folder: root, path: BonePath(from: "Murray/Simple/SimpleItem/Replacement.swift", to: ""))
            templateFile.createSource()
        }
        
        
        public static func multipleItemsSingleGroup(names: [String], from root: Folder) throws {
            let xcode = try root.createSubfolderIfNeeded(at: "Test.xcodeproj")
            try xcode.createFileIfNeeded(at: "project.pbxproj").write(testPBX)
            let specPath = "Murray/SingleGroup/SingleGroup.json"
            let murrayFile = ConcreteFile(contents: Mocks.Murrayfile.simple(specPath: specPath), folder: root, path: BonePath(from: "Murrayfile.json", to: ""))
            murrayFile.createSource()
            
            let boneSpec = ConcreteFile(contents: Mocks.BoneSpec.singleGroup(named: "singleGroup", items: names), folder: root, path: BonePath(from: specPath, to: ""))
            boneSpec.createSource()
            
            
            
            names.forEach { name in
                let simpleItem = ConcreteFile(contents: Mocks.BoneItem.customBone(named: name), folder: root, path: BonePath(from: "Murray/SingleGroup/\(name.firstUppercased())/\(name.firstUppercased()).json", to: ""))
                           simpleItem.createSource()
                           
                ConcreteFile(contents: "{{name}}Test - {{ author }}", folder: root, path: BonePath(from: "Murray/SingleGroup/\(name.firstUppercased())/Bone.swift", to: "output/{{name}}.swift")).createSource()
                ConcreteFile(contents: "{{name}}Test", folder: root, path: BonePath(from: "Murray/SingleGroup/\(name.firstUppercased())/Bone.xib", to: "output/{{name}}.swift")).createSource()
            }
            let replacementFile = ConcreteFile(contents: Mocks.BoneItem.placeholderFileContents, folder: root, path: BonePath(from: Mocks.BoneItem.placeholderFilePath, to: ""))
            replacementFile.createSource()
           
        }
    }
}



extension Mocks.Scenario {
    static var testPBX: String {
    """
        // !$*UTF8*$!
        {
            archiveVersion = 1;
            classes = {
            };
            objectVersion = 50;
            objects = {

        /* Begin PBXBuildFile section */
                7097276323D7415000A5A857 /* App.h in Headers */ = {isa = PBXBuildFile; fileRef = 7097276123D7415000A5A857 /* App.h */; settings = {ATTRIBUTES = (Public, ); }; };
        /* End PBXBuildFile section */

        /* Begin PBXFileReference section */
                7097275E23D7415000A5A857 /* App.framework */ = {isa = PBXFileReference; explicitFileType = wrapper.framework; includeInIndex = 0; path = App.framework; sourceTree = BUILT_PRODUCTS_DIR; };
                7097276123D7415000A5A857 /* App.h */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.h; path = App.h; sourceTree = "<group>"; };
                7097276223D7415000A5A857 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
        /* End PBXFileReference section */

        /* Begin PBXFrameworksBuildPhase section */
                7097275B23D7415000A5A857 /* Frameworks */ = {
                    isa = PBXFrameworksBuildPhase;
                    buildActionMask = 2147483647;
                    files = (
                    );
                    runOnlyForDeploymentPostprocessing = 0;
                };
        /* End PBXFrameworksBuildPhase section */

        /* Begin PBXGroup section */
                7097275223D7411000A5A857 = {
                    isa = PBXGroup;
                    children = (
                        7097276023D7415000A5A857 /* App */,
                        7097275F23D7415000A5A857 /* Products */,
                    );
                    sourceTree = "<group>";
                };
                7097275F23D7415000A5A857 /* Products */ = {
                    isa = PBXGroup;
                    children = (
                        7097275E23D7415000A5A857 /* App.framework */,
                    );
                    name = Products;
                    sourceTree = "<group>";
                };
                7097276023D7415000A5A857 /* App */ = {
                    isa = PBXGroup;
                    children = (
                        7097276123D7415000A5A857 /* App.h */,
                        7097276223D7415000A5A857 /* Info.plist */,
                    );
                    path = App;
                    sourceTree = "<group>";
                };
        /* End PBXGroup section */

        /* Begin PBXHeadersBuildPhase section */
                7097275923D7415000A5A857 /* Headers */ = {
                    isa = PBXHeadersBuildPhase;
                    buildActionMask = 2147483647;
                    files = (
                        7097276323D7415000A5A857 /* App.h in Headers */,
                    );
                    runOnlyForDeploymentPostprocessing = 0;
                };
        /* End PBXHeadersBuildPhase section */

        /* Begin PBXNativeTarget section */
                7097275D23D7415000A5A857 /* App */ = {
                    isa = PBXNativeTarget;
                    buildConfigurationList = 7097276623D7415000A5A857 /* Build configuration list for PBXNativeTarget "App" */;
                    buildPhases = (
                        7097275923D7415000A5A857 /* Headers */,
                        7097275A23D7415000A5A857 /* Sources */,
                        7097275B23D7415000A5A857 /* Frameworks */,
                        7097275C23D7415000A5A857 /* Resources */,
                    );
                    buildRules = (
                    );
                    dependencies = (
                    );
                    name = App;
                    productName = App;
                    productReference = 7097275E23D7415000A5A857 /* App.framework */;
                    productType = "com.apple.product-type.framework";
                };
        /* End PBXNativeTarget section */

        /* Begin PBXProject section */
                7097275323D7411000A5A857 /* Project object */ = {
                    isa = PBXProject;
                    attributes = {
                        LastUpgradeCheck = 1130;
                        TargetAttributes = {
                            7097275D23D7415000A5A857 = {
                                CreatedOnToolsVersion = 11.3.1;
                            };
                        };
                    };
                    buildConfigurationList = 7097275623D7411000A5A857 /* Build configuration list for PBXProject "Test" */;
                    compatibilityVersion = "Xcode 9.3";
                    developmentRegion = en;
                    hasScannedForEncodings = 0;
                    knownRegions = (
                        en,
                        Base,
                    );
                    mainGroup = 7097275223D7411000A5A857;
                    productRefGroup = 7097275F23D7415000A5A857 /* Products */;
                    projectDirPath = "";
                    projectRoot = "";
                    targets = (
                        7097275D23D7415000A5A857 /* App */,
                    );
                };
        /* End PBXProject section */

        /* Begin PBXResourcesBuildPhase section */
                7097275C23D7415000A5A857 /* Resources */ = {
                    isa = PBXResourcesBuildPhase;
                    buildActionMask = 2147483647;
                    files = (
                    );
                    runOnlyForDeploymentPostprocessing = 0;
                };
        /* End PBXResourcesBuildPhase section */

        /* Begin PBXSourcesBuildPhase section */
                7097275A23D7415000A5A857 /* Sources */ = {
                    isa = PBXSourcesBuildPhase;
                    buildActionMask = 2147483647;
                    files = (
                    );
                    runOnlyForDeploymentPostprocessing = 0;
                };
        /* End PBXSourcesBuildPhase section */

        /* Begin XCBuildConfiguration section */
                7097275723D7411000A5A857 /* Debug */ = {
                    isa = XCBuildConfiguration;
                    buildSettings = {
                    };
                    name = Debug;
                };
                7097275823D7411000A5A857 /* Release */ = {
                    isa = XCBuildConfiguration;
                    buildSettings = {
                    };
                    name = Release;
                };
                7097276423D7415000A5A857 /* Debug */ = {
                    isa = XCBuildConfiguration;
                    buildSettings = {
                        ALWAYS_SEARCH_USER_PATHS = NO;
                        CLANG_ANALYZER_NONNULL = YES;
                        CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
                        CLANG_CXX_LANGUAGE_STANDARD = "gnu++14";
                        CLANG_CXX_LIBRARY = "libc++";
                        CLANG_ENABLE_MODULES = YES;
                        CLANG_ENABLE_OBJC_ARC = YES;
                        CLANG_ENABLE_OBJC_WEAK = YES;
                        CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
                        CLANG_WARN_BOOL_CONVERSION = YES;
                        CLANG_WARN_COMMA = YES;
                        CLANG_WARN_CONSTANT_CONVERSION = YES;
                        CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
                        CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
                        CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
                        CLANG_WARN_EMPTY_BODY = YES;
                        CLANG_WARN_ENUM_CONVERSION = YES;
                        CLANG_WARN_INFINITE_RECURSION = YES;
                        CLANG_WARN_INT_CONVERSION = YES;
                        CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
                        CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
                        CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
                        CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
                        CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
                        CLANG_WARN_STRICT_PROTOTYPES = YES;
                        CLANG_WARN_SUSPICIOUS_MOVE = YES;
                        CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
                        CLANG_WARN_UNREACHABLE_CODE = YES;
                        CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
                        CODE_SIGN_STYLE = Automatic;
                        COPY_PHASE_STRIP = NO;
                        CURRENT_PROJECT_VERSION = 1;
                        DEBUG_INFORMATION_FORMAT = dwarf;
                        DEFINES_MODULE = YES;
                        DYLIB_COMPATIBILITY_VERSION = 1;
                        DYLIB_CURRENT_VERSION = 1;
                        DYLIB_INSTALL_NAME_BASE = "@rpath";
                        ENABLE_STRICT_OBJC_MSGSEND = YES;
                        ENABLE_TESTABILITY = YES;
                        GCC_C_LANGUAGE_STANDARD = gnu11;
                        GCC_DYNAMIC_NO_PIC = NO;
                        GCC_NO_COMMON_BLOCKS = YES;
                        GCC_OPTIMIZATION_LEVEL = 0;
                        GCC_PREPROCESSOR_DEFINITIONS = (
                            "DEBUG=1",
                            "$(inherited)",
                        );
                        GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
                        GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
                        GCC_WARN_UNDECLARED_SELECTOR = YES;
                        GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
                        GCC_WARN_UNUSED_FUNCTION = YES;
                        GCC_WARN_UNUSED_VARIABLE = YES;
                        INFOPLIST_FILE = App/Info.plist;
                        INSTALL_PATH = "$(LOCAL_LIBRARY_DIR)/Frameworks";
                        IPHONEOS_DEPLOYMENT_TARGET = 13.2;
                        LD_RUNPATH_SEARCH_PATHS = (
                            "$(inherited)",
                            "@executable_path/Frameworks",
                            "@loader_path/Frameworks",
                        );
                        MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
                        MTL_FAST_MATH = YES;
                        ONLY_ACTIVE_ARCH = YES;
                        PRODUCT_BUNDLE_IDENTIFIER = it.test.App;
                        PRODUCT_NAME = "$(TARGET_NAME:c99extidentifier)";
                        SDKROOT = iphoneos;
                        SKIP_INSTALL = YES;
                        SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
                        SWIFT_OPTIMIZATION_LEVEL = "-Onone";
                        SWIFT_VERSION = 5.0;
                        TARGETED_DEVICE_FAMILY = "1,2";
                        VERSIONING_SYSTEM = "apple-generic";
                        VERSION_INFO_PREFIX = "";
                    };
                    name = Debug;
                };
                7097276523D7415000A5A857 /* Release */ = {
                    isa = XCBuildConfiguration;
                    buildSettings = {
                        ALWAYS_SEARCH_USER_PATHS = NO;
                        CLANG_ANALYZER_NONNULL = YES;
                        CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
                        CLANG_CXX_LANGUAGE_STANDARD = "gnu++14";
                        CLANG_CXX_LIBRARY = "libc++";
                        CLANG_ENABLE_MODULES = YES;
                        CLANG_ENABLE_OBJC_ARC = YES;
                        CLANG_ENABLE_OBJC_WEAK = YES;
                        CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
                        CLANG_WARN_BOOL_CONVERSION = YES;
                        CLANG_WARN_COMMA = YES;
                        CLANG_WARN_CONSTANT_CONVERSION = YES;
                        CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
                        CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
                        CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
                        CLANG_WARN_EMPTY_BODY = YES;
                        CLANG_WARN_ENUM_CONVERSION = YES;
                        CLANG_WARN_INFINITE_RECURSION = YES;
                        CLANG_WARN_INT_CONVERSION = YES;
                        CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
                        CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
                        CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
                        CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
                        CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
                        CLANG_WARN_STRICT_PROTOTYPES = YES;
                        CLANG_WARN_SUSPICIOUS_MOVE = YES;
                        CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
                        CLANG_WARN_UNREACHABLE_CODE = YES;
                        CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
                        CODE_SIGN_STYLE = Automatic;
                        COPY_PHASE_STRIP = NO;
                        CURRENT_PROJECT_VERSION = 1;
                        DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
                        DEFINES_MODULE = YES;
                        DYLIB_COMPATIBILITY_VERSION = 1;
                        DYLIB_CURRENT_VERSION = 1;
                        DYLIB_INSTALL_NAME_BASE = "@rpath";
                        ENABLE_NS_ASSERTIONS = NO;
                        ENABLE_STRICT_OBJC_MSGSEND = YES;
                        GCC_C_LANGUAGE_STANDARD = gnu11;
                        GCC_NO_COMMON_BLOCKS = YES;
                        GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
                        GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
                        GCC_WARN_UNDECLARED_SELECTOR = YES;
                        GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
                        GCC_WARN_UNUSED_FUNCTION = YES;
                        GCC_WARN_UNUSED_VARIABLE = YES;
                        INFOPLIST_FILE = App/Info.plist;
                        INSTALL_PATH = "$(LOCAL_LIBRARY_DIR)/Frameworks";
                        IPHONEOS_DEPLOYMENT_TARGET = 13.2;
                        LD_RUNPATH_SEARCH_PATHS = (
                            "$(inherited)",
                            "@executable_path/Frameworks",
                            "@loader_path/Frameworks",
                        );
                        MTL_ENABLE_DEBUG_INFO = NO;
                        MTL_FAST_MATH = YES;
                        PRODUCT_BUNDLE_IDENTIFIER = it.test.App;
                        PRODUCT_NAME = "$(TARGET_NAME:c99extidentifier)";
                        SDKROOT = iphoneos;
                        SKIP_INSTALL = YES;
                        SWIFT_COMPILATION_MODE = wholemodule;
                        SWIFT_OPTIMIZATION_LEVEL = "-O";
                        SWIFT_VERSION = 5.0;
                        TARGETED_DEVICE_FAMILY = "1,2";
                        VALIDATE_PRODUCT = YES;
                        VERSIONING_SYSTEM = "apple-generic";
                        VERSION_INFO_PREFIX = "";
                    };
                    name = Release;
                };
        /* End XCBuildConfiguration section */

        /* Begin XCConfigurationList section */
                7097275623D7411000A5A857 /* Build configuration list for PBXProject "Test" */ = {
                    isa = XCConfigurationList;
                    buildConfigurations = (
                        7097275723D7411000A5A857 /* Debug */,
                        7097275823D7411000A5A857 /* Release */,
                    );
                    defaultConfigurationIsVisible = 0;
                    defaultConfigurationName = Release;
                };
                7097276623D7415000A5A857 /* Build configuration list for PBXNativeTarget "App" */ = {
                    isa = XCConfigurationList;
                    buildConfigurations = (
                        7097276423D7415000A5A857 /* Debug */,
                        7097276523D7415000A5A857 /* Release */,
                    );
                    defaultConfigurationIsVisible = 0;
                    defaultConfigurationName = Release;
                };
        /* End XCConfigurationList section */
            };
            rootObject = 7097275323D7411000A5A857 /* Project object */;
        }

    """
    }
}
