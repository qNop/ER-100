import QtQuick 2.0
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.2 as Controls
import QtQuick.Window 2.2
import WeldSys.WeldMath 1.0
import WeldSys.MySQL 1.0
import QtQuick.Layouts 1.1
import "MyMath.js" as MyMath
TableCard {
    id:root
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "LimitedConditon"
    /*ListModel{id:pasteModel;
        ListElement{ID:"";C1:"";C2:"";C3:"";C4:"";C5:"";C6:"";C7:"";C8:"";C9:"";C10:""}
    }*/
    property bool swingWidthOrWeldWidth

    //property Item message

    property string limitedRulesName:""
    property string limitedRulesNameList:""

    property string currentUserName

    property bool addOrEdit: false

    property bool saveAs: false

    property int num: 0

    property string limitedString: ""

    Connections{
        target: MySQL
        onLimitedTableListChanged:{
            //更新列表
            updateListModel("Clear",{});
            for(var i=0;i<jsonObject.length;i++){
                updateListModel("Append",jsonObject[i]);
            }
            limitedRulesName=jsonObject[0].Name;
            MySQL.getJsonTable(limitedRulesName);
        }
        onLimitedTableChanged:{//更新数据表
            updateModel("Clear",{});
            for(var i=0;i<jsonObject.length;i++){
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

    function getLastRulesName(){
        MySQL.getDataOrderByTime(limitedRulesNameList,"EditTime");
    }

    function setLimited(){
        for(var i=0;i<model.count;i++){
            WeldMath.setLimited(model.get(i));
        }
    }

    function save(){
        if(typeof(limitedRulesName)==="string"){
            //清除保存数据库
            MySQL.clearTable(limitedRulesName,"","");
            for(var i=0;i<model.count;i++){
                //插入新的数据
                MySQL.insertTable(limitedRulesName,model.get(i));
            }
            //更新数据库保存时间
            MySQL.setValue(limitedRulesNameList,"Name",limitedRulesName,"EditTime",MyMath.getSysTime());
            MySQL.setValue(limitedRulesNameList,"Name",limitedRulesName,"Editor",currentUserName);
            message.open("限制条件已保存！")
        }else{
            message.open("限制条件格式不是字符串！")
        }
    }function openName(name){
        limitedRulesName=name+"限制条件"+limitedString;
        //打开最新的数据库
        MySQL.getJsonTable(limitedRulesName);
    }
    function removeName(name){
        //搜寻最近列表 删除本次列表 更新 最近列表如model
        message.open("正在删除限制条件表格！");
        //删除坡口条件表格
        MySQL.deleteTable(limitedRulesName)
        //删除在坡口条件列表链接
        MySQL.clearTable(limitedRulesNameList,"Name",limitedRulesName)
        //选择最新的表格替换
        getLastRulesName();
        //提示
        message.open("已删除限制条件表格！")
    }
    function newFile(name,saveAs){
        //更新标题
        if((name!==limitedRulesName)&&(typeof(name)==="string")){
            var user=currentUserName;
            var Time=MyMath.getSysTime();
            message.open("正在创建限制条件数据库！")
            limitedRulesName=name+"限制条件"+limitedString;
            //插入新的list
            MySQL.insertTableByJson(limitedRulesNameList,{"Name":limitedRulesName,"CreatTime":Time,"Creator":user,"EditTime":Time,"Editor":user});
            updateListModel("Append",{"Name":limitedRulesName,"CreatTime":Time,"Creator":user,"EditTime":Time,"Editor":user});
            //创建新的 坡口条件
            MySQL.createTable(limitedRulesName,"ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT,C10 TEXT,C11 TEXT");
            if(saveAs){
                save();
            }else
                MySQL.getJsonTable(limitedRulesName);
            message.open("已创建限制条件数据库！")
        }
    }

    headerTitle: limitedRulesName.replace(limitedString,"");
    firstColumn.title: "限制条件\n      层"
    footerText: limitedString
    tableRowCount:7

    tableData:[
        Controls.TableViewColumn{role: "C1";title:"坡口/中/非坡口\n   焊接电流(A)";width:Units.dp(140);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C2";title: "坡口/非坡口\n停留时间(s)";width:Units.dp(100);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C4";title: "   坡口/非坡口\n接近距离(mm)";width:Units.dp(130);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C3";title: "层高Min/Max\n       (mm)";width:Units.dp(110);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C5";title: swingWidthOrWeldWidth?"摆动宽度Max\n       (mm)":"焊道宽度Max\n       (mm)";width:Units.dp(120);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter; },
        Controls.TableViewColumn{role: "C6";title: "分道间隔\n   (mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C7";title: "分开结束比\n       (%)";width:Units.dp(100);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C8";title: "焊接电压\n     (V)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C10";title:"层填充系数\n       (%)";width:Units.dp(100);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C9";title: "焊接速度Min/Max\n        (cm/min)";width:Units.dp(160);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C11";title:"代码";width:Units.dp(100);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;visible: false}
    ]
    /*
    Dialog{
        id:open
        title:qsTr("打开限制条件")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        property var nameList: [""]
        property string name
        onOpened:{//打开对话框加载model
            nameList.length=0;
            for(var i=0;i<limitedRulesNameListModel.count;i++)
                nameList.push(limitedRulesNameListModel.get(i).Name);
            menuField.model=nameList;
            name=limitedRulesNameListModel.get(0).Name;
            menuField.helperText="创建时间:"+limitedRulesNameListModel.get(0).CreatTime+
                    "\n创建者:"+limitedRulesNameListModel.get(0).Creator+
                    "\n修改时间:"+limitedRulesNameListModel.get(0).EditTime+
                    "\n修改者:"+limitedRulesNameListModel.get(0).Editor;
        }
        dialogContent: MenuField{id:menuField
            width:Units.dp(300)
            onItemSelected: {
                open.name=limitedRulesNameListModel.get(index).Name;
                menuField.helperText="创建时间:"+limitedRulesNameListModel.get(index).CreatTime+
                        "\n创建者:"+limitedRulesNameListModel.get(index).Creator+
                        "\n修改时间:"+limitedRulesNameListModel.get(index).EditTime+
                        "\n修改者:"+limitedRulesNameListModel.get(index).Editor;
            }
        }
        onAccepted: {
            if(typeof(open.name)==="string"){
                limitedRulesName=open.name;
                //打开最新的数据库
                MySQL.getJsonTable(limitedRulesName);
            }
        }
    }
    Dialog{
        id:newFile
        title: saveAs?qsTr("另存限制条件"):qsTr("新建限制条件")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        property var nameList:[""]
        onOpened:{
            if((typeof(limitedRulesNameList)==="string")&&(limitedRulesNameList!=="")){
                //名称存在且格式正确  那么 重新更新 表名称参数 找出最新的表
                nameList.length=0;
                for(var i=0;i<limitedRulesNameListModel.count;i++){
                    nameList.push(limitedRulesNameListModel.get(i).Name.replace("限制条件",""));
                }
            }
            newFileTextField.text=limitedRulesName.replace("限制条件"+limitedString,"")
            newFileTextField.helperText=qsTr("请输入新的限制条件名称！")
        }
        dialogContent:Item{
            width: Units.dp(300)
            height:newFileTextField.actualHeight
            TextField{
                id:newFileTextField
                helperText: "请输入新的限制条件名称！"
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
                        helperText="该限制条件名称已存在！"
                        hasError=true;
                    }else{
                        newFile.positiveButtonEnabled=true;
                        helperText="限制条件名称有效！"
                        hasError=false;
                    }
                    if(!isNaN(Number(text.charAt(0)))){ //开头字母为数字
                        newFile.positiveButtonEnabled=false;
                        helperText="限制条件名称开头不能数字！"
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
                message.open("正在创建限制条件数据库！")
                limitedRulesName=title+"限制条件"+limitedString;
                //插入新的list
                MySQL.insertTableByJson(limitedRulesNameList,{"Name":limitedRulesName,"CreatTime":time,"Creator":user,"EditTime":time,"Editor":user});
                limitedRulesNameListModel.append({"Name":limitedRulesName,"CreatTime":time,"Creator":user,"EditTime":time,"Editor":user});
                //创建新的 坡口条件
                MySQL.createTable(limitedRulesName,"ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT,C10 TEXT,C11 TEXT");
                if(saveAs){
                    save();
                }else
                    MySQL.getJsonTable(limitedRulesName);
                message.open("已创建限制条件数据库！")
            }
            newFileTextField.text="";
        }
        onRejected: newFileTextField.text=""
    }
    Dialog{
        id:remove
        title: qsTr("删除限制条件")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        onOpened:{
            positiveButtonEnabled=limitedRulesNameList.replace("列表","")===limitedRulesName?false:true
        }
        dialogContent: Item{
            width: label.contentWidth
            height:Units.dp(48)
            Label{
                id:label
                text:"确认删除\n"+limitedRulesName+"！"
                style: "menu"
            }
        }
        onAccepted: {
            if(positiveButtonEnabled){
                //搜寻最近列表 删除本次列表 更新 最近列表如model
                message.open(qsTr("正在删除限制条件表格！"));
                //删除坡口条件表格
                MySQL.deleteTable(limitedRulesName)
                //删除在坡口条件列表链接
                MySQL.clearTable(limitedRulesNameList,"Name",limitedRulesName)
                //选择最新的表格替换
                getLastRulesName();
                //提示
                message.open(qsTr("已删除限制条件表格！"))
            }
        }
    }
    MyTextFieldDialog{
        id:edit
        title: addOrEdit?"添加限制条件":"编辑限制条件"
        objectName: "editDialog"
        repeaterModel:nameModel
        message: root.message
        onOpened: {
            var res=limitedMath(currentRow,currentRow+1);
            for(var i=0;i<res.length;i++){
                nameModel.setProperty(i,"value",res[i])
            }
            updateText()
            focusIndex=0;
            changeFocus(focusIndex)
        }
        onAccepted: {
            if(addOrEdit){
                var str=model.count===0?"陶瓷衬垫":model.count===1?"打底层":model.count===2?"第二层":model.count===3?"填充层":model.count===4?"盖面层":"立板余高层"
                model.append(
                            {"ID":str,"C1":getText(0)+"/"+getText(1)+"/"+getText(2),
                                "C2":getText(3)+"/"+getText(4),
                                "C3":getText(5)+"/"+getText(6),
                                "C4":getText(7)+"/"+getText(8),
                                "C5":getText(9),
                                "C6":getText(10),
                                "C7":getText(11),
                                "C8":getText(12),
                                "C9":getText(13)+"/"+getText(14),
                                "C10":getText(15),
                                "C11":limitedString==="_实芯碳钢_脉冲无_CO2_12"?"4":limitedString==="_药芯碳钢_脉冲无_CO2_12"?"68":limitedString==="_实芯碳钢_脉冲无_MAG_12"?"260":"388"
                            });
            }else{
                model.set(currentRow,
                          {"C1":getText(0)+"/"+getText(1)+"/"+getText(2),
                              "C2":getText(3)+"/"+getText(4),
                              "C3":getText(5)+"/"+getText(6),
                              "C4":getText(7)+"/"+getText(8),
                              "C5":getText(9),
                              "C6":getText(10),
                              "C7":getText(11),
                              "C8":getText(12),
                              "C9":getText(13)+"/"+getText(14),
                              "C10":getText(15),
                              "C11":limitedString==="_实芯碳钢_脉冲无_CO2_12"?"4":limitedString==="_药芯碳钢_脉冲无_CO2_12"?"68":limitedString==="_实芯碳钢_脉冲无_MAG_12"?"260":"388",
                          });
            }
        }
    }*/
}
