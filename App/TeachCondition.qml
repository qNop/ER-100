import QtQuick 2.4
import Material 0.1 as Material
import Material.Extras 0.1 as JS
//import WeldSys.ERModbus 1.0
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.3 as QuickControls
import QtQuick.Window 2.2
import WeldSys.MySQL 1.0
import WeldSys.WeldControl 1.0

MyConditionView{
    id:root
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "TeachCondition"
    condition: new Array(listName.length)
    titleName: qsTr("示教条件");
    property var teachmodemodel: ["全自动","半自动","手动"];
    property var teachmodeEnable: [true,true,true]
    property var startendcheckmodel:["自动","手动"];
    property var startendcheckEnable: [true,true]
    property var teachfisrtpointmodel: ["左方","右方"];
    property var teachfisrtpointEnable: [true,true]

    listValueName:[teachmodemodel,startendcheckmodel,teachfisrtpointmodel]
    listValueNameEnable: [teachmodeEnable,startendcheckEnable,teachfisrtpointEnable]
    listName: [qsTr("示教模式"),qsTr("始终端检测"),qsTr("示教第一点位置"),qsTr("示教点数"),qsTr("焊接长度"),
        qsTr("坡口检测点左"),qsTr("坡口检测点右")]
    listDescription:[
        "选择全自动、半自动、或手动模式。",
        "设定焊接起始、终端的检测是自动或是手动。",
        "设定第一点从左右哪边开始。",
        "设定示教点数（1~30点任意）。",
        "示教点数为1点时,设定至第二点的焊接距离。",
        "设定左端部的延长、缩短量。",
        "设定右端部的延长、缩短量。"
    ]
    valueType: ["点","mm","mm","mm"]

    signal changeTeachModel(int model) //改变示教模式
    signal changeTeachPoint(int num) //改变示教点数
    signal changeWeldLength(double num)//改变焊接长度
    signal changeFirstPointLeftOrRight(bool num)//改变示教点位置

    onChangeGroup: {
        switch(selectedIndex){
        case 0:
            changeGroupCurrent(index,flag);
            if(index===2){//手动
                changeEnable(1,0,false)//始终端 手动
                changeEnable(1,1,true);
                changeEnable(5,0,false);// 坡口检测点左有效
                changeEnable(6,0,false);
                if(root.condition[1]===0){
                    selectedIndex=1;
                    changeGroupCurrent(1,false);
                    selectedIndex=0;
                    message.open("示教模式为手动时，始终端检测切换为手动。")
                }
            }else if(index===1){
                changeEnable(1,0,true);
                changeEnable(1,1,false)//始终端 手动
                changeEnable(5,0,false);// 坡口检测点左有效
                changeEnable(6,0,false);
                if(root.condition[1]===1){
                    selectedIndex=1;
                    changeGroupCurrent(0,false);
                    selectedIndex=0;
                    message.open("示教模式为半自动时，始终端检测切换为自动。")
                }
            }else{
                changeEnable(1,0,true);
                changeEnable(1,1,true);//始终端 自动
                changeEnable(5,0,true);// 坡口检测点左有效
                changeEnable(6,0,true);
            }
            break;
        default :
            changeGroupCurrent(index,flag);break;
        }
    }
    onWork: {
        var num=Number(root.condition[index]);
        if(isNaN(num)){
            num=0;
        }
        switch(index){
            //示教模式
        case 0:WeldControl.setTeachMode(num);changeTeachModel(num);break;
            //焊接始终端检测
        case 1:WeldControl.setWeldStartStop(num);break;
            // 示教第一点位置
        case 2:WeldControl.setTeachFirstPoint(num);changeFirstPointLeftOrRight(num);break;
            //示教点数
        case 3:WeldControl.setTeachPointNum(num);changeTeachPoint(num);break;
            //焊接长度
        case 4:WeldControl.setWeldLength(num);changeWeldLength(num);break;
            //坡口检测点左
        case 5:WeldControl.setGrooveCheckLeftLength(num);break;
            //坡口检测点右
        case 6:WeldControl.setGrooveCheckRightLength(num);break;
            //
        default:break;
        }
        if(flag){
            //存储数据
            MySQL.setValue(root.objectName,"id",index.toString(),"value",num.toString());
        }
    }
    onKeyDec:{
        var num=Number(root.condition[selectedIndex]);
        if(isNaN(num)) num=0;
        switch(index){
            //示教点数
        case 0:num-=1; if(num<0)num=0;break;
            //焊接长度
        case 1:if(flag)num-=10;else num-=1; if(num<0)num=0;break;
            //检测点左
        case 2:if(flag)num-=10;else num-=1; if(num<-1000)num=-1000;break;
            //检测点右
        case 3:if(flag)num-=10;else num-=1;if(num<-1000)num=-1000;break;
        }
        if(index>=0){
            //变更显示但是不变更数据
            changeText(num,true);
        }
    }
    onKeyInc:{
        var num=Number(root.condition[selectedIndex]);
        if(isNaN(num)) num=0;
        switch(index){
            //示教点数
        case 0:num+=1; if(num>30)num=30;break;
            //焊接长度
        case 1:if(flag)num+=10;else num+=1; if(num>10000)num=10000;break;
            //检测点左
        case 2:if(flag)num+=10;else num+=1; if(num>1000)num=1000;break;
            //检测点右
        case 3:if(flag)num+=10;else num+=1; if(num>1000)num=1000;break;
        }
        if(index>=0){
            //变更显示但是不变更数据
            changeText(num,true);
        }
    }
    Connections{
        target: MySQL
        onTeachConditionChanged:{
            condition.length=0;
            for(var i=0;i<jsonObject.length;i++){
                condition.push(Number(jsonObject[i].value));
            }
            update();
            //下发数据
            for( i=0;i<listName.length;i++){
                work(i,false);
            }
            if(root.condition[0]===2)
                changeEnable(1,0,false);
        }
    }
    Connections{
        target: WeldControl
        onUpdateTeachSet:{
            if(jsonObject.StartStop!==condition[1]){
                root.selectedIndex=1;
                root.changeGroupCurrent(jsonObject.StartStop,true);
                MySQL.setValue(root.objectName,"id","1","value",String(jsonObject.StartStop));
                message.open(root.listName[1]+"设置为"+root.listValueName[1][Number(jsonObject.StartStop)]+"。")
            }else if(jsonObject.FirstPointLeftOrRight!==condition[2]){
                root.selectedIndex=2;
                root.changeGroupCurrent(jsonObject.FirstPointLeftOrRight,true);
                MySQL.setValue(root.objectName,"id","2","value",String(jsonObject.FirstPointLeftOrRight));
                root.changeFirstPointLeftOrRight(jsonObject.FirstPointLeftOrRight)
                message.open(root.listName[2]+"设置为"+root.listValueName[2][Number(jsonObject.FirstPointLeftOrRight)]+"。")
            }else if(jsonObject.TeachPoint!==condition[3]){
                root.selectedIndex=3;
                root.changeText(jsonObject.TeachPoint,true);
                MySQL.setValue(root.objectName,"id","3","value",String(jsonObject.TeachPoint));
                root.changeTeachPoint(jsonObject.TeachPoint)
                message.open(root.listName[3]+"设置为"+String(jsonObject.TeachPoint)+"点。")
            }else if(jsonObject.WeldLength!==condition[4]){
                root.selectedIndex=4;
                root.changeText(jsonObject.WeldLength,true);
                MySQL.setValue(root.objectName,"id","4","value",String(jsonObject.WeldLength));
                root.changeWeldLength(jsonObject.WeldLength)
                message.open(root.listName[4]+"设置为"+String(jsonObject.WeldLength)+"mm。")
            }
        }
    }

    Component.onCompleted: {
        MySQL.getJsonTable(objectName);
    }
}
