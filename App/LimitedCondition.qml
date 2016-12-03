import QtQuick 2.0
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.2 as Controls
import QtQuick.Window 2.2
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0
import WeldSys.WeldMath 1.0
import QtQuick.Layouts 1.1
TableCard {
    id:root
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "LimitedConditon"

    ListModel{id:pasteModel;
        ListElement{ID:"";C1:"";C2:"";C3:"";C4:"";C5:"";C6:"";C7:"";C8:"";C9:"";C10:""}
    }

    property Item message
    property string limitedRulesName
    property var nameModel: ["电流前侧","电流中间","电流后侧","端部停止时间前(s)","端部停止时间后(s)","层高Min","层高Max","接近前","接近后","最大摆宽","摆动间隔","分开结束比","焊接电压","焊接速度Min","焊接速度Max","层填充系数"]
    //脉冲有无
    property int pulse:255
    //焊丝种类
    property int wireType:255
    //焊丝直径
    property int wireD:255
    //气体
    property int gas:255

    signal changeGasError()
    signal changeWireDError()
    signal changeWireTypeError()
    signal changePulseError()
    property int num: 0

    function getTableData(index,type){
        if((limitedRulesName!=="")&&(typeof(limitedRulesName)==="string")){
            console.log(objectName+"limitedRulesName"+limitedRulesName)
            var res=UserData.getLimitedTableJson(limitedRulesName,index)
            if((typeof(res)==="object")&&(res.length)){
                for(var i=0;i<res.length;i++){
                    //删除object 里面C11属性
                    delete res[i].C11
                    limitedTable.set(i,res[i])
                }
                WeldMath.setLimited(limitedMath(0,limitedTable.count));
                headerTitle=limitedRulesName;
            }else{
                if(typeof(type)==="number")
                {
                    switch(type){
                    case 0: changeGasError();break;
                    case 1: changePulseError();break;
                    case 2: changeWireTypeError();break;
                    case 3: changeWireDError();break;
                    }
                }
                message.open(limitedRulesName+"数据不存在！")
            }
        }
    }
    function makeNum(){
        var num=gas;
        num<<=1;
        num|=pulse;
        num<<=3;
        num|=wireType;
        num<<=4;
        num|=wireD;
        return String(num)
    }

    onGasChanged:{getTableData(makeNum(),0);console.log(root.objectName+"gas value="+gas)}
    onPulseChanged: {getTableData(makeNum(),1);console.log(root.objectName+"pulse value="+pulse);}
    onWireTypeChanged:{ getTableData(makeNum(),2);console.log(root.objectName+"WireType value="+wireType);}
    onWireDChanged: {getTableData(makeNum(),3);console.log(root.objectName+"WireD value="+wireD);}

    //规则改变时重新加载限制条件
    onLimitedRulesNameChanged:getTableData(makeNum(),4);

    function limitedMath(start,end){
        var resArray=new Array();
        var temp;
        for(var i=start;i<end;i++){
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
            onTriggered: { if(typeof(limitedRulesName)==="string"){
                    var C11=makeNum();
                    //清空数据表格
                    UserData.clearTable(limitedRulesName,"C11",C11)
                    //数据表格重新插入数据
                    for(var i=0;i<table.rowCount;i++){
                        UserData.insertTable(limitedRulesName,"(?,?,?,?,?,?,?,?,?,?,?,?)",[
                                                 limitedTable.get(i).ID,limitedTable.get(i).C1,limitedTable.get(i).C2,limitedTable.get(i).C3,limitedTable.get(i).C4,
                                                 limitedTable.get(i).C5,limitedTable.get(i).C6,limitedTable.get(i).C7,limitedTable.get(i).C8,limitedTable.get(i).C9,limitedTable.get(i).C10,C11])
                    }
                    message.open("限制条件已保存！")
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
    inforMenu: [ Action{iconName: "awesome/trash_o";  name:"详细信息" ;
        }]
    funcMenu: [ Action{iconName:"awesome/send_o";name:"更新算法";
            onTriggered: {WeldMath.setLimited(limitedMath(0,limitedTable.count));}
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

    MyTextFieldDialog{
        id:edit
        title: "编辑限制条件"
        repeaterModel:nameModel
        onOpened: {
            var res=limitedMath(currentRow,currentRow+1);
            pasteModel.set(0,limitedTable.get(currentRow))
            for(var i=0;i<repeaterModel.length;i++){
                openText(i,res[i])
            }
            focusIndex=0;
            changeFocus(focusIndex)
        }
        onChangeText: {
            var str;
            var data=["0","0","0"];
            switch(index){
            case 0:str=pasteModel.get(0).C1;
                if(typeof(str)==="string"){
                    data=str.split("/");
                    str=text+"/"+data[1]+"/"+data[2];
                }
                else
                    str=text+"/0/0";
                pasteModel.setProperty(0,"C1",str);
                break;
            case 1:str=pasteModel.get(0).C1;
                if(typeof(str)==="string"){
                    data=str.split("/");
                    str=+data[0]+"/"+text+"/"+data[2];
                }
                else
                    str="/0"+text+"/0";
                pasteModel.setProperty(0,"C1",str);break;
            case 2:str=pasteModel.get(0).C1;
                if(typeof(str)==="string"){
                    data=str.split("/");
                    str=+data[0]+"/"+data[1]+"/"+text;
                }
                else
                    str="/0/0"+text;
                pasteModel.setProperty(0,"C1",str);break;
            case 3:str=pasteModel.get(0).C2;
                if(typeof(str)==="string"){
                    data=str.split("/");
                    str=text+"/"+data[1];
                }else{
                    str=text+"/0"
                }

                pasteModel.setProperty(0,"C2",str);break;
            case 4:str=pasteModel.get(0).C2;
                if(typeof(str)==="string"){
                    data=str.split("/");
                    str=data[0]+"/"+text;
                }else{
                    str="0/"+text;
                }
                pasteModel.setProperty(0,"C2",str);break;
            case 5:str=pasteModel.get(0).C3;
                if(typeof(str)==="string"){
                    data=str.split("/");
                    str=text+"/"+data[1];
                }else{
                    str=text+"/0"
                }
                pasteModel.setProperty(0,"C3",str);break;
            case 6:str=pasteModel.get(0).C3;
                if(typeof(str)==="string"){
                    data=str.split("/");
                    str=data[0]+"/"+text;
                }else{
                    str="0/"+text;
                }
                pasteModel.setProperty(0,"C3",str);break;
            case 7:str=pasteModel.get(0).C4;
                if(typeof(str)==="string"){
                    data=str.split("/");
                    str=text+"/"+data[1];
                }else{
                    str=text+"/0"
                }
                pasteModel.setProperty(0,"C4",str);break;
            case 8:str=pasteModel.get(0).C4;
                if(typeof(str)==="string"){
                    data=str.split("/");
                    str=data[0]+"/"+text;
                }else{
                    str="0/"+text;
                }
                pasteModel.setProperty(0,"C4",str);break;
            case 9:
                pasteModel.setProperty(0,"C5",text);break;
            case 10:
                pasteModel.setProperty(0,"C6",text);break;
            case 11:
                pasteModel.setProperty(0,"C7",text);break;
            case 12:
                pasteModel.setProperty(0,"C8",text);break;
            case 13:str=pasteModel.get(0).C9;
                if(typeof(str)==="string"){
                    data=str.split("/");
                    str=text+"/"+data[1];
                }else{
                    str=text+"/0"
                }
                pasteModel.setProperty(0,"C9",str);break;
            case 14:str=pasteModel.get(0).C9;
                if(typeof(str)==="string"){
                    data=str.split("/");
                    str=data[0]+"/"+text;
                }else{
                    str="0/"+text;
                }
                pasteModel.setProperty(0,"C9",str);break;
            case 15:
                pasteModel.setProperty(0,"C10",text);break;
            }
        }
        onAccepted: {
            model.set(currentRow,pasteModel.get(0));
        }
    }
}
