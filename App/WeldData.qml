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
    property string status:"空闲态"

    //上次焊接规范名称
    property string weldRulesName;
 //   property bool weldTableEx
    property string weldRulesNameList

    property string currentUserName
    //外部更新数据
    signal changeWeldData();

    property bool saveAs:false

    Connections{
        target: MySQL
        onWeldTableListChanged:{
            updateListModel("Clear",{});
            for(var i=0;i<jsonObject.length;i++){
                updateListModel("Append",jsonObject[i]);
            }
            weldRulesName=jsonObject[0].Name;
            MySQL.getJsonTable(weldRulesName);
        }
        onWeldTableChanged:{//更新数据表
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

    function openName(name){
        weldRulesName=name+"焊接规范";
        //打开最新的数据库
        MySQL.getJsonTable(weldRulesName);
    }
    function removeName(name){
        //搜寻最近列表 删除本次列表 更新 最近列表如model
        message.open("正在删除焊接规范表格！");
        //删除坡口条件表格
        MySQL.deleteTable(weldRulesName)
        //删除在坡口条件列表链接
        MySQL.clearTable(weldRulesNameList,"Name",weldRulesName)
        //选择最新的表格替换
        getLastweldRulesName();
        //提示
        message.open("已删除焊接规范表格！")
    }
    function newFile(name,saveAs){
        //更新标题
        if((name!==weldRulesName)&&(typeof(name)==="string")){
            var user=currentUserName;
            var Time=MyMath.getSysTime();
            message.open("正在创建焊接规范数据库！")
            weldRulesName=name+"限制条件";
            //插入新的list
            MySQL.insertTableByJson(limitedRulesNameList,{"Name":weldRulesName,"CreatTime":Time,"Creator":user,"EditTime":Time,"Editor":user});
            updateListModel("Append",{"Name":weldRulesName,"CreatTime":Time,"Creator":user,"EditTime":Time,"Editor":user});
            //创建新的 坡口条件
            MySQL.createTable(weldRulesName,"ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT,C10 TEXT,C11 TEXT,C12 TEXT,C13 TEXT,C14 TEXT,C15 TEXT,C16 TEXT,C17 TEXT,C18 TEXT,C19 TEXT");
            if(saveAs){
                save();
            }else
                MySQL.getJsonTable(weldRulesName);
            message.open("已创建焊接规范数据库！")
        }
    }

    //当前页面关闭 则 关闭当前页面内 对话框
    onStatusChanged: {
        if(status==="坡口检测完成态"){
            currentRow=0;
            selectIndex(0);
        }
    }

    footerText:"系统当前处于"+status.replace("态","状态。")
    tableRowCount:7
    headerTitle: weldRulesName
    table.__listView.interactive: status!=="焊接态"
    tableData:[
        Controls.TableViewColumn{role: "C1";title:"   焊接\n层道数";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C2";title: "电流\n  A";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C3";title: "电压\n  V";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C4";title: " 摆幅\n  mm";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C5";title: "   摆速   \ncm/min";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C6";title: "焊接速度\n cm/min";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C7";title: "焊接线\n X mm";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C8";title: "焊接线\n Y mm";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C9";title: "前停留\n     s";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter; },
        Controls.TableViewColumn{role: "C10";title: "后停留\n     s";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C11";title: "停止\n时间";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C12";title: "层面积";width:Units.dp(70);movable:false;resizable:false;visible: false},
        Controls.TableViewColumn{role: "C13";title: "道面积";width:Units.dp(70);movable:false;resizable:false;visible: false},
        Controls.TableViewColumn{role: "C14";title: "起弧x";width:Units.dp(70);movable:false;resizable:false;},
        Controls.TableViewColumn{role: "C15";title: "起弧y";width:Units.dp(70);movable:false;resizable:false;},
        Controls.TableViewColumn{role: "C16";title: "起弧z";width:Units.dp(70);movable:false;resizable:false;},
        Controls.TableViewColumn{role: "C17";title: "收弧x";width:Units.dp(70);movable:false;resizable:false;},
        Controls.TableViewColumn{role: "C18";title: "收弧y";width:Units.dp(70);movable:false;resizable:false;},
        Controls.TableViewColumn{role: "C19";title: "收弧z";width:Units.dp(70);movable:false;resizable:false;}
    ]

}
