import QtQuick
import Quickshell
import Quickshell.Io

// Headless service: run the session restore once when the shell starts.
// The restore script locks and consumes its manifest, so a shell restart
// or a parallel post-boot hook run is a safe no-op.
Item {
  id: root

  readonly property string pluginDir: Qt.resolvedUrl(".").toString().replace("file://", "")

  Process {
    id: restoreProc
    command: ["bash", root.pluginDir + "bin/omarchy-session-restore"]
  }

  Component.onCompleted: restoreProc.running = true
}
