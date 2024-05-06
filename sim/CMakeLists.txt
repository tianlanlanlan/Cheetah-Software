cmake_minimum_required(VERSION 3.5)
project(sim)

SET(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt5 REQUIRED)
find_package(FreeGLUT REQUIRED)

# Instruct CMake to run moc automatically when needed
set(CMAKE_AUTOMOC ON)
# Create code from a list of Qt designer ui files
set(CMAKE_AUTOUIC ON)
get_target_property(QtCore_location Qt5::Core LOCATION)
message(STATUS ${QtCore_location})

set(QOBJECT_HEADERS
        include/Graphics3D.h
        include/GameController.h
        include/SimControlPanel.h
        include/JoystickTest.h)
#        include/main_window.h
#        include/gamepad_monitor.h
#        include/spi_debug.h)

QT5_WRAP_CPP(tst_hdr_moc ${QOBJECT_HEADERS})

include_directories("include/")
include_directories("../common/include/")
include_directories("../lcm-types/cpp")
include_directories("../third-party/ParamHandler")
include_directories(${CMAKE_BINARY_DIR})
file(GLOB sources "src/*.cpp")

# OpenGL
set(OpenGL_GL_PREFERENCE LEGACY)
find_package(OpenGL REQUIRED)
include_directories(${OPENGL_INCLUDE_DIR})
message(STATUS "OPENGL_LIBRARIES: ${OPENGL_LIBRARIES}")

add_executable(sim ${sources} ${tst_hdr_moc})
target_link_libraries(sim
  biomimetics lcm inih dynacore_param_handler
  # Qt5::Widgets Qt5::Core Qt5::Gui Qt5::Gamepad
  FreeGLUT::freeglut
  qt::qt
  ${OPENGL_LIBRARIES}
  pthread
)

if (CMAKE_SYSTEM_NAME MATCHES Linux)
  target_link_libraries(sim rt ${GLUT_glut_LIBRARIES})
  include (CheckIncludeFileCXX)
endif (CMAKE_SYSTEM_NAME MATCHES Linux)

if (APPLE)
  target_link_libraries(sim "-framework GLUT")
endif (APPLE)


