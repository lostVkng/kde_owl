import QtQuick 2.8

Rectangle {
    id: button
    radius: 5
    color: focus ? "#33000000" : "transparent"
  
    property url normalImg: ""

    signal clicked()
    signal enterPressed()

    onNormalImgChanged: img.source = normalImg

    Image {
        id: img
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        // Thanks to this hack, qml can now only DOWN-SCALE/SHRINK the SVG, which won't cause blurriness/pixelation
        sourceSize: Qt.size(
                // first "trick" qml that the SVG is larger than we EVER NEED
                Math.max(hiddenImg.sourceSize.width, 250),
                // change 250 to a per-project "biggest icon in project" value
                Math.max(hiddenImg.sourceSize.height, 250))
        
        Image {
            id: hiddenImg
            source: parent.source
            width: 0
            height: 0
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onExited: img.source = normalImg
        onReleased: img.source = normalImg
        onClicked: button.clicked()
    }
    Component.onCompleted: {
        img.source = normalImg
    }
    Keys.onPressed: {
        if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter) {
            button.clicked()
            button.enterPressed()
        }
    }
}
