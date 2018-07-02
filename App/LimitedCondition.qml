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

}
