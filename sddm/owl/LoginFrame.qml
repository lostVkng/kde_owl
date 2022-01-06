import QtQuick 2.8
import QtGraphicalEffects 1.0

import "components"

Item {
    id: frame
    property int sessionIndex: sessionModel.lastIndex
    property string userName: userModel.lastUser
    property alias input: passwdInput
    property alias button: loginButton

    property alias notificationMessage: notifyMessage.text

    Connections {
        target: sddm
        onLoginSucceeded: {
            Qt.quit()
        }
    }

    Item {
        id: loginItem
        anchors.centerIn: parent
        width: parent.width
        height: parent.height

        // User Avatar
        UserAvatar {
            id: userIconRec
            anchors {
                top: parent.top
                topMargin: parent.height / 4
                horizontalCenter: parent.horizontalCenter
            }
            width: 130
            height: 130
            source: userFrame.currentIconPath
            onClicked: {
                root.state = "stateUser"
                userFrame.focus = true
            }
        }

        // Username
        Text {
            id: userNameText
            anchors {
                top: userIconRec.bottom
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }

            text: userName
            color: textColor
            font.pointSize: 20
        }

        // Password Field
        Rectangle {
            id: passwdInputRec
            visible: true
            anchors {
                top: userNameText.bottom
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
            width: 260
            height: 35
            radius: 3
            color: "#55000000"

            TextInput {
                id: passwdInput
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8 + 36
                clip: true
                focus: true
                color: textColor
                font.pointSize: 10
                selectByMouse: true
                selectionColor: "#a8d6ec"
                echoMode: TextInput.Password
                verticalAlignment: TextInput.AlignVCenter
                onFocusChanged: {
                    if (focus) {
                        color = textColor
                        echoMode = TextInput.Password
                        text = ""
                    }
                }
                onAccepted: {
                    sddm.login(userNameText.text, passwdInput.text, sessionIndex)
                }
                KeyNavigation.backtab: {
                    if (sessionButton.visible) {
                        return sessionButton
                    }
                    else if (userButton.visible) {
                        return userButton
                    }
                    else {
                        return shutdownButton
                    }
                }
                KeyNavigation.tab: loginButton
                Timer {
                    interval: 200
                    running: true
                    onTriggered: passwdInput.forceActiveFocus()
                }
            }
            ImgButton {
                id: loginButton
                height: passwdInput.height
                width: height
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }

                normalImg: "icons/general/login_normal.png"
                onClicked: {
                    sddm.login(userNameText.text, passwdInput.text, sessionIndex)
                }
                KeyNavigation.tab: shutdownButton
                KeyNavigation.backtab: passwdInput
            }
        }
        Text {
            id: notifyMessage
            anchors {
                top: passwdInputRec.bottom
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
            color: textColor
            font.pointSize: 20
            text: notificationMessage
        }
    }
}
