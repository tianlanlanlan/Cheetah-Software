include_directories("./")
include_directories("./Controllers")
include_directories("../../robot/include")
include_directories("../../common/include/")
include_directories("../../common/FootstepPlanner")
include_directories("../../third-party/")
include_directories(SYSTEM "../../third-party/qpOASES/include")
include_directories("../../third-party/ParamHandler")

include_directories("../../lcm-types/cpp")
include_directories(${CMAKE_BINARY_DIR})
include_directories(${PROJECT_SOURCE_DIR})

file(GLOB_RECURSE sources
  "./*.cpp"
  "FSM_States/*.cpp"
  "Controllers/BalanceController/*.cpp"
  "Controllers/convexMPC/*.cpp")

add_subdirectory(Controllers/WBC)
add_subdirectory(Controllers/WBC_Ctrl)
add_subdirectory(Controllers/VisionMPC)

find_package(glog REQUIRED)
add_executable(mit_ctrl ${sources} MIT_Controller.cpp main.cpp)
target_link_libraries(mit_ctrl
  robot biomimetics
  dynacore_param_handler qpOASES
  Goldfarb_Optimizer osqp
  WBC_Ctrl
  VisionMPC
  Eigen3::Eigen
  glog::glog
)
