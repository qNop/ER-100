import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.2 as Controls
import QtQuick.Window 2.2
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0
import WeldSys.WeldMath 1.0
import QtQuick.Layouts 1.1

FocusScope{
    id:root
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "WeldAnalyse"
    anchors{
        left:parent.left
        right:parent.right
        top:parent.top
        bottom: parent.bottom
        leftMargin:visible?0:Units.dp(250)
    }
    Behavior on anchors.leftMargin{NumberAnimation { duration: 400 ;easing.type:Easing.InQuad }}
    property bool actionEnable:false
    property var groovestyles: [
        qsTr( "平焊单边V型坡口T接头"), qsTr( "平焊单边V型坡口平对接"),  qsTr("平焊V型坡口平对接"),
        qsTr("横焊单边V型坡口T接头"), qsTr( "横焊单边V型坡口平对接"),
        qsTr("立焊单边V型坡口T接头"),  qsTr("立焊单边V型坡口平对接"), qsTr("立焊V型坡口平对接"),
        qsTr("水平角焊")  ]
    property Item message
    property var editData:["","","","","","","","","","","","","","",""]
    property string status:"空闲态"
    property alias weldTableCurrentRow: tableView.currentRow
    property alias weldDataModel: tableView.model
    //上次焊接规范名称
    property alias weldRulesName: tableView.headerTitle
    property bool weldTableEx:AppConfig.currentUserType=="SuperUser"?true:false
    property  int  currentGroove:0
    //当前层数
    property int floorNum:0
    //焊缝长度
    property int weldLength: 0
    //当前焊缝所需要时间
    property var weldTime;
    //
    property int currentTimeHour:0
    //
    property int currentTimeMinutes:0
    //
    property int currentTimeSecond:0
    //
    property int  hour: 0
    property int  minutes: 0
    property int  second: 0
    //当前道数
    property int weldNum:0
    //总共多少层
    property int totalFloorNum: 0
    //总共多少道
    property int totalWeldNum:0
    Keys.onPressed: {
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
    onWeldTableCurrentRowChanged: {
        if(weldTableCurrentRow!==-1){
            actionEnable=weldDataModel.get(weldTableCurrentRow).ID!==""?true:false
            tableView.selection.__selectOne(weldTableCurrentRow);
            if(weldDataModel.get(weldTableCurrentRow).C1!==""){
                var floor=weldDataModel.get(weldTableCurrentRow).C1.split("/");
                floorNum=floor[0];
                weldNum=floor[1];
                if(weldTime.length>1){
                    currentTimeHour=Math.floor(weldTime[weldTableCurrentRow]/3600);
                    var res=Math.floor(weldTime[weldTableCurrentRow]%3600);
                    currentTimeMinutes=Math.floor(res/60);
                    currentTimeSecond=Math.floor(res%60);
                    console.log(weldTime[weldTime.length-1])
                    hour=Math.floor(weldTime[weldTime.length-1]/3600);
                    res=Math.floor(weldTime[weldTime.length-1]%3600);
                    minutes=Math.floor(res/60);
                    second=Math.floor(res%60);
                    console.log(weldTime)
                }
            }
        } }
    //当前页面关闭 则 关闭当前页面内 对话框
    onVisibleChanged: {
        if(visible==false){
            if(edit.showing) edit.close();
            if(open.showing) open.close();
            if(add.showing) add.close();

        }else{
            root.forceActiveFocus();
            console.log(root.objectName+"forceActiveFocus"+root.activeFocus)
            //当前页面打开 且weldTableCurrentRow=-1则切换weldTableCurrentRow=0;
            if(weldTableCurrentRow==-1){
                weldTableCurrentRow=0;
                //tableView.selection.__selectOne(weldTableCurrentRow);

            }
        }
    }
    property list<Action> fileMenu: [
        Action{iconName:"awesome/calendar_plus_o";name:"新建";
            onTriggered: newFile.show();},
        Action{iconName:"awesome/folder_open_o";name:"打开";
            onTriggered: open.show();},
        Action{iconName:"awesome/save";name:"保存";
            onTriggered: {
                if(weldRulesName){
                    //清除保存数据库
                    UserData.clearTable(weldRulesName,"","");
                }
                for(var i=0;i<tableView.rowCount;i++){
                    if(weldRulesName){
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
                }
                //更新数据库保存时间
                UserData.setValue("weldRulesList"+currentGroove.toString(),weldRulesName,new Date())
                message.open("焊接规范已保存。");
            }},
        Action{iconName:"awesome/calendar_times_o";name:"删除";
            onTriggered: remove.show();}
    ]
    property list<Action> editMenu:[
        Action{iconName:"awesome/plus_square_o";onTriggered: add.show();name:"添加"},
        Action{iconName:"awesome/edit";onTriggered: edit.show();name:"编辑";
        },
        Action{iconName:"awesome/paste";name:"复制";enabled:root.actionEnable
            onTriggered: {
                for(var i=0;i<tableView.rowCount;i++){
                    switch(i){
                    case 0:editData[0]=tableView.model.get(weldTableCurrentRow).ID; break;
                    case 1:editData[1]=tableView.model.get(weldTableCurrentRow).C1; break;
                    case 2:editData[2]=tableView.model.get(weldTableCurrentRow).C2; break;
                    case 3:editData[3]=tableView.model.get(weldTableCurrentRow).C3; break;
                    case 4:editData[4]=tableView.model.get(weldTableCurrentRow).C4; break;
                    case 5:editData[5]=tableView.model.get(weldTableCurrentRow).C5; break;
                    case 6:editData[6]=tableView.model.get(weldTableCurrentRow).C6; break;
                    case 7:editData[7]=tableView.model.get(weldTableCurrentRow).C7; break;
                    case 8:editData[8]=tableView.model.get(weldTableCurrentRow).C8; break;
                    case 9:editData[9]=tableView.model.get(weldTableCurrentRow).C9; break;
                    case 10:editData[10]=tableView.model.get(weldTableCurrentRow).C10; break;
                    case 11:editData[11]=tableView.model.get(weldTableCurrentRow).C11; break;
                    case 12:editData[12]=tableView.model.get(weldTableCurrentRow).C12; break;
                    case 13:editData[13]=tableView.model.get(weldTableCurrentRow).C13; break;
                    case 14:editData[14]=tableView.model.get(weldTableCurrentRow).C14; break;
                    case 15:editData[15]=tableView.model.get(weldTableCurrentRow).C15; break;
                    case 16:editData[16]=tableView.model.get(weldTableCurrentRow).C16; break;
                    }
                }
                message.open("已复制。");
            }},
        Action{iconName:"awesome/copy"; name:"粘帖";enabled:root.actionEnable
            onTriggered: {
                tableView.model.insert(weldTableCurrentRow,
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
                tableView.__listView.currentIndex=weldTableCurrentRow;
                tableView.selection.__selectOne(weldTableCurrentRow);
                message.open("已粘帖。");
            }
        },
        Action{iconName: "awesome/trash_o";  name:"移除" ;enabled:root.actionEnable
            onTriggered: {
                if(tableView.rowCount===1)
                    tableView.model.set(0,{"ID":"","C1":"","C2":"","C3":"","C4":"","C5":"","C6":"","C7":"",
                                            "C8":"","C9":"","C10":"","C11":"","C12":"","C13":"","C14":"",
                                            "C15":"","C16":"",})
                else
                    tableView.model.remove(weldTableCurrentRow);
                message.open("已删除。");
            }
        }]
    property list<Action> inforMenu: [ Action{iconName: "awesome/trash_o";  name:"移除" ;enabled:root.actionEnable
            onTriggered: {
                if(tableView.rowCount===1)
                    tableView.model.set(0,{"ID":"","C1":"","C2":"","C3":"","C4":"","C5":"","C6":"","C7":"",
                                            "C8":"","C9":"","C10":"","C11":"","C12":"","C13":"","C14":"",
                                            "C15":"","C16":"",})
                else
                    tableView.model.remove(weldTableCurrentRow);
                message.open("已删除。");
            }
        }]
    property list<Action> funcMenu: [
        Action{iconName:"awesome/send_o";
            onTriggered:{
                if(weldTableCurrentRow>-1){
                    var floor=tableView.model.get(weldTableCurrentRow).C1.split("/");
                    ERModbus.setmodbusFrame(["W","201","17",
                                             (Number(floor[0])*100+Number(floor[1])).toString(),
                                             tableView.model.get(weldTableCurrentRow).C2,
                                             tableView.model.get(weldTableCurrentRow).C3*10,
                                             tableView.model.get(weldTableCurrentRow).C4*10,
                                             tableView.model.get(weldTableCurrentRow).C5,
                                             tableView.model.get(weldTableCurrentRow).C6*10,
                                             tableView.model.get(weldTableCurrentRow).C7*10,
                                             tableView.model.get(weldTableCurrentRow).C8*10,
                                             tableView.model.get(weldTableCurrentRow).C9*10,
                                             tableView.model.get(weldTableCurrentRow).C10*10,
                                             tableView.model.get(weldTableCurrentRow).C11==="连续"?"0":"1",
                                                                                                  tableView.model.get(weldTableCurrentRow).C12*10,//层面积
                                                                                                  tableView.model.get(weldTableCurrentRow).C13*10,//单道面积
                                                                                                  tableView.model.get(weldTableCurrentRow).C14*10,//起弧位置偏移
                                                                                                  tableView.model.get(weldTableCurrentRow).C15*10,//起弧
                                                                                                  tableView.model.get(weldTableCurrentRow).C16*10,//起弧
                                                                                                  tableView.rowCount//总共焊道号
                                            ]);
                    message.open("已下发焊接规范。");
                }else {
                    message.open("请选择下发焊接规范。")
                }
            }
            hoverAnimation:true;summary: "F6"
            enabled: root.actionEnable
            name:"下发规范"
        }]
    Table{
        id:tableView
        headerTitle: weldRulesName
        footerText:  "参数"
        tableRowCount:7
        actions: [
            Action{iconName:"awesome/file_text_o";name:"文件";hoverAnimation:true;summary: "F1"
                onTriggered: {
                    //source为triggered的传递参数
                    tableView.menuDropDown.actions=fileMenu;
                    tableView.menuDropDown.open(source,0,source.height+5);
                    tableView.menuDropDown.place=0;
                }
            },
            Action{iconName:"awesome/edit"; name:"修改";hoverAnimation:true;summary: "F2";
                onTriggered:{
                    tableView.menuDropDown.actions=editMenu;
                    tableView.menuDropDown.open(source,0,source.height+5);
                    tableView.menuDropDown.place=1;
                }
            },
            Action{iconName:"awesome/calendar_plus_o";name:"信息";hoverAnimation:true;summary: "F3"
                onTriggered:{
                    tableView.menuDropDown.actions=inforMenu;
                    tableView.menuDropDown.open(source,0,source.height+5);
                    tableView.menuDropDown.place=2;
                }
            },
            Action{iconName:"awesome/stack_overflow";  name:"工具";hoverAnimation:true;summary: "F4"
                onTriggered:{
                    tableView.menuDropDown.actions=funcMenu;
                    tableView.menuDropDown.open(source,0,source.height+5);
                    tableView.menuDropDown.place=3;
                }
            }
        ]
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
            Controls.TableViewColumn{role: "C11";title: "预约\n停止";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C12";title: "层面积";width:Units.dp(70);movable:false;resizable:false;visible: weldTableEx},
            Controls.TableViewColumn{role: "C13";title: "道面积";width:Units.dp(70);movable:false;resizable:false;visible: weldTableEx},
            Controls.TableViewColumn{role: "C14";title: "起弧x";width:Units.dp(70);movable:false;resizable:false;visible: weldTableEx},
            Controls.TableViewColumn{role: "C15";title: "起弧y";width:Units.dp(70);movable:false;resizable:false;visible: weldTableEx},
            Controls.TableViewColumn{role: "C16";title: "起弧z";width:Units.dp(70);movable:false;resizable:false;visible: weldTableEx}
        ]
    }
    Dialog{
        id:infor
        title:qsTr("信息")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
    }
    Dialog{
        id:open
        title:qsTr("打开焊接规范")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        property var listName:[""]
        property var listTime:[""]
        onOpened:{
            var  Name =UserData.getWeldRulesListName("weldRulesList"+currentGroove.toString());
            if(Name){
                var buf;
                listName=[""];
                listTime=[""];
                for(var i=0;i<Name.length;i++){
                    buf=Name[i].split(".")
                    listName[i]=buf[0];
                    listTime[i]=String(buf[1]).replace("T"," ");}
                menuField.model=listName
                menuField.helperText=listTime[0];
            }
        }
        dialogContent:MenuField{
            id:menuField
            width: Units.dp(240)
            onItemSelected: {
                weldRulesName=open.listName[index];
                menuField.helperText=open.listTime[index]
            }
        }
        Keys.onPressed: {
            switch(event.key){
            case Qt.Key_Up:
                if(open.visible){
                    if(menuField.weldTableCurrentRow!==0){
                        menuField.weldTableCurrentRow--;
                        weldRulesName=open.listName[menuField.weldTableCurrentRow];
                        menuField.helperText=open.listTime[menuField.weldTableCurrentRow]
                    }event.accpet=true;
                }break;
            case Qt.Key_Down:
                if(open.visible){
                    if(menuField.weldTableCurrentRow!==(menuField.model.length-1)){
                        menuField.weldTableCurrentRow++;
                        weldRulesName=open.listName[menuField.weldTableCurrentRow];
                        menuField.helperText=open.listTime[menuField.weldTableCurrentRow]
                    } event.accept=true;}break;
            }
        }
        onAccepted: {
            console.log(weldRulesName)
            headerTitle=weldRulesName;
            var listModel=UserData.getWeldRules(weldRulesName);
            if(weldDataModel.count>1)
                weldDataModel.remove(1,weldDataModel.count-1);
            if(listModel.length>1){
                weldDataModel.set(0,listModel[0])
                for(var i=1;i<listModel.length;i++){
                    weldDataModel.append(listModel[i]);
                }
            }else{
                weldDataModel.set(0,{"ID":"","C1":"","C2":"","C3":"","C4":"","C5":"","C6":"","C7":"","C8":"","C9":"","C10":"","C11":"","C12":"","C13":"","C14":"","C15":"","C16":"",})
            }
        }
    }
    Dialog{
        id:newFile
        title: qsTr("新建焊接规范")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        onOpened:{
            newFileTextField.text=headerTitle
            newFileTextField.helperText="请输入新的焊接规范名称"
        }
        dialogContent:TextField{
            id:newFileTextField
            text:weldRulesName
            helperText: "请输入新的焊接规范名称"//new Date().toLocaleString("yyMd hh:mm")
            width: Units.dp(240)
            anchors.horizontalCenter: parent.horizontalCenter
            onTextChanged: {
                //检索数据库
                var res= UserData.getLastWeldRulesName("weldRulesList"+currentGroove.toString())
                if(String(res)===text){
                    newFile.positiveButtonEnabled=false;
                    helperText="该焊接规范名称已存在"
                }else{
                    newFile.positiveButtonEnabled=true;
                    helperText="焊接规范名称有效"
                }
            }
        }
        onAccepted: {
            //更新标题
            headerTitle=weldRulesName=newFileTextField.text.toString();
            //清除焊接规范表格
            weldDataModel.set(0,{"ID":"","C1":"","C2":"","C3":"","C4":"","C5":"","C6":"","C7":"","C8":"","C9":"","C10":"","C11":"","C12":"","C13":"","C14":"","C15":"","C16":"",});
            if(weldDataModel.count>1)
                weldDataModel.remove(1,weldDataModel.count-1);
            //插入新的list
            UserData.insertTable("weldRulesList"+currentGroove.toString(),"(?,?)",[newFileTextField.text.toString(),new Date()])
            //创建新的 Table
            UserData.createTable(newFileTextField.text.toString(),"ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT,C10 TEXT,C11 TEXT,C12 TEXT,C13 TEXT,C14 TEXT,C15 TEXT,C16 TEXT")
        }
    }
    Dialog{
        id:remove
        title: qsTr("删除焊接规范")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        onOpened:{
            positiveButtonEnabled=groovestyles[currentGroove]+"焊接规范"===weldRulesName?false:true
        }
        dialogContent:Label{
            text:"删除"+weldRulesName
            width: Units.dp(240)
            anchors.horizontalCenter: parent.horizontalCenter
            height:Units.dp(64)
        }
        onAccepted: {
            UserData.deleteTable(weldRulesName);
            UserData.clearTable("weldRulesList"+currentGroove.toString(),"Name",weldRulesName);
            //获取最新的数据表格
            var res= UserData.getLastWeldRulesName("weldRulesList"+currentGroove.toString())
            if(res!==-1){
                headerTitle=weldRulesName=res;
                var listModel=UserData.getWeldRules(weldRulesName);
                if(weldDataModel.count>1)
                    weldDataModel.remove(1,weldDataModel.count-1);
                if(listModel.length>1){
                    weldDataModel.set(0,listModel[0])
                    for(var i=1;i<listModel.length;i++){
                        weldDataModel.append(listModel[i]);
                    }
                }else{
                    weldDataModel.set(0,{"ID":"","C1":"","C2":"","C3":"","C4":"","C5":"","C6":"","C7":"","C8":"","C9":"","C10":"","C11":"","C12":"","C13":"","C14":"","C15":"","C16":"",})
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
            tableView.model.set(weldTableCurrentRow+1,
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
                //                Image{
                //                    id:image
                //                    anchors.left: parent.left
                //                    anchors.verticalCenter: parent.verticalCenter
                //                    source: "../Pic/坡口参数图.png"
                //                    sourceSize.width: Units.dp(350)
                //                }
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
            tableView.model.set(weldTableCurrentRow,
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
            //复制数据到 editData
            for(var i=0;i<editcolumnRepeater.model.length;i++){
                switch(i){
                case 0:editcolumnRepeater.itemAt(i).text=tableView.model.get(weldTableCurrentRow).ID; break;
                case 1:editcolumnRepeater.itemAt(i).text=tableView.model.get(weldTableCurrentRow).C1; break;
                case 2:editcolumnRepeater.itemAt(i).text=tableView.model.get(weldTableCurrentRow).C2; break;
                case 3:editcolumnRepeater.itemAt(i).text=tableView.model.get(weldTableCurrentRow).C3; break;
                case 4:editcolumnRepeater.itemAt(i).text=tableView.model.get(weldTableCurrentRow).C4; break;
                case 5:editcolumnRepeater.itemAt(i).text=tableView.model.get(weldTableCurrentRow).C5; break;
                case 6:editcolumnRepeater.itemAt(i).text=tableView.model.get(weldTableCurrentRow).C6; break;
                case 7:editcolumnRepeater.itemAt(i).text=tableView.model.get(weldTableCurrentRow).C7; break;
                case 8:editcolumnRepeater.itemAt(i).text=tableView.model.get(weldTableCurrentRow).C8; break;
                case 9:editcolumnRepeater.itemAt(i).text=tableView.model.get(weldTableCurrentRow).C9; break;
                case 10:editcolumnRepeater.itemAt(i).text=tableView.model.get(weldTableCurrentRow).C10; break;
                case 11:editcolumnRepeater.itemAt(i).text=tableView.model.get(weldTableCurrentRow).C11; break;
                case 12:editcolumnRepeater.itemAt(i).text=tableView.model.get(weldTableCurrentRow).C12; break;
                case 13:editcolumnRepeater.itemAt(i).text=tableView.model.get(weldTableCurrentRow).C13; break;
                case 14:editcolumnRepeater.itemAt(i).text=tableView.model.get(weldTableCurrentRow).C14; break;
                case 15:editcolumnRepeater.itemAt(i).text=tableView.model.get(weldTableCurrentRow).C15; break;
                case 16:editcolumnRepeater.itemAt(i).text=tableView.model.get(weldTableCurrentRow).C16; break;
                }
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
}

