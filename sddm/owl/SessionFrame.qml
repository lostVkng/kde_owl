import QtQuick 2.8
import QtGraphicalEffects 1.0

import "components"


Item {
    id: frame
    signal selected(var index)
    signal needClose()

    readonly property int m_viewMaxWidth: frame.width - prevSession.width - nextSession.width - 230;
    property bool shouldShowBG: false
    property var sessionTypeList: ["awesome","bspwm","deepin","dwm","fluxbox","gnome","i3","kbd","lxqt","plasma","ubuntu","windows","xfce"]
    property alias currentItem: sessionList.currentItem

    function getIconName(sessionName) {
        for (var item in sessionTypeList) {
            var str = sessionTypeList[item]
            var index = sessionName.toLowerCase().indexOf(str)
            if (index >= 0) {
                return str
            }
        }

        return "linux"
    }

    function getCurrentSessionIconIndicator() {
        return sessionList.currentItem.iconIndicator;
    }

    function isMultipleSessions() {
        return sessionList.count > 1
    }

    onOpacityChanged: {
        shouldShowBG = false
    }

    onFocusChanged: {
        // Active by mouse click
        if (focus) {
            sessionList.currentItem.focus = false
        }
    }

    ImgButton {
        id: prevSession
        visible: sessionList.childrenRect.width > m_viewMaxWidth
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 10
        normalImg: "icons/general/angle-left.png"
        onClicked: {
            sessionList.decrementCurrentIndex()
            shouldShowBG = true
        }
    }

    ListView {
        id: sessionList
        anchors.centerIn: parent
        width:  childrenRect.width > m_viewMaxWidth ? m_viewMaxWidth : childrenRect.width
        height: 150
        clip: true
        model: sessionModel
        currentIndex: sessionModel.lastIndex
        orientation: ListView.Horizontal
        spacing: 10
        delegate: Rectangle {
            property string iconIndicator: iconButton.indicator
            property bool activeBG: sessionList.currentIndex === index && shouldShowBG

            border.width: 3
            border.color: activeBG || focus ? "#33ffffff" : "transparent"
            radius: 8
            color: activeBG || focus ? "#55000000" : "transparent"

            width: 230
            height: 150

            ImgButton {
                id: iconButton
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: 100
                height: 100
                normalImg: ("%1.svg").arg(prefix)

                property var prefix: ("icons/session/%1").arg(getIconName(name));
                property var indicator: ("icons/session/%1.svg").arg(getIconName(name));

                onClicked: {
                    selected(index)
                    sessionList.currentIndex = index
                }
            }

            Text {
                width: parent.width
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                text: name
                font.pointSize: 15
                color: "white"
                wrapMode: Text.WordWrap
            }

            Keys.onLeftPressed: {
                sessionList.decrementCurrentIndex()
                sessionList.currentItem.forceActiveFocus()
            }
            Keys.onRightPressed: {
                sessionList.incrementCurrentIndex()
                sessionList.currentItem.forceActiveFocus()
            }
            Keys.onEscapePressed: needClose()
            Keys.onEnterPressed: {
                selected(index)
                sessionList.currentIndex = index
            }
            Keys.onReturnPressed: {
                selected(index)
                sessionList.currentIndex = index
            }
        }
    }

    ImgButton {
        id: nextSession
        visible: sessionList.childrenRect.width > m_viewMaxWidth
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 10
        normalImg: "icons/general/angle-right.png"
        onClicked: {
            sessionList.incrementCurrentIndex()
            shouldShowBG = true
        }
    }

    MouseArea {
        z: -1
        anchors.fill: parent
        onClicked: needClose()
    }

    Keys.onEscapePressed: needClose()
}
