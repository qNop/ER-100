import QtQuick 2.0
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.2 as Controls
import QtQuick.Window 2.2
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0
import WeldSys.WeldMath 1.0
import QtQuick.Layouts 1.1
FocusScope {
    id:root
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "LimitedCondition"
    anchors{
        left:parent.left
        right:parent.right
        top:parent.top
        bottom: parent.bottom
        leftMargin:visible?0:Units.dp(250)
    }
    Behavior on anchors.leftMargin{NumberAnimation { duration: 400 }}
    property var grooveNameList: ["flatweldsinglebevelgroovet","flatweldsinglebevelgroove","flatweldvgroove","horizontalweldsinglebevelgroovet","horizontalweldsinglebevelgroove","verticalweldsinglebevelgroovet","verticalweldsinglebevelgroove","verticalweldvgroove","flatfillet"]
    property alias name: tableView.headerTitle
    property alias limitedModel: tableView.model
//   ListModel{
//       id:limitedModel
//        ListElement{ ID:"陶瓷衬垫";C1:"200/201/202";C2:"500/500";C3:"6";C4:"2/2";C5:"20";C6:"2";C7:"0.9";C8:"30";C9:"200/201"}
//        ListElement{ ID:"打底层";C1:"200/201/202";C2:"500/500";C3:"6";C4:"2/2";C5:"20";C6:"2";C7:"0.9";C8:"30";C9:"200/201"}
//        ListElement{ ID:"第二层";C1:"200/201/202";C2:"500/500";C3:"6";C4:"2/2";C5:"20";C6:"2";C7:"0.9";C8:"30";C9:"200/201"}
//        ListElement{ ID:"填充层";C1:"200/201/202";C2:"500/500";C3:"6";C4:"2/2";C5:"20";C6:"2";C7:"0.9";C8:"30";C9:"200/201"}
//        ListElement{ ID:"盖面层";C1:"200/201/202";C2:"500/500";C3:"6";C4:"2/2";C5:"20";C6:"2";C7:"0.9";C8:"30";C9:"200/201"}
//   }
    Table{
        id:tableView
        firstColumn.title: "    层\\限制参数"
        footerText:  "参数"
        tableRowCount:7
        tableData:[
            Controls.TableViewColumn{role: "C1";title:"焊接电流\n前/中/后";width:Units.dp(120);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C2";title: "停留时间\n   前/后";width:Units.dp(100);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C3";title: "层高\nMax";width:Units.dp(50);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C4";title: "接近坡口\n   前/后";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C5";title: "摆宽\nMax";width:Units.dp(50);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter; },
            Controls.TableViewColumn{role: "C6";title: "分道\n间隔";width:Units.dp(50);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C7";title: "结束开始\n      比";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C8";title: "焊接\n电压";width:Units.dp(50);movable:false;resizable:false;},
            Controls.TableViewColumn{role: "C9";title: "焊接速度\nMin/Max";width:Units.dp(100);movable:false;resizable:false;}
        ]
    }
}
