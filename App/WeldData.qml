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
//import QtCharts 2.1

TableCard{
    id:root
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "WeldData"

    property Item message
    property string status:"空闲态"

    //上次焊接规范名称
    property string weldRulesName;
    property bool weldTableEx
    property string weldRulesNameList

    property string currentUserName
    //外部更新数据
    signal updateModel(string str,var data);
    signal changeWeldData();

    property bool saveAs:false

    ListModel{
        id:weldCondtion
        ListElement{name:"        NO.          :";show:true;value:"";min:1;max:1000;isNum:true;step:1}
        ListElement{name:"层                号 :";show:true;value:"";min:1;max:1000;isNum:true;step:1}
        ListElement{name:"道                号 :";show:true;value:"";min:1;max:1000;isNum:true;step:1}
        ListElement{name:"电      流  (A)    :";show:true;value:"";min:10;max:300;isNum:true;step:1}
        ListElement{name:"电      压  (V)    :";show:true;value:"";min:10;max:50;isNum:true;step:0.1}
        ListElement{name:"摆      幅(mm) :";show:true;value:"";min:0;max:1000;isNum:true;step:0.1}
        ListElement{name:"摆速(cm/min) :";show:true;value:"";min:50;max:250;isNum:true;step:1}
        ListElement{name:"焊速(cm/min) :";show:true;value:"";min:4;max:200;isNum:true;step:0.1}
        ListElement{name:"焊接线X(mm)  :";show:true;value:"";min:-100;max:100;isNum:true;step:0.1}
        ListElement{name:"焊接线Y(mm)  :";show:true;value:"";min:-10;max:100;isNum:true;step:0.1}
        ListElement{name:"前   停  留   (s) :";show:true;value:"";min:0;max:5;isNum:true;step:0.01}
        ListElement{name:"后   停  留   (s) :";show:true;value:"";min:0;max:5;isNum:true;step:0.01}
        ListElement{name:"停  止 时 间(s) :";show:true;value:"";min:0;max:1000;isNum:true;step:0.1}
        ListElement{name:"层       面     积 :";show:false;value:"";min:1;max:10000;isNum:true;step:0.1}
        ListElement{name:"道       面     积 :";show:false;value:"";min:1;max:10000;isNum:true;step:0.1}
        ListElement{name:"起    弧   点   X :";show:true;value:"";min:-100;max:100;isNum:true;step:0.1}
        ListElement{name:"起    弧   点   Y :";show:true;value:"";min:-10;max:100;isNum:true;step:0.1}
        ListElement{name:"起    弧   点   Z :";show:true;value:"";min:-30000;max:30000;isNum:true;step:1}
        ListElement{name:"收    弧   点   X :";show:true;value:"";min:-100;max:100;isNum:true;step:0.1}
        ListElement{name:"收    弧   点   Y :";show:true;value:"";min:-10;max:100;isNum:true;step:0.1}
        ListElement{name:"收    弧   点   Z :";show:true;value:"";min:-30000;max:30000;isNum:true;step:1}
    }
    onWeldTableExChanged: {
        weldCondtion.setProperty(6,"show",weldTableEx?true:false);
        weldCondtion.setProperty(15,"show",weldTableEx?true:false);
        weldCondtion.setProperty(16,"show",weldTableEx?true:false);
        weldCondtion.setProperty(17,"show",weldTableEx?true:false);
        weldCondtion.setProperty(18,"show",weldTableEx?true:false);
        weldCondtion.setProperty(19,"show",weldTableEx?true:false);
        weldCondtion.setProperty(20,"show",weldTableEx?true:false);
    }

    ListModel{id:pasteModel;
        ListElement{ID:"";C1:"";C2:"";C3:"";C4:"";C5:"";C6:"";C7:"";C8:"";C9:"";C10:"";C11:"";C12:"";C13:"";C14:"";C15:"";C16:"";C17:"";C18:"";C19:""}
    }
    ListModel{id:weldRulesNameListModel
        ListElement{Name:"";CreatTime:"";Creater:"";EditTime:"";Editor:"";}
    }
    Connections{
        target: MySQL
        onMySqlChanged:{
            var i;
            //更新列表
            if(tableName===weldRulesNameList){
                for(i=0;i<jsonObject.length;i++){
                    console.log(jsonObject[i]);
                    if(weldRulesNameListModel.count<jsonObject.length)
                        weldRulesNameListModel.append(jsonObject[i]);
                    else
                        weldRulesNameListModel.set(i,jsonObject[i]);
                }
                if(weldRulesNameListModel.count>jsonObject.length)
                    weldRulesNameListModel.remove(jsonObject.length,weldRulesNameListModel.count-jsonObject.length)
                weldRulesName=jsonObject[0].Name;
                MySQL.getJsonTable(weldRulesName);
            }else if(tableName===weldRulesName){//更新数据表
                updateModel("Clear",{});
                for(i=0;i<jsonObject.length;i++){
                    updateModel("Append",jsonObject[i]);
                }
                currentRow=0;
                selectIndex(0);
            }
        }
    }

    function getLastweldRulesName(){
        MySQL.getDataOrderByTime(weldRulesNameList,"EditTime");
    }

    function save(){
        if(typeof(weldRulesName)==="string"){
            //清除保存数据库
            MySQL.clearTable(weldRulesName,"","");
            for(var i=0;i<model.count;i++){
                //插入新的数据
                MySQL.insertTable(weldRulesName,model.get(i));
            }
            //更新数据库保存时间
            MySQL.setValue(weldRulesNameList,"Name",weldRulesName,"EditTime",MyMath.getSysTime());
            MySQL.setValue(weldRulesNameList,"Name",weldRulesName,"Editor",currentUserName);
            message.open("焊接规范已保存。");
        }else{
            message.open("焊接规范名称格式不符，规范未保存！")
        }
    }

    //当前页面关闭 则 关闭当前页面内 对话框
    onStatusChanged: {
        if(status==="坡口检测完成态"){
            currentRow=0;
            selectIndex(0);
        }
    }

    function selectIndex(index){
        if((index<model.count)&&(index>-1)){
            table.selection.clear();
            table.selection.select(index);
        }
        else{
            if(model.count>0)
                message.open("索引超过条目上限或索引无效！")
        }
    }

    footerText:"系统当前处于"+status.replace("态","状态。")
    tableRowCount:7
    headerTitle: weldRulesName
    table.__listView.interactive: status!=="焊接态"
    fileMenu: [
        Action{iconName:"awesome/calendar_plus_o";name:"新建";
            onTriggered: {saveAs=false;newFile.show();}},
        Action{iconName:"awesome/folder_open_o";name:"打开";
            onTriggered: open.show();},
        Action{iconName:"awesome/save";name:"保存";
            onTriggered: {save()}},
        Action{iconName:"awesome/credit_card";name:"另存为";
            onTriggered: {saveAs=true;newFile.show();
            }
        },
        Action{iconName:"awesome/calendar_times_o";name:"删除";enabled: weldRulesNameList.replace("列表","")===weldRulesName?false:true
            onTriggered: remove.show();}
    ]
    editMenu:[
        Action{iconName:"awesome/plus_square_o";name:"添加"
            onTriggered:{
                myTextFieldDialog.title="添加焊接规范";
                myTextFieldDialog.show();}},
        Action{iconName:"awesome/edit";name:"编辑";onTriggered: {myTextFieldDialog.title="编辑焊接规范"
                if((currentRow>=0)&&(table.rowCount)){
                    myTextFieldDialog.show()
                }else{
                    message.open("请选择要编辑的行！")
                }
            }
        },
        Action{iconName:"awesome/copy";name:"复制";
            onTriggered: {
                if((currentRow>=0)&&(table.rowCount)){
                    pasteModel.set(0,model.get(currentRow));
                    message.open("已复制。");}
                else{
                    message.open("请选择要复制的行！")
                }
            }},
        Action{iconName:"awesome/paste"; name:"粘帖"
            onTriggered: {
                if((currentRow>=0)&&(table.rowCount)){
                    updateModel("Set", pasteModel.get(0));
                    message.open("已粘帖。");}
                else
                    message.open("请选择要粘帖的行！")
            }
        },
        Action{iconName: "awesome/trash_o";  name:"移除";
            onTriggered: {
                if((currentRow>=0)&&(table.rowCount)){
                    updateModel("Remove",{})
                    message.open("已移除。");}
                else
                    message.open("请选择要移除的行！")
            }
        },
        Action{iconName:"awesome/calendar_o";name:"清空";
            onTriggered: {
                currentRow=-1;
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
                if((currentRow>=0)&&(table.rowCount)){
                    changeWeldData();
                    message.open("已下发焊接规范。");
                }else {
                    message.open("请选择下发焊接规范。")
                }
            }
        }/*,
        Action{iconName:"awesome/send_o";name:"填充面积"
            onTriggered: {}//{weldArea.show()}
        }*/
    ]
    tableData:[
        Controls.TableViewColumn{role: "C1";title:"   焊接\n层道数";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C2";title: "电流\n  A";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C3";title: "电压\n  V";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C4";title: " 摆幅\n  mm";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;visible: weldTableEx},
        Controls.TableViewColumn{role: "C5";title: "   摆速   \ncm/min";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;visible: weldTableEx},
        Controls.TableViewColumn{role: "C6";title: "焊接速度\n cm/min";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C7";title: "焊接线\n X mm";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C8";title: "焊接线\n Y mm";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C9";title: "前停留\n     s";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter; },
        Controls.TableViewColumn{role: "C10";title: "后停留\n     s";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C11";title: "停止\n时间";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C12";title: "层面积";width:Units.dp(70);movable:false;resizable:false;visible: false},
        Controls.TableViewColumn{role: "C13";title: "道面积";width:Units.dp(70);movable:false;resizable:false;visible: false},
        Controls.TableViewColumn{role: "C14";title: "起弧x";width:Units.dp(70);movable:false;resizable:false;visible: weldTableEx},
        Controls.TableViewColumn{role: "C15";title: "起弧y";width:Units.dp(70);movable:false;resizable:false;visible: weldTableEx},
        Controls.TableViewColumn{role: "C16";title: "起弧z";width:Units.dp(70);movable:false;resizable:false;visible: weldTableEx},
        Controls.TableViewColumn{role: "C17";title: "收弧x";width:Units.dp(70);movable:false;resizable:false;visible: weldTableEx},
        Controls.TableViewColumn{role: "C18";title: "收弧y";width:Units.dp(70);movable:false;resizable:false;visible: weldTableEx},
        Controls.TableViewColumn{role: "C19";title: "收弧z";width:Units.dp(70);movable:false;resizable:false;visible: weldTableEx}
    ]

    Dialog{
        id:open
        title:qsTr("打开焊接规范")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        property var nameList: [""]
        property string name
        onOpened:{//打开对话框加载model
            nameList.length=0;
            for(var i=0;i<weldRulesNameListModel.count;i++)
                nameList.push(weldRulesNameListModel.get(i).Name);
            menuField.model=nameList;
            name=weldRulesNameListModel.get(0).Name;
            menuField.helperText="创建时间:"+weldRulesNameListModel.get(0).CreatTime+
                    "\n创建者:"+weldRulesNameListModel.get(0).Creator+
                    "\n修改时间:"+weldRulesNameListModel.get(0).EditTime+
                    "\n修改者:"+weldRulesNameListModel.get(0).Editor;
        }
        dialogContent: MenuField{id:menuField
            width:Units.dp(300)
            onItemSelected: {
                open.name=weldRulesNameListModel.get(index).Name;
                menuField.helperText="创建时间:"+weldRulesNameListModel.get(index).CreatTime+
                        "\n创建者:"+weldRulesNameListModel.get(index).Creator+
                        "\n修改时间:"+weldRulesNameListModel.get(index).EditTime+
                        "\n修改者:"+weldRulesNameListModel.get(index).Editor;
            }
        }
        onAccepted: {
            if(typeof(open.name)==="string")
            {
                weldRulesName=open.name;
                //打开最新的数据库
                MySQL.getJsonTable(weldRulesName);
            }
        }
    }
    Dialog{
        id:newFile
        title: saveAs?qsTr("另存焊接规范"):qsTr("新建焊接规范")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        property var nameList:[""]
        onOpened:{
            newFileTextField.text=weldRulesName.replace("焊接规范","")
            newFileTextField.helperText=qsTr("请输入新的焊接规范名称！")
            nameList.length=0;
            for(var i=0;i<weldRulesNameListModel.count;i++){
                nameList.push(weldRulesNameListModel.get(i).Name.replace("焊接规范",""));
            }
        }
        dialogContent:Item{
            width: Units.dp(300)
            height:newFileTextField.actualHeight
            TextField{
                id:newFileTextField
                // text:weldRulesName
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
                    if(!isNaN(Number(text.charAt(0)))){ //开头字母为数字
                        newFile.positiveButtonEnabled=false;
                        helperText="焊接规范名称开头不能数字！"
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
                var time=MyMath.getSysTime();
                var user=currentUserName
                message.open("正在创建焊接规范数据库！")
                //插入新的list
                MySQL.insertTableByJson(weldRulesNameList,{"Name":title+"焊接规范","CreatTime":time,"Creator":user,"EditTime":time,"Editor":user});
                weldRulesNameListModel.append({"Name":title+"焊接规范","CreatTime":time,"Creator":user,"EditTime":time,"Editor":user});
                //创建新的 坡口条件
                MySQL.createTable(title+"焊接规范","ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT,C10 TEXT,C11 TEXT,C12 TEXT,C13 TEXT,C14 TEXT,C15 TEXT,C16 TEXT,C17 TEXT,C18 TEXT,C19 TEXT");
                weldRulesName=title+"焊接规范";
                if(saveAs){
                    save();
                }else
                    MySQL.getJsonTable(weldRulesName);
                message.open("已创建焊接规范数据库！")
            }
            newFileTextField.text=""
        }
        onRejected: newFileTextField.text=""
    }
    Dialog{
        id:remove
        title: qsTr("删除焊接规范")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        onOpened:{
            positiveButtonEnabled=weldRulesNameList.replace("列表","")===weldRulesName?false:true
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
            if(positiveButtonEnabled){
                //搜寻最近列表 删除本次列表 更新 最近列表如model
                message.open(qsTr("正在删除坡口条件表格！"));
                //删除坡口条件表格
                MySQL.deleteTable(weldRulesName)
                //删除在坡口条件列表链接
                MySQL.clearTable(weldRulesNameList,"Name",weldRulesName)
                //选择最新的表格替换
                getLastweldRulesName();
                //提示
                message.open(qsTr("已删除坡口条件表格！"))
            }
        }
    }

    MyTextFieldDialog{
        id:myTextFieldDialog
        repeaterModel: weldCondtion
        message: root.message
        onAccepted: {
            updateModel(myTextFieldDialog.title==="编辑焊接规范"?"Set":"Append",
                                                            {"ID":getText(0), "C1":getText(1)+"/"+getText(2),"C2":getText(3),"C3":getText(4),"C4":getText(5),"C5":getText(6),"C6":getText(7),
                                                                "C7":getText(8),"C8":getText(9),"C9":getText(10),"C10":getText(11),"C11":getText(12),"C12":getText(13),"C13":getText(14),
                                                                "C14":getText(15),"C15":getText(16),"C16":getText(17),"C17":getText(18),"C18":getText(19),"C19":getText(20)})
        }
        onOpened: {
                if(title==="编辑焊接规范"){
                     if(currentRow>-1){
                    //复制数据到 editData
                    var obj=model.get(currentRow);
                    weldCondtion.setProperty(0,"value",obj.ID);
                    var temp=obj.C1;
                    if(temp!==""){
                        temp=temp.split("/")
                        weldCondtion.setProperty(1,"value",temp[0])
                        weldCondtion.setProperty(2,"value",temp[1]);
                    }else{
                        weldCondtion.setProperty(1,"value","0")
                        weldCondtion.setProperty(2,"value","0");
                    }
                    weldCondtion.setProperty(3,"value",obj.C2);
                    weldCondtion.setProperty(4,"value",obj.C3);
                    weldCondtion.setProperty(5,"value",obj.C4);
                    weldCondtion.setProperty(6,"value",obj.C5);
                    weldCondtion.setProperty(7,"value",obj.C6);
                    weldCondtion.setProperty(8,"value",obj.C7);
                    weldCondtion.setProperty(9,"value",obj.C8);
                    weldCondtion.setProperty(10,"value",obj.C9);
                    weldCondtion.setProperty(11,"value",obj.C10);
                    weldCondtion.setProperty(12,"value",obj.C11);
                    weldCondtion.setProperty(13,"value",obj.C12);
                    weldCondtion.setProperty(14,"value",obj.C13);
                    weldCondtion.setProperty(15,"value",obj.C14);
                    weldCondtion.setProperty(16,"value",obj.C15);
                    weldCondtion.setProperty(17,"value",obj.C16);
                    weldCondtion.setProperty(18,"value",obj.C17);
                    weldCondtion.setProperty(19,"value",obj.C18);
                    weldCondtion.setProperty(20,"value",obj.C19);
                    updateText();
                    focusIndex=0;
                    changeFocus(focusIndex)
                     }
                    else{
                        message.open("请选择要编辑的行！")
                        positiveButtonEnabled=false;
                    }
                }else{
                    weldCondtion.setProperty(0,String(model.count+1));
                    for(var i=1;i<=weldCondtion.count;i++){
                        weldCondtion.setProperty(i,"0")
                    }
                    updateText();
                }
        }
    }
    Dialog{
        id:info
        title: qsTr("焊接规范信息")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        globalMouseAreaEnabled:false
    }

}
