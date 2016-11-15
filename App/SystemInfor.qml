import QtQuick 2.4

import WeldSys.ERModbus 1.0
import Material 0.1

Item {
    anchors.fill: parent
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "SystemInfor"
    anchors{
        left:parent.left
        top:parent.top
        bottom: parent.bottom
        leftMargin:visible?0:Units.dp(250)
    }
   width:parent.width
    Behavior on anchors.leftMargin{NumberAnimation { duration: 400 }}

    property var inforName: ["系统版本号：","控制器版本号：","驱动器版本号：","操作盒版本号："]
    Card{
        anchors{left:parent.left;right:parent.right;top:parent.top;bottom:parent.bottom;margins: Units.dp(12)}
        elevation: 2
        Column{
            spacing: 8
            Repeater{
                model:inforName
                delegate:Row{
                    spacing:4
                    Label{
                        text:modelData
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }
    Component.onCompleted: {
        ERModbus.setmodbusFrame(["R","500","3"]);
    }
}
