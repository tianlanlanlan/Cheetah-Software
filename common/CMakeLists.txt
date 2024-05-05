# Source/Include files
include_directories(".")
include_directories("include/") # common includes
include_directories("/usr/local/include/") # lcm includes
include_directories("../lcm-types/cpp/")
include_directories("../third-party/inih") # inih includes
include_directories("../third-party/osqp/include") # osqp includes
include_directories("../third-party/ParamHandler")
include_directories("FootstepPlanner")
include_directories(${CMAKE_BINARY_DIR})
include_directories(${PROJECT_SOURCE_DIR})
file(GLOB_RECURSE sources "src/*.cpp") # common library cpp files

# Library
add_library(biomimetics SHARED ${sources}) # produce a library used by sim/robot
target_link_libraries(biomimetics glog::glog inih dynacore_param_handler JCQP osqp)

if(CMAKE_SYSTEM_NAME MATCHES Linux)
    # Pull in Google Test
    include(CTest)

    # Test
    find_package(GTest REQUIRED)
    file(GLOB_RECURSE test_sources "test/test_*.cpp") # test cpp files
    add_executable(test-common ${test_sources})
    target_link_libraries(test-common
        gtest::gtest Eigen3::Eigen
        lcm rt inih osqp dynacore_param_handler pthread biomimetics
        Goldfarb_Optimizer JCQP
    )

    add_test(NAME example_test COMMAND test-common)
endif(CMAKE_SYSTEM_NAME MATCHES Linux)

# Our libraries
add_subdirectory(FootstepPlanner)
