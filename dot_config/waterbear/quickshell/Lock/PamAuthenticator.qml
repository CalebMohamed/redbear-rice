import QtQml
import Quickshell.Services.Pam

QtObject {
  id: root

  readonly property bool active: pam.active
  readonly property string errorMessage: _errorMessage

  property string _password: ""
  property string _errorMessage: ""

  signal authenticated()
  signal failed()

  property PamContext pam: PamContext {
    configDirectory: "/etc/pam.d"
    config: "quickshell-lock"

    onPamMessage: {
      if (responseRequired)
      respond(root._password)
    }

    onCompleted: result => {
      root._password = ""

      if (result === PamResult.Success) {
        root._errorMessage = ""
        root.authenticated()
      } else {
        root._errorMessage = "Authentication failed"
        root.failed()
      }
    }

    onError: {
      root._password = ""
      root._errorMessage = "Authentication error"
      root.failed()
    }
  }

  function authenticate(password) {
    if (pam.active)
    return false

    root._password = password
    root._errorMessage = ""

    return pam.start()
  }
}
