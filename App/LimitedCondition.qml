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
    // property alias name: tableView.headerTitle
    // property alias limitedModel: tableView.model

    property string currentGrooveName

    ListModel{id:limitedTable;
        ListElement{ ID:"陶瓷衬垫";C1:"200/201/202";C2:"500/500";C3:"6";C4:"2/2";C5:"20";C6:"2";C7:"0.9";C8:"30";C9:"200/201"}
        ListElement{ ID:"打底层";C1:"200/201/202";C2:"500/500";C3:"6";C4:"2/2";C5:"20";C6:"2";C7:"0.9";C8:"30";C9:"200/201"}
        ListElement{ ID:"第二层";C1:"200/201/202";C2:"500/500";C3:"6";C4:"2/2";C5:"20";C6:"2";C7:"0.9";C8:"30";C9:"200/201"}
        ListElement{ ID:"填充层";C1:"200/201/202";C2:"500/500";C3:"6";C4:"2/2";C5:"20";C6:"2";C7:"0.9";C8:"30";C9:"200/201"}
        ListElement{ ID:"盖面层";C1:"200/201/202";C2:"500/500";C3:"6";C4:"2/2";C5:"20";C6:"2";C7:"0.9";C8:"30";C9:"200/201"}
        ListElement{ ID:"立板余高层";C1:"200/201/202";C2:"500/500";C3:"6";C4:"2/2";C5:"20";C6:"2";C7:"0.9";C8:"30";C9:"200/201"}}
    property list<Action> fileMenu: [
        Action{iconName:"awesome/calendar_plus_o";name:"新建";enabled: false;
        },
        Action{iconName:"awesome/folder_open_o";name:"打开";
        },
        Action{iconName:"awesome/save";name:"保存";
        },
        Action{iconName:"awesome/calendar_times_o";name:"删除";
        }
    ]
    property list<Action> editMenu:[
        Action{iconName:"awesome/edit";name:"编辑";
        },
        Action{iconName:"awesome/paste";name:"复制";enabled: false;
        },
        Action{iconName:"awesome/copy"; name:"粘帖";enabled: false
        },
        Action{iconName: "awesome/trash_o";  name:"移除" ;enabled: false
        }]
    property list<Action> inforMenu: [ Action{iconName: "awesome/trash_o";  name:"移除" ;
        }]
    property list<Action> funcMenu: [ Action{iconName:"awesome/send_o";name:"下发规范";
        }]
    TableCard{
        id:tableView
        firstColumn.title: "    层\\限制参数"
        headerTitle: currentGrooveName+"限制条件"
        footerText:  "参数"
        tableRowCount:7
        model:limitedTable
        actions: [
            Action{iconName:"awesome/file_text_o";name:"文件";hoverAnimation:true;summary: "F1"
                onTriggered: {
                    //source为triggered的传递参数
                    tableView.menuDropDown.actions=fileMenu;
                    tableView.menuDropDown.open(source,0,source.height+3);
                    tableView.menuDropDown.place=0;
                }
            },
            Action{iconName:"awesome/edit"; name:"修改";hoverAnimation:true;summary: "F2";
                onTriggered:{
                    tableView.menuDropDown.actions=editMenu;
                    tableView.menuDropDown.open(source,0,source.height+3);
                    tableView.menuDropDown.place=1;
                }
            },
            Action{iconName:"awesome/calendar_plus_o";name:"信息";hoverAnimation:true;summary: "F3"
                onTriggered:{
                    tableView.menuDropDown.actions=inforMenu;
                    tableView.menuDropDown.open(source,0,source.height+3);
                    tableView.menuDropDown.place=2;
                }
            },
            Action{iconName:"awesome/stack_overflow";  name:"工具";hoverAnimation:true;summary: "F4"
                onTriggered:{
                    tableView.menuDropDown.actions=funcMenu;
                    tableView.menuDropDown.open(source,0,source.height+3);
                    tableView.menuDropDown.place=3;
                }
            }
        ]
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
    Keys.onPressed: {
        console.log(event.key)
        switch(event.key){
        case Qt.Key_F1:
            if(tableView.menuDropDown.showing)
                tableView.menuDropDown.toggle();
            else{
                tableView.actions[0].triggered(tableView.actionRepeater.itemAt(0));
                tableView.menuDropDown.place=0;
            }
            event.accepted=true;
            break;
        case Qt.Key_F2:
            if(tableView.menuDropDown.showing)
                tableView.menuDropDown.close();
            else{
                tableView.actions[1].triggered(tableView.actionRepeater.itemAt(1));
                tableView.menuDropDown.place=1;
            }
            event.accepted=true;
            break;
        case Qt.Key_F3:
            if(tableView.menuDropDown.showing)
                tableView.menuDropDown.close();
            else{
                tableView.actions[2].triggered(tableView.actionRepeater.itemAt(2));
                tableView.menuDropDown.place=2;
            }
            event.accepted=true;
            break;
        case Qt.Key_F4:
            if(tableView.menuDropDown.showing)
                tableView.menuDropDown.close();
            else{
                tableView.actions[3].triggered(tableView.actionRepeater.itemAt(3));
                tableView.menuDropDown.place=3;
            }
            event.accepted=true;
            break;
        case Qt.Key_Down:
            tableView.__listView.incrementCurrentIndex();
            event.accept=true;
            break;
        case Qt.Key_Up:
            tableView.__listView.decrementCurrentIndex();
            event.accept=true;
            break;
        case Qt.Key_Right:
            tableView.__horizontalScrollBar.value +=Units.dp(70);
            event.accept=true;
            break;
        case Qt.Key_Left:
            tableView.__horizontalScrollBar.value -=Units.dp(70);
            event.accept=true;
            break;
        }
    }

    onCurrentGrooveNameChanged: {
        if(currentGrooveName!==""){
            var res=UserData.getValueFromFuncOfTable(currentGrooveName+"限制条件","","")
            if(res!==-1){
                var j=0,i=0;
                for(j=0;j<6;j++){
                    limitedTable.set(j,{"C1":res[i++]+"/"+res[i++]+"/"+res[i++],
                                         "C2":res[i++]+"/"+res[i++],
                                         "C3":res[i++],
                                         "C4":res[i++]+"/"+res[i++],
                                         "C5":res[i++],
                                         "C6":res[i++],
                                         "C7":res[i++],
                                         "C8":res[i++],
                                         "C9":"100/100"})

                }
                WeldMath.setLimited(res);
            }
        }
    }
}
