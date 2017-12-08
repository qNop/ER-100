import QtQuick 2.4
import Material 0.1 as Material
import WeldSys.ERModbus 1.0
import WeldSys.WeldMath 1.0
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.3 as QuickControls
import QtQuick.LocalStorage 2.0
import QtQuick.Window 2.2
import "MyMath.js" as MyMath

MyConditionView{
    id:root
    objectName: "WeldCondition"

    signal changeNum(string value)

    function makeNum(){
        //实芯碳钢/脉冲无/MAG/1.2
        var str=root.condition[2]===0?"_实芯碳钢_":"_药芯碳钢_";
        str+=root.condition[6]===0?"脉冲无_":"脉冲有_";
        str+=root.condition[5]===0?"CO2_":"MAG_";
        str+=root.condition[4]===0?"12":"16";
        changeNum(str)
        return str
    }

    titleName: qsTr("焊接条件");
    condition: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    listName: ["焊丝伸出长度:","头部摇动方式:","焊丝种类:","机头放置侧:","焊丝直径:","保护气体:","焊接脉冲状态:","焊接往返动作:","电弧跟踪:","预期余高:","溶敷系数:","焊接电流偏置:","焊接电压偏置:","提前送气时间:","滞后送气时间","起弧停留时间:","收弧停留时间","起弧电流衰减系数:","起弧电压衰减系数:","收弧电流衰减系数:","收弧电压衰减系数:"
        ,"层间起弧位置偏移:" ,"层间收弧位置偏移:" ,"层内起弧位置偏移:" ,"层内收弧位置偏移:","收弧回退距离:","收弧回退速度:","收弧回退停留时间:","回烧电压补偿:","回烧时间补偿1:","回烧时间补偿2:","顿边:","层间停止时间:","层内停止时间:","陶瓷衬垫打底起弧停留时间:","陶瓷衬垫打底起弧摆动速度:"]
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
    property var returnWayModel:               ["单向","往返"];
    property var returnWayEnable:              [true,true];
    property var weldPowerModel:              ["关闭","打开"];
    property var weldPowerEnable:             [true,true];
    property var weldTrackModel:                ["关闭","打开"];
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
        "设定电弧跟踪是否开启。",
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
                    str="焊丝种类为药芯碳钢时，保护气切换为CO2"
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
        default:
            //变更显示但是不变更数据
            changeGroupCurrent(index,flag);
            break;
        }
    }
    onWork: {
        var frame=new Array(0);
        frame.push("W");
        var num=Number(root.condition[index]);
        switch(index){
            //干伸长
        case 0: frame.push("120");frame.push("1");frame.push(num ===0?"3":num===1?"4":num===2?"6":"7");break;
            //头部摆动方式
        case 1:frame.push("99");frame.push("1");frame.push(String(num));break;
            // 焊丝种类
        case 2:frame.push("126");frame.push("1");frame.push(num ===0?"0":"4");
            if(flag)
                makeNum();
            WeldMath.setWireType(num===0?0:4);
            break;
            //机头放置侧
        case 3:frame.push("122");frame.push("1");frame.push(String(num));
            WeldMath.setGrooveDir(num);
            break;
            //焊丝直径
        case 4:frame.push("123");frame.push("1");frame.push(num ===0?"4":"6");
            if(flag)
                makeNum();
            WeldMath.setWireD(num===0?4:6);
            break;
            //保护气体
        case 5:frame.push("124");frame.push("1");frame.push(String(num));
            if(flag)
                makeNum();
            WeldMath.setGas(num);
            break;
            //往返动作
        case 7:
            WeldMath.setReturnWay(num);break;
            //frame.push("125");frame.push("1");frame.push(String(num));break;
            //电源特性
        case 6:frame.push("119");frame.push("1");frame.push(String(num ));
            if(flag)
                makeNum();
            WeldMath.setPulse(num);
            break;
            //电弧跟踪
      //  case 8:frame.push("127");frame.push("1");frame.push(String(num));break;
            //预期余高
        case 9: WeldMath.setReinforcement(num);
            break;
            //溶敷系数
        case 10: WeldMath.setMeltingCoefficient(num);
            break;
            //焊接电流偏置
        case 11:frame.push("128");frame.push("1");frame.push(String(num));break;
            //焊接电压偏置
        case 12:frame.push("129");frame.push("1");frame.push(String(num*10));break;
            //提前送气时间
        case 13:frame.push("132");frame.push("1");frame.push(String(num*10));break;
            //滞后送气时间
        case 14:frame.push("133");frame.push("1");frame.push(String(num*10));break;
            //起弧停留时间
        case 15:frame.push("134");frame.push("1");frame.push(String(num*10));break;
            //收弧停留时间
        case 16:frame.push("135");frame.push("1");frame.push(String(num*10));break;
            //起弧电流
        case 17:frame.push("136");frame.push("1");frame.push(String(num));break;
            //起弧电压
        case 18:frame.push("137");frame.push("1");frame.push(String(num*10));break;
            //收弧电流
        case 19:frame.push("138");frame.push("1");frame.push(String(num));break;
            //收弧电压
        case 20:frame.push("139");frame.push("1");frame.push(String(num*10));break;
            //层内起弧X位置偏移
        case 21:WeldMath.setStartArcZz(num);break;
            //层内收弧X位置偏移
        case 22:WeldMath.setStopArcZz(num);break;
            //层间起弧X位置偏移
        case 23:WeldMath.setStartArcZx(num);break;
            //层间收弧X位置偏移
        case 24:WeldMath.setStopArcZx(num);break;
        //收弧回退相关 屏蔽掉
            //收弧回退距离
   //     case 25:frame.push("303");frame.push("1");frame.push(String(num*10));break;
            //收弧回退速度
      //  case 26:frame.push("304");frame.push("1");frame.push(String(num*10));break;
            //收弧回退时间
  //      case 27:frame.push("305");frame.push("1");frame.push(String(num*10));break;
            //回烧电压补偿
        case 28:frame.push("300");frame.push("1");frame.push(String(num));break;
            //回烧时间补偿1
        case 29:frame.push("301");frame.push("1");frame.push(String(num));break;
            //回烧时间补偿2
        case 30:frame.push("302");frame.push("1");frame.push(String(num));break;
            //顿边
        case 31:WeldMath.setRootFace(num);frame.push("161");frame.push("1");frame.push(String(num*10));break;
            //层内停止时间
        case 32:WeldMath.setStopOutTime(num);break;
            //层内停止时间
        case 33:WeldMath.setStopInTime(num);break;
            //设定起弧停留时间
        case 34:frame.push("148");frame.push("1");frame.push(String(num*10));break;
            //设定起弧摆动速度
        case 35:frame.push("149");frame.push("1");frame.push(String(num*10));break;
        default:frame.length=0;break;
        }
        if(frame.length===4){
            //下发规范
            ERModbus.setmodbusFrame(frame)
            if(index===1){//头部摇动
                frame.length=0;
                frame.push("W");
                frame.push("130");
                frame.push("2");
                switch(num){
                case 0:frame.push("0");frame.push("0");break;
                case 1:frame.push("22");frame.push("0");break;
                case 2:frame.push("0");frame.push("22");break;
                case 3:frame.push("22");frame.push("22");break;
                }
                ERModbus.setmodbusFrame(frame);
            }
        }
        if(flag){
            //存储数据
            Material.UserData.setValueFromFuncOfTable(root.objectName,index,num)
        }
        //console.log(frame)
        //清空
        frame.length=0;
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
        case 15:
            //收弧回退距离
        case 16:num-=1; if(num<-1000)num=1000;break;
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
    Component.onCompleted: {
        //变更限制条件
        condition=Material.UserData.getValueFromFuncOfTable(objectName,"","");
        for(var i=0;i<listName.length;i++){
            work(i,false);
        }
        makeNum();
        //关闭1.6丝径
        changeEnable(4,1,false) //关闭1.6丝径
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
        if(condition[6]){//maichong
            changeEnable(2,1,false) //药芯 disable
            changeEnable(5,0,false) //CO2 disable
            changeEnable(6,1,true);//脉冲 disable
        }
    }
}
