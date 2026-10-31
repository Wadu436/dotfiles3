pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Notification daemon. Every notification is kept in history (the server's
// tracked list) until dismissed; `popups` is the queue of ones still to be
// shown as toasts in the island.
Singleton {
    id: root

    property bool dnd: false
    property list<Notification> popups: []

    readonly property list<Notification> history: server.trackedNotifications.values
    readonly property int count: history.length

    // Notification has no timestamp, so remember arrival times by id.
    property var received: ({})

    function age(n: Notification, now: date): string {
        const s = Math.floor((now - (received[n.id] ?? now)) / 1000);
        if (s < 60)
            return "now";
        if (s < 3600)
            return Math.floor(s / 60) + "m";
        if (s < 86400)
            return Math.floor(s / 3600) + "h";
        return Math.floor(s / 86400) + "d";
    }

    function dropPopup(n: Notification): void {
        popups = popups.filter(p => p !== n);
    }

    function clearAll(): void {
        // dismiss() removes from the tracked list, so iterate a copy
        for (const n of [...history])
            n.dismiss();
        popups = [];
    }

    function timeout(n: Notification): int {
        if (n.urgency === NotificationUrgency.Critical)
            return 0;
        if (n.urgency === NotificationUrgency.Low)
            return 4000;
        return 8000;
    }

    NotificationServer {
        id: server

        keepOnReload: true
        actionsSupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: n => {
            n.tracked = true;
            root.received[n.id] = Date.now();
            n.closed.connect(() => root.dropPopup(n));
            if (!root.dnd || n.urgency === NotificationUrgency.Critical)
                root.popups = [...root.popups, n];
        }
    }
}
