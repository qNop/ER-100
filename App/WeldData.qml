import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.2 as Controls
import QtQuick.Window 2.2
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0
import WeldSys.WeldMath 1.0
import QtQuick.Layouts 1.1
import QtCharts 2.1

FocusScope{
    id:root
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "WeldData"
    anchors{
        left:parent.left
        top:parent.top
        bottom: parent.bottom
        leftMargin:visible?0:Units.dp(250)
    }
   width:parent.width
    Behavior on anchors.leftMargin{NumberAnimation { duration: 400 }}

    property Item message
    property string status:"空闲态"
    property alias weldTableIndex: tableView.currentRow
    property alias model: tableView.model
    //上次焊接规范名称
    property string weldRulesName;
    property bool weldTableEx
    property string currentGrooveName
    //外部更新数据
    signal updateModel(string str,var data);
    signal updateWeldRulesName(string str);

    property var weldCondtion: [
        "        NO.          ",
        "层    /道      号 ",
        "电      流  (A)   ",
        "电      压  (V)   ",
        "摆      幅(mm) ",
        "摆      频(mm) ",
        "焊速(cm/min)",
        "焊接线X(mm)",
        "焊接线Y(mm)",
        "内   停  留 (s)  ",
        "外   停  留 (s)  ",
        "停  止 时 间(s)","层面积","道面积","起弧点X","起弧点Y","起弧点Z"]
    ListModel{id:pasteModel;
        ListElement{ID:"";C1:"";C2:"";C3:"";C4:"";C5:"";C6:"";C7:"";C8:"";C9:"";C10:"";C11:"";C12:"";C13:"";C14:"";C15:"";C16:""}
    }

    function getLastRulesName(){
        if((typeof(currentGrooveName)==="string")&&(currentGrooveName!=="")){
            //名称存在且格式正确  那么 重新更新 表名称参数 找出最新的表
            var res =UserData.getWeldRulesNameOrderByTime(currentGrooveName+"次列表","EditTime")
            if((res!==-1)&&(typeof(res)==="object")){
                return res[0].Rules;
            }else
                return -1;
        }
        return -1;
    }
    //当前页面关闭 则 关闭当前页面内 对话框
    onStatusChanged: {
        if(status==="坡口检测完成态"){
            weldTableIndex=0;
            selectIndex(0)
        }
    }
    function selectIndex(index){
        if((index<model.count)&&(index>-1)){
             tableView.table.selection.clear();
            tableView.table.selection.select(index);
        }
        else{
            message.open("索引超过条目上限或索引无效！")
        }
    }
    onVisibleChanged: {
        if(visible){
            tableView.table.__listView.forceActiveFocus();
            if((tableView.table.selection.count===0)&&(tableView.model.count!==0)&&(tableView.currentRow===-1)){
                tableView.currentRow=0;
                tableView.table.selection.select(0);
            }
        }
    }

    TableCard{
        id:tableView
        footerText:"系统当前处于"+status.replace("态","状态。")
        tableRowCount:7
        headerTitle: weldRulesName
        table.__listView.interactive: status!=="焊接态"
        fileMenu: [
            Action{iconName:"awesome/calendar_plus_o";name:"新建";
                onTriggered: newFile.show();},
            Action{iconName:"awesome/folder_open_o";name:"打开";
                onTriggered: open.show();},
            Action{iconName:"awesome/save";name:"保存";
                onTriggered: {
                    if((typeof(weldRulesName)==="string")&&(weldRulesName!=="")){
                        //清除保存数据库
                        UserData.clearTable(weldRulesName,"","");
                        for(var i=0;i<tableView.table.rowCount;i++){
                            //插入新的数据
                            UserData.insertTable(weldRulesName,"(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",[
                                                     model.get(i).ID,
                                                     model.get(i).C1,
                                                     model.get(i).C2,
                                                     model.get(i).C3,
                                                     model.get(i).C4,
                                                     model.get(i).C5,
                                                     model.get(i).C6,
                                                     model.get(i).C7,
                                                     model.get(i).C8,
                                                     model.get(i).C9,
                                                     model.get(i).C10,
                                                     model.get(i).C11,
                                                     model.get(i).C12,
                                                     model.get(i).C13,
                                                     model.get(i).C14,
                                                     model.get(i).C15,
                                                     model.get(i).C16,])
                        }
                        message.open("焊接规范已保存。");}
                    else{
                        message.open("焊接规范名称格式不符，规范未保存！")
                    }
                }},
            Action{iconName:"awesome/credit_card";name:"另存为";
                onTriggered: {
                    //备份数据 新建表格
                    //插入表格数据
                }
            },
            Action{iconName:"awesome/calendar_times_o";name:"删除";enabled: currentGrooveName+"焊接规范"===weldRulesName?false:true
                onTriggered: remove.show();}
        ]
        editMenu:[
            Action{iconName:"awesome/plus_square_o";onTriggered: add.show();name:"添加"},
            Action{iconName:"awesome/edit";onTriggered: edit.show();name:"编辑";
            },
            Action{iconName:"awesome/copy";name:"复制";
                onTriggered: {
                    if(weldTableIndex>=0){
                        pasteModel.set(0,model.get(weldTableIndex));
                        message.open("已复制。");}
                    else{
                        message.open("请选择要复制的行！")
                    }
                }},
            Action{iconName:"awesome/paste"; name:"粘帖"
                onTriggered: {
                    if(weldTableIndex>=0){
                        updateModel("Set", pasteModel.get(0));
                        message.open("已粘帖。");}
                    else
                        message.open("请选择要粘帖的行！")
                }
            },
            Action{iconName: "awesome/trash_o";  name:"移除";
                onTriggered: {
                    if(weldTableIndex>=0){
                        updateModel("Remove",{})
                        message.open("已移除。");}
                    else
                        message.open("请选择要移除的行！")
                }
            },
            Action{iconName:"awesome/calendar_o";name:"清空";
                onTriggered: {
                    weldTableIndex=-1;
                    updateModel("Clear",{});
                    message.open("已清空。");
                }}
        ]
        inforMenu: [ Action{iconName: "awesome/info";  name:"详细信息" ;
                onTriggered: {info.show();}
            }]
        funcMenu: [
            Action{iconName:"awesome/send_o";name:"下发规范"
                onTriggered:{
                    if(weldTableIndex>-1){
                        var index= weldTableIndex
                        var floor=tableView.model.get(index).C1.split("/");
                        ERModbus.setmodbusFrame(["W","201","17",
                                                 (Number(floor[0])*100+Number(floor[1])).toString(),
                                                 model.get(index).C2,
                                                 model.get(index).C3*10,
                                                 model.get(index).C4*10,
                                                 model.get(index).C5,
                                                 model.get(index).C6*10,
                                                 model.get(index).C7*10,
                                                 model.get(index).C8*10,
                                                 model.get(index).C9*10,
                                                 model.get(index).C10*10,
                                                 model.get(index).C11==="连续"?"0":"1",
                                                                              model.get(index).C12*10,//层面积
                                                                              model.get(index).C13*10,//单道面积
                                                                              model.get(index).C14*10,//起弧位置偏移
                                                                              model.get(index).C15*10,//起弧
                                                                              model.get(index).C16*10,//起弧
                                                                              tableView.table.rowCount//总共焊道号
                                                ]);
                        message.open("已下发焊接规范。");
                    }else {
                        message.open("请选择下发焊接规范。")
                    }
                }
            },
            Action{iconName:"awesome/send_o";name:"计算道面积"
                onTriggered: {weldArea.show()}
            }
        ]
        tableData:[
            Controls.TableViewColumn{role: "C1";title:"   焊接\n层道数";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C2";title: "电流\n  A";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C3";title: "电压\n  V";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C4";title: " 摆幅\n  mm";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;visible: weldTableEx},
            Controls.TableViewColumn{role: "C5";title: "  摆频\n次/min";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C6";title: "焊接速度\n cm/min";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C7";title: "焊接线\n X mm";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C8";title: "焊接线\n Y mm";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C9";title: "内停留\n     s";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter; },
            Controls.TableViewColumn{role: "C10";title: "外停留\n     s";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C11";title: "停止\n时间";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C12";title: "层面积";width:Units.dp(70);movable:false;resizable:false;visible: weldTableEx},
            Controls.TableViewColumn{role: "C13";title: "道面积";width:Units.dp(70);movable:false;resizable:false;visible: weldTableEx},
            Controls.TableViewColumn{role: "C14";title: "起弧x";width:Units.dp(70);movable:false;resizable:false;visible: weldTableEx},
            Controls.TableViewColumn{role: "C15";title: "起弧y";width:Units.dp(70);movable:false;resizable:false;visible: weldTableEx},
            Controls.TableViewColumn{role: "C16";title: "起弧z";width:Units.dp(70);movable:false;resizable:false;visible: weldTableEx}
        ]

    }

    Dialog{
        id:open
        title:qsTr("打开坡口参数")
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
            if((typeof(currentGrooveName)==="string")&&(currentGrooveName!=="")){
                //名称存在且格式正确  那么 重新更新 表名称参数 找出最新的表
                var res =UserData.getWeldRulesNameOrderByTime(currentGrooveName+"次列表","EditTime")
                if((res!==-1)&&(typeof(res)==="object")){
                    for(var i=0;i<res.length;i++){
                        rulesList.push(res[i].Rules);
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
                open.name=open.rulesList[index]
                menuField.helperText="创建时间:"+open.creatTimeList[index]+"\n创建者:"+open.creatorList[index]+"\n修改时间:"+open.editTimeList[index]+"\n修改者:"+open.editorList[index];
                console.log("创建时间:"+open.creatTimeList[index]+"\n创建者:"+open.creatorList[index]+"\n修改时间:"+open.editTimeList[index]+"\n修改者:"+open.editorList[index])
            }
        }
        onAccepted: {
            if(typeof(open.name)==="string")
            {
                updateWeldRulesName(open.name)
            }
        }
        onRejected: {
            open.name=weldRulesName
        }
    }
    Dialog{
        id:newFile
        title: qsTr("新建焊接规范")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        property var nameList:[""]
        onOpened:{
            if((typeof(currentGrooveName)==="string")&&(currentGrooveName!=="")){
                //名称存在且格式正确  那么 重新更新 表名称参数 找出最新的表
                var res =UserData.getWeldRulesNameOrderByTime(currentGrooveName+"次列表","EditTime")
                if((res!==-1)&&(typeof(res)==="object")){
                    nameList.length=0;
                    for(var i=0;i<res.length;i++){
                        nameList.push(res[i].Rules);
                    }
                }
            }
            newFileTextField.text=weldRulesName.replace("焊接规范","")
            newFileTextField.helperText=qsTr("请输入新的焊接规范名称！")
        }
        dialogContent:Item{
            width: Units.dp(300)
            height:newFileTextField.actualHeight
            TextField{
                id:newFileTextField
                text:weldRulesName
                helperText: "请输入新的焊接规范名称！"
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
                        helperText="该焊接规范名称已存在！"
                        hasError=true;
                    }else{
                        newFile.positiveButtonEnabled=true;
                        helperText="焊接规范名称有效！"
                        hasError=false;
                    }
                }
            }
        }
        onAccepted: {
            //更新标题
            var title=newFileTextField.text.toString();
            updateWeldRulesName(title+"焊接规范");
            //获取系统时间
            var time=UserData.getSysTime();
            var user=AppConfig.currentUserName
            //在次列表插入新的数据
            UserData.insertTable(currentGrooveName+"次列表","(?,?,?,?,?,?,?,?)",[title+"焊接规范",title+"限制条件",title+"过程分析",title+"焊接曲线",time,user,time,user])
            //创建新的 焊接条件
            UserData.createTable(title+"焊接规范","ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT,C10 TEXT,C11 TEXT,C12 TEXT,C13 TEXT,C14 TEXT,C15 TEXT,C16 TEXT")
            //创建新的 限制条件
            UserData.createTable(title+"限制条件","ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT")
            //创建新的 曲线

            //创建新的过程分析列表
            UserData.createTable(title+"过程分析","ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT")

        }
    }
    Dialog{
        id:remove
        title: qsTr("删除焊接规范")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        onOpened:{
            positiveButtonEnabled=currentGrooveName+"焊接规范"===weldRulesName?false:true
        }
        dialogContent: Item{
            width: label.contentWidth
            height:Units.dp(48)
            Label{
                id:label
                text:"确认删除\n"+weldRulesName+"！"
                style: "menu"
            }
        }
        onAccepted: {
            UserData.deleteTable(weldRulesName);
            //删除限制条件列表
            UserData.deleteTable(weldRulesName.replace("焊接规范","限制条件"))
            //删除曲线列表

            //删除过程分析列表
            UserData.deleteTable(weldRulesName.replace("焊接规范","过程分析"))
            //清除次列表
            UserData.clearTable(currentGrooveName+"次列表","Rules",weldRulesName);
            //获取最新的数据表格
            var res=getLastRulesName();
            if(res!==-1){
                updateWeldRulesName(res)
            }
        }
    }
    Dialog{
        id:add
        title: qsTr("添加焊接规范")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        globalMouseAreaEnabled:false
        onAccepted: {
            updateModel("Append", pasteModel.get(0))
        }
        onOpened: {
            pasteModel.set(0,{"ID":"0", "C1":"0","C2":"0","C3":"0","C4":"0","C5":"0","C6":"0","C7":"0","C8":"0","C9":"0","C10":"0","C11":"0","C12":"0","C13":"0","C14":"0","C15":"0","C16":"0"})
            for(var i=0;i<weldCondtion.length;i++){
                columnRepeater.itemAt(i).text="0";
            }
        }
        dialogContent: [
            Item{
                id:item
                property int  focusIndex;
                width: Units.dp(140)
                height:column.height
                Column{
                    id:column
                    anchors.top:parent.top
                    anchors.left: parent.left
                    anchors.leftMargin: Units.dp(16)
                    anchors.right: parent.right
                    Repeater{
                        id:columnRepeater
                        model:weldCondtion
                        delegate:Row{
                            property alias text: textField.text
                            property bool textFeildfocus:false
                            onTextFeildfocusChanged: {
                                if(textFeildfocus){
                                    textField.forceActiveFocus()
                                }
                            }
                            spacing: Units.dp(8)
                            Label{text:modelData;anchors.bottom: parent.bottom
                                visible:weldTableEx?true:index<12?true:false }
                            TextField{
                                id:textField
                                horizontalAlignment:TextInput.AlignHCenter
                                visible:weldTableEx?true:index<12?true:false
                                width: Units.dp(60)
                                inputMethodHints: Qt.ImhDigitsOnly
                                onActiveFocusChanged: {
                                    if(activeFocus){
                                        item.focusIndex=index;
                                    }
                                }
                                onTextChanged: {
                                    switch(index){
                                    case 0:pasteModel.setProperty(0,"ID",text);break;
                                    case 1:pasteModel.setProperty(0,"C1",text);break;
                                    case 2:pasteModel.setProperty(0,"C2",text);break;
                                    case 3:pasteModel.setProperty(0,"C3",text);break;
                                    case 4:pasteModel.setProperty(0,"C4",text);break;
                                    case 5:pasteModel.setProperty(0,"C5",text);break;
                                    case 6:pasteModel.setProperty(0,"C6",text);break;
                                    case 7:pasteModel.setProperty(0,"C7",text);break;
                                    case 8:pasteModel.setProperty(0,"C8",text);break;
                                    case 9:pasteModel.setProperty(0,"C9",text);break;
                                    case 10:pasteModel.setProperty(0,"C10",text);break;
                                    case 11:pasteModel.setProperty(0,"C11",text);break;
                                    case 12:pasteModel.setProperty(0,"C12",text);break;
                                    case 13:pasteModel.setProperty(0,"C13",text);break;
                                    case 14:pasteModel.setProperty(0,"C14",text);break;
                                    case 15:pasteModel.setProperty(0,"C15",text);break;
                                    case 16:pasteModel.setProperty(0,"C16",text);break;
                                    }
                                }
                            }}
                    }
                }
                Keys.onDownPressed: {
                    if(focusIndex<columnRepeater.count){
                        if(focusIndex!=-1)
                            columnRepeater.itemAt(focusIndex).textFeildfocus=false;
                        focusIndex++;
                        columnRepeater.itemAt(focusIndex).textFeildfocus=true;
                    }
                }
                Keys.onUpPressed: {
                    if(focusIndex>-1){
                        if(focusIndex<columnRepeater.count)
                            columnRepeater.itemAt(focusIndex).textFeildfocus=false;
                        focusIndex--;
                        columnRepeater.itemAt(focusIndex).textFeildfocus=true;
                    }
                }
                onVisibleChanged:  focusIndex=-1;
            }
        ]
    }
    Dialog{
        id:edit
        title: qsTr("编辑焊接规范")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        globalMouseAreaEnabled:false
        onAccepted: {
            updateModel("Set",pasteModel.get(0))
        }
        onOpened: {
            if(weldTableIndex>-1){
                //复制数据到 editData
                var index=weldTableIndex
                editcolumnRepeater.itemAt(0).text=model.get(index).ID;
                editcolumnRepeater.itemAt(1).text=model.get(index).C1;
                editcolumnRepeater.itemAt(2).text=model.get(index).C2;
                editcolumnRepeater.itemAt(3).text=model.get(index).C3;
                editcolumnRepeater.itemAt(4).text=model.get(index).C4;
                editcolumnRepeater.itemAt(5).text=model.get(index).C5;
                editcolumnRepeater.itemAt(6).text=model.get(index).C6;
                editcolumnRepeater.itemAt(7).text=model.get(index).C7;
                editcolumnRepeater.itemAt(8).text=model.get(index).C8;
                editcolumnRepeater.itemAt(9).text=model.get(index).C9;
                editcolumnRepeater.itemAt(10).text=model.get(index).C10;
                editcolumnRepeater.itemAt(11).text=model.get(index).C11;
                editcolumnRepeater.itemAt(12).text=model.get(index).C12;
                editcolumnRepeater.itemAt(13).text=model.get(index).C13;
                editcolumnRepeater.itemAt(14).text=model.get(index).C14;
                editcolumnRepeater.itemAt(15).text=model.get(index).C15;
                editcolumnRepeater.itemAt(16).text=model.get(index).C16;
                pasteModel.set(0,model.get(index));
            }
            else{
                message.open("请选择要编辑的行！")
                positiveButtonEnabled=false;
            }
        }
        dialogContent: [
            Item{
                id:item1
                property int  focusIndex;
                Keys.onDownPressed: {
                    if(focusIndex<editcolumnRepeater.count){
                        if(focusIndex!=-1)
                            editcolumnRepeater.itemAt(focusIndex).textFeildfocus=false;
                        focusIndex++;
                        editcolumnRepeater.itemAt(focusIndex).textFeildfocus=true;
                    }
                }
                Keys.onUpPressed: {
                    if(focusIndex>-1){
                        if(focusIndex<editcolumnRepeater.count)
                            editcolumnRepeater.itemAt(focusIndex).textFeildfocus=false;
                        focusIndex--;
                        editcolumnRepeater.itemAt(focusIndex).textFeildfocus=true;
                    }
                }
                onVisibleChanged:  focusIndex=-1;
                width: Units.dp(140)
                height:editcolumn.height
                Column{
                    id:editcolumn
                    anchors.top:parent.top
                    anchors.left: parent.left
                    anchors.leftMargin: Units.dp(16)
                    anchors.right: parent.right
                    Repeater{
                        id:editcolumnRepeater
                        model:weldCondtion
                        delegate:Row{
                            property alias text: edittextField.text
                            property bool textFeildfocus:false
                            onTextFeildfocusChanged: {
                                if(textFeildfocus){
                                    edittextField.forceActiveFocus()
                                }
                            }
                            spacing: Units.dp(8)
                            Label{text:modelData;anchors.bottom: parent.bottom
                                visible:weldTableEx?true:index<12?true:false}
                            TextField{
                                id:edittextField
                                visible:weldTableEx?true:index<12?true:false
                                horizontalAlignment:TextInput.AlignHCenter
                                width: Units.dp(60)
                                inputMethodHints: Qt.ImhDigitsOnly
                                onActiveFocusChanged: {
                                    if(activeFocus){
                                        item1.focusIndex=index;
                                    }
                                }
                                onTextChanged: {
                                    switch(index){
                                    case 0:pasteModel.setProperty(0,"ID",text);break;
                                    case 1:pasteModel.setProperty(0,"C1",text);break;
                                    case 2:pasteModel.setProperty(0,"C2",text);break;
                                    case 3:pasteModel.setProperty(0,"C3",text);break;
                                    case 4:pasteModel.setProperty(0,"C4",text);break;
                                    case 5:pasteModel.setProperty(0,"C5",text);break;
                                    case 6:pasteModel.setProperty(0,"C6",text);break;
                                    case 7:pasteModel.setProperty(0,"C7",text);break;
                                    case 8:pasteModel.setProperty(0,"C8",text);break;
                                    case 9:pasteModel.setProperty(0,"C9",text);break;
                                    case 10:pasteModel.setProperty(0,"C10",text);break;
                                    case 11:pasteModel.setProperty(0,"C11",text);break;
                                    case 12:pasteModel.setProperty(0,"C12",text);break;
                                    case 13:pasteModel.setProperty(0,"C13",text);break;
                                    case 14:pasteModel.setProperty(0,"C14",text);break;
                                    case 15:pasteModel.setProperty(0,"C15",text);break;
                                    case 16:pasteModel.setProperty(0,"C16",text);break;
                                    }
                                }
                            }}
                    }
                }
            }
        ]
    }
    Dialog{
        id:info
        title: qsTr("焊接规范信息")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        globalMouseAreaEnabled:false
        property int currentGroove : AppConfig.currentGroove
        dialogContent: [
            Label{text:"焊接位置："+String(AppConfig.currentGroove&0x00000003)},
            Label{text:"坡口形式："+String(AppConfig.currentGroove&0x00000004)},
            Label{text:"接头形式："+String(AppConfig.currentGroove&0x00000008)},
            Label{text:"衬垫形式："+String(AppConfig.currentGroove&0x00000030)},
            Label{text:"操作用户："+AppConfig.currentUserName},
            Label{text:"用户类别："+AppConfig.currentUserType},
            Label{text:"创建时间："+AppConfig.currentUserType},
            Label{text:"编辑时间："+AppConfig.currentUserType},
            Label{text:"总计焊接时间："+10},
            Label{text:"总计气体消耗量："+10}
        ]
    }
    Dialog{
        id:weldArea
        title: qsTr("计算道面积")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        property var current: 0
        property var weldSpeed: 0
        property var k: 0
        property var met: 0
        property var area: 0

        signal changedArea();
        onOpened: {
            current=0;
            weldSpeed=0;
            k=0;
            met=0;
            area=0;
        }
        Row{
            Repeater{
                model:["焊接电流:","焊接速度:","层填充系数:","溶敷系数:","填充量:"]
                delegate: Row{
                    property alias text: textfield.text
                    Label{anchors.bottom: parent.bottom;text:modelData}
                    TextField{id:textfield
                        horizontalAlignment:TextInput.AlignHCenter
                        width: Units.dp(60)
                        onTextChanged: {
                            switch(index){
                            case 0: weldArea.current=Number(text);break;
                            case 1: weldArea.weldSpeed=Number(text);break;
                            case 2: weldArea.k=Number(text);break;
                            case 3: weldArea.met=Number(text);break;
                            case 4: weldArea.area=Number(text);break;
                            }
                        }
                    }
                }
            }
            Button{
                text:"计算"
                onPressedChanged: {
                    if(pressed){
                        if(weldArea.weldSpeed){
                           weldArea.area=WeldMath.getWeldArea(weldArea.current,weldArea.weldSpeed,weldArea.k,weldArea.met);
                           // WeldMath.getWeldA(weldArea.current,weldArea.weldSpeed,weldArea.k,weldArea.met,weldArea.area)
                            console.log("计算weldArea.area"+weldArea.area)
                        }
                    }
                }
            }

        }
    }
  Component.onCompleted: {
      tableView.table.__listView.forceActiveFocus();
      if((tableView.table.selection.count===0)&&(tableView.model.count!==0)&&(tableView.currentRow===-1)){
          tableView.currentRow=0;
          tableView.table.selection.select(0);
      }
  }
}

