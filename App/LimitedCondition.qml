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
    property string limitedRulesName
    property var repeaterModel: ["电流前侧","电流中间","电流后侧","端部停止时间前(s)","端部停止时间后(s)","层高Min","层高Max","接近前","接近后","最大摆宽","摆动间隔","分开结束比","焊接电压","焊接速度min","焊接速度Min","层填充系数"]
    property alias selectedIndex: tableView.currentRow

    //规则改变时重新加载限制条件
    onLimitedRulesNameChanged:{
        if((limitedRulesName!=="")&&(typeof(limitedRulesName)==="string")){
            console.log(objectName+"limitedRulesName"+limitedRulesName)
            var res=UserData.getLimitedTableJson(limitedRulesName,"4")
            if((typeof(res)==="object")&&(res.length)){
                for(var i=0;i<res.length;i++){
                    //删除object 里面C11属性
                    delete res[i].C11
               //     console.log(res[i].ID+res[i].C1+res[i].C2+res[i].C3+res[i].C4+res[i].C5+res[i].C6+res[i].C7+res[i].C8+res[i].C9+res[i].C10);
                    limitedTable.set(i,res[i])
                }
                WeldMath.setLimited(lmitedMath());
                tableView.headerTitle=limitedRulesName;
            }else{
                message.open(limitedRulesName+"数据不存在！")
            }
        }
    }

    function lmitedMath(){
        var resArray=new Array();
        var temp;
        for(var i=0;i<limitedTable.count;i++){
           var res=limitedTable.get(i);
            if((typeof(res.C1)==="string")&&(res.C1!=="")){
                temp=res.C1.split("/")
                resArray.push(temp[0])
                resArray.push(temp[1])
                resArray.push(temp[2])
            }else{
                resArray.push("0")
                resArray.push("0")
                resArray.push("0")
            }
            if((typeof(res.C2)==="string")&&(res.C2!=="")){
                temp=res.C2.split("/")
                resArray.push(temp[0])
                resArray.push(temp[1])
            }else{
                resArray.push("0")
                resArray.push("0")
            }
            if((typeof(res.C3)==="string")&&(res.C3!=="")){
                temp=res.C3.split("/")
                resArray.push(temp[0])
                resArray.push(temp[1])}
            else{
                resArray.push("0")
                resArray.push("0")
            }
            if((typeof(res.C4)==="string")&&(res.C4!=="")){
                temp=res.C4.split("/")
                resArray.push(temp[0])
                resArray.push(temp[1])
            } else{
                resArray.push("0")
                resArray.push("0")
            }
            if((typeof(res.C5)==="string")&&(res.C5!==""))
                resArray.push(res.C5)
            else
                resArray.push("0");
            if((typeof(res.C6)==="string")&&(res.C6!==""))
                resArray.push(res.C6)
            else
                resArray.push("0");
            if((typeof(res.C7)==="string")&&(res.C7!==""))
                resArray.push(res.C7)
            else
                resArray.push("0");
            if((typeof(res.C8)==="string")&&(res.C8!==""))
                resArray.push(res.C8)
            else
                resArray.push("0");
            if((typeof(res.C9)==="string")&&(res.C9!=="")){
                temp=res.C9.split("/")
                resArray.push(temp[0])
                resArray.push(temp[1])
            }else{
                resArray.push("0")
                resArray.push("0")
            }
            if((typeof(res.C10)==="string")&&(res.C10!=="")){
                resArray.push(res.C10)
            }else{
                resArray.push("0")
            }

        }
        return resArray;
    }

    ListModel{id:limitedTable;}

    TableCard{
        id:tableView
        firstColumn.title: "    层\\限制参数"
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
                        UserData.clearTable(currentGrooveName.replace("焊接规范","限制条件"),"","")
                        //数据表格重新插入数据
                        for(var i=0;i<tableView.table.rowCount;i++){
                            UserData.insertTable(currentGrooveName.replace("焊接规范","限制条件"),"(?,?,?,?,?,?,?,?,?,?,?)",[
                                                     limitedTable.get(i).ID,limitedTable.get(i).C1,limitedTable.get(i).C2,limitedTable.get(i).C3,limitedTable.get(i).C4,
                                                     limitedTable.get(i).C5,limitedTable.get(i).C6,limitedTable.get(i).C7,limitedTable.get(i).C8,limitedTable.get(i).C9])
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
                onTriggered: {WeldMath.setLimited(lmitedMath());}
            }]
        tableData:[
            Controls.TableViewColumn{role: "C1";title:"焊接电流\n前/中/后";width:Units.dp(120);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C2";title: "停留时间\n   前/后";width:Units.dp(100);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C3";title: "    层高    \nMin/Max";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C4";title: "接近坡口\n   前/后";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C5";title: "摆宽\nMax";width:Units.dp(50);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter; },
            Controls.TableViewColumn{role: "C6";title: "分道\n间隔";width:Units.dp(50);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C7";title: "结束开始\n      比";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C8";title: "焊接\n电压";width:Units.dp(50);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C9";title: "焊接速度\nMin/Max";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C10";title:"  层填充 \n   系数";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter}
        ]
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
                                    "C3":editData[5]+"/"+editData[6],"C4":editData[7]+"/"+editData[8],
                                    "C5":editData[9],"C6":editData[10],
                                    "C7":editData[11],"C8":editData[12],"C9":editData[13]+"/"+editData[14]})}
        onOpened: {
            //复制数据到 editData
            var Index=selectedIndex;
            if(Index>=0){
                var res=lmitedMath();
                for(var i=0;i<res.length;i++){
                    columnRepeater.itemAt(i).text=res[i];
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
