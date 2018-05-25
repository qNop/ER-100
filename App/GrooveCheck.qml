import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.2 as Controls
import QtQuick.Window 2.2
import WeldSys.ERModbus 1.0
import WeldSys.WeldMath 1.0
import WeldSys.MySQL 1.0
import QtQuick.Layouts 1.1
import "MyMath.js" as MyMath
/*
  * tableView 选中当前行时必需 要更改__listview.currentrow 然后在选择要选择的行单纯的只选择 选中的行无效
  * 能不使用 ProgressCircle 不要使用 太耗费cpu 能够达到30% 使用率 获取当前位置 工具有 生成焊接规范 获取当前位置
*/
TableCard{
    id:root
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "GrooveCheck"

    property int currentGroove;

    property var settings

    //property Item message
    property string helpText;
    //当前坡口名称
    property string grooveName:""
    //坡口条件列表
    property string grooveNameList: ""
    property string status:"空闲态"

    property int teachModel

    property alias fixDialog: fix

    property bool saveAs: false
/*
    ListModel{id:pasteModel
        ListElement{ID:"";C1:"";C2:"";C3:"";C4:"";C5:"";C6:"0";C7:"0";C8:"0"}
    }
    ListModel{id:grooveNameListModel
        ListElement{Name:"";CreatTime:"";Creater:"";EditTime:"";Editor:"";}
    }
    ListModel{id:grooveRules
        ListElement{name:"          No.       :";value:"";show:true;min:0;max:100;isNum:true;step:1}
        ListElement{name:"板    厚δ(mm):";value:"";show:true;min:0;max:100;isNum:true;step:0.1}
        ListElement{name:"板厚差e(mm):";value:"";show:true;min:-100;max:100;isNum:true;step:0.1}
        ListElement{name:"间    隙b(mm):";value:"";show:true;min:0;max:100;isNum:true;step:0.1}
        ListElement{name:"角  度β1(deg):";value:"";show:true;min:-180;max:180;isNum:true;step:0.1}
        ListElement{name:"角  度β2(deg):";value:"";show:true;min:-180;max:180;isNum:true;step:0.1}
    }
    onCurrentGrooveChanged: {
        grooveRules.setProperty(1,"name",currentGroove===8?"脚   长ι1(mm):":"板    厚δ(mm):")
        grooveRules.setProperty(2,"name",currentGroove===8||currentGroove==0||currentGroove==3||currentGroove==5?"脚   长ι2(mm):":"板厚差e(mm):")
        grooveRules.setProperty(3,"show",currentGroove===8?false:true)
    }*/
    //外部更新数据
    //signal updateModel(string str,var data);

    signal getWeldRules();

    Connections{
        target: MySQL
        onMySqlChanged:{
            //更新列表
            if(tableName===grooveNameList){
                //更新列表
                updateListModel("Clear",{});
                for(var i=0;i<jsonObject.length;i++){
                    updateListModel("Append",jsonObject[i]);
                }
                grooveName=jsonObject[0].Name;
                MySQL.getJsonTable(grooveName);
            }else if(tableName===grooveName){//更新数据表
                updateModel("Clear",{});
                for(i=0;i<jsonObject.length;i++){
                    updateModel("Append",jsonObject[i]);
                }
                if(jsonObject.length===0){
                    currentRow=-1;
                }else{
                    currentRow=0;
                    selectIndex(0);
                }
            }
        }
    }

    function getLastGrooveName(){
        MySQL.getDataOrderByTime(grooveNameList,"EditTime");
    }

    function save(){
        if(typeof(grooveName)==="string"){
            //清除保存数据库
            MySQL.clearTable(grooveName,"","");
            for(var i=0;i<model.count;i++){
                //插入新的数据
                MySQL.insertTable(grooveName,model.get(i));
            }
            //更新数据库保存时间
            MySQL.setValue(grooveNameList,"Name",grooveName,"EditTime",MyMath.getSysTime());
            MySQL.setValue(grooveNameList,"Name",grooveName,"Editor",settings.currentUserName);
            message.open("坡口条件已保存。");
        }else{
            message.open("坡口名称格式不是字符串！")
        }
    }

    headerTitle: grooveName
    footerText:status==="坡口检测态"?"系统当前处于"+status.replace("态","状态。高压输出！"):"系统当前处于"+status.replace("态","状态。")
    tableRowCount:7
  /*  fileMenu: [
        Action{iconName:"av/playlist_add";name:"新建";enabled:false
            onTriggered: {saveAs=false;newFile.show()}},
        Action{iconName:"awesome/folder_open_o";name:"打开";enabled: false
            onTriggered: open.show();},
        Action{iconName:"awesome/save";name:"保存";
            onTriggered: {save();}},
        Action{iconName:"awesome/credit_card";name:"另存为";enabled: false
            onTriggered: {saveAs=true;newFile.show();
                //备份数据 新建表格
                //插入表格数据
            }
        },
        Action{iconName:"awesome/trash_o";name:"删除";enabled: false//grooveNameList.replace("列表","")===grooveName?false:true
            onTriggered: remove.show();}
    ]
    editMenu:[
        Action{iconName:"awesome/calendar_plus_o";name:"添加";onTriggered:{
                myTextFieldDialog.title="添加坡口条件";
                myTextFieldDialog.show();}},
        Action{iconName:"awesome/edit";name:"编辑";onTriggered:{
                myTextFieldDialog.title="编辑坡口条件";
                if((currentRow>=0)&&(table.rowCount)){
                    myTextFieldDialog.show();
                }else
                    message.open("请选择要编辑的行！")
            }},
        Action{iconName:"awesome/paste";name:"复制";
            onTriggered: {
                if((currentRow>=0)&&(table.rowCount)){
                    pasteModel.set(0,model.get(currentRow));
                    message.open("已复制。");}
                else{
                    message.open("请选择要复制的行！")
                }
            }},
        Action{iconName:"awesome/copy"; name:"粘帖";
            onTriggered: {
                if((currentRow>=0)&&(table.rowCount)){
                    updateModel("Set", pasteModel.get(0));
                    selectIndex(currentRow)
                    message.open("已粘帖。");}
                else
                    message.open("请选择要粘帖的行！")
            }
        },
        Action{iconName: "awesome/calendar_times_o";  name:"移除" ;
            onTriggered: {
                if((currentRow>=0)&&(table.rowCount)){
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
    inforMenu: []
    funcMenu: [
        Action{iconName:"awesome/send_o";hoverAnimation:true;summary: "F4"; name:"生成规范";
            onTriggered:{
                if((currentRow>=0)&&(table.rowCount)){
                    getWeldRules();
                }else {
                    message.open("请选择要生成规范的坡口信息。")
                }
            }
        },
        Action{iconName: "awesome/server";name:"条件补正";enabled:teachModel===1;
            onTriggered: {
                fix.show()
            }
        },
        Action{iconName: "av/fast_forward";name:"移至中线";
            onTriggered: {
                message.open("暂不支持移至中线命令！")
            }
        }
    ]*/
    tableData:[
        Controls.TableViewColumn{  role:"C1"; title:currentGroove===8?"脚长 ι1\n (mm)": "板厚 δ\n (mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{  role:"C2"; title:currentGroove===8?"脚长 ι2\n (mm)": currentGroove==0||currentGroove==3||currentGroove==5?"脚长 ι\n (mm)":"板厚差 e\n   (mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{  role:"C3"; title: "间隙 b\n (mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;visible:currentGroove!==8?true:false},
        Controls.TableViewColumn{  role:"C4"; title: "角度 β1\n  (deg)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{  role:"C5"; title: "角度 β2\n  (deg)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{  role:"C6"; title: "中心线 \n X(mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;visible:true},
        Controls.TableViewColumn{  role:"C7"; title: "中心线 \n Y(mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;visible:true},
        Controls.TableViewColumn{  role:"C8"; title: "中心线 \n Z(mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;visible:true}
    ]
    function openName(name){
        grooveName=name+"坡口条件"
        //打开最新的数据库
        MySQL.getJsonTable(grooveName);
    }
    function removeName(name){
        //搜寻最近列表 删除本次列表 更新 最近列表如model
        message.open(qsTr("正在删除坡口条件表格！"));
        //删除坡口条件表格
        MySQL.deleteTable(grooveName)
        //删除在坡口条件列表链接
        MySQL.clearTable(grooveNameList,"Name",grooveName)
        //选择最新的表格替换
        getLastGrooveName();
        //提示
        message.open(qsTr("已删除坡口条件表格！"))
    }
    function newFile(name,saveAs){
        //更新标题
        if((name!==grooveName)&&(typeof(name)==="string")){
            var user=settings.currentUserName;
            var Time=MyMath.getSysTime();
            message.open("正在创建坡口条件数据库！")
            //插入新的list
            MySQL.insertTableByJson(grooveNameList,{"Name":name+"坡口条件","CreatTime":Time,"Creator":user,"EditTime":Time,"Editor":user});
            updateListModel("Append",{"Name":name+"坡口条件","CreatTime":Time,"Creator":user,"EditTime":Time,"Editor":user});
            //创建新的 坡口条件
            MySQL.createTable(name+"坡口条件","ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT");
            grooveName=name+"坡口条件";
            if(saveAs){
                save();
            }else
                MySQL.getJsonTable(grooveName);
            message.open("已创建坡口条件数据库！")
        }
    }
    /*
    Dialog{
        id:open
        title:qsTr("打开坡口条件")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        property string name;
        property var nameList: [""]
        onOpened:{//打开对话框加载model
            nameList.length=0;
            for(var i=0;i<grooveNameListModel.count;i++)
                nameList.push(grooveNameListModel.get(i).Name);
            menuField.model=nameList;
            name=grooveNameListModel.get(0).Name;
            menuField.helperText="创建时间:"+grooveNameListModel.get(0).CreatTime+
                    "\n创建者:"+grooveNameListModel.get(0).Creator+
                    "\n修改时间:"+grooveNameListModel.get(0).EditTime+
                    "\n修改者:"+grooveNameListModel.get(0).Editor;
        }
        dialogContent: MenuField{id:menuField
            width:Units.dp(300)
            onItemSelected: {
                open.name=grooveNameListModel.get(index).Name;
                menuField.helperText="创建时间:"+grooveNameListModel.get(index).CreatTime+
                        "\n创建者:"+grooveNameListModel.get(index).Creator+
                        "\n修改时间:"+grooveNameListModel.get(index).EditTime+
                        "\n修改者:"+grooveNameListModel.get(index).Editor;
            }
        }
        onAccepted: {
            if(typeof(open.name)==="string"){
                grooveName=open.name;
                //打开最新的数据库
                MySQL.getJsonTable(grooveName);
            }
        }
    }
    Dialog{
        id:remove
        title: qsTr("删除坡口条件")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        onOpened:{
            //确保不是默认的坡口名称
            positiveButtonEnabled=grooveNameList.replace("列表","")===grooveName?false:true
        }
        dialogContent:
            Item{
            width: Units.dp(300)
            height:Units.dp(48)
            Label{
                text:"确认删除\n"+grooveName+"！"
                style: "menu"
            }
        }
        onAccepted: {
            if(positiveButtonEnabled){
                //搜寻最近列表 删除本次列表 更新 最近列表如model
                message.open(qsTr("正在删除坡口条件表格！"));
                //删除坡口条件表格
                MySQL.deleteTable(grooveName)
                //删除在坡口条件列表链接
                MySQL.clearTable(grooveNameList,"Name",grooveName)
                //选择最新的表格替换
                getLastGrooveName();
                //提示
                message.open(qsTr("已删除坡口条件表格！"))
            }
        }
    }
    Dialog{
        id:newFile
        title: saveAs?qsTr("另存坡口条件"):qsTr("新建坡口条件")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        property var grooveList: [""]
        onOpened:{
            newFileTextField.text=grooveName.replace("坡口条件","");
            newFileTextField.helperText="请输入新的坡口条件"
            grooveList.length=0;
            for(var i=0;i<grooveNameListModel.count;i++){
                grooveList.push(grooveNameListModel.get(i).Name.replace("坡口条件",""));
            }
        }
        dialogContent:[Item{
                width: Units.dp(300)
                height:newFileTextField.actualHeight
                TextField{
                    id:newFileTextField
                    helperText: "请输入新的坡口条件"
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
                            helperText="该坡口条件名称已存在！"
                            hasError=true;
                        }else{
                            newFile.positiveButtonEnabled=true;
                            helperText="坡口条件名称有效！"
                            hasError=false
                        }
                        if(!isNaN(Number(text.charAt(0)))){ //开头字母为数字
                            newFile.positiveButtonEnabled=false;
                            helperText="坡口条件名称开头不能数字！"
                            hasError=true;
                        }
                    }
                }
            }]
        onAccepted: {
            if(positiveButtonEnabled){
                //更新标题
                var name = newFileTextField.text
                if((name!==grooveName)&&(typeof(name)==="string")){
                    var user=settings.currentUserName;
                    var Time=MyMath.getSysTime();
                    message.open("正在创建坡口条件数据库！")
                    //插入新的list
                    MySQL.insertTableByJson(grooveNameList,{"Name":name+"坡口条件","CreatTime":Time,"Creator":user,"EditTime":Time,"Editor":user});
                    grooveNameListModel.append({"Name":name+"坡口条件","CreatTime":Time,"Creator":user,"EditTime":Time,"Editor":user});
                    //创建新的 坡口条件
                    MySQL.createTable(name+"坡口条件","ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT");
                    grooveName=name+"坡口条件";
                    if(saveAs){
                        save();
                    }else
                        MySQL.getJsonTable(grooveName);
                    message.open("已创建坡口条件数据库！")
                }
            }
            newFileTextField.text=""
        }
        onRejected: newFileTextField.text=""
    }
    MyTextFieldDialog{
        id:myTextFieldDialog
        sourceComponent:Image{
            id:addImage
            source: "../Pic/坡口参数图.png"
            sourceSize.width: Units.dp(350)
        }
        message:root.message
        repeaterModel:grooveRules
        onAccepted: {
            updateModel(myTextFieldDialog.title==="编辑坡口条件"?"Set":"Append",
                                                            {"ID":getText(0),"C1":getText(1),"C2":getText(2),"C3":getText(3),"C4":getText(4),"C5":getText(5),
                                                                "C6":myTextFieldDialog.title==="编辑坡口条件"?model.get(currentRow).C6:"0",
                                                                                                         "C7":myTextFieldDialog.title==="编辑坡口条件"?model.get(currentRow).C7:"0",
                                                                                                                                                  "C8":myTextFieldDialog.title==="编辑坡口条件"?model.get(currentRow).C8:"0",
                                                            })
        }
        onOpened: {
            if(title==="编辑坡口条件"){
                if(currentRow>-1){
                    //复制数据到 editData
                    var obj=model.get(currentRow);
                    grooveRules.setProperty(0,"value",obj.ID);
                    grooveRules.setProperty(1,"value",obj.C1);
                    grooveRules.setProperty(2,"value",obj.C2);
                    grooveRules.setProperty(3,"value",obj.C3);
                    grooveRules.setProperty(4,"value",obj.C4);
                    grooveRules.setProperty(5,"value",obj.C5);
                    updateText();
                    focusIndex=0;
                    changeFocus(focusIndex)
                }else{
                    message.open("请选择要编辑的行！")
                    positiveButtonEnabled=false;
                }
            }else{
                grooveRules.setProperty(0,"value",String(model.count+1));
                for(var i=1;i<grooveRules.count;i++){
                    grooveRules.setProperty(i,"value","0");
                }
                 updateText();
            }
        }
    }*/
    Dialog{
        id:fix
        title: qsTr("坡口条件补正")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        globalMouseAreaEnabled:false
        property int selectedIndex: 0
        property var valueModel:[currentGroove===8||currentGroove==0||currentGroove==3||currentGroove==5?"脚长补正标志:":"板厚补正标志:","间隙补正标志:","角度补正标志:"]
        property var valueBuf:new Array(valueModel.length)
        signal changeFixSelectedIndex(int index)
        signal changeValue(int index,bool value)
        onChangeFixSelectedIndex:{
            fix.selectedIndex=index;
        }
        Keys.onUpPressed: {
            if(fix.selectedIndex)
                fix.selectedIndex--;
        }
        Keys.onDownPressed: {
            if(fix.selectedIndex<2)
                fix.selectedIndex++;
        }
        Keys.onVolumeDownPressed: {
            changeValue(fix.selectedIndex,false)
        }
        Keys.onVolumeUpPressed: {
            changeValue(fix.selectedIndex,true)
        }
        onOpened:{
            valueBuf[0]=settings.fixHeight;
            valueBuf[1]=settings.fixGap;
            valueBuf[2]=settings.fixAngel;
            fix.changeValue(0,settings.fixHeight);
            fix.changeValue(1,settings.fixGap);
            fix.changeValue(2,settings.fixAngel);
        }
        onAccepted: {
            settings.fixHeight=valueBuf[0];
            settings.fixGap=valueBuf[1];
            settings.fixAngel=valueBuf[2];
        }
        onRejected: {
            valueBuf[0]=settings.fixHeight;
            valueBuf[1]=settings.fixGap;
            valueBuf[2]=settings.fixAngel;
        }
        dialogContent:Repeater{
            model:fix.valueModel
            delegate: ListItem.Subtitled{
                id:sub
                property int subIndex:index
                text:modelData
                height:Units.dp(32)
                width: Units.dp(250)
                selected: index===fix.selectedIndex
                onPressed:fix.changeFixSelectedIndex(index)
                Connections{
                    target: fix
                    onChangeValue:{
                        if(sub.subIndex===index){
                            checkBox.checked=value;
                        }
                    }
                }
                secondaryItem: CheckBox{
                    id:checkBox
                    text:checked?"打开":"关闭"
                    anchors.verticalCenter: parent.verticalCenter
                    onCheckedChanged: {
                        fix.changeFixSelectedIndex(sub.subIndex)
                        fix.valueBuf[sub.subIndex]=checked;
                    }
                }
            }
        }
    }
}

