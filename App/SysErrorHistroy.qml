import QtQuick 2.4
import Material 0.1
import Material.Extras 0.1
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0
import WeldSys.WeldMath 1.0
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.3 as Controls

Item {
    id:root
    anchors.fill: parent
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "SysErrorHistroy"
    signal remove
    signal removeall

    property alias model:tableCard.model
    property alias seletedIndex: tableCard.currentRow

    TableCard{
        id:tableCard
        headerTitle:"系统错误历史信息"
        tableRowCount:7
        footerText:"总计："+table.rowCount+"条错误信息"
        editMenu:[
            Action{iconName:"awesome/edit";name:"清空错误";
                onTriggered: removeall()
            },
            Action{iconName: "awesome/trash_o"; name:"移除" ;
                onTriggered:{ remove();
                }
            }]
         inforMenu: [ Action{iconName: "awesome/trash_o";  name:"错误描述" ;
            }]
        tableData:[
            Controls.TableViewColumn{role: "C1";title:"错误代码";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C2";title:"错误状态";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C3";title:"操作用户";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C4";title:"错误信息";width:Units.dp(250);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C5";title:"发生时间";width:Units.dp(180);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter}
        ]
    }
}
