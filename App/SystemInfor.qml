import QtQuick 2.4


import Material 0.1

Item {
    anchors.fill: parent
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "SystemInfor"
    anchors{
        left:parent.left
        right:parent.right
        top:parent.top
        bottom: parent.bottom
        leftMargin:visible?0:Units.dp(250)
    }
    Behavior on anchors.leftMargin{NumberAnimation { duration: 400 ;easing.type:Easing.InQuad }}



}
