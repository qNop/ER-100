import QtQuick 2.4
import Material 0.1 as Material
import Material.Extras 0.1
import WeldSys.ERModbus 1.0
import WeldSys.WeldMath 1.0
import Material.ListItems 0.1 as ListItem

Item {
    id:root
    anchors.fill: parent
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "SysTime"
    Row{
        Material.TimePicker{

        }
        Material.DatePicker {
            id:datePicker
            __locale:Qt.locale("zh_Cn")
            frameVisible: false;dayAreaBottomMargin : Material.Units.dp(48);isLandscape: true;
            onClicked: {
                var current=date.toLocaleDateString(Qt.locale("zh_Cn"),"yy/M/d/");
                current =current+new Date().toLocaleTimeString(Qt.locale("zh_Cn"),"h/m/s");
            }
        }
    }
}
