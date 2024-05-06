from conan import ConanFile
from conan.tools import CppInfo
from conan.tools.files import copy
from conan.tools.cmake import CMake, CMakeToolchain, CMakeDeps, cmake_layout
import os

required_conan_version = ">=2.0"


class Cheetah(ConanFile):
    name = "Cheetah"
    version = "1.0.0"
    settings = "os", "compiler", "build_type", "arch"

    def build_requirements(self):
        self.tool_requires("cmake/3.24.4")

    def requirements(self):
        self.requires("glog/0.7.0")
        self.requires("gtest/1.14.0")
        self.requires("eigen/3.4.0")
        self.requires("qt/5.15.13")
        self.requires("freeglut/3.4.0")
        self.requires("xkbcommon/1.5.0", override=True)

    def generate(self):
        tc = CMakeToolchain(self)
        tc.generate()
        deps = CMakeDeps(self)
        deps.generate()

        self.print_dependencies()
        # self.copy_shared_libs()

    def config_options(self):
        self.options["qt"].qtgamepad = True
        self.options["qt"].with_harfbuzz = False
        self.options["qt"].with_mysql = False
        self.options["qt"].with_pq = False
        self.options["qt"].with_odbc = False
        self.options["qt"].with_sqlite3 = False

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def layout(self):
        # save conan generated file to {self.build_folder}/conan
        self.folders.generators = "conan"

    def print_dependencies(self):
        for require, dependency in self.dependencies.items():
            direct = require.direct
            ref = str(dependency.ref)
            try:
                build_type = str(dependency.settings.build_type)
            except:
                build_type = "None"
            cpp_libs = str(dependency.cpp_info.libs)
            libs = [component.libs for component_name,
                    component in dependency.cpp_info.components.items()]
            self.output.info(
                f"Dep_direct={direct}: {ref:20} {build_type:10} {cpp_libs:10} {libs}"
            )

    def copy_shared_libs(self):
        dst_dir = f"{self.build_folder}/bin"
        for dep in self.dependencies.values():
            try:
                src_dir = dep.cpp_info.libdirs[0]
                copy(self, "*.so*", src_dir, dst_dir)
            except:
                continue
