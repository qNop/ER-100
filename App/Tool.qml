import QtQuick 2.4
import Material 0.1
import WeldSys.WeldMath 1.0
import WeldSys.MySQL 1.0
import QtQuick.Controls 1.2 as Controls
import WeldSys.ERModbus 1.0
import "MyMath.js" as MyMath

OverlayLayer {
    id:root
    objectName: "ActionButtonOverlayer"
    z:message.opened?4:0
    property alias message: snackbar
    property string status
    property int errorCode
    property int errorCode1

    property var settings

    property int currentGroove;

    property int tablePageNumber:5

    property int toolGrooveIndex;
    property string toolGrooveName;
    property string toolGrooveNameList;
    property var toolGrooveNameListModel;
    property string toolGrooveModelName;
    property var toolGrooveModel;

    property int toolLimitedIndex;
    property string toolLimitedName;
    property string toolLimitedNameList;
    property var toolLimitedNameListModel;
    property string toolLimitedModelName;
    property var toolLimitedModel;

    property int toolWeldIndex;
    property string toolWeldName;
    property string toolWeldNameList;
    property var toolWeldNameListModel;
    property string toolWeldModelName;
    property var toolWeldModel;

    property int toolAccountIndex;
    property string toolAccountName;
    property string toolAccountNameList;
    property var toolAccountNameListModel;
    property string toolAccountModelName;
    property var toolAccountModel;

    signal updateModel(string modelName,string cmd,int startAddr,var data);
    signal openMyErrorDialog();
    signal toggleMyErrorDialog();
    signal openMotoDialog();
    signal toggleMotoDialog();


    property var model
    property int currentRow
    property var pasteModel
    property string modelName
    property string toolName
   // ListModel{id:pasteModel}

    //刷新数据
    onTablePageNumberChanged: {
        switch(tablePageNumber){
        case 0:toolName="坡口条件";
            modelName="grooveModel";
            currentNameList=toolGrooveNameList;
            currentNameListModel=toolGrooveNameListModel;
            model=toolGrooveModel;
            break;
        case 1:toolName="限制条件";
            modelName="limitedModel";
            currentNameList=toolLimitedNameList;
            currentNameListModel=toolLimitedNameListModel;
            model=toolLimitedModel;
            break;
        case 2:toolName="焊接规范";
            modelName="weldModel";
            currentNameList=toolWeldNameList;
            currentNameListModel=toolWeldNameListModel;
            model=toolWeldModel;
            break;
        case 3:toolName="用户信息";
            modelName="accountModel";
            model=toolAccountModel;
            break;
        default:toolName="";
            modelName="errorHistory";
            currentNameList="";
            currentNameListModel=null;
            model=toolGrooveModel;
            break;
        }
        paste.enabled=false;
    }
    property list<Action> fileMenu: [
        Action{iconName:"av/playlist_add";name:"新建";enabled: false
            onTriggered: {newFile.saveAs=false;newFile.show();}},
        Action{iconName:"awesome/folder_open_o";name:"打开";enabled: false
            onTriggered: open.show();},
        Action{iconName:"awesome/save";name:"保存";enabled: tablePageNumber<4
            onTriggered: {if(tablePageNumber===0)
                    saveGrooveName("");
                else if(tablePageNumber===1)
                    saveLimitedName("");
                else if(tablePageNumber===2)
                    saveWeldName("");
                else if(tablePageNumber===3)
                    saveAccountName("");
                else
                    message.open("该表格不符合应该保存的表格名称！")
            }},
        Action{iconName:"awesome/credit_card";name:"另存为";enabled: false
            onTriggered: {newFile.saveAs=true;newFile.show();}},
        Action{iconName:"awesome/trash_o";name:"删除";enabled: currentNameList.replace("列表","")===currentName?false:true
            onTriggered: remove.show();}
    ]
    signal updateGrooveTable(string str,var data);
    signal updateLimitedTable(string str,var data);
    signal updateWeldTable(string str,var data);
    signal updateAccountTable(string str,var data);
    signal updateErrorHistroyTable(string str,var data);
    onUpdateModel: {
        switch(modelName){
        case "grooveModel":updateGrooveTable(cmd,data);
            break;
        case "limitedModel":updateLimitedTable(cmd,data);
            break;
        case "weldModel":updateWeldTable(cmd,data);
            break;
        case "accountModel":updateAccountTable(cmd,data);
            break;
        case "errorHistory":updateErrorHistroyTable(cmd,data);
            break;
        default:break;
        }
    }
    property list<Action> editMenu:[
        Action{id:addOn
            iconName:"awesome/calendar_plus_o";name:"添加";
            onTriggered:{
                if(tablePageNumber===3){
                    account.title=name+toolName ;
                    account.show();
                }else if(tablePageNumber===2){
                    weld.title=name+toolName ;
                    weld.show();
                }else if(tablePageNumber===1){
                    limited.title=name+toolName ;
                    limited.show();
                }else if(tablePageNumber===0){
                    groove.title=name+toolName ;
                    groove.show();
                }}},
        Action{id:edit
            iconName:"awesome/edit";name:"编辑";
            onTriggered:{
                if((currentRow>=0)){
                    if(tablePageNumber===3){
                        account.title=name+toolName ;
                        account.show();
                    }else if(tablePageNumber===2){
                        weld.title=name+toolName ;
                        weld.show();
                    }else if(tablePageNumber===1){
                        limited.title=name+toolName ;
                        limited.show();
                    }else if(tablePageNumber===0){
                        groove.title=name+toolName ;
                        groove.show();
                    }
                }else
                    message.open("请选择要编辑的行！")
            }},
        Action{id:copy
            iconName:"awesome/paste";name:"复制";
            onTriggered: {
                if(currentRow>=0){
                    pasteModel=model.get(currentRow)
                    paste.enabled=true;
                    message.open("已复制。");}
                else{
                    message.open("请选择要复制的行！")
                }
            }},
        Action{id:paste;
            iconName:"awesome/copy";name:"粘帖";
            onTriggered: {
                if(currentRow>=0){
                    paste.enabled=false;
                    updateModel(modelName,"Set",currentRow, {"ID":model.get(currentRow).ID,"C1":pasteModel.C1,
                                    "C2":pasteModel.C2,"C3":pasteModel.C3,"C4":pasteModel.C4,"C5":pasteModel.C5,"C6":pasteModel.C6,"C7":pasteModel.C7,
                                "C8":pasteModel.C8,"C9":pasteModel.C9,"C10":pasteModel.C10,"C11":pasteModel.C11});
                    pasteModel=null
                    message.open("已粘帖。");}
                else
                    message.open("请选择要粘帖的行！")
            }
        },
        Action{id:removeOne;
            iconName: "awesome/calendar_times_o";name:"移除";
            onTriggered: {
                if(currentRow>=0){
                    updateModel(modelName,"Remove",currentRow,{})
                    message.open("已移除。");}
                else
                    message.open("请选择要移除的行！")}
        },
        Action{id:removeAll
            iconName:"awesome/calendar_o";name:"清空";enabled: model.count>0
            onTriggered: {
                updateModel(modelName,"Clear",currentRow,{});
                message.open("已清空。");
            }}
    ]
    property list<Action> inforMenu;

    signal fixDialogShow();
    signal makeWeldRules();
    signal setLimited();
    signal sendWeldData();
    signal userUpdate();
    property int teachModel
    property list<Action> funcMenu:[
        Action{id:first;iconName:tablePageNumber===3?"awesome/user":"awesome/send_o";hoverAnimation:true;summary: "F4";visible: tablePageNumber<4
            name:tablePageNumber===0?"生成规范":tablePageNumber===1?"更新算法":
                                                                 tablePageNumber===2?"下发规范": tablePageNumber===3?"登录用户":"";
            onTriggered:{
                switch(tablePageNumber){
                case 0:makeWeldRules();break;
                case 1:setLimited();break;
                case 2:sendWeldData();break;
                case 3:userUpdate();break;
                }
            }
        },
        Action{id:second;iconName: "awesome/server";name:"条件补正"; onTriggered:fixDialogShow()
        }
    ]
    MenuDropdown{id:fileDropdown;actions:fileMenu;place:0}
    MenuDropdown{id:editDropdown;actions:editMenu;place:1}
    MenuDropdown{id:inforDropdown;actions:inforMenu;place:2}
    MenuDropdown{id:funcDropdown;actions:funcMenu;place:3}

    property list<Action>  actions: [
        Action{iconName:"awesome/file_text_o";name:"文件";hoverAnimation:true;summary: "F1"
            onTriggered: {
                //source为triggered的传递参数
                //更新List
                currentName=tablePageNumber===0?toolGrooveName:tablePageNumber===1?toolLimitedName:
                                                                                    tablePageNumber===2?toolWeldName: tablePageNumber===3?toolAccountName:"" ;
                fileDropdown.open(source,0,source.height+3);
            }
        },
        Action{iconName:"awesome/edit"; name:"修改";hoverAnimation:true;summary: "F2";
            onTriggered:{
                //当前行
                currentRow=tablePageNumber===0?toolGrooveIndex:tablePageNumber===1?toolLimitedIndex:
                                                                                    tablePageNumber===2?toolWeldIndex: tablePageNumber===3?toolAccountIndex:0 ;
                model=tablePageNumber===0?toolGrooveModel:tablePageNumber===1?toolLimitedModel:
                                                                               tablePageNumber===2?toolWeldModel:toolAccountModel;
                if(tablePageNumber===4){
                    addOn.enabled=edit.enabled=copy.enabled=removeOne.enabled=false;
                    removeAll.enabled=true;
                }else if(tablePageNumber===3){
                    addOn.enabled=true;
                    edit.enabled=copy.enabled=removeOne.enabled=currentRow!==-1;
                    removeAll.enabled=false;
                }else if(tablePageNumber===2){
                    addOn.enabled=true;
                    removeOne.enabled=removeAll.enabled=edit.enabled=copy.enabled=currentRow!==-1;
                }else if(tablePageNumber===1){
                    addOn.enabled=true;
                    removeOne.enabled=edit.enabled=copy.enabled=currentRow!==-1;
                    removeAll.enabled=false;
                }else if(tablePageNumber===0){
                    addOn.enabled=true;
                    removeOne.enabled=removeAll.enabled=edit.enabled=copy.enabled=currentRow!==-1;
                }
                editDropdown.open(source,0,source.height+3);
            }
        },
        Action{iconName:"awesome/sticky_note_o";name:"信息";hoverAnimation:true;summary: "F3"
            onTriggered:{
                inforDropdown.open(source,0,source.height+3);
            }
        },
        Action{iconName:"awesome/stack_overflow";  name:"工具";hoverAnimation:true;summary: "F4"
            onTriggered:{
                switch(tablePageNumber){
                case 0:first.name="生成规范";first.iconName="awesome/send_o";first.visible=true;
                    second.visible=true;second.enabled=(teachModel===1)&&(visible);break;
                case 1:first.name="更新算法";first.iconName="awesome/send_o";first.visible=true;second.visible=false;break;
                case 2:first.name="下发规范";first.iconName="awesome/send_o";first.visible=true;second.visible=false;break;
                case 3:first.name="登录用户";first.iconName="awesome/user";first.visible=true;second.visible=false;break;
                case 4:first.visible=false;second.visible=false;break;
                }
                funcDropdown.open(source,0,source.height+3);
            }
        }
    ]
    ActionButton{
        id:robot
        iconName: "action/android"
        anchors.right: message.left
        anchors.rightMargin:Units.dp(24)
        anchors.verticalCenter: message.verticalCenter
        isMiniSize: true
        onPressedChanged: {
            if(pressed){
                openMotoDialog();
            }
        }
    }
    /*危险报警action*/
    ActionButton{
        id:error
        iconName: errorCode||errorCode1?"alert/warning":status==="空闲态"?"awesome/play":
                                                                        status==="坡口检测态"?"awesome/flash":
                                                                                          status==="焊接态"?"user/MAG":
                                                                                                          status==="坡口检测完成态"?"awesome/step_forward":
                                                                                                                              status==="停止态"?"awesome/stop": "awesome/pause"
        anchors.right: robot.visible? robot.left:message.left
        anchors.rightMargin: Units.dp(16)
        anchors.verticalCenter: message.verticalCenter
        isMiniSize: true
        onPressedChanged: {
            if(pressed){
                openMyErrorDialog();
            }
        }
    }

    property int pageWidth
    property int pageHeight

    Snackbar{
        id:snackbar
        anchors {
            left:parent.left;
            leftMargin: opened ? pageWidth - width : pageWidth
            right:undefined
            bottom:undefined
            bottomMargin: undefined
            top:parent.top
            topMargin:root.height-pageHeight-snackbar.height/2
            horizontalCenter:undefined
            Behavior on leftMargin {
                NumberAnimation {duration: 300}
            }
        }
        property string status: "open"
        fullWidth:false
        duration:3000;
    }
    Row{
        visible: tablePageNumber<5
        anchors{right:parent.right;rightMargin:Units.dp(24);top:message.bottom;topMargin: Units.dp(5)}
        spacing: Units.dp(4);
        Repeater{
            id:repeater
            model:actions.length
            delegate:View{
                id:view
                width: row.width+Units.dp(8)
                enabled: actions[index].enabled
                opacity: enabled ? 1 : 0.6
                height:Units.dp(36)
                radius: 4
                Ink{id:ink
                    anchors.fill: parent
                    onPressed: actions[index].triggered(view);
                    enabled: actions[index].enabled
                    circular: true
                    centered: true
                }
                Row{
                    id:row
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Units.dp(4);
                    Icon{
                        id:icon
                        source:actions[index].iconSource
                        size: Units.dp(27)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label{
                        style: "button"
                        text:actions[index].name;
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
    signal saveGrooveName(string name);
    signal saveLimitedName(string name);
    signal saveWeldName(string name);
    signal saveAccountName(string name);

    signal newGrooveFile(string name,bool saveAs);
    signal newLimitedFile(string name,bool saveAs);
    signal newWeldFile(string name,bool saveAs);

    property string currentNameList
    property string currentName
    property var currentNameListModel
    //
    Dialog{
        id:newFile
        negativeButtonText:"取消"
        positiveButtonText:"确定"
        property var nameList: [""]
        property bool saveAs: false
        onOpened:{
            newFileTextField.text=currentName.replace(toolName,"");
            if(saveAs){
                title="另存"+toolName;
                newFileTextField.helperText=toolName+"名称已存在！"
                hasError=true;newFile.positiveButtonEnabled=false;
            }else{
                title="新建"+toolName;
                newFileTextField.helperText="请输入新的"+toolName
            }
            nameList.length=0;
            for(var i=0;i<currentNameListModel.count;i++){
                nameList.push(currentNameListModel.get(i).Name.replace(toolName,""));
            }
        }
        dialogContent:[
            Item{
                width: Units.dp(300)
                height:newFileTextField.actualHeight
                TextField{
                    id:newFileTextField
                    helperText: "请输入新的"+toolName
                    width: Units.dp(300)
                    anchors.horizontalCenter: parent.horizontalCenter
                    onTextChanged: {
                        var check=false;
                        //检索数据库
                        for(var i=0;i<newFile.nameList.length;i++){
                            if(newFile.nameList[i]===text){
                                check=true;
                            }
                        }
                        if(check){
                            newFile.positiveButtonEnabled=false;
                            helperText=toolName+"名称已存在！"
                            hasError=true;
                        }else{
                            newFile.positiveButtonEnabled=true;
                            helperText=toolName+"名称有效！"
                            hasError=false
                        }
                        if(!isNaN(Number(text.charAt(0)))){ //开头字母为数字
                            newFile.positiveButtonEnabled=false;
                            helperText=toolName+"名称开头不能数字！"
                            hasError=true;
                        }
                    }
                }
            }]
        onAccepted: {
            if(positiveButtonEnabled){
                switch(tablePageNumber){
                case 0: newGrooveFile(newFileTextField.text,saveAs);break;
                case 1: newLimitedFile(newFileTextField.text,saveAs);break;
                case 2: newWeldFile(newFileTextField.text,saveAs);break;
                }
            }
            newFileTextField.text=""
        }
        onRejected: newFileTextField.text=""
    }
    signal openGrooveName(string name)
    signal openLimitedName(string name)
    signal openWeldName(string name)
    Dialog{
        id:open
        title:"打开"+toolName
        negativeButtonText:"取消"
        positiveButtonText:"确定"
        property string name;
        property var nameList: [""]
        onOpened:{//打开对话框加载model
            nameList.length=0;
            for(var i=0;i<currentNameListModel.count;i++){
                nameList.push(currentNameListModel.get(i).Name.replace(toolName,""));
            }
            menuField.model=nameList
            name=currentNameListModel.get(0).Name;
            menuField.helperText="创建时间:"+currentNameListModel.get(0).CreatTime+
                    "\n创建者:"+currentNameListModel.get(0).Creator+
                    "\n修改时间:"+currentNameListModel.get(0).EditTime+
                    "\n修改者:"+currentNameListModel.get(0).Editor;
        }
        dialogContent: MenuField{id:menuField
            width:Units.dp(300)
            onItemSelected: {
                open.name=currentNameListModel.get(index).Name.replace(toolName,"");
                menuField.helperText="创建时间:"+currentNameListModel.get(index).CreatTime+
                        "\n创建者:"+currentNameListModel.get(index).Creator+
                        "\n修改时间:"+currentNameListModel.get(index).EditTime+
                        "\n修改者:"+currentNameListModel.get(index).Editor;
            }
        }
        onAccepted: {
            if(typeof(open.name)==="string"){
                switch(tablePageNumber){
                case 0: openGrooveName(open.name);break;
                case 1: openLimitedName(open.name);break;
                case 2: openWeldName(open.name);break;
                }
            }
        }
    }
    signal removeGrooveName(string name)
    signal removeLimitedName(string name)
    signal removeWeldName(string name)
    Dialog{
        id:remove
        title: "删除"+toolName
        negativeButtonText:"取消"
        positiveButtonText:"确定"
        dialogContent:
            Item{
            width: Units.dp(300)
            height:Units.dp(48)
            Label{
                text:"确认删除\n"+currentName+"！"
                style: "menu"
            }
        }
        onAccepted: {
            if(positiveButtonEnabled){
                switch(tablePageNumber){
                case 0:  removeGrooveName(currentName);break;
                case 1:  removeLimitedName(currentName);break;
                case 2:  removeWeldName(currentName);break;
                }
            }
        }
    }

    ListModel{id:grooveRules
        ListElement{name:"          No.       :";value:"";min:0;max:100;isNum:true;step:1}
        ListElement{name:"板    厚δ(mm):";value:"";min:0;max:100;isNum:true;step:0.1}
        ListElement{name:"板厚差e(mm):";value:"";min:0;max:100;isNum:true;step:0.1}
        ListElement{name:"间    隙b(mm):";value:"";min:0;max:100;isNum:true;step:0.1}
        ListElement{name:"角  度β1(deg):";value:"";min:-180;max:180;isNum:true;step:0.1}
        ListElement{name:"角  度β2(deg):";value:"";min:-180;max:180;isNum:true;step:0.1}
    }

    onCurrentGrooveChanged: {
        grooveRules.setProperty(1,"name",currentGroove===8?"脚   长ι1(mm):":"板    厚δ(mm):")
        grooveRules.setProperty(2,"name",currentGroove===8||currentGroove==0||currentGroove==3||currentGroove==5?"脚   长ι2(mm):":"板厚差e(mm):")
        if(currentGroove===8){
            grooveRules.remove(3);
        }else {
            if(grooveRules.count<6){
                grooveRules.insert(3,{"name":"间    隙b(mm):","value":" ","min":0,"max":100,"isNum":true,"step":0.1})
            }
        }
    }

    ListModel{
        id:limitedRules
        ListElement{name:"坡口侧          电流       (A):";value:"";min:10;max:350;isNum:true;step:1}
        ListElement{name:"中间              电流       (A):";value:"";min:10;max:350;isNum:true;step:1}
        ListElement{name:"非坡口侧      电流       (A):";value:"";min:10;max:350;isNum:true;step:1}
        ListElement{name:"坡口侧      停留时间    (s):";value:"";min:0;max:5;isNum:true;step:0.01}
        ListElement{name:"非坡口侧  停留时间    (s):";value:"";min:0;max:5;isNum:true;step:0.01}
        ListElement{name:"层      高      Min     (mm):";value:"";min:1;max:10;isNum:true;step:0.1}
        ListElement{name:"层      高      Max    (mm):";value:"";min:1;max:10;isNum:true;step:0.1}
        ListElement{name:"坡口侧    接近距离(mm):";value:"";min:-50;max:50;isNum:true;step:0.1}
        ListElement{name:"非坡口侧接近距离(mm):";value:"";min:-50;max:50;isNum:true;step:0.1}
        ListElement{name:"摆  动  宽  度  Max (mm):";value:"";min:1;max:100;isNum:true;step:0.1}
        ListElement{name:"分    道    间   隔     (mm):";value:"";min:0;max:100;isNum:true;step:0.1}
        ListElement{name:"分    开    结   束  比   (%):";value:"";min:0;max:1;isNum:true;step:0.01}
        ListElement{name:"焊    接    电     压        (V):";value:"";min:0;max:50;isNum:true;step:0.1}
        ListElement{name:"焊接速度Min  (mm/min):";value:"";min:0;max:2000;isNum:true;step:0.1}
        ListElement{name:"焊接速度Max (mm/min):";value:"";min:0;max:2000;isNum:true;step:0.1}
        ListElement{name:"层    填    充   系   数  (%):";value:"";min:0;max:1;isNum:true;step:0.01}
    }
    property bool swingWidthOrWeldWidth: settings.weldStyle===1||settings.weldStyle===3?false:true
    onSwingWidthOrWeldWidthChanged: {
        limitedRules.setProperty(9,"name",swingWidthOrWeldWidth?"摆  动  宽  度  Max (mm)":"焊  道  宽  度  Max (mm)")
    }

    ListModel{
        id:weldRules
        ListElement{name:"        NO.          :";value:"";min:1;max:1000;isNum:true;step:1}
        ListElement{name:"层                号 :";value:"";min:1;max:1000;isNum:true;step:1}
        ListElement{name:"道                号 :";value:"";min:1;max:1000;isNum:true;step:1}
        ListElement{name:"电      流  (A)    :";value:"";min:10;max:350;isNum:true;step:1}
        ListElement{name:"电      压  (V)    :";value:"";min:10;max:50;isNum:true;step:0.1}
        ListElement{name:"摆      幅(mm) :";value:"";min:0;max:1000;isNum:true;step:0.1}
        ListElement{name:"摆速(cm/min) :";value:"";min:50;max:210;isNum:true;step:1}
        ListElement{name:"焊速(cm/min) :";value:"";min:4;max:200;isNum:true;step:0.1}
        ListElement{name:"焊接线X(mm)  :";value:"";min:-100;max:100;isNum:true;step:0.1}
        ListElement{name:"焊接线Y(mm)  :";value:"";min:-10;max:100;isNum:true;step:0.1}
        ListElement{name:"前   停  留   (s) :";value:"";min:0;max:5;isNum:true;step:0.01}
        ListElement{name:"后   停  留   (s) :";value:"";min:0;max:5;isNum:true;step:0.01}
        ListElement{name:"停  止 时 间(s) :";value:"";min:0;max:1000;isNum:true;step:0.1}
        ListElement{name:"起    弧   点   X :";value:"";min:-100;max:100;isNum:true;step:0.1}
        ListElement{name:"起    弧   点   Y :";value:"";min:-10;max:100;isNum:true;step:0.1}
        ListElement{name:"起    弧   点   Z :";value:"";min:-30000;max:30000;isNum:true;step:1}
        ListElement{name:"收    弧   点   X :";value:"";min:-100;max:100;isNum:true;step:0.1}
        ListElement{name:"收    弧   点   Y :";value:"";min:-10;max:100;isNum:true;step:0.1}
        ListElement{name:"收    弧   点   Z :";value:"";min:-30000;max:30000;isNum:true;step:1}
    }
    ListModel{
        id:accountRules
        ListElement{name:"工        号：";value:"";min:1;max:1000;isNum:false;step:1}
        ListElement{name:"用  户  名：";value:"";min:10;max:300;isNum:false;step:1}
        ListElement{name:"密        码：";value:"";min:10;max:300;isNum:false;step:1}
        ListElement{name:"用  户  组：";value:"";min:10;max:300;isNum:false;step:1}
        ListElement{name:"所在班组：";value:"";min:10;max:300;isNum:false;step:1}
        ListElement{name:"备        注：";value:"";min:10;max:300;isNum:false;step:1}
    }
    property string limitedString

    MyDialog{
        id:groove
        sourceComponent:Image{
            id:addImage
            source: "../Pic/坡口参数图.png"
            sourceSize.width: Units.dp(350)
        }
        loaderVisible:true
        onAccepted: {
            updateModel("grooveModel",title==="编辑坡口条件"?"Set":"Append",toolGrooveIndex,
                                                        {"ID":getText(0),"C1":getText(1),"C2":getText(2),
                                                            "C3":currentGroove===8?"0":getText(3),
                                                                                    "C4":currentGroove===8?getText(3):getText(4),"C5":currentGroove===8?getText(4):getText(5),
                                                                                                                                                         "C6":title==="编辑坡口条件"?toolGrooveModel.get(toolGrooveIndex).C6:"0",
                                                                                                                                                                                "C7":title==="编辑坡口条件"?toolGrooveModel.get(toolGrooveIndex).C7:"0",
                                                                                                                                                                                                       "C8":title==="编辑坡口条件"?toolGrooveModel.get(toolGrooveIndex).C8:"0", })

        }
        onOpened: {
            var i,res,obj;
            if(title==="编辑坡口条件"){
                if(toolGrooveIndex>-1){
                    obj=toolGrooveModel.get(toolGrooveIndex);
                    grooveRules.setProperty(0,"value",obj.ID);
                    grooveRules.setProperty(1,"value",obj.C1);
                    grooveRules.setProperty(2,"value",obj.C2);
                    if(currentGroove===8){
                        grooveRules.setProperty(3,"value",obj.C4);
                        grooveRules.setProperty(4,"value",obj.C5);
                    }else{
                        grooveRules.setProperty(3,"value",obj.C3);
                        grooveRules.setProperty(4,"value",obj.C4);
                        grooveRules.setProperty(5,"value",obj.C5);
                    }
                }else{
                    message.open("请选择要编辑的行！")
                    positiveButtonEnabled=false;
                }
            }else if(title==="添加坡口条件"){
                grooveRules.setProperty(0,"value",String(toolGrooveModel.count+1));
                for(i=1;i<grooveRules.count;i++){
                    grooveRules.setProperty(i,"value","0");
                }
            }
            repeaterModel=grooveRules
        }
    }

    MyDialog{
        id:limited
        loaderVisible: false
        onAccepted: {
            var str=toolLimitedIndex===0?"陶瓷衬垫":toolLimitedIndex===1?"打底层":toolLimitedIndex===2?"第二层":toolLimitedIndex===3?"填充层":toolLimitedIndex===4?"盖面层":"立板余高层"
            var count=toolLimitedModel.count;
            var str1=count===0?"陶瓷衬垫":count===1?"打底层":count===2?"第二层":count===3?"填充层":count===4?"盖面层":"立板余高层"
            updateModel("limitedModel",title==="编辑限制条件"?"Set":"Append",toolLimitedIndex,{"ID":title==="编辑限制条件"?str:str1,"C1":getText(0)+"/"+getText(1)+"/"+getText(2),
                                                                                                               "C2":getText(3)+"/"+getText(4), "C3":getText(5)+"/"+getText(6),"C4":getText(7)+"/"+getText(8),"C5":getText(9),
                                                                                                               "C6":getText(10), "C7":getText(11),"C8":getText(12),"C9":getText(13)+"/"+getText(14),"C10":getText(15),
                                                                                                               "C11":limitedString==="_实芯碳钢_脉冲无_CO2_12"?"4":limitedString==="_药芯碳钢_脉冲无_CO2_12"?"68":limitedString==="_实芯碳钢_脉冲无_MAG_12"?"260":"388"
                                                         }
                        )
        }
        onOpened: {
            var i,res
            if(title==="编辑限制条件"){
                if(toolLimitedIndex>-1){
                    res=WeldMath.getLimitedMath(toolLimitedModel.get(toolLimitedIndex))
                    for(i=0;i<res.length;i++){
                        limitedRules.setProperty(i,"value",res[i])
                    }
                }else{
                    message.open("请选择要编辑的行！")
                    positiveButtonEnabled=false;
                }
            }else if(title==="添加限制条件"){
                console.log("tool"+toolLimitedModel.count)
                if(toolLimitedModel.count<5){
                    res=WeldMath.getLimitedMath(toolLimitedModel.get(toolLimitedIndex))
                    console.log("here")
                    for(i=0;i<res.length;i++){
                        limitedRules.setProperty(i,"value","0")
                    }
                }else
                    console.log("here1")
            }
            repeaterModel=limitedRules
        }
    }

    MyDialog{
        id:weld
        loaderVisible: false
        onAccepted: {
            updateModel("weldModel",title==="编辑焊接规范"?"Set":"Append",toolWeldIndex,
                                                      {"ID":getText(0), "C1":getText(1)+"/"+getText(2),"C2":getText(3),"C3":getText(4),"C4":getText(5),"C5":getText(6),"C6":getText(7),
                                                          "C7":getText(8),"C8":getText(9),"C9":getText(10),"C10":getText(11),"C11":getText(12),
                                                          "C12":title==="编辑焊接规范"?toolWeldModel.get(toolWeldIndex).C12:"0","C13":title==="编辑焊接规范"?toolWeldModel.get(toolWeldIndex).C13:"0",
                                                                                                                                                  "C14":getText(13),"C15":getText(14),"C16":getText(15),"C17":getText(16),"C18":getText(17),"C19":getText(18)})
        }
        onOpened: {
            var i,obj
            if(title==="编辑焊接规范"){
                if(toolWeldIndex>-1){
                    //复制数据到 editData
                    obj=toolWeldModel.get(toolWeldIndex);
                    weldRules.setProperty(0,"value",obj.ID);
                    var temp=obj.C1;
                    if(temp!==""){
                        temp=temp.split("/")
                        weldRules.setProperty(1,"value",temp[0])
                        weldRules.setProperty(2,"value",temp[1]);
                    }else{
                        weldRules.setProperty(1,"value","0")
                        weldRules.setProperty(2,"value","0");
                    }
                    weldRules.setProperty(3,"value",obj.C2);
                    weldRules.setProperty(4,"value",obj.C3);
                    weldRules.setProperty(5,"value",obj.C4);
                    weldRules.setProperty(6,"value",obj.C5);
                    weldRules.setProperty(7,"value",obj.C6);
                    weldRules.setProperty(8,"value",obj.C7);
                    weldRules.setProperty(9,"value",obj.C8);
                    weldRules.setProperty(10,"value",obj.C9);
                    weldRules.setProperty(11,"value",obj.C10);
                    weldRules.setProperty(12,"value",obj.C11);
                    weldRules.setProperty(13,"value",obj.C14);
                    weldRules.setProperty(14,"value",obj.C15);
                    weldRules.setProperty(15,"value",obj.C16);
                    weldRules.setProperty(16,"value",obj.C17);
                    weldRules.setProperty(17,"value",obj.C18);
                    weldRules.setProperty(18,"value",obj.C19);
                }else{
                    message.open("请选择要编辑的行！")
                }
            }else if(title==="添加焊接规范"){
                weldRules.setProperty(0,"value",String(toolWeldModel.count+1));
                for( i=1;i<weldRules.count;i++){
                    weldRules.setProperty(i,"value","0")
                }
            }
            repeaterModel=weldRules
        }
    }

    MyDialog{
        id:account
        loaderVisible: false
        onAccepted: {
            updateModel("accountModel",title==="编辑用户信息"?"Set":"Append",toolAccountIndex,
                                                         {"ID":title==="编辑用户信息"?toolAccountModel.get(toolAccountIndex).ID:String(toolAccountModel.count+1),"C1":getText(0),"C2":getText(1),"C3":getText(2),"C4":getText(3),"C5":getText(4),"C6":getText(5)});
        }
        onOpened: {
            var i,res,obj;
            if(title==="编辑用户信息"){
                if(toolAccountIndex>-1){
                    obj=toolAccountModel.get(toolAccountIndex);
                    accountRules.setProperty(0,"value",obj.C1);
                    accountRules.setProperty(1,"value",obj.C2);
                    accountRules.setProperty(2,"value",obj.C3);
                    accountRules.setProperty(3,"value",obj.C4);
                    accountRules.setProperty(4,"value",obj.C5);
                    accountRules.setProperty(5,"value",obj.C6);
                }
                else{
                    message.open("请选择要编辑的行！")
                    positiveButtonEnabled=false;
                }
            }else if(title==="添加用户信息"){
                for( i=0;i<accountRules.count;i++){
                    accountRules.setProperty(i,"value","0")
                }
            }
            repeaterModel=accountRules;
        }
    }
    function keyFunction(num){
        switch(num){
        case 0:
            if(tablePageNumber<5){
                if(fileDropdown.showing){
                    fileDropdown.close();
                }else{
                    actions[0].triggered(repeater.itemAt(0));
                }
            }
            break;
        case 1:
            if(tablePageNumber<5){
                if(editDropdown.showing)
                    editDropdown.close();
                else{
                    actions[1].triggered(repeater.itemAt(1));
                }
            }
            break;
        case 2:
            if(tablePageNumber<5){
                if(inforDropdown.showing)
                    inforDropdown.close();
                else{
                    actions[2].triggered(repeater.itemAt(2));
                }}
            break;
        case 3:if(tablePageNumber<5){
                if(funcDropdown.showing)
                    funcDropdown.close();
                else{
                    actions[3].triggered(repeater.itemAt(3));
                }}
            break;
        case 4:
            toggleMyErrorDialog();
            break;
        case 5:
            toggleMotoDialog();
            break;
        }
    }

}
