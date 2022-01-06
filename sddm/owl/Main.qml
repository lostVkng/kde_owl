/* 
    Main qml file - entry point for SDDM
*/

import QtQuick 2.8

import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "components"

PlasmaCore.ColorScope {
    id: root

    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software

    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup

    height: config.ScreenHeight
    width: config.ScreenWidth

    property string notificationMessage

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    state: "stateLogin"
    readonly property int m_powerButtonSize: 30

    PlasmaCore.DataSource {
        id: keystateSource
        engine: "keystate"
        connectedSources: "Caps Lock"
    }

    states: [
        State {
            name: "statePower"
            PropertyChanges { target: loginFrame; opacity: 0}
            PropertyChanges { target: powerFrame; opacity: 1}
            PropertyChanges { target: sessionFrame; opacity: 0}
            PropertyChanges { target: userFrame; opacity: 0}
            PropertyChanges { target: bgBlur; radius: 30}
        },
        State {
            name: "stateSession"
            PropertyChanges { target: loginFrame; opacity: 0}
            PropertyChanges { target: powerFrame; opacity: 0}
            PropertyChanges { target: sessionFrame; opacity: 1}
            PropertyChanges { target: userFrame; opacity: 0}
            PropertyChanges { target: bgBlur; radius: 30}
        },
        State {
            name: "stateUser"
            PropertyChanges { target: loginFrame; opacity: 0}
            PropertyChanges { target: powerFrame; opacity: 0}
            PropertyChanges { target: sessionFrame; opacity: 0}
            PropertyChanges { target: userFrame; opacity: 1}
            PropertyChanges { target: bgBlur; radius: 30}
        },
        State {
            name: "stateLogin"
            PropertyChanges { target: loginFrame; opacity: 1}
            PropertyChanges { target: powerFrame; opacity: 0}
            PropertyChanges { target: sessionFrame; opacity: 0}
            PropertyChanges { target: userFrame; opacity: 0}
            PropertyChanges { target: bgBlur; radius: 0}
        }
    ]


    MouseArea {
        id: loginScreenRoot
        anchors.fill: parent
                
        drag.filterChildren: true

        Keys.onPressed: {
            event.accepted = false;
        }

        // Main Section
        Item {
            id: mainFrame
            property variant geometry: screenModel.geometry(screenModel.primary)
            width: 640
            height: 480
            anchors.fill: parent

            Image {
                id: mainFrameBackground
                anchors.fill: parent
                source: config.background
            }

            FastBlur {
                id: bgBlur
                anchors.fill: mainFrameBackground
                source: mainFrameBackground
                radius: 0
            }

            Item {
                id: centerArea
                width: parent.width
                height: parent.height / 3
                anchors.top: parent.top
                anchors.topMargin: parent.height / 5

                PowerFrame {
                    id: powerFrame
                    anchors.fill: parent
                    enabled: root.state == "statePower"
                    onNeedClose: {
                        root.state = "stateLogin"
                        loginFrame.input.forceActiveFocus()
                    }
                    onNeedShutdown: sddm.powerOff()
                    onNeedRestart: sddm.reboot()
                    onNeedSuspend: sddm.suspend()
                }

                SessionFrame {
                    id: sessionFrame
                    anchors.fill: parent
                    enabled: root.state == "stateSession"
                    onNeedClose: {
                        root.state = "stateLogin"
                        loginFrame.input.forceActiveFocus()
                    }
                    onSelected: {
                        console.log("Selected session:", index)
                        root.state = "stateLogin"
                        loginFrame.sessionIndex = index
                        loginFrame.input.forceActiveFocus()
                    }
                }

                UserFrame {
                    id: userFrame
                    anchors.fill: parent
                    enabled: root.state == "stateUser"
                    onNeedClose: {
                        root.state = "stateLogin"
                        loginFrame.input.forceActiveFocus()
                    }
                    onSelected: {
                        root.state = "stateLogin"
                        loginFrame.userName = userName
                        loginFrame.input.forceActiveFocus()
                    }
                }

                LoginFrame {
                    id: loginFrame
                    anchors.fill: parent
                    enabled: root.state == "stateLogin"
                    opacity: 0
                    transformOrigin: Item.Top
                    notificationMessage: {
                        var text = ""
                        if (keystateSource.data["Caps Lock"]["Locked"]) {
                            text += i18nd("plasma_lookandfeel_org.kde.lookandfeel","Caps Lock is on")
                            if (root.notificationMessage) {
                                text += " • "
                            }
                        }
                        text += root.notificationMessage
                        return text
                    }
                }
            }
        }

        // Menu Area
        Item {
            id: menuArea
            anchors {
                bottom: parent.bottom
                right: parent.right
            }
            width: parent.width / 3
            height: m_powerButtonSize

            Row {
                spacing: 20
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                rightPadding: 10
                bottomPadding: 10

                ImgButton {
                    id: sessionButton
                    width: m_powerButtonSize
                    height: m_powerButtonSize
                    visible: sessionFrame.isMultipleSessions()
                    normalImg: sessionFrame.getCurrentSessionIconIndicator()
                    onClicked: {
                        root.state = "stateSession"
                        sessionFrame.focus = true
                    }
                    onEnterPressed: sessionFrame.currentItem.forceActiveFocus()

                    KeyNavigation.tab: loginFrame.input
                    KeyNavigation.backtab: {
                        if (userButton.visible) {
                            return userButton
                        }
                        else {
                            return shutdownButton
                        }
                    }
                }

                ImgButton {
                    id: userButton
                    width: m_powerButtonSize
                    height: m_powerButtonSize
                    visible: userFrame.isMultipleUsers()

                    normalImg: "icons/general/userswitch_normal.png"
                    onClicked: {
                        console.log("Switch User...")
                        root.state = "stateUser"
                        userFrame.focus = true
                    }
                    onEnterPressed: userFrame.currentItem.forceActiveFocus()
                    KeyNavigation.backtab: shutdownButton
                    KeyNavigation.tab: {
                        if (sessionButton.visible) {
                            return sessionButton
                        }
                        else {
                            return loginFrame.input
                        }
                    }
                }

                ImgButton {
                    id: shutdownButton
                    width: m_powerButtonSize
                    height: m_powerButtonSize
                    visible: true//sddm.canPowerOff

                    normalImg: "icons/general/shutdown.svg"
                    onClicked: {
                        console.log("Show shutdown menu")
                        root.state = "statePower"
                        powerFrame.focus = true
                    }
                    onEnterPressed: powerFrame.shutdown.focus = true
                    KeyNavigation.backtab: loginFrame.button
                    KeyNavigation.tab: {
                        if (userButton.visible) {
                            return userButton
                        }
                        else if (sessionButton.visible) {
                            return sessionButton
                        }
                        else {
                            return loginFrame.input
                        }
                    }
                }
            }
        }

        Loader {
            id: inputPanel
            state: "hidden"
            property bool keyboardActive: item ? item.active : false
            onKeyboardActiveChanged: {
                if (keyboardActive) {
                    state = "visible"
                } else {
                    state = "hidden";
                }
            }
            source: "components/VirtualKeyboard.qml"
            anchors {
                left: parent.left
                right: parent.right
            }

            function showHide() {
                state = state == "hidden" ? "visible" : "hidden";
            }

            states: [
                State {
                    name: "visible"
                    PropertyChanges {
                        target: mainFrame
                        y: Math.min(0, root.height - inputPanel.height - userListComponent.visibleBoundary)
                    }
                    PropertyChanges {
                        target: inputPanel
                        y: root.height - inputPanel.height
                        opacity: 1
                    }
                },
                State {
                    name: "hidden"
                    PropertyChanges {
                        target: mainFrame
                        y: 0
                    }
                    PropertyChanges {
                        target: inputPanel
                        y: root.height - root.height/4
                        opacity: 0
                    }
                }
            ]
            transitions: [
                Transition {
                    from: "hidden"
                    to: "visible"
                    SequentialAnimation {
                        ScriptAction {
                            script: {
                                inputPanel.item.activated = true;
                                Qt.inputMethod.show();
                            }
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                target: mainFrame
                                property: "y"
                                duration: units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: inputPanel
                                property: "y"
                                duration: units.longDuration
                                easing.type: Easing.OutQuad
                            }
                            OpacityAnimator {
                                target: inputPanel
                                duration: units.longDuration
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                },
                Transition {
                    from: "visible"
                    to: "hidden"
                    SequentialAnimation {
                        ParallelAnimation {
                            NumberAnimation {
                                target: mainFrame
                                property: "y"
                                duration: units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: inputPanel
                                property: "y"
                                duration: units.longDuration
                                easing.type: Easing.InQuad
                            }
                            OpacityAnimator {
                                target: inputPanel
                                duration: units.longDuration
                                easing.type: Easing.InQuad
                            }
                        }
                        ScriptAction {
                            script: {
                                Qt.inputMethod.hide();
                            }
                        }
                    }
                }
            ]
        }

        // Separate mouse area in the back to capture non selection clicks
        MouseArea {
            z: -1
            anchors.fill: parent
            onClicked: {
                root.state = "stateLogin"
                loginFrame.input.forceActiveFocus()
            }
        }

    }

    Connections {
        target: sddm
        onLoginFailed: {
            //var text = i18nd("plasma_lookandfeel_org.kde.lookandfeel","Caps Lock is on")
            //loginFrame.notificationMessage = text

            notificationMessage = i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Login Failed")
        }
        onLoginSucceeded: {
            //note SDDM will kill the greeter at some random point after this
            //there is no certainty any transition will finish, it depends on the time it
            //takes to complete the init
            mainFrame.opacity = 0
        }
    }

    onNotificationMessageChanged: {
        if (notificationMessage) {
            notificationResetTimer.start();
        }
    }

    Timer {
        id: notificationResetTimer
        interval: 2000
        onTriggered: notificationMessage = ""
    }
}