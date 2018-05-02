import QtQuick 2.4
import Material 0.1
import Material.Extras 0.1
import WeldSys.WeldControl 1.0
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.3 as Controls

TableCard {
    id:root
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "SysErrorHistroy"
    //错误历史信息 ID：条数 C1 错误代码 C2 错误状态 C3 错误信息 C4: 操作用户 C5 错误发生/解除时刻

    signal remove
    signal removeall

    property string status: ""
    property var settings

    headerTitle:"系统错误历史信息"
    tableRowCount:7
    footerText:"总计："+String(model.count)+"条错误信息"
    table.__listView.interactive:status!=="焊接态"
    fileMenu: [
        Action{iconName:"awesome/calendar_plus_o";name:"新建"; enabled: false},
        Action{iconName:"awesome/folder_open_o";name:"打开"; enabled: false},
        Action{iconName:"awesome/save";name:"保存";enabled: false},
        Action{iconName:"awesome/credit_card";name:"另存为";enabled: false},
        Action{iconName:"awesome/calendar_times_o";name:"删除";enabled: false}
    ]
    editMenu:[
        Action{iconName:"awesome/edit";name:"清空错误";
            onTriggered: removeall()
        }]
    inforMenu: [ Action{iconName: "awesome/info";  name:"错误描述" ;
        }]
    tableData:[
        Controls.TableViewColumn{role: "C1";title:"错误代码";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C2";title:"错误状态";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C3";title:"操作用户";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C4";title:"错误信息";width:Units.dp(250);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C5";title:"发生时间";width:Units.dp(180);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter}
    ]
}

