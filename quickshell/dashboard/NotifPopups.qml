import "../services"
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Scope {
    PanelWindow {
        id: popupWindow
        screen: {
            for (let i = 0; i < Quickshell.screens.length; i++)
                if (Quickshell.screens[i].name === "DP-1") return Quickshell.screens[i]
            return Quickshell.screens[0] ?? null
        }

        anchors { top: true; right: true }
        implicitWidth: 372
        implicitHeight: Notifications.popupModel.count > 0 ? toastCol.y + toastCol.implicitHeight + 16 : 1

        color: "transparent"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.exclusiveZone: 0
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        visible: Notifications.popupModel.count > 0

        Column {
            id: toastCol
            x: 8
            y: 56
            opacity: Notifications.popupModel.count > 0 ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }
            width: 356
            spacing: 6

            Repeater {
                model: Notifications.popupModel

                delegate: Rectangle {
                    required property var notif

                    width: toastCol.width
                    radius: 12
                    color: Theme.panelBg
                    border.color: {
                        if (!notif || !notif.notifRef) return Theme.cardBorder
                        return notif.notifRef.urgency === 2 ? Qt.rgba(1, 0.3, 0.3, 0.5) : Theme.cyanBorder
                    }
                    border.width: 1
                    implicitHeight: inner.implicitHeight + 20

                    ColumnLayout {
                        id: inner
                        anchors { top: parent.top; topMargin: 10; left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12 }
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            IconImage {
                                implicitSize: 16
                                source: { const i = notif?.notifRef?.appIcon ?? ""; return i.startsWith("/") ? "file://" + i : i }
                                visible: source !== ""
                            }
                            Text {
                                Layout.fillWidth: true
                                text: notif?.notifRef?.appName ?? ""
                                font.pixelSize: 11; font.family: Theme.font
                                color: Theme.textMuted
                                elide: Text.ElideRight
                            }
                            Text {
                                text: "×"
                                font.pixelSize: 16; font.family: Theme.font
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
                            font.pixelSize: 13; font.family: Theme.font; font.weight: Font.Medium
                            color: Theme.textPrimary
                            elide: Text.ElideRight
                            visible: text !== ""
                        }

                        Text {
                            Layout.fillWidth: true
                            text: notif?.notifRef?.body ?? ""
                            font.pixelSize: 12; font.family: Theme.font
                            color: Theme.textMuted
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            visible: text !== ""
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 120
                            radius: 6
                            clip: true
                            color: "transparent"
                            visible: thumbImg.source !== ""

                            Image {
                                id: thumbImg
                                anchors.fill: parent
                                source: {
                                    const icon = notif?.notifRef?.appIcon ?? ""
                                    if (/\.(png|jpg|jpeg|webp)$/i.test(icon)) return "file://" + icon
                                    return ""
                                }
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    const icon = notif?.notifRef?.appIcon ?? ""
                                    if (icon) Qt.openUrlExternally("file://" + icon)
                                }
                            }
                        }

                        Row {
                            spacing: 6
                            visible: notif && notif.actionData && notif.actionData.length > 0

                            Repeater {
                                model: notif ? notif.actionData : []
                                delegate: Rectangle {
                                    required property var modelData
                                    height: 26; radius: 6
                                    implicitWidth: actionLabel.implicitWidth + 16
                                    color: actionMa.containsMouse ? Theme.hoverBg : Theme.moduleBg
                                    Behavior on color { ColorAnimation { duration: 100 } }

                                    Text {
                                        id: actionLabel
                                        anchors.centerIn: parent
                                        text: modelData.text ?? ""
                                        font.pixelSize: 11; font.family: Theme.font
                                        color: Theme.cyan
                                    }
                                    MouseArea {
                                        id: actionMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (modelData.id.startsWith("open-file:"))
                                                Qt.openUrlExternally("file://" + modelData.id.slice(10))
                                            notif.invokeAction(modelData.id ?? "")
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
