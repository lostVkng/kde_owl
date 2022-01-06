import QtQuick 2.8
import QtGraphicalEffects 1.0

import "components"


Item {
    signal needClose()
    signal needShutdown()
    signal needRestart()
    signal needSuspend()

    property alias shutdown: shutdownButton

    Row {
        spacing: 70
        height: 150        
        anchors.centerIn: parent

        Item {
            width: 100
            height: 150

            ImgButton {
                id: shutdownButton
                width: 75
                height: 75
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                normalImg: "icons/general/shutdown.svg"
                onClicked: needShutdown()
                KeyNavigation.right: restartButton
                KeyNavigation.left: suspendButton
                Keys.onEscapePressed: needClose()
            }

            Text {
                text: qsTr("Shutdown")
                font.pointSize: 15
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
            }
        }

        Item {
            width: 100
            height: 150

            ImgButton {
                id: restartButton
                width: 75
                height: 75
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                normalImg: "icons/general/reboot.svg"
                onClicked: needRestart()
                KeyNavigation.right: suspendButton
                KeyNavigation.left: shutdownButton
                Keys.onEscapePressed: needClose()
            }

            Text {
                text: qsTr("Reboot")
                font.pointSize: 15
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
            }
        }

        Item {
            width: 100
            height: 150

            ImgButton {
                id: suspendButton
                width: 75
                height: 75
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                normalImg: "icons/general/suspend.svg"
                onClicked: needSuspend()
                KeyNavigation.right: shutdownButton
                KeyNavigation.left: restartButton
                Keys.onEscapePressed: needClose()
            }

            Text {
                text: qsTr("Suspend")
                font.pointSize: 15
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
            }
        }
    }

    MouseArea {
        z: -1
        anchors.fill: parent
        onClicked: needClose()
    }

    Keys.onEscapePressed: needClose()
}
