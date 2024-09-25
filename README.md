# ares-deps

ares-deps is a group of build scripts for precompiling and packaging dependencies for [ares](https://github.com/ares-emulator/ares) on macOS and Windows.

ares-deps is designed to be pulled in at configure/generation time when building ares, such that any necessary libraries can be pulled in for any build configuration, included and linked appropriately, and finally packaged correctly in the app bundle or rundir as appropriate.

## Running

If you need to compile ares-deps locally, run `./build_deps.sh <config>`, providing either `debug`, `release`, or `optimized` for the config argument.

## Dependency specifics

Dependency build functions are provided in a `<dependency>` file in the `deps.macos` or `deps.windows` directory as appropriate. These files should define the following functions that will build and package the dependency:

* `<dependency>_setup()`: This function should clone the repository, checkout a specific commit, and perform any other setup required to build, such as mapping build configurations if necessary.
* `<dependency>_patch()`: This function should apply any necessary patches to the code prior to building.
* `<dependency>_build()`: This function should build the library in the provided configuration.
* `<dependency>_install()`: This function should copy build products to the final output directories. The product directory takes the form `ares-deps-$os-$arch-$config` depending on environment and build configuration. Within the build output directory:
  * The `lib` folder should contain all .dylibs or .dlls for the library, as well as all debug symbol files if necessary.
  * The `include/<dependency>/` directory should contain any necessary header files for the library.
  * Any relevant licenses for the library should be placed in the `licenses/` directory and named appropriately.
