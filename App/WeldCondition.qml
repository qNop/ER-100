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
    objectName:"WeldCondition"
    property int currentGroove
    signal changeNum(string value)

    ListModel{
        id:weldConditionModel
        ListElement{name:"焊丝伸出长度";
            groupOrText:true;value:"0";valueType:"";min:0;max:3;increment:1;description:"设定焊丝端部到导电嘴的长度。";rowEnable:true;}
        ListElement{name:"头部摇动方式";
            groupOrText:true;value:"0";valueType:"";min:0;max:3;increment:1;description:"设定在焊接的起始、端部头部是否摆动。";rowEnable:true;}
        ListElement{name:"焊丝种类";
            groupOrText:true;value:"0";valueType:"";min:0;max:1;increment:1;description:"设定焊丝种类实芯碳钢或药芯碳钢。";rowEnable:true;}
        ListElement{name:"机头放置侧";
            groupOrText:true;value:"0";valueType:"";min:0;max:1;increment:1;description:"设定机头相对于坡口的放置位置。";rowEnable:true;}
        ListElement{name:"焊丝直径";
            groupOrText:true;value:"0";valueType:"";min:0;max:1;increment:1;description:"设定焊丝的直径。";rowEnable:true;}
        ListElement{name:"保护气体";
            groupOrText:true;value:"0";valueType:"";min:0;max:1;increment:1;description:"设定焊接过程中使用保护气体。";rowEnable:true;}
        ListElement{name:"焊接脉冲状态";
            groupOrText:true;value:"0";valueType:"";min:0;max:1;increment:1;description:"设定电源特性，直流或脉冲。";rowEnable:true;}
        ListElement{name:"焊接往返动作";
            groupOrText:true;value:"0";valueType:"";min:0;max:2;increment:1;description:"设定焊接往返动作方向为往返方向或单向。";rowEnable:true;}
        ListElement{name:"焊枪冷却方式";
            groupOrText:true;value:"0";valueType:"";min:0;max:1;increment:1;description:"设定焊枪的冷却方式为空冷或水冷。";rowEnable:true;}
        ListElement{name:"预期余高";
            groupOrText:false;value:"0";valueType:"mm";min:-3;max:3;increment:0.1;description:"设定焊接预期板面焊道堆起高度。";rowEnable:true;}
        ListElement{name:"溶敷系数";
            groupOrText:false;value:"0";valueType:"%";min:50;max:150;increment:1;description:"设定焊接过程中溶敷系数的大小，以方便推算更合适的焊接规范。";rowEnable:true;}
        ListElement{name:"焊接电流偏置";
            groupOrText:false;value:"0";valueType:"A";min:-100;max:100;increment:1;description:"焊接条件所设定的电流和实际电流的微调整。";rowEnable:true;}
        ListElement{name:"焊接电压偏置";
            groupOrText:false;value:"0";valueType:"V";min:-10;max:10;increment:0.1;description:"焊接条件所设定的电压和实际电压的微调整。";rowEnable:true;}
        ListElement{name:"提前送气时间";
            groupOrText:false;value:"0";valueType:"S";min:0;max:10;increment:0.1;description:"设定焊接提前送气时间。";rowEnable:true;}
        ListElement{name:"滞后送气时间";
            groupOrText:false;value:"0";valueType:"S";min:0;max:10;increment:0.1;description:"设定焊接滞后送气时间。";rowEnable:true;}
        ListElement{name:"起弧停留时间";
            groupOrText:false;value:"0";valueType:"S";min:0;max:10;increment:0.1;description:"设定焊接起弧停留时间。";rowEnable:true;}
        ListElement{name:"收弧停留时间";
            groupOrText:false;value:"0";valueType:"S";min:0;max:10;increment:0.1;description:"设定焊接收弧停留时间。";rowEnable:true;}
        ListElement{name:"起弧电流衰减系数";
            groupOrText:false;value:"0";valueType:"%";min:50;max:150;increment:1;description:"设定焊接起弧电流相对焊接电流的衰减系数。";rowEnable:true;}
        ListElement{name:"起弧电压衰减系数";
            groupOrText:false;value:"0";valueType:"%";min:50;max:150;increment:1;description:"设定焊接起弧电压相对焊接电压的衰减系数。";rowEnable:true;}
        ListElement{name:"收弧电流衰减系数";
            groupOrText:false;value:"0";valueType:"%";min:50;max:150;increment:1;description:"设定焊接收弧电流相对焊接电流的衰减系数。";rowEnable:true;}
        ListElement{name:"收弧电压衰减系数";
            groupOrText:false;value:"0";valueType:"%";min:50;max:150;increment:1;description:"设定焊接收弧电压相对焊接电压的衰减系数。";rowEnable:true;}
        ListElement{name:"层间起弧位置偏移";
            groupOrText:false;value:"0";valueType:"mm";min:-1000;max:1000;increment:1;description:"设定每层之间起弧坐标Z行走轴偏移量,焊接方向为正反之则为负。";rowEnable:true;}
        ListElement{name:"层间收弧位置偏移";
            groupOrText:false;value:"0";valueType:"mm";min:-1000;max:1000;increment:1;description:"设定每层之间收弧坐标Z行走轴偏移量,焊接方向为正反之则为负。";rowEnable:true;}
        ListElement{name:"层内起弧位置偏移";
            groupOrText:false;value:"0";valueType:"mm";min:-1000;max:1000;increment:1;description:"设定层内每层焊道之间起弧坐标Z行走轴偏移量,焊接方向为正反之则为负。";rowEnable:true;}
        ListElement{name:"层内收弧位置偏移";
            groupOrText:false;value:"0";valueType:"mm";min:-1000;max:1000;increment:1;description:"设定层内每层焊道之间收弧坐标Z行走轴偏移量,焊接方向为正反之则为负。";rowEnable:true;}
        ListElement{name:"收弧回退距离";
            groupOrText:false;value:"0";valueType:"mm";min:0;max:100;increment:1;description:"设定焊接收弧回退距离。";rowEnable:true;}
        ListElement{name:"收弧回退速度";
            groupOrText:false;value:"0";valueType:"cm/min";min:0;max:100;increment:0.1;description:"设定焊接收弧回退速度。";rowEnable:true;}
        ListElement{name:"收弧回退停留时间";
            groupOrText:false;value:"0";valueType:"S";min:0;max:10;increment:0.1;description:"设定焊接收弧回退停留时间。";rowEnable:true;}
        ListElement{name:"回烧电压补偿";
            groupOrText:false;value:"0";valueType:"";min:-50;max:50;increment:1;description:"设定回烧时间中的输出电压微调整(和焊丝的上燃量有关)。";rowEnable:true;}
        ListElement{name:"回烧时间补偿1";
            groupOrText:false;value:"0";valueType:"";min:-50;max:50;increment:1;description:"设定回烧时间的微调整(和焊丝的上燃量有关)。";rowEnable:true;}
        ListElement{name:"回烧时间补偿2";
            groupOrText:false;value:"0";valueType:"";min:-50;max:50;increment:1;description:"设定回烧时间的微调整(和焊丝的上燃量有关)。";rowEnable:true;}
        ListElement{name:"钝边";
            groupOrText:false;value:"0";valueType:"mm";min:0;max:10;increment:0.1;description:"设定顿边大小。";rowEnable:true;}
        ListElement{name:"层间停止时间";
            groupOrText:false;value:"0";valueType:"S";min:0;max:3600;increment:1;description:"设定每层之间焊接结束后停止焊接的时间(最长1小时)。";rowEnable:true;}
        ListElement{name:"层内停止时间";
            groupOrText:false;value:"0";valueType:"S";min:0;max:3600;increment:1;description:"设定层内每层焊道之间焊接结束后停止焊接的时间(最长1小时)。";rowEnable:true;}
        ListElement{name:"陶瓷衬垫打底起弧停留时间";
            groupOrText:false;value:"0";valueType:"S";min:0;max:3;increment:1;description:"设定陶瓷衬垫打底起弧两端停留时间。";rowEnable:true;}
        ListElement{name:"陶瓷衬垫打底起弧摆动速度";
            groupOrText:false;value:"0";valueType:"cm/min";min:0;max:200;increment:1;description:"设定陶瓷衬垫打底起弧时摆动速度。";rowEnable:true;}
    }
    model:weldConditionModel
    titleName:"焊接条件"
    property list<ListModel> weldConditionModels:[
        ListModel{ListElement{name:"15mm";enable:true}ListElement{name:"20mm";enable:true}ListElement{name:"25mm";enable:true}ListElement{name:"30mm";enable:true}}
        ,ListModel{ListElement{name:"无";enable:true}ListElement{name:"左方";enable:true}ListElement{name:"右方";enable:true}ListElement{name:"左右";enable:true}}
        ,ListModel{ListElement{name:"实芯碳钢";enable:true}ListElement{name:"药芯碳钢";enable:true}}
        ,ListModel{ListElement{name:"坡口侧";enable:true}ListElement{name:"非坡口侧";enable:true}}
        ,ListModel{ListElement{name:"1.2mm";enable:true}ListElement{name:"1.6mm";enable:true}}
        ,ListModel{ListElement{name:"CO2";enable:true}ListElement{name:"MAG";enable:true}}
        ,ListModel{ListElement{name:"关闭";enable:true}ListElement{name:"打开";enable:true}}
        ,ListModel{ListElement{name:"单向";enable:true}ListElement{name:"道间往返";enable:true}ListElement{name:"层间往返";enable:true}}
        ,ListModel{ListElement{name:"空冷";enable:true}ListElement{name:"水冷";enable:true}}
    ]
    groupModel: weldConditionModels
    onCurrentGrooveChanged: {
        weldConditionModels[3].setProperty(1,"enable",currentGroove===2?false:currentGroove===7?false:true)
        weldConditionModels[8].setProperty(1,"enable",currentGroove===5?false:currentGroove===6?false:currentGroove===7?false:true)
        weldConditionModels[4].setProperty(1,"enable",currentGroove===5?false:currentGroove===6?false:currentGroove===7?false:true)
        if(weldConditionModel.get(3).value==="1"){
            weldConditionModel.setProperty(3,"value","0");
            changeValue(3);
        }
        if(weldConditionModel.get(4).value==="1"){
            weldConditionModel.setProperty(4,"value","0");
            changeValue(4);
        }
        if(weldConditionModel.get(8).value==="1"){
            weldConditionModel.setProperty(8,"value","0");
            changeValue(8);
        }
    }
    onUpdateModel: {
        weldConditionModel.setProperty(selectIndex,"value",value);
        switch(selectIndex){
        case 2:
            weldConditionModels[5].setProperty(1,"enable",value==="1"?false:true);
            if(weldConditionModel.get(5).value==="1"){
                weldConditionModel.setProperty(5,"value","0");
                changeValue(5)
            }
            weldConditionModels[6].setProperty(1,"enable",value==="1"?false:true);
            if(weldConditionModel.get(6).value==="1"){
                weldConditionModel.setProperty(6,"value","0");
                changeValue(6)
            }
            break;
        case 5:
            weldConditionModels[2].setProperty(1,"enable",value==="1"?false:true);
            if(weldConditionModel.get(2).value==="1"){
                weldConditionModel.setProperty(2,"value","0");
                changeValue(2)
            }
            weldConditionModels[6].setProperty(1,"enable",value==="0"?false:true);
            if(weldConditionModel.get(6).value==="1"){
                weldConditionModel.setProperty(6,"value","0");
                changeValue(6)
            }
            weldConditionModels[8].setProperty(0,"enable",value==="0"?true:false);
            if((weldConditionModel.get(8).value==="0")&&(value==="1")){
                weldConditionModel.setProperty(8,"value","1");
                changeValue(8);
            }
            break;
        case 6:
            weldConditionModels[2].setProperty(1,"enable",value==="1"?false:true);
            if(weldConditionModel.get(2).value==="1"){
                weldConditionModel.setProperty(2,"value","0");
                changeValue(2)
            }
            weldConditionModels[5].setProperty(0,"enable",value==="1"?false:true);
            if(weldConditionModel.get(5).value==="0"){
                weldConditionModel.setProperty(5,"value","1");
                changeValue(5)
            }
            break;
        }
    }
    function makeNum(){
        //实芯碳钢/脉冲无/MAG/1.2
        var str;
        str=weldConditionModel.get(8).value==="0"?"_":"_水冷焊枪_";
        str+=weldConditionModel.get(2).value==="0"?"实芯碳钢_":"药芯碳钢_";
        str+=weldConditionModel.get(6).value==="0"?"脉冲无_":"脉冲有_";
        str+=weldConditionModel.get(5).value==="0"?"CO2_":"MAG_";
        str+=weldConditionModel.get(4).value==="0"?"12":"16";
        changeNum(str)
        return str
    }
    onChangeValue: {
        var num=Number(weldConditionModel.get(index).value);
        switch(index){
            //干伸长
        case 0:
            WeldMath.setPara("wireLength",num ===0?3:num===1?4:num===2?6:7,true,false);
            break;
            //头部摆动方式
        case 1:
            WeldMath.setPara("swingWay",num,true,false);
            break;
            // 焊丝种类
        case 2:
            makeNum();
            WeldMath.setPara("wireType",num===0?0:4,true,false);
            break;
            //机头放置侧
        case 3:
            WeldMath.setPara("grooveDir",num,true,false);
            break;
            //焊丝直径
        case 4:
            makeNum();
            WeldMath.setPara("wireD",num===0?4:6,true,false);
            break;
            //保护气体
        case 5:
            makeNum();
            WeldMath.setPara("gas",num,true,false);
            break;
            //往返动作
        case 7:
            WeldMath.setPara("returnWay",num,false,false);
            break;
            //电源特性
        case 6:
            makeNum();
            WeldMath.setPara("pulse",num,true,false);
            break;
            //电弧跟踪
        case 8:
            makeNum();
            break;
            //预期余高
        case 9:
            WeldMath.setPara("reinforcement",num,false,false);
            break;
            //溶敷系数
        case 10:
            WeldMath.setPara("meltingCoefficient",num,false,false);
            break;
            //焊接电流偏置
        case 11:
            WeldMath.setPara("currentAdd",num,true,false);
            break;
            //焊接电压偏置
        case 12:
            WeldMath.setPara("voltageAdd",num*10,true,false);
            break;
            //提前送气时间
        case 13:
            WeldMath.setPara("beforeGas",num*10,true,false);
            break;
            //滞后送气时间
        case 14:
            WeldMath.setPara("afterGas",num*10,true,false);
            break;
            //起弧停留时间
        case 15:
            WeldMath.setPara("startArcTime",num*10,true,false);
            break;
            //收弧停留时间
        case 16:
            WeldMath.setPara("stopArcTime",num*10,true,false);
            break;
            //起弧电流
        case 17:
            WeldMath.setPara("startArcCurrent",num,true,false);
            break;
            //起弧电压
        case 18:
            WeldMath.setPara("startArcVoltage",num*10,true,false);
            break;
            //收弧电流
        case 19:
            WeldMath.setPara("stopArcCurrent",num,true,false);
            break;
            //收弧电压
        case 20:
            WeldMath.setPara("stopArcVoltgae",num*10,true,false);
            break;
            //层间起弧位置偏移
        case 21:
            WeldMath.setPara("startArcZz",num,false,false);
            break;
            //层间收弧位置偏移
        case 22:
            WeldMath.setPara("stopArcZz",num,false,false);
            break;
            //层内起弧X位置偏移
        case 23:
            WeldMath.setPara("startArcZx",num,false,false);
            break;
            //层内收弧X位置偏移
        case 24:
            WeldMath.setPara("stopArcZx",num,false,false);
            break;
            //收弧回退相关 屏蔽掉
            //收弧回退距离
        case 25:
            WeldMath.setPara("stopArcBackLength",num*10,true,false);
            break;
            //收弧回退速度
        case 26:
             WeldMath.setPara("stopArcBackSpeed",num*10,true,false);
            break;
            //收弧回退时间
        case 27:
             WeldMath.setPara("stopArcBackTime",num*10,true,false);
            break;
            //回烧电压补偿
        case 28:
            WeldMath.setPara("voltageBack",num,true,false);
            break;
            //回烧时间补偿1
        case 29:
            WeldMath.setPara("time1Back",num,true,false);
            break;
            //回烧时间补偿2
        case 30:
            WeldMath.setPara("time2Back",num,true,false);
            break;
            //顿边
        case 31:
            WeldMath.setPara("rootFace",num*10,true,false);
            break;
            //层内停止时间
        case 32:
            WeldMath.setPara("stopOutTime",num,true,false);
            break;
            //层内停止时间
        case 33:
            WeldMath.setPara("stopInTime",num,true,false);
            break;
            //设定起弧停留时间
        case 34:
            WeldMath.setPara("startArcStayTime",num*10,true,fasle);
            break;
            //设定起弧摆动速度
        case 35:
            WeldMath.setPara("startArcSwingSpeed",num*10,true,false);
            break;
        default:
            break;
        }
        //存储数据
        MySQL.setValue(root.objectName,"id",index.toString(),"value",num.toString());
    }
    Connections{
        target: MySQL
        onWeldConditionChanged:{
            for(var i=0;i<(jsonObject.length-1);i++){
                weldConditionModel.setProperty(i,"value",String(jsonObject[i].value));
                var num=Number(jsonObject[i].value);
                switch(i){
                    //干伸长
                case 0:
                    WeldMath.setPara("wireLength",num ===0?3:num===1?4:num===2?6:7,true,false);
                    break;
                    //头部摆动方式
                case 1:
                    WeldMath.setPara("swingWay",num,true,false);
                    break;
                    // 焊丝种类
                case 2:
                    WeldMath.setPara("wireType",num===0?0:4,true,false);
                    break;
                    //机头放置侧
                case 3:
                    WeldMath.setPara("grooveDir",num,true,false);
                    break;
                    //焊丝直径
                case 4:
                    WeldMath.setPara("wireD",num===0?4:6,true,false);
                    break;
                    //保护气体
                case 5:
                    WeldMath.setPara("gas",num,true,false);
                    break;
                    //往返动作
                case 7:
                    WeldMath.setPara("returnWay",num,false,false);
                    break;
                    //电源特性
                case 6:
                    WeldMath.setPara("pulse",num,true,false);
                    break;
                    //电弧跟踪 已取消
                case 8:

                    break;
                    //预期余高
                case 9:
                    WeldMath.setPara("reinforcement",num,false,false);
                    break;
                    //溶敷系数
                case 10:
                    WeldMath.setPara("meltingCoefficient",num,false,false);
                    break;
                    //焊接电流偏置
                case 11:
                    WeldMath.setPara("currentAdd",num,true,false);
                    break;
                    //焊接电压偏置
                case 12:
                    WeldMath.setPara("voltageAdd",num*10,true,false);
                    break;
                    //提前送气时间
                case 13:
                    WeldMath.setPara("beforeGas",num*10,true,false);
                    break;
                    //滞后送气时间
                case 14:
                    WeldMath.setPara("afterGas",num*10,true,false);
                    break;
                    //起弧停留时间
                case 15:
                    WeldMath.setPara("startArcTime",num*10,true,false);
                    break;
                    //收弧停留时间
                case 16:
                    WeldMath.setPara("stopArcTime",num*10,true,false);
                    break;
                    //起弧电流
                case 17:
                    WeldMath.setPara("startArcCurrent",num,true,false);
                    break;
                    //起弧电压
                case 18:
                    WeldMath.setPara("startArcVoltage",num*10,true,false);
                    break;
                    //收弧电流
                case 19:
                    WeldMath.setPara("stopArcCurrent",num,true,false);
                    break;
                    //收弧电压
                case 20:
                    WeldMath.setPara("stopArcVoltgae",num*10,true,false);
                    break;
                    //层间起弧位置偏移
                case 21:
                    WeldMath.setPara("startArcZz",num,false,false);
                    break;
                    //层间收弧位置偏移
                case 22:
                    WeldMath.setPara("stopArcZz",num,false,false);
                    break;
                    //层内起弧X位置偏移
                case 23:
                    WeldMath.setPara("startArcZx",num,false,false);
                    break;
                    //层内收弧X位置偏移
                case 24:
                    WeldMath.setPara("stopArcZx",num,false,false);
                    break;
                    //收弧回退相关 屏蔽掉
                    //收弧回退距离
                case 25:
                    WeldMath.setPara("stopArcBackLength",num*10,true,false);
                    break;
                    //收弧回退速度
                case 26:
                     WeldMath.setPara("stopArcBackSpeed",num*10,true,false);
                    break;
                    //收弧回退时间
                case 27:
                     WeldMath.setPara("stopArcBackTime",num*10,true,false);
                    break;
                    //回烧电压补偿
                case 28:
                    WeldMath.setPara("voltageBack",num,true,false);
                    break;
                    //回烧时间补偿1
                case 29:
                    WeldMath.setPara("time1Back",num,true,false);
                    break;
                    //回烧时间补偿2
                case 30:
                    WeldMath.setPara("time2Back",num,true,false);
                    break;
                    //顿边
                case 31:
                    WeldMath.setPara("rootFace",num*10,true,false);
                    break;
                    //层内停止时间
                case 32:
                    WeldMath.setPara("stopOutTime",num,true,false);
                    break;
                    //层内停止时间
                case 33:
                    WeldMath.setPara("stopInTime",num,true,false);
                    break;
                    //设定起弧停留时间
                case 34:
                    WeldMath.setPara("startArcStayTime",num*10,true,false);
                    break;
                    //设定起弧摆动速度
                case 35:
                    WeldMath.setPara("startArcSwingSpeed",num*10,true,false);
                    break;
                default:
                    break;
                }
            }
            makeNum();
            switch(selectIndex){
            case 2:
                weldConditionModels[5].setProperty(1,"enable",value==="1"?false:true);
                weldConditionModels[6].setProperty(1,"enable",value==="1"?false:true);
                break;
            case 5:
                weldConditionModels[2].setProperty(1,"enable",value==="1"?false:true);
                weldConditionModels[6].setProperty(1,"enable",value==="0"?false:true);
                break;
            case 6:
                weldConditionModels[2].setProperty(1,"enable",value==="1"?false:true);
                weldConditionModels[5].setProperty(0,"enable",value==="1"?false:true);
                break;
            case 8:
                weldConditionModels[4].setProperty(1,"enable",value==="1"?false:true);
                break;
            }
        }
    }
   Connections{
        target: WeldMath
        onEr100_TeachSet:{
            var setValue
            setValue=Number(value[0]);
              if(setValue!==Number(weldConditionModel.get(1).value)){
                    weldConditionModel.setProperty(1,"value",String(setValue))
                    MySQL.setValue(root.objectName,"id",String(1),"value",String(setValue));
            }
        }
    }
    Component.onCompleted: {
        weldConditionModels[4].setProperty(1,"enable",false);
        //变更限制条件
        MySQL.getJsonTable(objectName);
    }
}
