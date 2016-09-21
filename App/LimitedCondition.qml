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

    property Item message
    property string currentGrooveName
    property var repeaterModel: ["电流前侧","电流中间","电流后侧","端部停止时间前(ms)","端部停止时间后(ms)","层高MAX","接近前","接近后","最大摆宽","摆动间隔","分开结束比","焊接电压","焊接最大速度","焊接最小速度"]
    property alias selectedIndex: tableView.currentRow


    onActiveFocusChanged: {
        if(activeFocus){
            tableView.forceActiveFocus();
        }
    }

    ListModel{id:limitedTable;
        ListElement{ ID:"陶瓷衬垫";C1:"200/201/202";C2:"500/500";C3:"6";C4:"2/2";C5:"20";C6:"2";C7:"0.9";C8:"30";C9:"200/201"}
        ListElement{ ID:"打底层";C1:"200/201/202";C2:"500/500";C3:"6";C4:"2/2";C5:"20";C6:"2";C7:"0.9";C8:"30";C9:"200/201"}
        ListElement{ ID:"第二层";C1:"200/201/202";C2:"500/500";C3:"6";C4:"2/2";C5:"20";C6:"2";C7:"0.9";C8:"30";C9:"200/201"}
        ListElement{ ID:"填充层";C1:"200/201/202";C2:"500/500";C3:"6";C4:"2/2";C5:"20";C6:"2";C7:"0.9";C8:"30";C9:"200/201"}
        ListElement{ ID:"盖面层";C1:"200/201/202";C2:"500/500";C3:"6";C4:"2/2";C5:"20";C6:"2";C7:"0.9";C8:"30";C9:"200/201"}
        ListElement{ ID:"立板余高层";C1:"200/201/202";C2:"500/500";C3:"6";C4:"2/2";C5:"20";C6:"2";C7:"0.9";C8:"30";C9:"200/201"}}

    TableCard{
        id:tableView
        firstColumn.title: "    层\\限制参数"
        headerTitle: currentGrooveName+"限制条件"
        footerText:  "参数"
        tableRowCount:7
        model:limitedTable
        fileMenu: [
            Action{iconName:"awesome/calendar_plus_o";name:"新建";enabled: false;
            },
            Action{iconName:"awesome/folder_open_o";name:"打开";enabled:false;
            },
            Action{iconName:"awesome/save";name:"保存";
                onTriggered: { if(typeof(currentGrooveName)==="string"){
                        //清空数据表格
                        UserData.clearTable(currentGrooveName+"限制条件","","")
                        //数据表格重新插入数据
                        for(var i=0;i<tableView.table.rowCount;i++){
                            UserData.insertTable(currentGrooveName+"限制条件","(?,?,?,?,?,?,?,?,?,?)",[
                                                     limitedTable.get(i).ID,limitedTable.get(i).C1,limitedTable.get(i).C2,limitedTable.get(i).C3,limitedTable.get(i).C4,
                                                     limitedTable.get(i).C5,limitedTable.get(i).C6,limitedTable.get(i).C7,limitedTable.get(i).C8,limitedTable.get(i).C9  ])
                        }
                    }
                }
            },
            Action{iconName:"awesome/calendar_times_o";name:"删除";enabled: false;
            }
        ]
        editMenu:[
            Action{iconName:"awesome/edit";name:"编辑";
                onTriggered: edit.show()
            },
            Action{iconName:"awesome/paste";name:"复制";enabled: false;
            },
            Action{iconName:"awesome/copy"; name:"粘帖";enabled: false
            },
            Action{iconName: "awesome/trash_o";  name:"移除" ;enabled: false
            }]
        inforMenu: [ Action{iconName: "awesome/trash_o";  name:"移除" ;
            }]
        funcMenu: [ Action{iconName:"awesome/send_o";name:"更新算法";
            }]
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
    onCurrentGrooveNameChanged: {
        if((currentGrooveName!=="")&&(typeof(currentGrooveName)==="string")){
            var res=UserData.getTableJson(currentGrooveName+"限制条件")
            var resArray=new Array();
            var temp;
            if(typeof(res)==="object"){
                for(var i=0;i<res.length;i++){
                    limitedTable.set(i,res[i])
                    temp=res[i].C1.split("/")
                    resArray.push(temp[0])
                    resArray.push(temp[1])
                    resArray.push(temp[2])
                    temp=res[i].C2.split("/")
                    resArray.push(temp[0])
                    resArray.push(temp[1])
                    resArray.push(res[i].C3)
                    temp=res[i].C4.split("/")
                    resArray.push(temp[0])
                    resArray.push(temp[1])
                    resArray.push(res[i].C5)
                    resArray.push(res[i].C6)
                    resArray.push(res[i].C7)
                    resArray.push(res[i].C8)
                    temp=res[i].C9.split("/")
                    resArray.push(temp[0])
                    resArray.push(temp[1])
                }
                WeldMath.setLimited(resArray);
            }else{
                message.open(currentGrooveName+"限制条件 数据不存在！")
            }
        }
    }
    Dialog{
        id:edit
        title: qsTr("编辑限制条件")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        globalMouseAreaEnabled:false
        property var editData:new Array(repeaterModel.length)
        onAccepted: {
            //只有一个空白行则插入新的行
            tableView.model.set(selectedIndex,
                                {   "C1":editData[0]+"/"+editData[1]+"/"+editData[2],"C2":editData[3]+"/"+editData[4],
                                    "C3":editData[5],"C4":editData[6]+"/"+editData[7],
                                    "C5":editData[8],"C6":editData[9],
                                    "C7":editData[10],"C8":editData[11],"C9":editData[12]+"/"+editData[13]})}
        onOpened: {
            //复制数据到 editData
            var Index=selectedIndex;
            if(Index>=0){
                var str=limitedTable.get(Index).C1;
                if(typeof(str)==="string"){
                    var strData=str.split("/")
                    columnRepeater.itemAt(0).text=strData[0];
                    columnRepeater.itemAt(1).text=strData[1];
                    columnRepeater.itemAt(2).text=strData[2];
                }
                str=limitedTable.get(Index).C2
                if(typeof(str)==="string"){
                    strData=str.split("/")
                    columnRepeater.itemAt(3).text=strData[0];
                    columnRepeater.itemAt(4).text=strData[1];
                }
                columnRepeater.itemAt(5).text=limitedTable.get(Index).C3;
                str=limitedTable.get(Index).C4
                if(typeof(str)==="string"){
                    strData=str.split("/")
                    columnRepeater.itemAt(6).text=strData[0];
                    columnRepeater.itemAt(7).text=strData[1];
                }
                columnRepeater.itemAt(8).text=limitedTable.get(Index).C5;
                columnRepeater.itemAt(9).text=limitedTable.get(Index).C6;
                columnRepeater.itemAt(10).text=limitedTable.get(Index).C7;
                columnRepeater.itemAt(11).text=limitedTable.get(Index).C8;
                str=limitedTable.get(Index).C9
                if(typeof(str)==="string"){
                    strData=str.split("/")
                    columnRepeater.itemAt(12).text=strData[0];
                    columnRepeater.itemAt(13).text=strData[1];
                }
            }else{
                message.open("请选择要编辑的行！");
                positiveButtonEnabled=false;
            }
        }
        dialogContent: [
            Column{
                id:column
                Repeater{
                    id:columnRepeater
                    model:repeaterModel
                    delegate:Row{
                        property alias text: textField.text
                        spacing: Units.dp(8)
                        Label{text:modelData;anchors.bottom: parent.bottom}
                        TextField{
                            id:textField
                            horizontalAlignment:TextInput.AlignHCenter
                            width: Units.dp(60)
                            inputMethodHints: Qt.ImhDigitsOnly
                            onTextChanged: {
                                edit.editData[index]=text;
                            }
                        }
                    }
                }
            }
        ]
    }
}
