import QtQuick 2.0
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.2 as Controls
import QtQuick.Window 2.2
import WeldSys.WeldMath 1.0
import QtQuick.Layouts 1.1
TableCard {
    id:root
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "LimitedConditon"

    ListModel{id:pasteModel;
        ListElement{ID:"";C1:"";C2:"";C3:"";C4:"";C5:"";C6:"";C7:"";C8:"";C9:"";C10:""}
    }
    property bool swingWidthOrWeldWidth
    //property bool superUser
    property Item message
    property var  settings
    property string limitedRulesName

    ListModel{
        id:nameModel
        ListElement{name:"坡口侧          电流       (A)";show:true;min:10;max:300;isNum:true;step:1}
        ListElement{name:"中间              电流       (A)";show:true;min:10;max:300;isNum:true;step:1}
        ListElement{name:"非坡口侧      电流       (A)";show:true;min:10;max:300;isNum:true;step:1}
        ListElement{name:"坡口侧      停留时间    (s)";show:true;min:0;max:5;isNum:true;step:0.01}
        ListElement{name:"非坡口侧  停留时间    (s)";show:true;min:0;max:5;isNum:true;step:0.01}
        ListElement{name:"层      高      Min     (mm)";show:true;min:1;max:10;isNum:true;step:0.1}
        ListElement{name:"层      高      Max    (mm)";show:true;min:1;max:10;isNum:true;step:0.1}
        ListElement{name:"坡口侧    接近距离(mm)";show:true;min:-50;max:50;isNum:true;step:0.1}
        ListElement{name:"非坡口侧接近距离(mm)";show:true;min:-50;max:50;isNum:true;step:0.1}
        ListElement{name:"摆  动  宽  度  Max (mm)";show:true;min:1;max:100;isNum:true;step:0.1}
        ListElement{name:"摆    动    间   隔     (mm)";show:true;min:0;max:100;isNum:true;step:0.1}
        ListElement{name:"分    开    结   束  比   (%)";show:true;min:0;max:1;isNum:true;step:0.01}
        ListElement{name:"焊    接    电     压        (V)";show:true;min:0;max:50;isNum:true;step:0.1}
        ListElement{name:"焊接速度Min   (cm/min)";show:true;min:0;max:2000;isNum:true;step:0.1}
        ListElement{name:"焊接速度Max (cm/min)";show:true;min:0;max:2000;isNum:true;step:0.1}
        ListElement{name:"层    填    充   系   数 (%)";show:true;min:0;max:1;isNum:true;step:0.01}
    }
    onSwingWidthOrWeldWidthChanged: {
        nameModel.setProperty(9,"name",swingWidthOrWeldWidth?"摆  动  宽  度  Max (mm)":"焊  道  宽  度  Max (mm)")
    }

    property int num: 0

    function getTableData(index){
        if((limitedRulesName!=="")&&(typeof(limitedRulesName)==="string")){
            console.log(objectName+"limitedRulesName"+limitedRulesName)
            var res=UserData.getLimitedTableJson(limitedRulesName,index)
            limitedTable.clear();
            if((typeof(res)==="object")&&(res.length)){
                for(var i=0;i<res.length;i++){
                    //删除object 里面C11属性
                    delete res[i].C11
                    limitedTable.append(res[i])
                }
                WeldMath.setLimited(limitedMath(0,limitedTable.count));
                headerTitle=limitedRulesName;
            }else{
                message.open(limitedRulesName+"数据不存在！")
            }
        }
    }
    //开启线程
    //    WorkerScript{
    //        id:work
    //        source: "Limited.js"
    //        onMessage: {
    //            if(messageObject.error.length)
    //                message.open(messageObject.error)
    //            else{
    //                WeldMath.setLimited(limitedMath(0,limitedTable.count));
    //                 headerTitle=limitedRulesName;
    //            }
    //        }
    //    }

    onNumChanged: {getTableData(num);}
    //console.log("work.sendMessage")
    //work.sendMessage({"model":limitedTable,"index":num,"limitedRulesName":limitedRulesName})}
    //规则改变时重新加载限制条件
    onLimitedRulesNameChanged:getTableData(num);
    //显示当前的页脚
    onVisibleChanged: {
        var str;
        var temp=num;
        if(visible){
            var weldStyle=settings.weldStyle
            swingWidthOrWeldWidth=weldStyle===1||weldStyle===4?false:true
            if((temp&0x0f)===4){
                str="焊丝直径为1.2mm/"
            }else if((temp&0x0f)===6){
                str="焊丝直径为1.6mm/"
            }else
                str="焊丝直径不存在/"
            temp>>=4;
            if((temp&0x07)===0){
                str+="焊丝种类为实芯碳钢/"
            }else if((temp&0x07)===4){
                str+="焊丝种类为药芯碳钢/"
            }else
                str+="焊丝种类不存在/"
            temp>>=3;
            if((temp&0x01)===0){
                str+="脉冲无/"
            }else
                str+="脉冲有/"
            temp>>=1;
            if((temp&0x01)===0){
                str+="保护气体为CO2/代码"
            }else
                str+="保护气体为MAG/代码"
            str+=String(num);
            root.footerText=str;
        }
    }

    function limitedMath(start,end){
        var resArray=new Array(0);
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

    firstColumn.title: "限制条件\n      层"

    tableRowCount:7
    model:limitedTable
    fileMenu: [
        Action{iconName:"awesome/calendar_plus_o";name:"新建";enabled: false;
        },
        Action{iconName:"awesome/folder_open_o";name:"打开";enabled:false;
        },
        Action{iconName:"awesome/save";name:"保存";
            onTriggered: { if(typeof(limitedRulesName)==="string"){
                    var C11=num;
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
            onTriggered: {
                if(WeldMath.setLimited(limitedMath(0,limitedTable.count)))
                    message.open("更新限制条件成功！")
                else
                    message.open("限制条件数量不符。更新限制条件失败！")
            }
        }]
    tableData:[
        Controls.TableViewColumn{role: "C1";title:"坡口/中/非坡口\n   焊接电流(A)";width:Units.dp(140);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C2";title: "坡口/非坡口\n停留时间(s)";width:Units.dp(100);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C4";title: "   坡口/非坡口\n接近距离(mm)";width:Units.dp(130);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C3";title: "层高Min/Max\n       (mm)";width:Units.dp(110);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C5";title: swingWidthOrWeldWidth?"摆动宽度Max\n       (mm)":"焊道宽度Max\n       (mm)";width:Units.dp(120);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter; },
        Controls.TableViewColumn{role: "C6";title: "分道间隔\n   (mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C7";title: "结束开始比\n       (%)";width:Units.dp(100);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C8";title: "焊接电压\n     (V)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C10";title:"层填充系数\n       (%)";width:Units.dp(100);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C9";title: "焊接速度Min/Max\n        (cm/min)";width:Units.dp(160);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter}
    ]

    MyTextFieldDialog{
        id:edit
        title: "编辑限制条件"
        repeaterModel:nameModel
        onOpened: {
            var res=limitedMath(currentRow,currentRow+1);
            for(var i=0;i<repeaterModel.count;i++){
                openText(i,res[i])
            }
            focusIndex=0;
            changeFocus(focusIndex)
        }
        onAccepted: {
            model.set(currentRow,
                      {"C1":getText(0)+"/"+getText(1)+"/"+getText(2),
                          "C2":getText(3)+"/"+getText(4),
                          "C3":getText(5)+"/"+getText(6),
                          "C4":getText(7)+"/"+getText(8),
                          "C5":getText(9),
                          "C6":getText(10),
                          "C7":getText(11),
                          "C8":getText(12),
                          "C9":getText(13)+"/"+getText(14),
                          "C10":getText(15)
                      });
        }
    }
}
