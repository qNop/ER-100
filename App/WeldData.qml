import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.2 as Controls
import QtQuick.Window 2.2
import WeldSys.ERModbus 1.0
import WeldSys.WeldMath 1.0
import QtQuick.Layouts 1.1
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
    signal updateWeldRulesName(string str);
    signal changeWeldData();

    property bool saveAs:false

    ListModel{
        id:weldCondtion
        ListElement{name:"        NO.          :";show:true;min:1;max:1000;isNum:true;step:1}
        ListElement{name:"层                号 :";show:true;min:1;max:1000;isNum:true;step:1}
        ListElement{name:"道                号 :";show:true;min:1;max:1000;isNum:true;step:1}
        ListElement{name:"电      流  (A)    :";show:true;min:10;max:300;isNum:true;step:1}
        ListElement{name:"电      压  (V)    :";show:true;min:10;max:50;isNum:true;step:0.1}
        ListElement{name:"摆      幅(mm) :";show:true;min:0;max:1000;isNum:true;step:0.1}
        ListElement{name:"摆速(cm/min) :";show:true;min:50;max:250;isNum:true;step:1}
        ListElement{name:"焊速(cm/min) :";show:true;min:4;max:200;isNum:true;step:0.1}
        ListElement{name:"焊接线X(mm)  :";show:true;min:-100;max:100;isNum:true;step:0.1}
        ListElement{name:"焊接线Y(mm)  :";show:true;min:-10;max:100;isNum:true;step:0.1}
        ListElement{name:"前   停  留   (s) :";show:true;min:0;max:5;isNum:true;step:0.01}
        ListElement{name:"后   停  留   (s) :";show:true;min:0;max:5;isNum:true;step:0.01}
        ListElement{name:"停  止 时 间(s) :";show:true;min:0;max:1000;isNum:true;step:0.1}
        ListElement{name:"层       面     积 :";show:false;min:1;max:10000;isNum:true;step:0.1}
        ListElement{name:"道       面     积 :";show:false;min:1;max:10000;isNum:true;step:0.1}
        ListElement{name:"起    弧   点   X :";show:true;min:-100;max:100;isNum:true;step:0.1}
        ListElement{name:"起    弧   点   Y :";show:true;min:-10;max:100;isNum:true;step:0.1}
        ListElement{name:"起    弧   点   Z :";show:true;min:-30000;max:30000;isNum:true;step:1}
        ListElement{name:"收    弧   点   X :";show:true;min:-100;max:100;isNum:true;step:0.1}
        ListElement{name:"收    弧   点   Y :";show:true;min:-10;max:100;isNum:true;step:0.1}
        ListElement{name:"收    弧   点   Z :";show:true;min:-30000;max:30000;isNum:true;step:1}
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

    function getLastRulesName(){
        if((typeof(weldRulesNameList)==="string")&&(weldRulesNameList!=="")){
            //名称存在且格式正确  那么 重新更新 表名称参数 找出最新的表
            var res =UserData.getDataOrderByTime(weldRulesNameList,"EditTime")
            if((res!==-1)&&(typeof(res)==="object")){
                return res[0].Name;
            }else
                return -1;
        }
        return -1;
    }

    //当前页面关闭 则 关闭当前页面内 对话框
    onStatusChanged: {
        if(status==="坡口检测完成态"){
            currentRow=0;
            selectIndex(0);
        }
    }
    onUpdateWeldRulesName: {
        if((typeof(str)==="string")&&(str!=="")){
            var res=UserData.getTableJson(str)
            if(res!==-1){
                if(status!=="坡口检测完成态"){ //坡口检测完成态的时候要保存数据
                    updateModel("Clear",{});
                    for(var i=0;i<res.length;i++){
                        if(res[i].ID!==null)
                            updateModel("Append",res[i]);
                    }
                }
                currentRow=0;
                selectIndex(0);
                weldRulesName=str;
            }else{
                message.open("焊接规范表格不存在或为空！")
            }
        } else
            message.open("焊接规范列表内无数据！")
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

    function save(){
        if((typeof(weldRulesName)==="string")&&(weldRulesName!=="")){
            //清除保存数据库
            UserData.clearTable(weldRulesName,"","");
            for(var i=0;i<model.count;i++){
                //插入新的数据
                UserData.insertTable(weldRulesName,"(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",[
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
                                         model.get(i).C16,
                                         model.get(i).C17,
                                         model.get(i).C18,
                                         model.get(i).C19])
            }
            message.open("焊接规范已保存。");}
        else{
            message.open("焊接规范名称格式不符，规范未保存！")
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
            if((typeof(weldRulesNameList)==="string")&&(weldRulesNameList!=="")){
                //名称存在且格式正确  那么 重新更新 表名称参数 找出最新的表
                var res =UserData.getDataOrderByTime(weldRulesNameList,"EditTime")
                if((res!==-1)&&(typeof(res)==="object")){
                    for(var i=0;i<res.length;i++){
                        rulesList.push(res[i].Name.replace("焊接规范",""));
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
                //console.log("创建时间:"+open.creatTimeList[index]+"\n创建者:"+open.creatorList[index]+"\n修改时间:"+open.editTimeList[index]+"\n修改者:"+open.editorList[index])
            }
        }
        onAccepted: {
            if(typeof(open.name)==="string")
            {
                updateWeldRulesName(open.name.concat("焊接规范"))
            }
        }
        onRejected: {
            open.name=weldRulesName.replace("焊接规范","")
        }
    }
    Dialog{
        id:newFile
        title: saveAs?qsTr("另存焊接规范"):qsTr("新建焊接规范")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        property var nameList:[""]
        onOpened:{
            if((typeof(weldRulesNameList)==="string")&&(weldRulesNameList!=="")){
                //名称存在且格式正确  那么 重新更新 表名称参数 找出最新的表
                var res =UserData.getDataOrderByTime(weldRulesNameList,"EditTime")
                if((res!==-1)&&(typeof(res)==="object")){
                    nameList.length=0;
                    for(var i=0;i<res.length;i++){
                        nameList.push(res[i].Name.replace("焊接规范",""));
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
                var time=UserData.getSysTime();
                var user=currentUserName
                //在次列表插入新的数据
                UserData.insertTable(weldRulesNameList,"(?,?,?,?,?)",[title+"焊接规范",time,user,time,user])
                //创建新的 焊接条件
                UserData.createTable(title+"焊接规范","ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT,C10 TEXT,C11 TEXT,C12 TEXT,C13 TEXT,C14 TEXT,C15 TEXT,C16 TEXT,C17 TEXT,C18 TEXT,C19 TEXT")
                if(saveAs){
                    //保存焊接规范
                    weldRulesName=title+"焊接规范";
                    save();
                }else{
                    //更新焊接规范
                    updateWeldRulesName(title+"焊接规范");
                }
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
                UserData.deleteTable(weldRulesName);
                //清除次列表记录
                UserData.clearTable(weldRulesNameList,"Name",weldRulesName);
                //获取最新的数据表格
                var res=getLastRulesName();
                if(res!==-1){
                    updateWeldRulesName(res)
                }
            }
        }
    }

    MyTextFieldDialog{
        id:myTextFieldDialog
        // title: qsTr("编辑焊接规范")
        repeaterModel: weldCondtion
        message: root.message
        onAccepted: {
            updateModel(myTextFieldDialog.title==="编辑焊接规范"?"Set":"Append",
                                                            {"ID":getText(0), "C1":getText(1)+"/"+getText(2),"C2":getText(3),"C3":getText(4),"C4":getText(5),"C5":getText(6),"C6":getText(7),
                                                                "C7":getText(8),"C8":getText(9),"C9":getText(10),"C10":getText(11),"C11":getText(12),"C12":getText(13),"C13":getText(14),
                                                                "C14":getText(15),"C15":getText(16),"C16":getText(17),
                                                                "C17":getText(18),"C18":getText(19),"C19":getText(20)})
        }
        onOpened: {
            if(title==="编辑焊接规范"){
                if(currentRow>-1){
                    //复制数据到 editData
                    var index=currentRow
                    var obj=model.get(index);
                    openText(0,obj.ID);

                    var temp=obj.C1;
                    if(temp!==""){
                        temp=temp.split("/")
                        openText(1,temp[0])
                        openText(2,temp[1]);
                    }else{
                        openText(1,"0")
                        openText(2,"0");
                    }
                    openText(3,obj.C2);
                    openText(4,obj.C3);
                    openText(5,obj.C4);
                    openText(6,obj.C5);
                    openText(7,obj.C6);
                    openText(8,obj.C7);
                    openText(9,obj.C8);
                    openText(10,obj.C9);
                    openText(11,obj.C10);
                    openText(12,obj.C11);
                    openText(13,obj.C12);
                    openText(14,obj.C13);
                    openText(15,obj.C14);
                    openText(16,obj.C15);
                    openText(17,obj.C16);
                    openText(18,obj.C17);
                    openText(19,obj.C18);
                    openText(20,obj.C19);
                    focusIndex=0;
                    changeFocus(focusIndex)
                }
                else{
                    message.open("请选择要编辑的行！")
                    positiveButtonEnabled=false;
                }
            }else{
                openText(0,String(model.count+1));
                for(var i=1;i<=weldCondtion.count;i++){
                    openText(i,"0")
                }
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
/*
    Dialog{
        id:weldArea
        title: qsTr("计算填充面积")
        negativeButtonText:qsTr("关闭")
        positiveButton.visible: false
        // positiveButtonText:qsTr("计算")
        dismissOnTap:false
        property int current: 0
        property double weldSpeed: 0
        property double k: 0
        property int met: 0
        property double area: 0
        property double voltage: 0

        onOpened: {
            re.itemAt(0).text=0;
            re.itemAt(1).text=0;
            re.itemAt(2).text=0;
            re.itemAt(3).text=0;
            area=0;
        }
        onAccepted: {
            var temp
            if((current!==0)&&(weldSpeed!==0)&&(k!==0)&&(met!=0)){
                weldArea.area=Math.round(WeldMath.getWeldArea(weldArea.current,weldArea.weldSpeed,weldArea.met));
                weldArea.voltage=Math.round(WeldMath.getWeldVoltage(weldArea.current))
            }
            else
                message.open("输入参数不能为0 !")
        }
        onRejected:{
            weldArea.close();
        }
        Row{
            spacing: Units.dp(8)
            Column{
                width: Units.dp(150)
                Repeater{
                    id:re
                    model:["焊接电流:","焊接速度:","溶敷系数:","层填充系数:"]
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
                                case 2: weldArea.met=Number(text);break;
                                case 3: weldArea.k=Number(text);break;
                                }
                            }
                        }
                    }
                }
            }
            Rectangle{
                width:1
                height:parent.height-Units.dp(20)
            }
            Column{
                width: Units.dp(100)
                Repeater{
                    id:re1
                    model:["焊接电压:","填 充 量:"]
                    delegate: Row{
                        spacing: Units.dp(8)
                        Label{anchors.bottom: parent.bottom;text:modelData}
                        Label{
                            width: Units.dp(60)
                            text:index===0?weldArea.voltage:weldArea.area
                        }
                    }
                }
            }
        }
    }*/
}

