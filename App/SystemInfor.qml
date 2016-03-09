import QtQuick 2.4
import Material 0.1 as Material
import Material.ListItems 0.1 as ListItem
import QtGraphicalEffects 1.0

//
FocusScope{
    anchors.fill: parent
    property bool sidebarf: false
    property var titlesIcon: ["action/android","awesome/pause","user/MAG"]
    property var titles:["示教设置","坡口设置","焊接设置"];
    property string selectTitle: titles[0]
    //左边栏
    Material.Sidebar{
        id:sidebar
        anchors.left: parent.left
        width: sidebarf ? Material.Units.dp(300) :Material.Units.dp(240);
        Column{
            anchors.left: parent.left
            spacing: Material.Units.dp(24)
            Repeater{
                model: titles
                delegate:ListItem.BaseListItem {
                    implicitHeight: Material.Units.dp(48)
                        height: Material.Units.dp(48)
                        implicitWidth:label.width*2
                        width:Material.Units.dp(200)
                    Material.Label{
                        id:label
                        visible: true

                        text: modelData
                        style: "subheading"
                        color: Material.Theme.primaryColor//parent.selected ? Material.Theme.primaryColor : Material.Theme.dark.textColor
                    }
                }
            }
        }
    }
    Material.Card{
        anchors.top:parent.top
        anchors.right:parent.right
        anchors.topMargin: Material.Units.dp(10)
        anchors.left: sidebar.right
        anchors.leftMargin: Material.Units.dp(10)
        anchors.rightMargin: Material.Units.dp(10)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Material.Units.dp(10)
        elevation: 2;
        radius: 2;
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
                topMargin: Material.Units.dp(16)
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
            }

        }
    }
}
