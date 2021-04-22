import QtQuick 2.4
import Material 0.1 as Material
import WeldSys.WeldMath 1.0
import WeldSys.MySQL 1.0
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.3 as QuickControls
import QtQuick.Window 2.2
import "MyMath.js" as MyMath


MyConditionView{
    id:root
    objectName: "WeldCondition"

    signal changeNum(string value)

    function makeNum(){
        //实芯碳钢/脉冲无/MAG/1.2
        var   str=root.condition[8]===0?"_":"_水冷焊枪_";
        str+=root.condition[2]===0?"实芯碳钢_":"药芯碳钢_";
        str+=root.condition[6]===0?"脉冲无_":"脉冲有_";
        str+=root.condition[5]===0?"CO2_":"MAG_";
        str+=root.condition[4]===0?"12":"16";
        changeNum(str)
        return str
    }

    titleName: qsTr("焊接条件");
    condition: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    listName: ["焊丝伸出长度:","头部摇动方式:","焊丝种类:","机头放置侧:","焊丝直径:","保护气体:","焊接脉冲状态:","焊接往返动作:","焊枪冷却方式:","预期余高:","溶敷系数:","焊接电流偏置:","焊接电压偏置:","提前送气时间:","滞后送气时间","起弧停留时间:","收弧停留时间","起弧电流衰减系数:","起弧电压衰减系数:","收弧电流衰减系数:","收弧电压衰减系数:"
        ,"层间起弧位置偏移:" ,"层间收弧位置偏移:" ,"层内起弧位置偏移:" ,"层内收弧位置偏移:","收弧回退距离:","收弧回退速度:","收弧回退停留时间:","回烧电压补偿:","回烧时间补偿1:","回烧时间补偿2:","钝边:","层间停止时间:","层内停止时间:","陶瓷衬垫打底起弧停留时间:","陶瓷衬垫打底起弧摆动速度:"]
    property var weldWireLengthModel:     ["15mm","20mm","25mm","30mm"];
    property var weldWireLengthEnable:    [true,true,true,true]
    property var swingWayModel:                ["无","左方","右方","左右"];
    property var swingWayEnable:                [true,true,true,true]
    property var weldWireModel:                 ["实芯碳钢","药芯碳钢"];
    property var weldWireEnable:                [true,true]
    property var robotLayoutModel:            ["坡口侧","非坡口侧"];
    property var robotLayoutEnable:            [true,true];
    property var weldWireDiameterModel: ["1.2mm","1.6mm"];
    property var weldWireDiameterEnable: [true,true];
    property var weldGasModel:                   ["CO2","MAG"];
    property var weldGasEnable:                  [true,true];
    property var returnWayModel:               ["单向","道间往返","层间往返"];
    property var returnWayEnable:              [true,true,true];
    property var weldPowerModel:              ["关闭","打开"];
    property var weldPowerEnable:             [true,true];
    property var weldTrackModel:                ["空冷","水冷"];
    property var weldTrackEnable:               [true,true];
    listValueName: [weldWireLengthModel,swingWayModel,weldWireModel,robotLayoutModel,weldWireDiameterModel,weldGasModel,weldPowerModel,returnWayModel,weldTrackModel]
    listValueNameEnable: [weldWireLengthEnable,swingWayEnable,weldWireEnable,robotLayoutEnable,weldWireDiameterEnable,weldGasEnable,weldPowerEnable,returnWayEnable,weldTrackEnable]
    listDescription: ["设定焊丝端部到导电嘴的长度。",
        "设定在焊接的起始、端部头部是否摆动。",
        "设定焊丝种类实芯碳钢或药芯碳钢。",
        "设定机头相对于坡口的放置位置。",
        "设定焊丝的直径。",
        "设定焊接过程中使用保护气体。",
        "设定电源特性，直流或脉冲。",
        "设定焊接往返动作方向为往返方向或单向。",
        "设定焊枪的冷却方式为空冷或水冷。",
        "设定焊接预期板面焊道堆起高度。",
        "设定焊接过程中溶敷系数的大小，以方便推算更合适的焊接规范。",
        "焊接条件所设定的电流和实际电流的微调整。",
        "焊接条件所设定的电压和实际电压的微调整。",
        "设定焊接提前送气时间。",
        "设定焊接滞后送气时间。",
        "设定焊接起弧停留时间。",
        "设定焊接收弧停留时间。",
        "设定焊接起弧电流相对焊接电流的衰减系数。",
        "设定焊接起弧电压相对焊接电压的衰减系数。",
        "设定焊接收弧电流相对焊接电流的衰减系数。",
        "设定焊接收弧电压相对焊接电压的衰减系数。",
        "设定每层之间起弧坐标Z行走轴偏移量,焊接方向为正反之则为负。",
        "设定每层之间收弧坐标Z行走轴偏移量,焊接方向为正反之则为负。",
        "设定层内每层焊道之间起弧坐标Z行走轴偏移量,焊接方向为正反之则为负。",
        "设定层内每层焊道之间收弧坐标Z行走轴偏移量,焊接方向为正反之则为负。",
        "设定焊接收弧回退距离。",
        "设定焊接收弧回退速度。",
        "设定焊接收弧回退停留时间。",
        "设定回烧时间中的输出电压微调整(和焊丝的上燃量有关)。",
        "设定回烧时间的微调整(和焊丝的上燃量有关)。",
        "设定回烧时间的微调整(和焊丝的上燃量有关)。",
        "设定顿边大小。",
        "设定每层之间焊接结束后停止焊接的时间(最长1小时)。",
        "设定层内每层焊道之间焊接结束后停止焊接的时间(最长1小时)。",
        "设定陶瓷衬垫打底起弧两端停留时间。",
        "设定陶瓷衬垫打底起弧时摆动速度。"]
    valueType: ["mm","%","A","V","S","S","S","S","%","%","%","%","mm","mm","mm","mm","mm","cm/min","S","","","","mm","S","S","S","cm/min"]
    //处理 数据
    onChangeGroup: {
        var str;
        switch(selectedIndex){
        case 2:
            changeGroupCurrent(index,flag);
            if(index){//切换到药芯碳钢
                changeEnable(5,1,false);//Mag按钮失效
                changeEnable(6,1,false)//脉冲按钮失效
                if(root.condition[5]){//如果此时是MAG则切换到CO2
                    selectedIndex=5;
                    changeGroupCurrent(0,false)
                    str="焊丝种类为药芯碳钢时，保护气切换为CO2。"
                    //脉冲按钮也失效
                }else
                    str="";
                if(root.condition[6]){//脉冲打开则关闭
                    selectedIndex=6
                    changeGroupCurrent(0,false)
                    if(str.length>2)
                        str+="且脉冲状态切换为关闭。";
                    else
                        str="焊丝种类为药芯碳钢时，脉冲状态切换为关闭。"
                }else
                    if(str.length>2)
                        str+="。"
                selectedIndex=2;
                if(str.length>2)
                    message.open(str);
            }else{
                changeEnable(5,1,true);
                if(root.condition[6])//MAG才有效否则失效
                    changeEnable(6,1,true);
                else
                    changeEnable(6,1,false);
            }
            break;
        case 5:
            //切换到CO2变更显示但是不变更数据
            changeGroupCurrent(index,flag);
            if(index===0){//CO2
                changeEnable(6,1,false);
                changeEnable(2,1,true);
                if((root.condition[6])){
                    //选中脉冲 并关闭脉冲
                    selectedIndex=6;
                    //切换到CO2变更显示变更数据
                    changeGroupCurrent(0,false);
                    selectedIndex=5;
                    message.open("保护气体为CO2时，脉冲状态切换为关闭。");
                }
            }else{//MAG
                //药芯 失效
                changeEnable(2,1,false);
                changeEnable(6,1,true);
                if(root.condition[2]){//为药芯 则切换
                    selectedIndex=2;
                    changeGroupCurrent(0,false)
                    selectedIndex=5;
                    message.open("保护气体为MAG时，焊丝种类切换为实芯碳钢。")
                }
            }
            break;
        case 6:
            //由脉冲有 切换到无
            //变更显示但是不变更数据
            changeGroupCurrent(index,flag);
            if(index===0){//脉冲无
                //使能CO2
                changeEnable(5,0,true);
                if((root.condition[5]===0))//CO2
                    //使能药芯
                    changeEnable(2,1,true);
                else
                    changeEnable(2,1,false)
            }else{//脉冲有
                changeEnable(5,0,false);
                changeEnable(2,1,false);
                if(root.condition[5]===0){//CO2 切换为MAG
                    selectedIndex=5;
                    changeGroupCurrent(1,false);
                    str="脉冲状态打开时，保护气体切换为MAG"
                }else
                    str="";
                if(root.condition[2]){//药芯切换为 实芯碳钢
                    selectedIndex=2;
                    changeGroupCurrent(0,false)
                    if(str.length>2){
                        str+="且焊丝种类切换为实芯碳钢。"
                    }else
                        str="脉冲状态打开时，焊丝种类切换为实芯碳钢。"
                }else
                    if(str.length>2)
                        str+="。"
                selectedIndex=6;
                if(str.length>2){
                    message.open(str);
                }
            }
            break;
        case 8:
            if(index){//切换为1.6
                changeEnable(4,1,true)//关闭1.6丝径
            }else{
                if(root.condition[4]){
                    root.condition[8]=0;
                    selectedIndex=4;
                    changeGroupCurrent(0,false)
                    selectedIndex=8;
                    message.open("空冷焊枪时，关闭1.6mm焊丝。");
                }
                changeEnable(4,1,false)//关闭1.6丝径
            }
            changeGroupCurrent(index,flag);
            break;
        default:
            //变更显示但是不变更数据
            changeGroupCurrent(index,flag);
            break;
        }
    }
    onWork: {
        var num=Number(root.condition[index]);
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
            if(flag)
                makeNum();
            WeldMath.setPara("wireType",num===0?0:4,true,false);
            break;
            //机头放置侧
        case 3:
            WeldMath.setPara("grooveDir",num,true,false);
            break;
            //焊丝直径
        case 4:
            if(flag)
                makeNum();
            WeldMath.setPara("wireD",num===0?4:6,true,false);
            break;
            //保护气体
        case 5:
            if(flag)
                makeNum();
            WeldMath.setPara("gas",num,true,false);
            break;
            //往返动作
        case 7:
            WeldMath.setPara("returnWay",num,false,false);
            break;
            //电源特性
        case 6:
            if(flag)
                makeNum();
            WeldMath.setPara("pulse",num,true,false);
            break;
            //电弧跟踪
        case 8:
            if(flag)
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
        case 25://frame.push("303");frame.push("1");frame.push(String(num*10));
            WeldMath.setPara("stopArcBack",num,true,false);
            break;
            //收弧回退速度
            //  case 26:frame.push("304");frame.push("1");frame.push(String(num*10));break;
            //收弧回退时间
            //  case 27:frame.push("305");frame.push("1");frame.push(String(num*10));break;
            //回烧电压补偿
        case 28://frame.push("300");frame.push("1");frame.push(String(num));
            WeldMath.setPara("voltageBack",num,true,false);
            break;
            //回烧时间补偿1
        case 29://frame.push("301");frame.push("1");frame.push(String(num));
            WeldMath.setPara("time1Back",num,true,false);
            break;
            //回烧时间补偿2
        case 30://frame.push("302");frame.push("1");frame.push(String(num));
            WeldMath.setPara("time2Back",num,true,false);
            break;
            //顿边
        case 31:
            //  frame.push("161");frame.push("1");frame.push(String(num*10));
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
        case 34://frame.push("148");frame.push("1");frame.push(String(num*10));
            break;
            //设定起弧摆动速度
        case 35://frame.push("149");frame.push("1");frame.push(String(num*10));
            break;
        default://frame.length=0;
            break;
        }
        if(flag){
            //存储数据
            MySQL.setValue(root.objectName,"id",index.toString(),"value",num.toString());
        }
    }
    onKeyDec:{
        var num=Number(root.condition[selectedIndex]);
        switch(index){
            //余高层
        case 0:num-=0.1;num=num.toFixed(1); if(num<-3)num=-3;break;
            //溶敷系数
        case 1:num-=1; if(num<50)num=50;break;
            //电流偏置
        case 2:num-=1; if(num<-100)num=-100;break;
            //电压偏置
        case 3:num-=0.1;num=num.toFixed(1); if(num<-10)num=-10;break;
            //提前送气时间
        case 4:
            //滞后送气时间
        case 5:
            //起弧停留时间
        case 6:
            //收弧停留时间
        case 7:num-=0.1;num=num.toFixed(1); if(num<0)num=0;break;
            //起弧电流
        case 8:
            //起弧电压
        case 9:
            //收弧电流
        case 10:
            //收弧电压
        case 11:num-=1; if(num<50)num=50;break;
            //层间起弧偏移
        case 12:
            //层间收弧偏移
        case 13:
            //层内起弧偏移
        case 14:
            //层内收弧偏移
        case 15:num-=1; if(num<-1000)num=-1000;break;
            //收弧回退距离
        case 16:num-=1; if(num<0)num=0;break;
            //收弧回退速度
        case 17:num-=0.1;num=num.toFixed(1);if(num<0)num=0;break;
            //收弧回退时间
        case 18:num-=0.1;num=num.toFixed(1); if(num<0)num=0;break;
            //回烧电压补偿
        case 19:
            //回烧时间补偿
        case 20:
            //回烧时间补偿
        case 21:num-=1; if(num<-50)num=-50;break;
            //顿边
        case 22:num-=0.1;num=num.toFixed(1);if(num<0) num=0;break;
            //层间
        case 23:
            //层内
        case 24:num-=flag?10:1;if(num<0) num=0;break;
            //
        case 25:num-=0.1;num=num.toFixed(1); if(num<0)num=0;break;
            //层内
        case 26:num-=1;if(num<0) num=0;break;
        }
        if(index>=0){
            //变更显示但是不变更数据
            changeText(num,true);
        }
    }
    onKeyInc:{
        var num=Number(root.condition[selectedIndex]);
        switch(index){
            //余高层
        case 0:num+=0.1; num=num.toFixed(1);if(num>3)num=3;break;
            //溶敷系数
        case 1:num+=1; if(num>150)num=150;break;
            //电流偏置
        case 2:num+=1; if(num>100)num=100;break;
            //电压偏置
        case 3:num+=0.1; num=num.toFixed(1);if(num>10)num=10;break;
            //提前送气时间
        case 4:
            //滞后送气时间
        case 5:
            //起弧停留时间
        case 6:
            //收弧停留时间
        case 7:num+=0.1; num=num.toFixed(1);if(num>5)num=5;break;
            //起弧电流
        case 8:
            //起弧电压
        case 9:
            //收弧电流
        case 10:
            //收弧电压
        case 11:num+=1; if(num>130)num=130;break;
            //层间起弧偏移
        case 12:
            //层间收弧偏移
        case 13:
            //层内起弧偏移
        case 14:
            //层内收弧偏移
        case 15:
            //收弧回退距离
        case 16:num+=1; if(num>1000)num=1000;break;
            //收弧回退速度
        case 17:num+=0.1;num=num.toFixed(1);if(num>30)num=30;break;
            //收弧回退时间
        case 18:num+=0.1;num=num.toFixed(1);if(num>3)num=3;break;
            //回烧电压补偿
        case 19:
            //回烧时间补偿
        case 20:
            //回烧时间补偿
        case 21:num+=1;if(num>50)num=50;break;
            //顿边
        case 22:num+=0.1;num=num.toFixed(1);if(num>20)num=20;break;
            //层间
        case 23:
            //层内
        case 24:num+=flag?10:1;if(num>3600) num=3600;break;
            //层间
        case 25:num+=0.1;num=num.toFixed(1);if(num>3)num=3;break;
            //层内
        case 26:num+=1;if(num>200) num=200;break;
        }
        if(index>=0){
            //变更显示但是不变更数据
            changeText(num,true);
        }
    }
    Connections{
        target: MySQL
        onWeldConditionChanged:{
            condition.length=0;
            for(var i=0;i<jsonObject.length;i++){
                condition.push(Number(jsonObject[i].value));
            }
            update();
            //下发数据
            for( i=0;i<listName.length;i++){
                work(i,false);
            }
            makeNum();
            //关闭1.6丝径
            //
            changeEnable(0,2,false)//干伸长25mm disable
            changeEnable(0,3,false)//干伸长30mm disable
            //检查使能
            if(condition[2]){//药芯
                changeEnable(2,1,true);//自己使能
                changeEnable(5,1,false);//mag disable
                changeEnable(6,1,false);//脉冲 disable
            }
            if(condition[5]){//mag
                changeEnable(2,1,false);//药芯 disable
                changeEnable(5,1,true);//mag disable
                changeEnable(6,1,true);//脉冲 disable
            }
            if(condition[6]){//脉冲
                changeEnable(2,1,false) //药芯 disable
                changeEnable(5,0,false) //CO2 disable
                changeEnable(6,1,true);//脉冲 disable
            }
            if(condition[8]){
                changeEnable(4,1,true)//打开1.6丝径
            }else{
                changeEnable(4,1,false)//关闭1.6丝径
            }
        }
    }
    Component.onCompleted: {
        //变更限制条件
        MySQL.getJsonTable(objectName)
    }
}

