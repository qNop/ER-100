import QtQuick 2.0

Rectangle {
    id: root
    anchors.fill: parent
    TextEdit{
        anchors.top:parent.top
        anchors.left: parent.Left
        width: parent.width
        height:parent.height/20
        color: "yellow"
    }
}

