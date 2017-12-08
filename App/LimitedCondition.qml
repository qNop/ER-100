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

    /*    ListModel{id:pasteModel;
        ListElement{ID:"";C1:"";C2:"";C3:"";C4:"";C5:"";C6:"";C7:"";C8:"";C9:"";C10:""}
    }*/
    property bool swingWidthOrWeldWidth

    property Item message

    property string limitedRulesName:""
    property string limitedRulesNameList:""

    property string currentUserName

    property bool addOrEdit: false

    property bool saveAs: false


    ListModel{id:pasteModel;
        ListElement{ID:"";C1:"";C2:"";C3:"";C4:"";C5:"";C6:"";C7:"";C8:"";C9:"";C10:"";C11:""}
    }

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
        ListElement{name:"分    道    间   隔     (mm)";show:true;min:0;max:100;isNum:true;step:0.1}
        ListElement{name:"分    开    结   束  比   (%)";show:true;min:0;max:1;isNum:true;step:0.01}
        ListElement{name:"焊    接    电     压        (V)";show:true;min:0;max:50;isNum:true;step:0.1}
        ListElement{name:"焊接速度Min   (mm/min)";show:true;min:0;max:2000;isNum:true;step:0.1}
        ListElement{name:"焊接速度Max (mm/min)";show:true;min:0;max:2000;isNum:true;step:0.1}
        ListElement{name:"层    填    充   系   数 (%)";show:true;min:0;max:1;isNum:true;step:0.01}
    }
    onSwingWidthOrWeldWidthChanged: {
        nameModel.setProperty(9,"name",swingWidthOrWeldWidth?"摆  动  宽  度  Max (mm)":"焊  道  宽  度  Max (mm)")
    }

    property int num: 0

    property string limitedString: ""

    function getLastRulesName(){
        if((typeof(limitedRulesNameList)==="string")&&(limitedRulesNameList!=="")){
            //名称存在且格式正确  那么 重新更新 表名称参数 找出最新的表
            try{
                var res =UserData.getDataOrderByTime(limitedRulesNameList,"EditTime")
            }catch(e){
                //console.log(objectName+" get Last Rules Name Error "+e.message);
                message.open(objectName+" get Last Rules Name Error "+e.message);
            }
            if((res!==-1)&&(typeof(res)==="object")){
                return res[0].Name;
            }else
                return -1;
        }
        return -1;
    }

    signal updateLimitedRulesName(string str);

    function selectIndex(index){
        if((index<model.count)&&(index>-1)){
            table.selection.clear();
            table.selection.select(index);
        }
        else{
            message.open("索引超过条目上限或索引无效！")
        }
    }

    function setLimited(){
        return WeldMath.setLimited(limitedMath(0,limitedTable.count));
    }

    onUpdateLimitedRulesName: {
        if((typeof(str)==="string")&&(str!=="")){
            var res=UserData.getTableJson(str)
            if(res!==-1){
                limitedTable.clear();
                for(var i=0;i<res.length;i++){
                    if(res[i].ID!==null)
                        limitedTable.append(res[i]);
                }
                currentRow=0;
                selectIndex(0);
                limitedRulesName=str;
            }else{
                message.open("限制条件表格不存在或为空！")
            }
        } else
            message.open("限制条件列表内无数据！")
    }

    function limitedMath(start,end){
        var resArray=new Array(0);
        var temp;
        try{
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
                }if((typeof(res.C2)==="string")&&(res.C2!=="")){
                    temp=res.C2.split("/")
                    resArray.push(temp[0])
                    resArray.push(temp[1])
                }else{
                    resArray.push("0")
                    resArray.push("0")
                }if((typeof(res.C3)==="string")&&(res.C3!=="")){
                    temp=res.C3.split("/")
                    resArray.push(temp[0])
                    resArray.push(temp[1])}
                else{
                    resArray.push("0")
                    resArray.push("0")
                }if((typeof(res.C4)==="string")&&(res.C4!=="")){
                    temp=res.C4.split("/")
                    resArray.push(temp[0])
                    resArray.push(temp[1])
                }else{
                    resArray.push("0")
                    resArray.push("0")
                }if((typeof(res.C5)==="string")&&(res.C5!==""))
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
        }catch(e){
            message.open(objectName+"error"+e.message);
        }
        return resArray;
    }

    function save(){
        if(typeof(limitedRulesName)==="string"){
            //清空数据表格
            UserData.clearTable(limitedRulesName,"","")
            //数据表格重新插入数据
            for(var i=0;i<limitedTable.count;i++){
                var temp=limitedTable.get(i);
                UserData.insertTable(limitedRulesName,"(?,?,?,?,?,?,?,?,?,?,?,?)",[
                                         temp.ID,temp.C1,temp.C2,temp.C3,temp.C4,
                                         temp.C5,temp.C6,temp.C7,temp.C8,temp.C9,temp.C10,temp.C11])
            }
            message.open("限制条件已保存！")
        }
    }

    ListModel{id:limitedTable;}
    headerTitle: limitedRulesName.replace(limitedString,"");
    firstColumn.title: "限制条件\n      层"
    footerText: limitedString
    tableRowCount:7
    model:limitedTable
    fileMenu: [
        Action{iconName:"awesome/calendar_plus_o";name:"新建";enabled: true;
            onTriggered:{ saveAs=false;newFile.open()}
        },
        Action{iconName:"awesome/folder_open_o";name:"打开";enabled:true;
            onTriggered: open1.open();
        },
        Action{iconName:"awesome/save";name:"保存";
            onTriggered: {save();}
        },
        Action{iconName:"awesome/credit_card";name:"另存为";
            onTriggered: {saveAs=true;newFile.show();
                //备份数据 新建表格
                //插入表格数据
            }
        },
        Action{iconName:"awesome/calendar_times_o";name:"删除";enabled: limitedRulesNameList.replace("列表","")===limitedRulesName?false:true;
            onTriggered: remove.open();
        }
    ]
    editMenu:[
        Action{iconName:"awesome/edit";name:"添加";
            onTriggered:{addOrEdit=true;edit.show();}
        },
        Action{iconName:"awesome/edit";name:"编辑";
            onTriggered: {addOrEdit=false;edit.show();}
        },
        Action{iconName:"awesome/paste";name:"复制";
            onTriggered:{ if(currentRow>=0){
                    pasteModel.set(0,limitedTable.get(currentRow));
                    message.open("已复制。");}
                else{
                    message.open("请选择要复制的行！")
                }
            }
        },
        Action{iconName:"awesome/copy"; name:"粘帖";
            onTriggered:{  if(currentRow>=0){
                    pasteModel.setProperty(0,"ID",limitedTable.get(currentRow).ID)
                    limitedTable.set(currentRow,pasteModel.get(0));
                    selectIndex(currentRow);
                    message.open("已粘帖。");}
                else
                    message.open("请选择要粘帖的行！")
            }
        },
        Action{iconName: "awesome/trash_o";  name:"移除";
            onTriggered: {
                if(currentRow>=0){
                    selectIndex(currentRow-1);
                    limitedTable.remove(currentRow);
                    message.open("已移除。");}
                else
                    message.open("请选择要移除的行！")
            }
        }]
    inforMenu: [ //Action{iconName: "awesome/trash_o";  name:"详细信息" ; }
    ]
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
        Controls.TableViewColumn{role: "C7";title: "分开结束比\n       (%)";width:Units.dp(100);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C8";title: "焊接电压\n     (V)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C10";title:"层填充系数\n       (%)";width:Units.dp(100);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C9";title: "焊接速度Min/Max\n        (cm/min)";width:Units.dp(160);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C11";title:"代码";width:Units.dp(100);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;visible: false}
    ]

    Dialog{
        id:open1
        title:qsTr("打开限制条件")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        property var rulesList:[""]
        property var creatTimeList: [""]
        property var creatorList:[""]
        property var editTimeList: [""]
        property var editorList:[""]
        property string name
        onOpened:{//打开对话框加载model
            rulesList.length=0;
            creatTimeList.length=0;
            creatorList.length=0;
            editTimeList.length=0;
            editorList.length=0;
            if((typeof(limitedRulesNameList)==="string")&&(limitedRulesNameList!=="")){
                //名称存在且格式正确  那么 重新更新 表名称参数 找出最新的表
                var res =UserData.getDataOrderByTime(limitedRulesNameList,"EditTime")
                if((res!==-1)&&(typeof(res)==="object")){
                    for(var i=0;i<res.length;i++){
                        rulesList.push(res[i].Name.replace("限制条件"+limitedString,""));
                        creatTimeList.push(res[i].CreatTime);
                        creatorList.push(res[i].Creator);
                        editTimeList.push(res[i].EditTime);
                        editorList.push(res[i].Editor);
                    }
                    menuField.model=rulesList
                    menuField.selectedIndex=0;
                    menuField.helperText="创建时间:"+creatTimeList[0]+"\n创建者:"+creatorList[0]+"\n修改时间:"+editTimeList[0]+"\n修改者:"+editorList[0];
                    name=rulesList[0];
                }
            }
        }
        dialogContent: MenuField{id:menuField
            width:Units.dp(300)
            onItemSelected: {
                open1.name=open1.rulesList[index];
                menuField.helperText="创建时间:"+open1.creatTimeList[index]+"\n创建者:"+open1.creatorList[index]+"\n修改时间:"+open1.editTimeList[index]+"\n修改者:"+open1.editorList[index];
            }
        }
        onAccepted: {
            if(typeof(open1.name)==="string")
            {
                updateLimitedRulesName(open1.name.concat("限制条件"+limitedString))
            }
        }
        onRejected: {
            open1.name=limitedRulesName.replace("限制条件"+limitedString,"");
        }
    }
    Dialog{
        id:newFile
        title: saveAs?qsTr("另存限制条件"):qsTr("新建限制条件")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        property var nameList:[""]
        onOpened:{
            if((typeof(limitedRulesNameList)==="string")&&(limitedRulesNameList!=="")){
                //名称存在且格式正确  那么 重新更新 表名称参数 找出最新的表
                var res =UserData.getDataOrderByTime(limitedRulesNameList,"EditTime")
                if((res!==-1)&&(typeof(res)==="object")){
                    nameList.length=0;
                    for(var i=0;i<res.length;i++){
                        nameList.push(res[i].Name.replace("限制条件"+limitedString,""));
                    }
                }
            }
            newFileTextField.text=limitedRulesName.replace("限制条件"+limitedString,"")
            newFileTextField.helperText=qsTr("请输入新的限制条件名称！")
        }
        dialogContent:Item{
            width: Units.dp(300)
            height:newFileTextField.actualHeight
            TextField{
                id:newFileTextField
                helperText: "请输入新的限制条件名称！"
                width: Units.dp(300)
                anchors.horizontalCenter: parent.horizontalCenter
                onTextChanged: {
                    //检索数据库
                    var check=false;
                    for(var i=0;i<newFile.nameList.length;i++){
                        if(newFile.nameList[i]===text){
                            check=true;
                        }
                    }
                    if(check){
                        newFile.positiveButtonEnabled=false;
                        helperText="该限制条件名称已存在！"
                        hasError=true;
                    }else{
                        newFile.positiveButtonEnabled=true;
                        helperText="限制条件名称有效！"
                        hasError=false;
                    }
                    if(!isNaN(Number(text.charAt(0)))){ //开头字母为数字
                        newFile.positiveButtonEnabled=false;
                        helperText="限制条件名称开头不能数字！"
                        hasError=true;
                    }
                }
            }
        }
        onAccepted: {
            if(positiveButtonEnabled){
                //更新标题
                var title=newFileTextField.text.toString();
                //获取系统时间
                var time=UserData.getSysTime();
                var user=currentUserName
                //在次列表插入新的数据
                UserData.insertTable(limitedRulesNameList,"(?,?,?,?,?)",[title+"限制条件"+limitedString,time,user,time,user])
                //创建新的 焊接条件
                UserData.createTable(title+"限制条件"+limitedString,"ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT,C10 TEXT,C11 TEXT")
                if(saveAs){
                    limitedRulesName=title+"限制条件"+limitedString
                    save();
                }else{
                    //更新焊接规范
                    updateLimitedRulesName(title+"限制条件"+limitedString);
                }
            }
            newFileTextField.text="";
        }
        onRejected: newFileTextField.text=""
    }
    Dialog{
        id:remove
        title: qsTr("删除限制条件")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        onOpened:{
            positiveButtonEnabled=limitedRulesNameList.replace("列表","")===limitedRulesName?false:true
        }
        dialogContent: Item{
            width: label.contentWidth
            height:Units.dp(48)
            Label{
                id:label
                text:"确认删除\n"+limitedRulesName+"！"
                style: "menu"
            }
        }
        onAccepted: {
            if(positiveButtonEnabled){
                UserData.deleteTable(limitedRulesName);
                //清除次列表记录
                UserData.clearTable(limitedRulesNameList,"Name",limitedRulesName);
                //获取最新的数据表格
                var res=getLastRulesName();
                if(res!==-1){
                    updateLimitedRulesName(res)
                }
            }
        }
    }
    MyTextFieldDialog{
        id:edit
        title: addOrEdit?"添加限制条件":"编辑限制条件"
        objectName: "editDialog"
        repeaterModel:nameModel
        message: root.message
        onOpened: {
            var res=limitedMath(currentRow,currentRow+1);
            for(var i=0;i<res.length;i++){
                openText(i,res[i])
            }
            focusIndex=0;
            changeFocus(focusIndex)
        }
        onAccepted: {
            try{
                if(addOrEdit){
                    var str=model.count===0?"陶瓷衬垫":model.count===1?"打底层":model.count===2?"第二层":model.count===3?"填充层":model.count===4?"盖面层":"立板余高层"
                    model.append(
                                {"ID":str,"C1":getText(0)+"/"+getText(1)+"/"+getText(2),
                                    "C2":getText(3)+"/"+getText(4),
                                    "C3":getText(5)+"/"+getText(6),
                                    "C4":getText(7)+"/"+getText(8),
                                    "C5":getText(9),
                                    "C6":getText(10),
                                    "C7":getText(11),
                                    "C8":getText(12),
                                    "C9":getText(13)+"/"+getText(14),
                                    "C10":getText(15),
                                    "C11":limitedString==="_实芯碳钢_脉冲无_CO2_12"?"4":limitedString==="_药芯碳钢_脉冲无_CO2_12"?"68":limitedString==="_实芯碳钢_脉冲无_MAG_12"?"260":"388"
                                });
                }else{
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
                                  "C10":getText(15),
                                  "C11":limitedString==="_实芯碳钢_脉冲无_CO2_12"?"4":limitedString==="_药芯碳钢_脉冲无_CO2_12"?"68":limitedString==="_实芯碳钢_脉冲无_MAG_12"?"260":"388",
                              });
                }
            }
            catch(e){
                message.open(objectName+"error"+e.message)
            }
        }
    }
}
