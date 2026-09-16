import QtQml
import Quickshell
import Quickshell.Wayland

QtObject {
  id: root

  enum State {
    Locked,
    Authenticating,
    Error,
    Unlocked
  }

  readonly property int state: _state
  readonly property string errorMessage: authenticator.errorMessage
  readonly property bool secure: sessionLock.secure

  property int _state: LockContext.State.Locked

  property PamAuthenticator authenticator: PamAuthenticator {
    onAuthenticated: {
      root._state = LockContext.State.Unlocked
    }

    onFailed: {
      root._state = LockContext.State.Error
    }
  }

  property WlSessionLock sessionLock: WlSessionLock {
    locked: root.state !== LockContext.State.Unlocked

    surface: Component {
      LockSurface {
        state: root.state
        errorMessage: root.errorMessage
        secure: root.secure

        onSubmit: password => {
          root.authenticate(password)
        }
      }
    }
  }

  function authenticate(password) {
    if (!root.secure)
    return

    if (root.state === LockContext.State.Authenticating ||
    root.state === LockContext.State.Unlocked) {
      return
    }

    root._state = LockContext.State.Authenticating

    if (!authenticator.authenticate(password))
    root._state = LockContext.State.Error
  }
}
