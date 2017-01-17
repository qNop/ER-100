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
TableCard{
    id:root
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "GrooveCheck"

    property int currentGroove;

    property Item message
    property string helpText;
    //坡口列表名称
    property string grooveName
    //当前坡口名称
    property string currentGrooveName
    property string status:"空闲态"

    property var grooveRules: ["           No.       ", "板    厚δ(mm)","板厚差e(mm)","间    隙b(mm)","角  度β1(deg)","角  度β2(deg)","中心线X(mm)","中心线Y(mm)","中心线Z(mm)"]

    ListModel{id:pasteModel
        ListElement{ID:"";C1:"";C2:"";C3:"";C4:"";C5:"";C6:"";C7:"";C8:""}
    }
    signal changedCurrentGroove(string name)
    //外部更新数据
    signal updateModel(string str,var data);

    function selectIndex(index){
        if((index<model.count)&&(index>-1)){
            table.selection.clear();
            table.selection.select(index);
        }
        else
            message.open("索引超过条目上限或索引无效！")
    }

    function update(){
        console.log("UPDATE")
        //清空坡口数据
        updateModel("Clear",{});
        //获取坡口数据
        var res=UserData.getTableJson(currentGrooveName)
        //插入数据到grooveTableInit
        if(typeof(res)==="object"){
            for(var i=0;i<res.length;i++){
                updateModel("Append",res[i])
            }
        }
    }

    onCurrentGrooveNameChanged: {
        if(currentGrooveName!==""){
            update();
        }
    }
    headerTitle: currentGrooveName+"坡口参数"
    footerText:  status==="坡口检测态"?"系统当前处于"+status.replace("态","状态。高压输出！"):"系统当前处于"+status.replace("态","状态。")
    tableRowCount:7
    fileMenu: [
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
                    for(var i=0;i<table.rowCount;i++){
                        //插入新的数据
                        UserData.insertTable(currentGrooveName,"(?,?,?,?,?,?,?,?,?)",[
                                                 model.get(i).ID,
                                                 model.get(i).C1,
                                                 model.get(i).C2,
                                                 model.get(i).C3,
                                                 model.get(i).C4,
                                                 model.get(i).C5,
                                                 model.get(i).C6,
                                                 model.get(i).C7,
                                                 model.get(i).C8])}
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
    editMenu:[
        Action{iconName:"awesome/calendar_plus_o";onTriggered: add.show();name:"添加"},
        Action{iconName:"awesome/edit";onTriggered: edit.show();name:"编辑";},
        Action{iconName:"awesome/paste";name:"复制";
            onTriggered: {
                if(currentRow>=0){
                    pasteModel.set(0,model.get(currentRow));
                    message.open("已复制。");}
                else{
                    message.open("请选择要复制的行！")
                }
            }},
        Action{iconName:"awesome/copy"; name:"粘帖";
            onTriggered: {
                if(currentRow>=0){
                    updateModel("Set", pasteModel.get(0));
                    selectIndex(currentRow)
                    message.open("已粘帖。");}
                else
                    message.open("请选择要粘帖的行！")
            }
        },
        Action{iconName: "awesome/calendar_times_o";  name:"移除" ;
            onTriggered: {
                if(currentRow>=0){
                    updateModel("Remove",{})
                    message.open("已移除。");}
                else
                    message.open("请选择要移除的行！")}
        },
        Action{iconName:"awesome/calendar_o";name:"清空";
            onTriggered: {
                updateModel("Clear",{});
                message.open("已清空。");
            }}
    ]
    inforMenu: [ Action{iconName: "awesome/sticky_note_o";  name:"移除";
            onTriggered: {}}]
    funcMenu: [
        Action{iconName:"awesome/send_o";hoverAnimation:true;summary: "F4"; name:"生成规范";
            onTriggered:{
                if(currentRow>-1){
                    WeldMath.setGrooveRules([
                                                model.get(0).C1,
                                                model.get(0).C2,
                                                model.get(0).C3,
                                                model.get(0).C4,
                                                model.get(0).C5,
                                                model.get(0).C6,
                                                model.get(0).C7,
                                                model.get(0).C8
                                            ]);
                    message.open("生成焊接规范。");
                }else {
                    message.open("请选择要生成规范的坡口信息。")
                }
            }
        },
        Action{iconName: "awesome/server";  name:"参数补正";
            onTriggered: {
                fix.show()
            }
        },
        Action{iconName: "av/fast_forward";  name:"移至中线";
            onTriggered: {
                message.open("暂不支持移至中线命令！")
            }
        }
    ]
    tableData:[
        Controls.TableViewColumn{  role:"C1"; title:currentGroove===8?"脚长 l\n (mm)": "板厚 δ\n (mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{  role:"C2"; title: "板厚差 e\n   (mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;visible:currentGroove!==8?true:false},
        Controls.TableViewColumn{  role:"C3"; title: "间隙 b\n (mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;visible:currentGroove!==8?true:false},
        Controls.TableViewColumn{  role:"C4"; title: "角度 β1\n  (deg)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{  role:"C5"; title: "角度 β2\n  (deg)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{  role:"C6"; title: "中心线 \n X(mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;visible:true},
        Controls.TableViewColumn{  role:"C7"; title: "中心线 \n Y(mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;visible:true},
        Controls.TableViewColumn{  role:"C8"; title: "中心线 \n Z(mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;visible:true}
    ]
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
                grooveList.length=0;
                creatTimeList.length=0;
                creatorList.length=0;
                editTimeList.length=0;
                editorList.length=0;
                var buf;
                for(var i=0;i<res.length;i++){
                    buf=res[i].split(",")
                    grooveList[i]=buf[0];
                    creatTimeList[i]=buf[1];
                    creatorList[i]=buf[2];
                    editTimeList[i]=buf[3];
                    editorList[i]=buf[4];
                }
                menuField.model=grooveList
                menuField.selectedIndex=0;
                menuField.helperText="创建时间:"+creatTimeList[0]+"\n创建者:"+creatorList[0]+"\n修改时间:"+editTimeList[0]+"\n修改者:"+editorList[0];
                name=grooveList[0];
            }
        }
        dialogContent: MenuField{id:menuField
            width:Units.dp(300)
            onItemSelected: {
                open.name=open.grooveList[index]
                menuField.helperText="创建时间:"+open.creatTimeList[index]+"\n创建者:"+open.creatorList[index]+"\n修改时间:"+open.editTimeList[index]+"\n修改者:"+open.editorList[index];
                console.log("创建时间:"+open.creatTimeList[index]+"\n创建者:"+open.creatorList[index]+"\n修改时间:"+open.editTimeList[index]+"\n修改者:"+open.editorList[index])
            }
        }
        onAccepted: {
            if(typeof(open.name)==="string"){
                //名称一样没有变化 则重新刷
                if(open.name===currentGrooveName){
                    root.update();
                }else
                    changedCurrentGroove(open.name);
            }
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
        dialogContent:
            Item{
            width: Units.dp(300)
            height:Units.dp(48)
            Label{
                text:"确认删除\n"+currentGrooveName+"坡口参数！"
                style: "menu"
            }
        }
        onAccepted: {
            if(positiveButtonEnabled){
                //搜寻最近列表 删除本次列表 更新 最近列表如model
                message.open(qsTr("正在删除坡口参数表格！"));
                //删除在总表里面的软链接
                UserData.clearTable(grooveName+"列表","Groove",currentGrooveName)
                //删除坡口参数表格
                UserData.deleteTable(currentGrooveName);

                //获取 次列表 内数据
                var res=UserData.getTableJson(currentGrooveName+"次列表")
                if((typeof(res)==="object")&&(res!==-1)){

                    for(var i=0;i<res.length;i++){
                        //删除焊接规范
                        message.open(qsTr("正在删除"+currentGrooveName+"参数下"+res[i].Rules+"表格！"));
                        UserData.deleteTable(res[i].Rules)
                        //删除限制条件列表
                        UserData.deleteTable(res[i].Limited)
                        //删除曲线列表

                        //删除过程分析列表
                        UserData.deleteTable(res[i].Analyse)
                    }
                }
                //删除次列表
                UserData.deleteTable(currentGrooveName+"次列表")
                //获取最新列表
                var name=UserData.getLastGrooveName(grooveName+"列表","EditTime")
                console.log("delete table name "+name)
                if((typeof(name)==="string")&&(name!=="")){
                    //更新新列表数据
                    changedCurrentGroove(name);
                }
                message.open(qsTr("已删除坡口参数表格！"))
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
                width: Units.dp(300)
                height:newFileTextField.actualHeight
                TextField{
                    id:newFileTextField
                    text:currentGrooveName
                    helperText: "请输入新的坡口参数"//new Date().toLocaleString("yyMd hh:mm")
                    width: Units.dp(300)
                    anchors.horizontalCenter: parent.horizontalCenter
                    onTextChanged: {
                        var check=false;
                        //检索数据库
                        for(var i=0;i<newFile.grooveList.length;i++){
                            if(newFile.grooveList[i]===text){
                                check=true;
                            }
                        }
                        if(check){
                            newFile.positiveButtonEnabled=false;
                            helperText="该坡口参数名称已存在！"
                            hasError=true;
                        }else{
                            newFile.positiveButtonEnabled=true;
                            helperText="坡口参数名称有效！"
                            hasError=false
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

                message.open("正在创建坡口参数数据库！")
                //插入新的list
                UserData.insertTable(grooveName+"列表","(?,?,?,?,?,?,?,?,?)",[name+"示教条件",name+"焊接条件",name,name+"次列表",name+"错误检测",Time,user,Time,user])
                //创建新的 坡口条件
                UserData.createTable(name,"ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT")
                //创建新的次列表
                UserData.createTable(name+"次列表","Rules TEXT,Limited TEXT,Analyse TEXT,Line TEXT,CreatTime TEXT,Creator TEXT,EditTime TEXT,Editor TEXT")
                //初始化次列表
                UserData.insertTable(name+"次列表","(?,?,?,?,?,?,?,?)",[name+"焊接规范",name+"限制条件",name+"过程分析",name+"焊接曲线",Time,user,Time,user])
                //创建新的 焊接条件
                UserData.createTable(name+"焊接规范","ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT,C10 TEXT,C11 TEXT,C12 TEXT,C13 TEXT,C14 TEXT,C15 TEXT,C16 TEXT")
                //创建新的 限制条件
                UserData.createTable(name+"限制条件","ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT")
                //创建新的 曲线

                //创建新的过程分析列表
                UserData.createTable(name+"过程分析","ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT")
                //更新名称
                changedCurrentGroove(name);

                message.open("已创建坡口参数数据库！")

            }
        }}
    Dialog{
        id:add
        title: qsTr("添加坡口参数")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        globalMouseAreaEnabled:false
        onAccepted: {
            //只有一个空白行则插入新的行
            updateModel("Append",pasteModel.get(0))}
        onOpened: {
            pasteModel.set(0,{"ID":"0", "C1":"0","C2":"0","C3":"0","C4":"0","C5":"0","C6":"0","C7":"0","C8":"0"})
            for(var i=0;i<grooveRules.length;i++){
                addColumnRepeater.itemAt(i).text="";
            }
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
                        model:grooveRules
                        delegate:Row{
                            property alias text: addTextField.text
                            spacing: Units.dp(8)
                            Label{text:modelData;anchors.bottom: parent.bottom}
                            TextField{
                                id:addTextField
                                horizontalAlignment:TextInput.AlignHCenter
                                width: Units.dp(60)
                                inputMethodHints: Qt.ImhDigitsOnly
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
                                    }
                                }
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
            updateModel("Set",pasteModel.get(0))
        }
        onOpened: {
            //复制数据到 editData
            var Index=currentRow;
            if(Index>=0){
                pasteModel.set(0,model.get(Index));
                columnRepeater.itemAt(0).text=model.get(Index).ID;
                columnRepeater.itemAt(1).text=model.get(Index).C1;
                columnRepeater.itemAt(2).text=model.get(Index).C2;
                columnRepeater.itemAt(3).text=model.get(Index).C3;
                columnRepeater.itemAt(4).text=model.get(Index).C4;
                columnRepeater.itemAt(5).text=model.get(Index).C5;
                columnRepeater.itemAt(6).text=model.get(Index).C6;
                columnRepeater.itemAt(7).text=model.get(Index).C7;
                columnRepeater.itemAt(8).text=model.get(Index).C8;
            }else{
                message.open("请选择要编辑的行！");
                positiveButtonEnabled=false;
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
                        model:grooveRules
                        delegate:Row{
                            property alias text: textField.text
                            spacing: Units.dp(8)
                            Label{text:modelData;anchors.bottom: parent.bottom}
                            TextField{
                                id:textField
                                property string oldText:text
                                horizontalAlignment:TextInput.AlignHCenter
                                width: Units.dp(60)
                                inputMethodHints: Qt.ImhDigitsOnly
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
                                    }
                                }
                            }
                        }
                    }
                }
            }
        ]
    }
    Dialog{
        id:fix
        title: qsTr("坡口参数补正")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        globalMouseAreaEnabled:false
        property int selectedIndex: 0
        signal changeFixSelectedIndex(int index)
        onChangeFixSelectedIndex:{
            fix.selectedIndex=index;
        }
        dialogContent:Repeater{
            model:["板厚补正标志:","间隙补正标志:","间隙补正标志:"]
            delegate: ListItem.Subtitled{
                id:sub
                property int subIndex: index
                text:modelData
                height:Units.dp(32)
                selected: index===fix.selectedIndex
                onPressed:fix.changeFixSelectedIndex(index)
                secondaryItem: RowLayout{
                    spacing: Units.dp(12)
                    anchors.verticalCenter: parent.verticalCenter
                    Switch{
                        id:switchButton
                        Layout.alignment: Qt.AlignVCenter
                        onClicked: {
                            fix.changeFixSelectedIndex(sub.subIndex)
                        }
                    }
                    Label{
                        text:switchButton.checked?"打开":"关闭"
                        style: "button"
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
        }
    }
}

