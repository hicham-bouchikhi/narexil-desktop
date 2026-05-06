pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    // var arrays for service logic (expiry checks, clearAll)
    property var list: []
    property var popups: []

    // ListModels for UI — fire incremental signals so Repeater only touches changed delegates
    ListModel { id: notifListModel }
    ListModel { id: popupListModel }

    readonly property ListModel listModel: notifListModel
    readonly property ListModel popupModel: popupListModel

    component Notif: QtObject {
        required property var notifRef
        property bool popup: true
        property date timestamp: new Date()
        property var actionData: []

        readonly property real expiry: {
            const u = notifRef?.urgency ?? 1
            if (u === 2) return 0
            return timestamp.getTime() + (u === 0 ? 3000 : 5000)
        }

        function dismiss(): void {
            notifRef?.dismiss()
            for (let i = 0; i < notifListModel.count; i++) {
                if (notifListModel.get(i).notif === this) { notifListModel.remove(i); break }
            }
            for (let i = 0; i < popupListModel.count; i++) {
                if (popupListModel.get(i).notif === this) { popupListModel.remove(i); break }
            }
            root.list = root.list.filter(n => n !== this)
            root.popups = root.popups.filter(n => n !== this)
            destroy()
        }

        function invokeAction(id: string): void {
            const acts = notifRef?.actions ?? []
            for (let i = 0; i < acts.length; i++) {
                if (acts[i].identifier === id) { acts[i].invoke(); break }
            }
            dismiss()
        }
    }

    // Timer checks popup expiry — iterates backwards so removal doesn't shift indices
    Timer {
        interval: 500
        repeat: true
        running: popupListModel.count > 0
        onTriggered: {
            const now = Date.now()
            for (let i = popupListModel.count - 1; i >= 0; i--) {
                const n = popupListModel.get(i).notif
                if (!n || n.expiry === 0) continue
                if (now >= n.expiry) {
                    n.popup = false
                    popupListModel.remove(i)
                    root.popups = root.popups.filter(x => x !== n)
                }
            }
        }
    }

    Component { id: notifComp; Notif {} }

    NotificationServer {
        keepOnReload: true
        actionsSupported: true

        onNotification: notif => {
            if (props.dnd && notif.urgency !== NotificationUrgency.Critical) return
            const acts = []
            for (let i = 0; i < notif.actions.length; i++)
                acts.push({ id: notif.actions[i].identifier, text: notif.actions[i].text })
            const obj = notifComp.createObject(root, { notifRef: notif, actionData: acts })
            notifListModel.insert(0, { notif: obj })
            root.list = [obj, ...root.list]
            if (popupListModel.count < 5) popupListModel.insert(0, { notif: obj })
            root.popups = [obj, ...root.popups].slice(0, 5)
        }
    }

    PersistentProperties {
        id: props
        reloadableId: "notifs"
        property bool dnd: false
    }

    readonly property bool dnd: props.dnd
    function toggleDnd(): void { props.dnd = !props.dnd }
    function clearAll(): void {
        for (const n of root.list.slice()) n.dismiss()
    }
}
