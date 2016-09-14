import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.2 as Controls
import QtQuick.Window 2.2
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0
import WeldSys.WeldMath 1.0
import QtQuick.Layouts 1.1
/*
  * tableView 选中当前行时必需 要更改__listview.currentrow 然后在选择要选择的行单纯的只选择 选中的行无效
  * 能不使用 ProgressCircle 不要使用 太耗费cpu 能够达到30% 使用率 获取当前位置 工具有 生成焊接规范 获取当前位置
*/
FocusScope{
    id:root
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "GrooveCheck"
    anchors{
        left:parent.left
        right:parent.right
        top:parent.top
        bottom: parent.bottom
        leftMargin:visible?0:Units.dp(250)
    }

    signal changedCurrentGroove(string name)

    property Item message
    property string helpText;
    Behavior on anchors.leftMargin{NumberAnimation { duration: 400 }}
    //坡口列表名称
    property string grooveName
    //当前坡口名称
    property string currentGrooveName
    property var editData:["","","","","","","","",""]
    property string status:"空闲态"
    property alias grooveModel: tableView.model
    property alias selectedIndex:tableView.currentRow

    property var test: [new Date()];

    property bool actionEnable: ((grooveModel.count>0)&&(selectedIndex>-1))?true:false

    ListModel{
        id:pasteModel
        ListElement{ID:"";C1:"";C2:"";C3:"";C4:"";C5:"";C6:"";C7:"";C8:""}
    }

    property list<Action> fileMenu: [
        Action{iconName:"av/playlist_add";name:"新建";
            onTriggered: {newFile.show()}},
        //newFile.show();},
        Action{iconName:"awesome/folder_open_o";name:"打开";
            onTriggered: open.show();},
        Action{iconName:"awesome/save";name:"保存";
            onTriggered: {
                if(typeof(currentGrooveName)==="string"){
                    //清除保存数据库
                    UserData.clearTable(currentGrooveName,"","");
                    for(var i=0;i<tableView.table.rowCount;i++){
                        //插入新的数据
                        UserData.insertTable(currentGrooveName,"(?,?,?,?,?,?,?,?,?)",[
                                                 tableView.model.get(i).ID,
                                                 tableView.model.get(i).C1,
                                                 tableView.model.get(i).C2,
                                                 tableView.model.get(i).C3,
                                                 tableView.model.get(i).C4,
                                                 tableView.model.get(i).C5,
                                                 tableView.model.get(i).C6,
                                                 tableView.model.get(i).C7,
                                                 tableView.model.get(i).C8])}

                    //更新数据库保存时间
                    UserData.setValueWanted(grooveName+"列表","Groove",currentGrooveName,"EditTime",UserData.getSysTime())
                    //更新数据库保存
                    UserData.setValueWanted(grooveName+"列表","Groove",currentGrooveName,"Editor",AppConfig.currentUserName)
                    message.open("坡口参数已保存。");
                }else{
                    message.open("坡口名称格式不是字符串！")
                }
            }},

        Action{iconName:"awesome/trash_o";name:"删除";enabled: grooveName===currentGrooveName?false:true
            onTriggered: remove.show();}
    ]
    property list<Action> editMenu:[
        Action{iconName:"awesome/calendar_plus_o";onTriggered: add.show();name:"添加"},
        Action{iconName:"awesome/edit";onTriggered: edit.show();name:"编辑";enabled:actionEnable},
        Action{iconName:"awesome/paste";name:"复制";enabled:actionEnable
            onTriggered: {
                pasteModel.set(0,tableView.model.get(selectedIndex));
                message.open("已复制。");
            }},
        Action{iconName:"awesome/copy"; name:"粘帖";enabled:actionEnable
            onTriggered: {
                tableView.model.insert(selectedIndex,pasteModel.get(0));
                tableView.table.selection.__selectOne(selectedIndex);
                message.open("已粘帖。");
            }
        },
        Action{iconName: "awesome/calendar_times_o";  name:"移除" ;enabled:actionEnable
            onTriggered: {
                tableView.model.remove(selectedIndex);
                message.open("已删除。");}
        },
        Action{iconName:"awesome/calendar_o";name:"清空";enabled:actionEnable
            onTriggered: {
                tableView.model.clear();
                message.open("已清空。");
            }}
    ]
    property list<Action> inforMenu: [ Action{iconName: "awesome/sticky_note_o";  name:"移除";enabled:root.actionEnable
            onTriggered: {}}]
    property list<Action> funcMenu: [
        Action{iconName:"awesome/send_o";hoverAnimation:true;summary: "F4"; name:"生成规范";enabled:actionEnable;
            onTriggered:{
                if(selectedIndex>-1){
                    WeldMath.setGrooveRules([
                                                tableView.model.get(0).C1,
                                                tableView.model.get(0).C2,
                                                tableView.model.get(0).C3,
                                                tableView.model.get(0).C4,
                                                tableView.model.get(0).C5,
                                                tableView.model.get(0).C6,
                                                tableView.model.get(0).C7,
                                                tableView.model.get(0).C8
                                            ]);
                    message.open("生成焊接规范。");
                }else {
                    message.open("请选择要生成规范的坡口信息。")
                }
            }
        },
        Action{iconName: "av/fast_forward";  name:"移至中线";enabled:root.actionEnable}
    ]
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
            tableView.table.__incrementCurrentIndex();
            event.accept=true;
            break;
        case Qt.Key_Up:
            tableView.table.__decrementCurrentIndex();
            event.accept=true;
            break;
        case Qt.Key_Right:
            tableView.table.__horizontalScrollBar.value +=Units.dp(70);
            event.accept=true;
            break;
        case Qt.Key_Left:
            tableView.table.__horizontalScrollBar.value -=Units.dp(70);
            event.accept=true;
            break;
        }
    }
    TableCard{
        id:tableView
        headerTitle: currentGrooveName+"坡口参数"
        footerText:  "参数"
        tableRowCount:7
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
            Action{iconName:"awesome/sticky_note_o";name:"信息";hoverAnimation:true;summary: "F3"
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
            Controls.TableViewColumn{  role:"C1"; title: "板厚 δ\n (mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{  role:"C2"; title: "板厚差 e\n   (mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{  role:"C3"; title: "间隙 b\n (mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{  role:"C4"; title: "角度 β1\n  (deg)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{  role:"C5"; title: "角度 β2\n  (deg)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{  role:"C6"; title: "中心线 \n X(mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{  role:"C7"; title: "中心线 \n Y(mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{  role:"C8"; title: "中心线 \n Z(mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter}
        ]
    }
    Dialog{
        id:open
        title:qsTr("打开坡口参数")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        property var grooveList:[""]
        property var creatTimeList: [""]
        property var creatorList:[""]
        property var editTimeList: [""]
        property var editorList:[""]
        property string name
        onOpened:{//打开对话框加载model
            var res=UserData.getListGrooveName(grooveName+"列表","EditTime")
            if(typeof(res)==="object"){
                grooveList=[""];
                creatTimeList=[""];
                creatorList=[""];
                editTimeList=[""];
                editorList=[""];
                var buf;
                for(var i=0;i<res.length;i++){
                    buf=res[i].split(",")
                    grooveList[i]=buf[0];
                    creatTimeList[i]=new Date(buf[1]).toLocaleString(Qt.locale("ch_ZN"),"yyyy-MM-dd h:mm:ss");
                    creatorList[i]=buf[2];
                    editTimeList[i]=new Date(buf[3]).toLocaleString(Qt.locale("ch_ZN"),"yyyy-MM-dd h:mm:ss");
                    editorList[i]=buf[4];
                }
                menuField.model=grooveList
                menuField.selectedIndex=0;
                menuField.helperText="创建时间:"+creatTimeList[0]+"\n创建者:"+creatorList[0]+"\n修改时间:"+editTimeList[0]+"\n修改者:"+editorList[0];
                name=grooveList[0];
            }
        }
        dialogContent: MenuField{id:menuField
            width:Units.dp(250)
            onItemSelected: {
                open.name=open.grooveList[index]
                menuField.helperText="创建时间:"+open.creatTimeList[index]+"\n创建者:"+open.creatorList[index]+"\n修改时间:"+open.editTimeList[index]+"\n修改者:"+open.editorList[index];
                console.log("创建时间:"+open.creatTimeList[index]+"\n创建者:"+open.creatorList[index]+"\n修改时间:"+open.editTimeList[index]+"\n修改者:"+open.editorList[index])
            }
        }
        onAccepted: {
            if(typeof(open.name)==="string")
                changedCurrentGroove(open.name);
        }
        onRejected: {
            open.name=currentGrooveName
        }
    }
    Dialog{
        id:remove
        title: qsTr("删除坡口参数")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        onOpened:{
            //确保不是默认的坡口名称
            positiveButtonEnabled=grooveName===currentGrooveName?false:true
        }
        dialogContent:Label{
            text:"删除"+currentGrooveName
            width: Units.dp(240)
            anchors.horizontalCenter: parent.horizontalCenter
            height:Units.dp(64)
        }
        onAccepted: {
            if(positiveButtonEnabled){
                //搜寻最近列表 删除本次列表 更新 最近列表如model

                //删除在总表里面的软链接
                UserData.clearTable(grooveName+"列表","Groove",currentGrooveName)
                //删除焊接规范
                UserData.deleteTable(currentGrooveName);
                //删除焊接条件
                UserData.deleteTable(currentGrooveName+"焊接条件")
                //删除限制条件列表
                UserData.deleteTable(currentGrooveName+"限制条件")
                //删除曲线列表
                //获取最新列表
                var name=UserData.getLastGrooveName(grooveName+"列表","EditTime")
                console.log("delete table name "+name)
                if((typeof(name)==="string")&&(name!==""))
                    //更新新列表数据
                    changedCurrentGroove(name);
            }
        }
    }
    Dialog{
        id:newFile
        title: qsTr("新建坡口参数")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        property var grooveList: [""]
        onOpened:{
            newFileTextField.text=currentGrooveName;
            newFileTextField.helperText="请输入新的坡口参数"
            var res=UserData.getListGrooveName(grooveName+"列表","EditTime")
            if(typeof(res)==="object"){
                grooveList=[""];
                var buf;
                for(var i=0;i<res.length;i++){
                    buf=res[i].split("+")
                    grooveList[i]=buf[0];
                }
            }
        }
        dialogContent:[Item{
                    width: Units.dp(240)
                    height:newFileTextField.actualHeight
                   TextField{
                    id:newFileTextField
                    text:currentGrooveName
                    helperText: "请输入新的坡口参数"//new Date().toLocaleString("yyMd hh:mm")
                    width: Units.dp(240)
                    anchors.horizontalCenter: parent.horizontalCenter
                    onTextChanged: {
                        //检索数据库
                        for(var i=0;i<newFile.grooveList.length;i++){
                            if(newFile.grooveList[i]==text){
                                newFile.positiveButtonEnabled=false;
                                helperText="该坡口参数名称已存在"
                            }else{
                                newFile.positiveButtonEnabled=true;
                                helperText="坡口参数名称有效"
                            }
                        }
                    }
                }
            }]
        onAccepted: {
            //更新标题
            var name = newFileTextField.text
            if((name!==currentGrooveName)&&(typeof(name)==="string")){
                var user=AppConfig.currentUserName;
                var Time=UserData.getSysTime();
                //插入新的list
                UserData.insertTable(grooveName+"列表","(?,?,?,?,?,?,?,?,?,?,?)",[name+"示教条件",name+"焊接条件",name,name+"限制条件",name+"焊接规范",name+"错误检测",name+"焊接曲线",Time,user,Time,user])
                //创建新的 坡口条件
                UserData.createTable(name,"ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT")
                //创建新的 焊接条件
                UserData.createTable(name+"焊接条件","ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT,C10 TEXT,C11 TEXT,C12 TEXT,C13 TEXT,C14 TEXT,C15 TEXT,C16 TEXT")
                //创建新的 限制条件
                UserData.createLimitedTable(grooveName,name+"限制条件")
                //创建新的 曲线

                //更新名称
                changedCurrentGroove(name);
            }
        }
    }

    Dialog{
        id:add
        title: qsTr("添加坡口参数")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        globalMouseAreaEnabled:false
        onAccepted: {
            //只有一个空白行则插入新的行
            tableView.model.append(
                        {   "ID":editData[0],
                            "C1":editData[1],"C2":editData[2],
                            "C3":editData[3],"C4":editData[4],
                            "C5":editData[5],"C6":editData[6],
                            "C7":editData[7],"C8":editData[8]})}
        onOpened: {
            for(var i=0;i<editData.length;i++)
                editData[i]="";
        }
        dialogContent: [
            Item{
                width: Units.dp(540)
                height:addColumn.height
                Image{
                    id:addImage
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    source: "../Pic/坡口参数图.png"
                    sourceSize.width: Units.dp(350)
                }
                Column{
                    id:addColumn
                    anchors.top:parent.top
                    anchors.left: addImage.right
                    anchors.leftMargin: Units.dp(16)
                    anchors.right: parent.right
                    Repeater{
                        id:addColumnRepeater
                        model:["           No.       ", "板    厚δ(mm)","板厚差e(mm)","间    隙b(mm)","角  度β1(deg)","角  度β2(deg)","中心线X(mm)","中心线Y(mm)","中心线Z(mm)"]
                        delegate:Row{
                            spacing: Units.dp(8)
                            Label{text:modelData;anchors.bottom: parent.bottom}
                            TextField{
                                id:addTextField
                                horizontalAlignment:TextInput.AlignHCenter
                                width: Units.dp(60)
                                inputMethodHints: Qt.ImhDigitsOnly
                                onTextChanged: {editData[index]=text}
                            }
                        }
                    }
                }
            }
        ]
    }

    Dialog{
        id:edit
        title: qsTr("编辑坡口参数")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        globalMouseAreaEnabled:false
        onAccepted: {
            //只有一个空白行则插入新的行
            tableView.model.set(selectedIndex,
                                {   "ID":editData[0],
                                    "C1":editData[1],"C2":editData[2],
                                    "C3":editData[3],"C4":editData[4],
                                    "C5":editData[5],"C6":editData[6],
                                    "C7":editData[7],"C8":editData[8]})}
        onOpened: {
            //复制数据到 editData
            var Index=selectedIndex;
            console.log("tableView.table.columnCount"+tableView.table.columnCount)
            for(var i=0;i<tableView.table.columnCount;i++){
                editData[i]="";
                switch(i){
                case 0:columnRepeater.itemAt(0).text=tableView.model.get(Index).ID; break;
                case 1:columnRepeater.itemAt(1).text=tableView.model.get(Index).C1; break;
                case 2:columnRepeater.itemAt(2).text=tableView.model.get(Index).C2; break;
                case 3:columnRepeater.itemAt(3).text=tableView.model.get(Index).C3; break;
                case 4:columnRepeater.itemAt(4).text=tableView.model.get(Index).C4; break;
                case 5:columnRepeater.itemAt(5).text=tableView.model.get(Index).C5; break;
                case 6:columnRepeater.itemAt(6).text=tableView.model.get(Index).C6; break;
                case 5:columnRepeater.itemAt(7).text=tableView.model.get(Index).C7; break;
                case 6:columnRepeater.itemAt(8).text=tableView.model.get(Index).C8; break;
                }
            }
        }
        dialogContent: [
            Item{
                width: Units.dp(540)
                height:column.height
                Image{
                    id:image
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    source: "../Pic/坡口参数图.png"
                    sourceSize.width: Units.dp(350)
                }
                Column{
                    id:column
                    anchors.top:parent.top
                    anchors.left: image.right
                    anchors.leftMargin: Units.dp(16)
                    anchors.right: parent.right
                    Repeater{
                        id:columnRepeater
                        model:["           No.       ", "板    厚δ(mm)","板厚差e(mm)","间    隙b(mm)","角  度β1(deg)","角  度β2(deg)","中心线X(mm)","中心线Y(mm)","中心线Z(mm)"]
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
                                    editData[index]=text;
                                }
                            }
                        }
                    }
                }
            }
        ]
    }

}

