pragma Singleton 

import Quickshell
import Quickshell.Io

Singleton {
    // property alias 
    property alias appearance: adapter.appearance

    FileView {
        path: Qt.resolvedUrl("../shell.json")
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: adapter

            property AppearanceConfig appearance: AppearanceConfig {}
        }
    }
}