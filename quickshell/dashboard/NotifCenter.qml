import "./."
import "../services"
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    property bool shown: false

    function show(): void   { root.shown = true  }
    function hide(): void   { root.shown = false }
    function toggle(): void { root.shown = !root.shown }

    IpcHandler {
        target: "notifs"
        function show(): void         { root.show() }
        function hide(): void         { root.hide() }
        function toggle(): void       { root.toggle() }
        function toggleDnd(): void    { Notifications.toggleDnd() }
        function clear(): void        { Notifications.clearAll() }
        function isDndEnabled(): bool { return Notifications.dnd }
    }

    PanelWindow {
        id: overlay
        screen: Shell.activeScreen
        visible: root.shown || slideAnim.running
        color: "transparent"

        anchors { top: true; left: true; right: true; bottom: true }
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: -1
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        MouseArea {
            anchors.fill: parent; z: -1
            onClicked: root.hide()
        }

        property real slideY: root.shown ? 56 : -(panel.height + 60)
        Behavior on slideY {
            NumberAnimation { id: slideAnim; duration: 240; easing.type: Easing.OutCubic }
        }

        Rectangle {
            id: panel
            y: overlay.slideY
            width: 480
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 14
            color: Theme.panelBg
            border.color: Theme.cyanBorder
            border.width: 1
            implicitHeight: col.implicitHeight + 16

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                id: col
                anchors { top: parent.top; topMargin: 14; left: parent.left; leftMargin: 8; right: parent.right; rightMargin: 8 }
                spacing: 8

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 4
                    spacing: 8

                    Text {
                        text: "NOTIFICATIONS"
                        font.pixelSize: 10; font.family: Theme.font; font.weight: Font.Bold; font.letterSpacing: 1.5
                        color: Theme.textDimmer
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        height: 24; radius: 6
                        implicitWidth: dndRow.implicitWidth + 12
                        color: Notifications.dnd ? Qt.rgba(1, 0.67, 0, 0.18) : Theme.moduleBg
                        border.color: Notifications.dnd ? Qt.rgba(1, 0.67, 0, 0.4) : "transparent"
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Row {
                            id: dndRow
                            anchors.centerIn: parent
                            spacing: 4
                            Text {
                                text: Notifications.dnd ? "󰂛" : "󰂚"
                                font.pixelSize: 13; font.family: Theme.iconFont
                                color: Notifications.dnd ? Theme.orange : Theme.textMuted
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: "DnD"
                                font.pixelSize: 11; font.family: Theme.font
                                color: Notifications.dnd ? Theme.orange : Theme.textMuted
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Notifications.toggleDnd()
                        }
                    }

                    Rectangle {
                        height: 24; radius: 6
                        implicitWidth: clearLabel.implicitWidth + 12
                        color: clearMa.containsMouse ? Theme.hoverBg : Theme.moduleBg
                        Behavior on color { ColorAnimation { duration: 100 } }
                        visible: Notifications.listModel.count > 0

                        Text {
                            id: clearLabel
                            anchors.centerIn: parent
                            text: "Clear"
                            font.pixelSize: 11; font.family: Theme.font
                            color: Theme.textMuted
                        }
                        MouseArea {
                            id: clearMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Notifications.clearAll()
                        }
                    }
                }

                // Empty state
                Column {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    Layout.bottomMargin: 8
                    spacing: 6
                    visible: Notifications.listModel.count === 0

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰂜"
                        font.pixelSize: 28; font.family: Theme.iconFont
                        color: Theme.textInactive
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "No notifications"
                        font.pixelSize: 12; font.family: Theme.font
                        color: Theme.textInactive
                    }
                }

                // Notification list
                Item {
                    id: listArea
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(notifCol.implicitHeight, 520)
                    visible: Notifications.listModel.count > 0
                    clip: true

                    Flickable {
                        anchors.fill: parent
                        contentHeight: notifCol.implicitHeight
                        clip: true

                        Column {
                            id: notifCol
                            width: listArea.width
                            spacing: 4

                            Repeater {
                                model: Notifications.listModel

                                delegate: Rectangle {
                                    required property var notif

                                    width: notifCol.width
                                    radius: 10
                                    color: Theme.cardBg
                                    border.color: {
                                        if (!notif || !notif.notifRef) return Theme.cardBorder
                                        return notif.notifRef.urgency === 2 ? Qt.rgba(1, 0.3, 0.3, 0.35) : Theme.cardBorder
                                    }
                                    border.width: 1
                                    implicitHeight: notifContent.implicitHeight + 20

                                    ColumnLayout {
                                        id: notifContent
                                        anchors { top: parent.top; topMargin: 10; left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12 }
                                        spacing: 3

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 6

                                            IconImage {
                                                implicitSize: 14
                                                source: { const i = notif?.notifRef?.appIcon ?? ""; return i.startsWith("/") ? "file://" + i : i }
                                                visible: source !== ""
                                            }
                                            Text {
                                                Layout.fillWidth: true
                                                text: notif?.notifRef?.appName ?? ""
                                                font.pixelSize: 10; font.family: Theme.font
                                                color: Theme.textDim
                                                elide: Text.ElideRight
                                            }
                                            Text {
                                                text: notif ? Qt.formatTime(notif.timestamp, "hh:mm") : ""
                                                font.pixelSize: 10; font.family: Theme.font
                                                color: Theme.textDimmer
                                            }
                                            Text {
                                                text: "×"
                                                font.pixelSize: 14; font.family: Theme.font
                                                color: Theme.textDim
                                                MouseArea {
                                                    anchors.fill: parent; anchors.margins: -4
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: notif.dismiss()
                                                }
                                            }
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: notif?.notifRef?.summary ?? ""
                                            font.pixelSize: 12; font.family: Theme.font; font.weight: Font.Medium
                                            color: Theme.textPrimary
                                            elide: Text.ElideRight
                                            visible: text !== ""
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: notif?.notifRef?.body ?? ""
                                            font.pixelSize: 11; font.family: Theme.font
                                            color: Theme.textMuted
                                            wrapMode: Text.WordWrap
                                            maximumLineCount: 3
                                            elide: Text.ElideRight
                                            visible: text !== ""
                                        }

                                        Row {
                                            spacing: 6
                                            visible: notif && notif.actionData && notif.actionData.length > 0

                                            Repeater {
                                                model: notif ? notif.actionData : []
                                                delegate: Rectangle {
                                                    required property var modelData
                                                    height: 24; radius: 5
                                                    implicitWidth: actLabel.implicitWidth + 14
                                                    color: actMa.containsMouse ? Theme.hoverBg : Theme.moduleBg
                                                    Behavior on color { ColorAnimation { duration: 100 } }

                                                    Text {
                                                        id: actLabel
                                                        anchors.centerIn: parent
                                                        text: modelData.text ?? ""
                                                        font.pixelSize: 10; font.family: Theme.font
                                                        color: Theme.cyan
                                                    }
                                                    MouseArea {
                                                        id: actMa
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: notif.invokeAction(modelData.id ?? "")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Keys.onEscapePressed: root.hide()
    }
}
