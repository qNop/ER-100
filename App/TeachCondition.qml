import QtQuick 2.4
import Material 0.1 as Material
import Material.Extras 0.1 as JS
import WeldSys.MySQL 1.0
import WeldSys.WeldMath 1.0
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.1

TestMyConditionView{
    id:root
    objectName:"TeachCondition"
    property int currentGroove
    titleName:"示教条件"
    signal changeTeachModel(int model) //改变示教模式
    signal changeTeachPoint(int num) //改变示教点数
    signal changeFirstPointLeftOrRight(bool num)//改变示教点位置
    ListModel{
        id:teachConditonModel
        ListElement{name:"示教模式";
            groupOrText:true;value:"0";valueType:"";min:0;max:2;increment:1;description:"选择全自动、半自动、或手动模式。";rowEnable:true;}
        ListElement{name:"始终端检测";
            groupOrText:true;value:"0";valueType:"";min:0;max:1;increment:1;description:"设定焊接起始、终端的检测是自动或是手动。";rowEnable:true;}
        ListElement{name:"示教第一点位置";
            groupOrText:true;value:"0";valueType:"";min:0;max:1;increment:1;description:"设定第一点从左右哪边开始。";rowEnable:true;}
        ListElement{name:"示教点数";
            groupOrText:false;value:"0";valueType:"点";min:2;max:30;increment:1;description:"设定示教点数（1~30点任意）。";rowEnable:true;}
        ListElement{name:"焊接长度";
            groupOrText:false;value:"0";valueType:"mm";min:0;max:100000;increment:1;description:"示教点数为1点时,设定至第二点的焊接距离。";rowEnable:true;}
        ListElement{name:"坡口检测点左";
            groupOrText:false;value:"0";valueType:"mm";min:-1000;max:1000;increment:1;description:"设定左端部的延长、缩短量。";rowEnable:true;}
        ListElement{name:"坡口检测点右";
            groupOrText:false;value:"0";valueType:"mm";min:-1000;max:1000;increment:1;description:"设定右端部的延长、缩短量。";rowEnable:true;}
    }
    model:teachConditonModel

    property list<ListModel> teachConditionModels:[
        ListModel{ListElement{name:"全自动";enable:true}ListElement{name:"半自动";enable:true}ListElement{name:"手动";enable:true}}
        ,ListModel{ListElement{name:"自动";enable:true}ListElement{name:"手动";enable:true}}
        ,ListModel{ListElement{name:"左方";enable:true}ListElement{name:"右方";enable:true}}
    ]
    groupModel: teachConditionModels
    onUpdateModel: {
        if(selectIndex!==4)
            teachConditonModel.setProperty(selectIndex,"value",value);
        switch(selectIndex){
        case 0:
            teachConditionModels[1].setProperty(0,"enable",value==="2"?false:true);
            teachConditionModels[1].setProperty(1,"enable",value==="2"?true:value==="1"?false:true);
            var mod=teachConditonModel.get(1).value;
            if((mod==="1")&&(value==="1")){
                teachConditonModel.setProperty(1,"value","0")
                changeValue(1)
            }else if((value==="2")&&(mod==="0")){
                teachConditonModel.setProperty(1,"value","1")
                changeValue(1)
            }
            teachConditonModel.setProperty(5,"rowEnable",value==="0"?true:false);
            teachConditonModel.setProperty(6,"rowEnable",value==="0"?true:false);
            break;
        }
    }

    onChangeValue: {
        var num=Number(teachConditonModel.get(index).value);
        switch(index){
            //示教模式
        case 0:
            changeTeachModel(num);
            WeldMath.setPara("teachMode",num ,true,false);
            break;
            //焊接始终端检测
        case 1:
            WeldMath.setPara("startEndCheck",num,true,false);
            break;
            //示教第一点位置
        case 2:
            changeFirstPointLeftOrRight(num);
            WeldMath.setPara("teachFirstPoint",num,true,false);
            break;
            //示教点数
        case 3:
             changeTeachPoint(num);
            WeldMath.setPara("teachPoint",num,true,false);
            break;
            //焊接长度
        case 4:
            WeldMath.setPara("weldLength",num,true,false);
            break;
            //坡口检测点左
        case 5:
            WeldMath.setPara("checkLeft",num,true,false);
            break;
            //坡口检测点右
        case 7:
            WeldMath.setPara("checkRight",num,false,false);
            break;
        }
        //存储数据
        MySQL.setValue(root.objectName,"id",index.toString(),"value",num.toString());
    }

    Connections{
        target: MySQL
        onTeachConditionChanged:{
            for(var i=0;i<7;i++){
                teachConditonModel.setProperty(i,"value",String(jsonObject[i].value));
                var num=Number(jsonObject[i].value);
                switch(i){
                    //示教模式
                case 0:
                    changeTeachModel(num);
                    WeldMath.setPara("teachMode",num ,true,false);
                    break;
                    //焊接始终端检测
                case 1:
                    WeldMath.setPara("startEndCheck",num,true,false);
                    break;
                    // 示教第一点位置
                case 2:
                    changeFirstPointLeftOrRight(num);
                    WeldMath.setPara("teachFirstPoint",num,true,false);
                    break;
                    //示教点数
                case 3:
                    changeTeachPoint(num);
                    WeldMath.setPara("teachPoint",num,true,false);
                    break;
                    //焊接长度
                case 4:
                    //WeldMath.setPara("weldLength",num,true,false);
                    break;
                    //坡口检测点左
                case 5:
                    WeldMath.setPara("checkLeft",num,true,false);
                    break;
                    //坡口检测点右
                case 6:
                    WeldMath.setPara("checkRight",num,false,false);
                    break;
                }
            }
            var value=teachConditonModel.get(0).value;
            teachConditionModels[1].setProperty(0,"enable",value==="2"?false:true);
            teachConditionModels[1].setProperty(1,"enable",value==="2"?true:value==="1"?false:true);
            teachConditonModel.setProperty(5,"rowEnable",value==="0"?true:false);
            teachConditonModel.setProperty(6,"rowEnable",value==="0"?true:false);
        }
    }
    Connections{
        target: WeldMath
        onEr100_UpdateWeldLength:{
            teachConditonModel.setProperty(4,"value",String(value));
            MySQL.setValue(root.objectName,"id",String(4),"value",String(value));
        }
        onEr100_TeachSet:{
            var setValue
            for(var i=2;i<6;i++){
                setValue=Number(value[i]);
                if(setValue!==Number(teachConditonModel.get(i-1).value)){
                    if(i==4){
                        changeTeachPoint(setValue);
                    }
                    teachConditonModel.setProperty(i-1,"value",String(setValue))
                    MySQL.setValue(root.objectName,"id",String(i-1),"value",String(setValue));
                }
            }
        }
    }

    Component.onCompleted: {
        //变更限制条件
        MySQL.getJsonTable(objectName)
    }
}
