# ares-deps

ares-deps is a group of build scripts for precompiling and packaging dependencies for [ares](https://github.com/ares-emulator/ares) on macOS and Windows. ares-deps also pre-packages certain non-library resources for Linux.

ares-deps is designed to be pulled in at configure/generation time when building ares, such that any necessary libraries and data can be included and linked appropriately, and finally packaged correctly in the app bundle or rundir as appropriate.

## Running

If you need to compile ares-deps locally, run `./build_deps.sh <config>`, providing either `<Debug|Release|RelWithDebInfo|MinSizeRel>` for the configuration.

## Dependency specifics

Dependency build functions are provided in a `<dependency>` file in the `deps.macos`, `deps.windows`, or `deps.linux` directory as appropriate. These files should define the following functions that will build and package the dependency:

* `<dependency>_setup()`: This function should clone the repository, checkout a specific commit, and perform any other setup required to build, such as mapping build configurations if necessary.
* `<dependency>_patch()`: This function should apply any necessary patches to the code prior to building.
* `<dependency>_build()`: This function should build the library in the provided configuration.

The above three functions are called from within the `build_temp` working directory.

* `<dependency>_install()`: This function should copy build products to the final output directory. The product directory is named `ares-deps` and should be treated as a prefix; that is, it will contain `lib`, `share`, `include`, etc. directories per Unix-like prefix structures.
  * The `lib` folder should contain all .dylibs or .dlls for the library, as well as all debug symbol files.
  * The `include/<dependency>/` directory should contain any necessary header files for the library.
  * Data dependencies go into the `share` folder.
  * Any relevant licenses for the library should be placed in the `licenses/<dependency>/` directory and named appropriately.
  
This last function is called from the base directory of this repository.
