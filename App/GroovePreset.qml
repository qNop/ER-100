import QtQuick 2.4
import Material 0.1 as Material
import Material.ListItems 0.1 as ListItem
import QtGraphicalEffects 1.0
//
FocusScope{
    anchors.fill: parent
    /*坡口列表*/
    property var groovestyles: [
        qsTr( "平焊单边V型坡口T接头"), qsTr( "平焊单边V型坡口平对接"),  qsTr("平焊V型坡口平对接"),  qsTr("水平角焊"),
        qsTr("横焊单边V型坡口T接头"), qsTr( "横焊单边V型坡口平对接"),  qsTr("横焊V型坡口平对接"),  qsTr("立焊单边V型坡口平对接"), qsTr("立焊V型坡口平对接")  ]
    property var grooveStyleEnglish: [];
    Material.Card{
        anchors{
            left:parent.left
            right:parent.right
            top:parent.top
            bottom: parent.bottom
            margins: Material.Units.dp(16)
        }
        Material.Label{
            id:title
            anchors.left: parent.left
            anchors.leftMargin: Material.Units.dp(24)
            height: Material.Units.dp(64)
            verticalAlignment:Text.AlignVCenter
            text:"坡口条件"
            style:"title"
            color: Material.Theme.light.shade(0.87)
        }
        Material.Card{
            anchors{
                left:parent.left
                leftMargin: Material.Units.dp(16)
                top:title.bottom
            }
            width: grooveImage.width+2*Material.Units.dp(24)
            height:grooveImage.height+2*Material.Units.dp(24)
            flat: false
            border.color: "black"
            radius: Material.Units.dp(5)
            Image{
                id:grooveImage
                anchors.centerIn: parent
                source: "../Pic/坡口参数图.png"
                sourceSize.width:  Material.Units.dp(300)
                sourceSize.height:Material.Units.dp(150)
                Material.Ink{
                    anchors.fill: parent
                    onClicked:  overlayView.open(grooveImage)
                }
            }
        }
        Material.OverlayView{
            id:overlayView
            width: 640-Material.Units.dp(64)
            height:480-Material.Units.dp(64)
            Image{
                anchors.fill: parent
                source: "../Pic/坡口参数图.png"
            }
        }
    }
}

