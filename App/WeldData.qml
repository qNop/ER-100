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
        right:parent.right
        top:parent.top
        bottom: parent.bottom
        leftMargin:visible?0:Units.dp(250)
    }
    Behavior on anchors.leftMargin{NumberAnimation { duration: 400 ;easing.type:Easing.InQuad }}
    property var groovestyles: [
        qsTr( "平焊单边V型坡口T接头"), qsTr( "平焊单边V型坡口平对接"),  qsTr("平焊V型坡口平对接"),
        qsTr("横焊单边V型坡口T接头"), qsTr( "横焊单边V型坡口平对接"),
        qsTr("立焊单边V型坡口T接头"),  qsTr("立焊单边V型坡口平对接"), qsTr("立焊V型坡口平对接"),
        qsTr("水平角焊")  ]
    property Item message
    property var editData:["","","","","","","","","","","","","","",""]
    property string status:"空闲态"
    property alias weldTableIndex: tableView.currentRow

    property int currentGroove: 0
    //上次焊接规范名称
    property string weldRulesName;
    property bool weldTableEx:AppConfig.currentUserType=="超级用户"?true:false

    property string currentGrooveName

    property var rulesList;

    //焊接规范表格
    ListModel{id:weldTable;}

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

    onCurrentGrooveNameChanged: {
        var res=getLastRulesName();
        if(res!==-1){
            weldRulesName=res;
            weldTable.clear()
            res=UserData.getTableJson(weldRulesName)
            if(res!==-1){
                for(var i=0;i<res.length;i++){
                    weldTable.append(res[i])
                }
            }
        }
    }
    //当前页面关闭 则 关闭当前页面内 对话框

    onStatusChanged: {
        if(status==="坡口检测完成态"){
            weldTableIndex=0;
            weldTable.clear();
        }
    }
    function selectIndex(index){
        if((index<weldTable.count)&&(index>-1)){
            tableView.table.selection.clear();
            tableView.table.selection.select(index);
        }
        else
            message.open("索引超过条目上限或索引无效！")
    }

    TableCard{
        id:tableView
        footerText:  "系统当前处于"+status.replace("态","状态。")
        tableRowCount:7
        headerTitle: weldRulesName
        table.__listView.interactive: status!=="焊接态"
        model: weldTable
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
                                                     tableView.model.get(i).ID,
                                                     tableView.model.get(i).C1,
                                                     tableView.model.get(i).C2,
                                                     tableView.model.get(i).C3,
                                                     tableView.model.get(i).C4,
                                                     tableView.model.get(i).C5,
                                                     tableView.model.get(i).C6,
                                                     tableView.model.get(i).C7,
                                                     tableView.model.get(i).C8,
                                                     tableView.model.get(i).C9,
                                                     tableView.model.get(i).C10,
                                                     tableView.model.get(i).C11,
                                                     tableView.model.get(i).C12,
                                                     tableView.model.get(i).C13,
                                                     tableView.model.get(i).C14,
                                                     tableView.model.get(i).C15,
                                                     tableView.model.get(i).C16,])
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
                    var index =weldTableIndex;
                    if(weldTableIndex>=0){
                        editData[0]=tableView.model.get(index).ID;
                        editData[1]=tableView.model.get(index).C1;
                        editData[2]=tableView.model.get(index).C2;
                        editData[3]=tableView.model.get(index).C3;
                        editData[4]=tableView.model.get(index).C4;
                        editData[5]=tableView.model.get(index).C5;
                        editData[6]=tableView.model.get(index).C6;
                        editData[7]=tableView.model.get(index).C7;
                        editData[8]=tableView.model.get(index).C8;
                        editData[9]=tableView.model.get(index).C9;
                        editData[10]=tableView.model.get(index).C10;
                        editData[11]=tableView.model.get(index).C11;
                        editData[12]=tableView.model.get(index).C12;
                        editData[13]=tableView.model.get(index).C13;
                        editData[14]=tableView.model.get(index).C14;
                        editData[15]=tableView.model.get(index).C15;
                        editData[16]=tableView.model.get(index).C16;
                        message.open("已复制。");}
                    else{
                        message.open("请选择要复制的行！")
                    }
                }},
            Action{iconName:"awesome/paste"; name:"粘帖"
                onTriggered: {
                    if(weldTableIndex>=0){
                        var index=weldTableIndex;
                        tableView.model.set(index,
                                            {   "ID":editData[0],
                                                "C1":editData[1],"C2":editData[2],
                                                "C3":editData[3],"C4":editData[4],
                                                "C5":editData[5],"C6":editData[6],
                                                "C7":editData[7],"C8":editData[8],
                                                "C9":editData[9],"C10":editData[10],
                                                "C11":editData[11],"C12":editData[12],
                                                "C13":editData[13],"C14":editData[14],
                                                "C15":editData[15],"C16":editData[16],
                                            })
                        selectIndex(index)
                        message.open("已粘帖。");}
                    else
                        message.open("请选择要粘帖的行！")
                }
            },
            Action{iconName: "awesome/trash_o";  name:"移除";
                onTriggered: {
                    if(weldTableIndex>=0){
                        tableView.model.remove(weldTableIndex);
                        message.open("已移除。");}
                    else
                        message.open("请选择要移除的行！")
                }
            }]
        inforMenu: [ Action{iconName: "awesome/info";  name:"详细信息" ;
                onTriggered: {info.show();}
            }]
        funcMenu: [
            Action{iconName:"awesome/send_o";
                onTriggered:{
                    if(weldTableIndex>-1){
                        var index= weldTableIndex
                        var floor=tableView.model.get(index).C1.split("/");
                        ERModbus.setmodbusFrame(["W","201","17",
                                                 (Number(floor[0])*100+Number(floor[1])).toString(),
                                                 tableView.model.get(index).C2,
                                                 tableView.model.get(index).C3*10,
                                                 tableView.model.get(index).C4*10,
                                                 tableView.model.get(index).C5,
                                                 tableView.model.get(index).C6*10,
                                                 tableView.model.get(index).C7*10,
                                                 tableView.model.get(index).C8*10,
                                                 tableView.model.get(index).C9*10,
                                                 tableView.model.get(index).C10*10,
                                                 tableView.model.get(index).C11==="连续"?"0":"1",
                                                                                        tableView.model.get(index).C12*10,//层面积
                                                                                        tableView.model.get(index).C13*10,//单道面积
                                                                                        tableView.model.get(index).C14*10,//起弧位置偏移
                                                                                        tableView.model.get(index).C15*10,//起弧
                                                                                        tableView.model.get(index).C16*10,//起弧
                                                                                        tableView.rowCount//总共焊道号
                                                ]);
                        message.open("已下发焊接规范。");
                    }else {
                        message.open("请选择下发焊接规范。")
                    }
                }
                hoverAnimation:true;summary: "F4"
                name:"下发规范"
            }]
        tableData:[
            Controls.TableViewColumn{role: "C1";title:"   焊接\n层道数";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C2";title: "电流\n  A";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C3";title: "电压\n  V";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C4";title: " 摆幅\n  mm";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
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
                weldRulesName=open.name
                weldTable.clear()
                var res=UserData.getTableJson(open.name)
                if(res!==-1){
                    for(var i=0;i<res.length;i++){
                        weldTable.append(res[i])
                    }
                }
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
            weldRulesName=title+"焊接规范";
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
                text:"确认删除\n"+weldRulesName+"坡口参数！"
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

            UserData.clearTable(currentGrooveName+"次列表","Rules",weldRulesName);
            //获取最新的数据表格
            var res=getLastRulesName();
            if(res!==-1){
                weldRulesName=res;
                var listModel=UserData.getTableJson(weldRulesName);
                if(listModel!==-1)
                    for(var i=0;i<listModel.length;i++){
                        weldTable.append(listModel[i]);
                    }
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
            //只有一个空白行则插入新的行
            tableView.model.append(
                        weldTableEx?  { "ID":columnRepeater.itemAt(0).text,
                                         "C1":columnRepeater.itemAt(1).text,
                                         "C2":columnRepeater.itemAt(2).text,
                                         "C3":columnRepeater.itemAt(3).text,
                                         "C4":columnRepeater.itemAt(4).text,
                                         "C5":columnRepeater.itemAt(5).text,
                                         "C6":columnRepeater.itemAt(6).text,
                                         "C7":columnRepeater.itemAt(7).text,
                                         "C8":columnRepeater.itemAt(8).text,
                                         "C9":columnRepeater.itemAt(9).text,
                                         "C10":columnRepeater.itemAt(10).text,
                                         "C11":columnRepeater.itemAt(11).text,
                                         "C12":columnRepeater.itemAt(12).text,
                                         "C13":columnRepeater.itemAt(13).text,
                                         "C14":columnRepeater.itemAt(14).text,
                                         "C15":columnRepeater.itemAt(15).text,
                                         "C16":columnRepeater.itemAt(16).text}
                        :{ "ID":columnRepeater.itemAt(0).text,
                            "C1":columnRepeater.itemAt(1).text,
                            "C2":columnRepeater.itemAt(2).text,
                            "C3":columnRepeater.itemAt(3).text,
                            "C4":columnRepeater.itemAt(4).text,
                            "C5":columnRepeater.itemAt(5).text,
                            "C6":columnRepeater.itemAt(6).text,
                            "C7":columnRepeater.itemAt(7).text,
                            "C8":columnRepeater.itemAt(8).text,
                            "C9":columnRepeater.itemAt(9).text,
                            "C10":columnRepeater.itemAt(10).text,
                            "C11":columnRepeater.itemAt(11).text,
                            "C12":"0",
                            "C13":"0",
                            "C14":"0",
                            "C15":"0",
                            "C16":"0"}
                        )}
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
                        model:weldTableEx?[
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
                                               "预   约  停  止 ","层面积","道面积","起弧点X","起弧点Y","起弧点Z"]
                                         :[ "        NO.          ",
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
                                           "预   约  停  止 "]
                        delegate:Row{
                            property alias text: textField.text
                            property bool textFeildfocus:false
                            onTextFeildfocusChanged: {
                                if(textFeildfocus){
                                    textField.forceActiveFocus()
                                }
                            }
                            spacing: Units.dp(8)
                            Label{text:modelData;anchors.bottom: parent.bottom}
                            TextField{
                                id:textField
                                horizontalAlignment:TextInput.AlignHCenter
                                width: Units.dp(60)
                                onVisibleChanged: {
                                    if(visible){
                                        text="0";
                                    }
                                }
                                inputMethodHints: Qt.ImhDigitsOnly
                                onActiveFocusChanged: {
                                    if(activeFocus){
                                        item.focusIndex=index;
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
            //只有一个空白行则插入新的行
            tableView.model.set(weldTableIndex,
                                weldTableEx?  { "ID":editcolumnRepeater.itemAt(0).text,
                                                 "C1":editcolumnRepeater.itemAt(1).text,
                                                 "C2":editcolumnRepeater.itemAt(2).text,
                                                 "C3":editcolumnRepeater.itemAt(3).text,
                                                 "C4":editcolumnRepeater.itemAt(4).text,
                                                 "C5":editcolumnRepeater.itemAt(5).text,
                                                 "C6":editcolumnRepeater.itemAt(6).text,
                                                 "C7":editcolumnRepeater.itemAt(7).text,
                                                 "C8":editcolumnRepeater.itemAt(8).text,
                                                 "C9":editcolumnRepeater.itemAt(9).text,
                                                 "C10":editcolumnRepeater.itemAt(10).text,
                                                 "C11":editcolumnRepeater.itemAt(11).text,
                                                 "C12":editcolumnRepeater.itemAt(12).text,
                                                 "C13":editcolumnRepeater.itemAt(13).text,
                                                 "C14":editcolumnRepeater.itemAt(14).text,
                                                 "C15":editcolumnRepeater.itemAt(15).text,
                                                 "C16":editcolumnRepeater.itemAt(16).text}
                                :{ "ID":editcolumnRepeater.itemAt(0).text,
                                    "C1":editcolumnRepeater.itemAt(1).text,
                                    "C2":editcolumnRepeater.itemAt(2).text,
                                    "C3":editcolumnRepeater.itemAt(3).text,
                                    "C4":editcolumnRepeater.itemAt(4).text,
                                    "C5":editcolumnRepeater.itemAt(5).text,
                                    "C6":editcolumnRepeater.itemAt(6).text,
                                    "C7":editcolumnRepeater.itemAt(7).text,
                                    "C8":editcolumnRepeater.itemAt(8).text,
                                    "C9":editcolumnRepeater.itemAt(9).text,
                                    "C10":editcolumnRepeater.itemAt(10).text,
                                    "C11":editcolumnRepeater.itemAt(11).text,
                                    "C12":"0",
                                    "C13":"0",
                                    "C14":"0",
                                    "C15":"0",
                                    "C16":"0"}
                                )}
        onOpened: {
            if(weldTableIndex>-1){
                //复制数据到 editData
                var index=weldTableIndex
                editcolumnRepeater.itemAt(0).text=tableView.model.get(index).ID;
                editcolumnRepeater.itemAt(1).text=tableView.model.get(index).C1;
                editcolumnRepeater.itemAt(2).text=tableView.model.get(index).C2;
                editcolumnRepeater.itemAt(3).text=tableView.model.get(index).C3;
                editcolumnRepeater.itemAt(4).text=tableView.model.get(index).C4;
                editcolumnRepeater.itemAt(5).text=tableView.model.get(index).C5;
                editcolumnRepeater.itemAt(6).text=tableView.model.get(index).C6;
                editcolumnRepeater.itemAt(7).text=tableView.model.get(index).C7;
                editcolumnRepeater.itemAt(8).text=tableView.model.get(index).C8;
                editcolumnRepeater.itemAt(9).text=tableView.model.get(index).C9;
                editcolumnRepeater.itemAt(10).text=tableView.model.get(index).C10;
                editcolumnRepeater.itemAt(11).text=tableView.model.get(index).C11;
                editcolumnRepeater.itemAt(12).text=tableView.model.get(index).C12;
                editcolumnRepeater.itemAt(13).text=tableView.model.get(index).C13;
                editcolumnRepeater.itemAt(14).text=tableView.model.get(index).C14;
                editcolumnRepeater.itemAt(15).text=tableView.model.get(index).C15;
                aeditcolumnRepeater.itemAt(16).text=tableView.model.get(index).C16;
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
                    anchors.left: parent.left//editimage.right
                    anchors.leftMargin: Units.dp(16)
                    anchors.right: parent.right
                    Repeater{
                        id:editcolumnRepeater
                        model:weldTableEx?[
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
                                               "预   约  停  止 ",
                                               "层面积","道面积","起弧点X","起弧点Y","起弧点Z"]
                                         :[ "        NO.          ",
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
                                           "预   约  停  止 "]
                        delegate:Row{
                            property alias text: edittextField.text
                            property bool textFeildfocus:false
                            onTextFeildfocusChanged: {
                                if(textFeildfocus){
                                    edittextField.forceActiveFocus()
                                }
                            }
                            spacing: Units.dp(8)
                            Label{text:modelData;anchors.bottom: parent.bottom}
                            TextField{
                                id:edittextField
                                horizontalAlignment:TextInput.AlignHCenter
                                width: Units.dp(60)
                                inputMethodHints: Qt.ImhDigitsOnly
                                onActiveFocusChanged: {
                                    if(activeFocus){
                                        item1.focusIndex=index;
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
    //链接 weldmath
    Connections{
        target: WeldMath
        onWeldRulesChanged:{
            console.log(value);
            //确保数组数值正确
            if((typeof(value)==="object")&&(value.length===18)&&(value[0]==="Successed")){
                weldTable.set(Number(value[1])-1,{
                                  "ID":value[1],
                                  "C1":value[2],
                                  "C2":value[3],
                                  "C3":value[4],
                                  "C4":value[5],
                                  "C5":value[6],
                                  "C6":value[7],
                                  "C7":value[8],
                                  "C8":value[9],
                                  "C9":value[10],
                                  "C10":value[11],
                                  "C11":value[12],
                                  "C12":value[13],
                                  "C13":value[14],
                                  "C14":value[15],
                                  "C15":value[16],
                                  "C16":value[17]
                              })
            }else{//输出错误
                message.open(value[0]);
            }
        }
        onGrooveRulesChanged:{
            console.log(value);
            if(value[0]==="Clear"){
                //清除焊接规范表格
                weldTable.clear();
            }
            else if(value[0]==="Finish"){
                // 切换状态为端部暂停
                if(status==="坡口检测完成态"){
                    //下发端部暂停态
                    //  ERModbus.setmodbusFrame(["W","0","1","5"]);
                }
                tableView.forceActiveFocus();
                weldTableIndex=0;
                selectIndex(weldTableIndex);
            }
        }
    }

    Connections{
        target: ERModbus
        //frame[0] 代表状态 1代读取的寄存器地址 2代表返回的 第一个数据 3代表返回的第二个数据 依次递推
        onModbusFrameChanged:{
            //通讯帧接受成功
            if(frame[0]==="Success"){
                if((frame[1]==="200")&&(status==="焊接端部暂停态")){
                    if((frame[2]!==weldTableIndex.toString())){
                        if(frame[2]!=="99"){
                            //当前焊道号与实际焊道号不符 更换当前焊道
                            weldTableIndex=Number(frame[2]);
                            selectIndex(weldTableIndex);
                        }
                        //选择行数据有效
                        if((weldTableIndex<weldTable.count)&&(weldTableIndex>-1)){
                            //分离层/道
                            var floor=weldTable.get(weldTableIndex).C1.split("/");
                            ERModbus.setmodbusFrame(["W","201","17",
                                                     (Number(floor[0])*100+Number(floor[1])).toString(),
                                                     weldTable.get(weldTableIndex).C2,
                                                     weldTable.get(weldTableIndex).C3*10,
                                                     weldTable.get(weldTableIndex).C4*10,
                                                     weldTable.get(weldTableIndex).C5,
                                                     weldTable.get(weldTableIndex).C6*10,
                                                     weldTable.get(weldTableIndex).C7*10,
                                                     weldTable.get(weldTableIndex).C8*10,
                                                     weldTable.get(weldTableIndex).C9*10,
                                                     weldTable.get(weldTableIndex).C10*10,
                                                     weldTable.get(weldTableIndex).C11==="连续"?"0":"1",
                                                                                               weldTable.get(weldTableIndex).C12*10,//层面积
                                                                                               weldTable.get(weldTableIndex).C13*10,//单道面积
                                                                                               weldTable.get(weldTableIndex).C14*10,//起弧位置偏移
                                                                                               weldTable.get(weldTableIndex).C15*10,//起弧
                                                                                               weldTable.get(weldTableIndex).C16*10,//起弧
                                                                                               weldTable.count//总共焊道号
                                                    ]);
                        }else
                            //发送全0数据
                            ERModbus.setmodbusFrame((["W","201","17","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0"]));
                    }else
                        ERModbus.setmodbusFrame(["R","0","3"]);
                }
            }
        }
    }
}

