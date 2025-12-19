# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

include(FetchContent)

FetchContent_Declare(
    Corrosion
    GIT_REPOSITORY https://github.com/corrosion-rs/corrosion.git
    GIT_TAG v0.5.2
)
FetchContent_MakeAvailable(Corrosion)

project(flutter_playsuipi_library VERSION 1.1.0 LANGUAGES C)

corrosion_import_crate(MANIFEST_PATH ../core/Cargo.toml)

add_library(flutter_playsuipi SHARED
  "flutter_playsuipi.c"
)

set_target_properties(flutter_playsuipi PROPERTIES
  PUBLIC_HEADER flutter_playsuipi.c
  OUTPUT_NAME "flutter_playsuipi"
)

target_compile_definitions(flutter_playsuipi PUBLIC DART_SHARED_LIB)

target_link_libraries(flutter_playsuipi PUBLIC playsuipi_core)

if (ANDROID)
  # Support Android 15 16k page size
  target_link_options(flutter_playsuipi PRIVATE "-Wl,-z,max-page-size=16384")
endif()
