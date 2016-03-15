import QtQuick 2.4
import Material 0.1 as Material

Item{
    anchors.fill: parent
    Image  {

        id:grooveImage
        anchors.centerIn: parent
        source: "../Pic/时序图.png"
        sourceSize.width:  Material.Units.dp(300)
        sourceSize.height:Material.Units.dp(150)
        Material.Ink{
            anchors.fill: parent
            onClicked:  overlayView.open(grooveImage)
        }
    }

}
