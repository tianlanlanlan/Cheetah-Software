/*! @file GameController.cpp
 *  @brief Code to read the Logitech F310 Game Controller
 *  Creates a DriverCommand object to be sent to the robot controller
 *  Used in the development simulator and in the robot control mode
 *
 *  NOTE: Because QT is weird, the updateDriverCommand has to be called from a
 * QT event. Running it in another thread will cause it to not work. As a
 * result, this only works if called in the update method of a QTObject
 */

#include "GameController.h"
#include "Utilities/utilities.h"

#include <QtCore/QObject>
#include <QtGamepad/QGamepad>

/*!
 * By default, the game controller selects the "first" joystick, printing a
 * warning if there are multiple joysticks On Linux, this is /dev/input/js0 If
 * no joystick is found, it will print an error message, and will return zero.
 * It is possible to change/add a joystick later with findNewController
 */
GameController::GameController(QObject *parent) : QObject(parent) {
  findNewController();
}

/*!
 * Re-run the joystick finding code to select the "first" joystick. This can be
 * used to set up the joystick if the simulator is started without a joystick
 * plugged in
 */
void GameController::findNewController() {
  delete _qGamepad;
  _qGamepad = nullptr;  // in case this doesn't work!

  LOG(INFO) << "[Gamepad] Searching for gamepads, please ignore \"Device "
               "discovery cannot open device\" errors";
  auto gamepadList = QGamepadManager::instance()->connectedGamepads();
  LOG(INFO) << "[Gamepad] Done searching for gamepads.";
  if (gamepadList.empty()) {
    LOG(ERROR)
        << "[ERROR: GameController] No controller was connected! All joystick "
           "commands will be zero!";
  } else {
    if (gamepadList.size() > 1) {
      LOG(INFO) << "[ERROR: GameController] There are " << gamepadList.size()
                << " joysticks connected.  Using "
                   "the first one.";
    } else {
      LOG(INFO) << "[GameController] Found 1 joystick";
    }

    _qGamepad = new QGamepad(*gamepadList.begin());
  }
}

/*!
 * Overwrite a driverCommand with the current joystick state.  If there's no
 * joystick, sends zeros
 * TODO: what happens if the joystick is unplugged?
 */
void GameController::updateGamepadCommand(GamepadCommand &gamepadCommand) {
  if (_qGamepad) {
    gamepadCommand.leftBumper = _qGamepad->buttonL1();
    gamepadCommand.rightBumper = _qGamepad->buttonR1();
    gamepadCommand.leftTriggerButton = _qGamepad->buttonL2() != 0.;
    gamepadCommand.rightTriggerButton = _qGamepad->buttonR2() != 0.;
    gamepadCommand.back = _qGamepad->buttonSelect();
    gamepadCommand.start = _qGamepad->buttonStart();
    gamepadCommand.a = _qGamepad->buttonA();
    gamepadCommand.b = _qGamepad->buttonB();
    gamepadCommand.x = _qGamepad->buttonX();
    gamepadCommand.y = _qGamepad->buttonY();
    gamepadCommand.leftStickButton = _qGamepad->buttonL3();
    gamepadCommand.rightStickButton = _qGamepad->buttonR3();
    gamepadCommand.leftTriggerAnalog = (float)_qGamepad->buttonL2();
    gamepadCommand.rightTriggerAnalog = (float)_qGamepad->buttonR2();
    gamepadCommand.leftStickAnalog =
        Vec2<float>(_qGamepad->axisLeftX(), -_qGamepad->axisLeftY());
    gamepadCommand.rightStickAnalog =
        Vec2<float>(_qGamepad->axisRightX(), -_qGamepad->axisRightY());
  } else {
    gamepadCommand.zero();  // no joystick, return all zeros
    gamepadCommand.leftStickAnalog = Vec2<float>(-0.0f, 0.5f); // Move front
  }

  // printf("%s\n", gamepadCommand.toString().c_str());
}

GameController::~GameController() { delete _qGamepad; }