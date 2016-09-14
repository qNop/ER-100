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
    property list<Action> editMenu:[
        Action{iconName:"awesome/edit";name:"清空错误";
            onTriggered: removeall()
        },
        Action{iconName: "awesome/trash_o"; name:"移除" ;
            onTriggered:{ remove();
            console.log(objectName+" tableCard.__listview.currentIndex "+tableCard.__listview.currentIndex)
            }
        }]
    property list<Action> inforMenu: [ Action{iconName: "awesome/trash_o";  name:"错误描述" ;
        }]

    TableCard{
        id:tableCard
        headerTitle:"系统错误历史信息"
        tableRowCount:7
        footerText:"总计："+table.rowCount+"条错误信息"
        actions: [
            Action{iconName:"awesome/file_text_o";name:"文件";hoverAnimation:true;summary: "F1";enabled:false
            },
            Action{iconName:"awesome/edit"; name:"修改";hoverAnimation:true;summary: "F2";
                onTriggered:{
                    tableCard.menuDropDown.actions=editMenu;
                    tableCard.menuDropDown.open(source,0,source.height+3);
                    tableCard.menuDropDown.place=1;
                }
            },
            Action{iconName:"awesome/calendar_plus_o";name:"信息";hoverAnimation:true;summary: "F3"
                onTriggered:{
                    tableCard.menuDropDown.actions=inforMenu;
                    tableCard.menuDropDown.open(source,0,source.height+3);
                    tableCard.menuDropDown.place=2;
                }
            },
            Action{iconName:"awesome/stack_overflow";  name:"工具";hoverAnimation:true;summary: "F4"; enabled: false; }
        ]
        tableData:[
            Controls.TableViewColumn{role: "C1";title:"错误代码";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C2";title:"错误状态";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C3";title:"操作用户";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C4";title:"错误信息";width:Units.dp(250);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C5";title:"发生时间";width:Units.dp(180);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter}
        ]
    }
}
