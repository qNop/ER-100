import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.2 as Controls
import QtQuick.Window 2.2
import WeldSys.AppConfig 1.0
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
    property string currentGrooveName

    property string currentUserName
    //外部更新数据
    signal updateModel(string str,var data);
    signal updateWeldRulesName(string str);

    property var weldCondtion: [
        "        NO.          :",
        "层                号 :",
        "道                号 :",
        "电      流  (A)    :",
        "电      压  (V)    :",
        "摆      幅(mm) :",
        "摆速(cm/min) :",
        "焊速(cm/min) :",
        "焊接线X(mm) :",
        "焊接线Y(mm) :",
        "前   停  留   (s):",
        "后   停  留   (s):",
        "停  止 时 间(s):",
        "层       面     积:",
        "道       面     积:",
        "起    弧   点   X:",
        "起    弧   点   Y:",
        "起    弧   点   Z:"]
    property var weldCondtion1: [
        "        NO.          :",
        "层                号 :",
        "道                号 :",
        "电      流  (A)    :",
        "电      压  (V)    :",
        "摆      幅(mm) :",
        "摆速(cm/min) :",
        "焊速(cm/min) :",
        "焊接线X(mm) :",
        "焊接线Y(mm) :",
        "前   停  留   (s):",
        "后   停  留   (s):",
        "停  止 时 间(s):"]
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
            currentRow=0;
            selectIndex(0)
        }
    }
    function selectIndex(index){
        if((index<model.count)&&(index>-1)){
            table.selection.clear();
            table.selection.select(index);
        }
        else{
            message.open("索引超过条目上限或索引无效！")
        }
    }
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
                    for(var i=0;i<table.rowCount;i++){
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
        Action{iconName:"awesome/plus_square_o";name:"添加"
            onTriggered:{
                myTextFieldDialog.title="添加焊接规范";
                myTextFieldDialog.show();}},
        Action{iconName:"awesome/edit";name:"编辑";onTriggered: {myTextFieldDialog.title="编辑焊接规范"
                myTextFieldDialog.show()}
        },
        Action{iconName:"awesome/copy";name:"复制";
            onTriggered: {
                if(currentRow>=0){
                    pasteModel.set(0,model.get(currentRow));
                    message.open("已复制。");}
                else{
                    message.open("请选择要复制的行！")
                }
            }},
        Action{iconName:"awesome/paste"; name:"粘帖"
            onTriggered: {
                if(currentRow>=0){
                    updateModel("Set", pasteModel.get(0));
                    message.open("已粘帖。");}
                else
                    message.open("请选择要粘帖的行！")
            }
        },
        Action{iconName: "awesome/trash_o";  name:"移除";
            onTriggered: {
                if(currentRow>=0){
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
                if(currentRow>-1){
                    var index= currentRow
                    var floor=model.get(index).C1.split("/");
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
                                             model.get(index).C11==="永久"?"0":model.get(index).C11,
                                                                          model.get(index).C12*10,//层面积
                                                                          model.get(index).C13*10,//单道面积
                                                                          model.get(index).C14*10,//起弧位置偏移
                                                                          model.get(index).C15*10,//起弧
                                                                          model.get(index).C16*10,//起弧
                                                                          table.rowCount//总共焊道号
                                            ]);
                    message.open("已下发焊接规范。");
                }else {
                    message.open("请选择下发焊接规范。")
                }
            }
        },
        Action{iconName:"awesome/send_o";name:"相关计算"
            onTriggered: {weldArea.show()}
        }
    ]
    tableData:[
        Controls.TableViewColumn{role: "C1";title:"   焊接\n层道数";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C2";title: "电流\n  A";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C3";title: "电压\n  V";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C4";title: " 摆幅\n  mm";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;visible: weldTableEx},
        Controls.TableViewColumn{role: "C5";title: "   摆速   \nmm/min";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;visible: weldTableEx},
        Controls.TableViewColumn{role: "C6";title: "焊接速度\n cm/min";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C7";title: "焊接线\n X mm";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C8";title: "焊接线\n Y mm";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C9";title: "前停留\n     s";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter; },
        Controls.TableViewColumn{role: "C10";title: "后停留\n     s";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C11";title: "停止\n时间";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C12";title: "层面积";width:Units.dp(70);movable:false;resizable:false;visible: weldTableEx},
        Controls.TableViewColumn{role: "C13";title: "道面积";width:Units.dp(70);movable:false;resizable:false;visible: weldTableEx},
        Controls.TableViewColumn{role: "C14";title: "起弧x";width:Units.dp(70);movable:false;resizable:false;visible: weldTableEx},
        Controls.TableViewColumn{role: "C15";title: "起弧y";width:Units.dp(70);movable:false;resizable:false;visible: weldTableEx},
        Controls.TableViewColumn{role: "C16";title: "起弧z";width:Units.dp(70);movable:false;resizable:false;visible: weldTableEx}
    ]

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
            var user=currentUserName
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

    MyTextFieldDialog{
        id:myTextFieldDialog
        // title: qsTr("编辑焊接规范")
        repeaterModel: weldTableEx?weldCondtion:weldCondtion1
        onAccepted: {
            updateModel(myTextFieldDialog.title==="编辑焊接规范"?"Set":"Append",pasteModel.get(0))
        }
        onKeysonVolumeDown: { //按键按下
            var num;
            switch(focusIndex){
            case 0:
                num=Number(pasteModel.get(0).ID);
                num--;
                if(num<=1)
                    num=1;
                else
                    openText(0,String(num))
                break;
            case 2:
                num=Number(pasteModel.get(0).C2);
                num--;
                if(num<=1)
                    num=1;
                else
                    openText(2,String(num))
                break;

            }
        }
        onKeysonVolumeUp: {//按键按上
            var num;
            switch(focusIndex){
            case 0:
                num=Number(pasteModel.get(0).ID);
                num++;
                if(num>99)
                    num=99;
                else
                    openText(0,String(num))
                break;
            case 2:
                num=Number(pasteModel.get(0).C2);
                num++;
                if(num>300)
                    num=300;
                else
                    openText(2,String(num))
                break;

            }
        }
        onChangeText: {
            var temp;
            switch(index){
            case 0:pasteModel.setProperty(0,"ID",text);break;
            case 1:temp=pasteModel.get(0).C1;
                temp=temp.split("/");
                pasteModel.setProperty(0,"C1",text+"/"+temp[1]);break;
            case 2:temp=pasteModel.get(0).C1;
                temp=temp.split("/");
                pasteModel.setProperty(0,"C1",+temp[0]+"/"+text);break;
            case 3:pasteModel.setProperty(0,"C2",text);break;
            case 4:pasteModel.setProperty(0,"C3",text);break;
            case 5:pasteModel.setProperty(0,"C4",text);break;
            case 6:pasteModel.setProperty(0,"C5",text);break;
            case 7:pasteModel.setProperty(0,"C6",text);break;
            case 8:pasteModel.setProperty(0,"C7",text);break;
            case 9:pasteModel.setProperty(0,"C8",text);break;
            case 10:pasteModel.setProperty(0,"C9",text);break;
            case 11:pasteModel.setProperty(0,"C10",text);break;
            case 12:pasteModel.setProperty(0,"C11",text);break;
            case 13:pasteModel.setProperty(0,"C12",text);break;
            case 14:pasteModel.setProperty(0,"C13",text);break;
            case 15:pasteModel.setProperty(0,"C14",text);break;
            case 16:pasteModel.setProperty(0,"C15",text);break;
            case 17:pasteModel.setProperty(0,"C16",text);break;
            }
        }
        onOpened: {
            if(title==="编辑焊接规范"){
                if(currentRow>-1){
                    //复制数据到 editData
                    var index=currentRow
                    var obj=model.get(index);
                    openText(0,obj.ID);
                    var temp=obj.C1;
                    temp=temp.split("/")
                    openText(1,temp[0])
                    openText(2,temp[1]);
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
                    if(weldTableEx){
                        openText(13,obj.C12);
                        openText(14,obj.C13);
                        openText(15,obj.C14);
                        openText(16,obj.C15);
                        openText(17,obj.C16);
                    }
                    pasteModel.set(0,obj);
                    focusIndex=0;
                    changeFocus(focusIndex)
                }
                else{
                    message.open("请选择要编辑的行！")
                    positiveButtonEnabled=false;
                }
            }else{
                for(var i=0;i<=weldCondtion.length;i++){
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
    Dialog{
        id:weldArea
        title: qsTr("相关计算")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        property int current: 0
        property int weldSpeed: 0
        property int k: 0
        property int met: 0
        property int area: 0

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
                            console.log("计算weldArea.area"+weldArea.area)
                        }
                    }
                }
            }

        }
    }
}

