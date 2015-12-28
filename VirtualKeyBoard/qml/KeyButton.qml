import QtQuick 2.2

Item {
    id:root
    property color color: "#90282828"
    property alias text: txt.text
    property alias font: txt.font
    property alias textColor: txt.color
    signal clicked()
    signal pressed()
    signal released()

    Image {
        anchors.fill: parent
        source: "qrc:/images/btnbg.png"

        Rectangle {
            anchors.fill: parent
            radius: 2
            color: buttonMouseArea.pressed ? root.color : "#00000000"

            Text {
                id: txt
                color: "white"
                anchors.margins: 2
                anchors.fill: parent
                fontSizeMode: Text.Fit
                font.pixelSize: 40
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: buttonMouseArea
                anchors.fill: parent
                onClicked: root.clicked()
                onPressed: root.pressed()
                onReleased: root.released()
            }
        }
    }
}
