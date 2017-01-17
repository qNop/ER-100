import QtQuick 2.4
import Material 0.1 as Material
import Material.Extras 0.1 as JS
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0
import WeldSys.WeldMath 1.0
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.3 as QuickControls
import QtQuick.LocalStorage 2.0
import QtQuick.Window 2.2

MyConditionView{
    id:root
    objectName: "WeldCondition"

    signal changeNum(int value)

    function makeNum(){
        //保护气体
        var num=root.condition[5];
        num<<=1;
        //电源特性
        num|=root.condition[7];
        num<<=3;
        //焊丝种类
        num|=root.condition[2]===0?0:4;
        num<<=4;
        //焊丝直径
        num|=root.condition[4]===0?4:6;
        //发射信号
        changeNum(num)
        return String(num)
    }

    titleName: qsTr("焊接条件");
    type:AppConfig.currentUserType==="超级用户"?true:false
    condition: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    listName: ["焊丝伸出长度:","头部摇动方式:","焊丝种类:","机头放置侧:","焊丝直径:","保护气体:","焊接脉冲状态:","焊接往返动作:","电弧跟踪:","预期余高:","溶敷系数:","焊接电流偏置:","焊接电压偏置:","提前送气时间:","滞后送气时间","起弧停留时间:","收弧停留时间","起弧电流:","起弧电压:","收弧电流:","收弧电压:"
        ,"收弧回退距离","收弧回退速度","收弧回退停留时间","回烧电压补偿","回烧时间补偿1","回烧时间补偿2"]
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
        "设定焊接起弧电流。",
        "设定焊接起弧电压。",
        "设定焊接收弧电流。",
        "设定焊接收弧电压。",
        "设定焊接收弧回退距离。",
        "设定焊接收弧回退速度。",
        "设定焊接收弧回退停留时间。",
        "设定回烧时间中的输出电压微调整(和焊丝的上燃量有关)。",
        "设定回烧时间的微调整(和焊丝的上燃量有关)。",
        "设定回烧时间的微调整(和焊丝的上燃量有关)。"]
    valueType: ["mm","%","A","V","S","S","S","S","A","V","A","V","mm","cm/min","S","","",""]
    //处理 数据
    onChangeGroup: {
        var str;
        switch(selectedIndex){
        case 2:
            changeGroupCurrent(index,flag);
            if(index){//切换到药芯碳钢
                changeEnable(5,1,false);  //Mag按钮失效
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
        case 5:frame.push("124");frame.push("1");frame.push(String(num ));
            if(flag)
                makeNum();
            WeldMath.setGas(num);
            break;
            //往返动作
        case 7:frame.push("125");frame.push("1");frame.push(String(num ));break;
            //电源特性
        case 6:frame.push("119");frame.push("1");frame.push(String(num ));
            if(flag)
                makeNum();
            WeldMath.setPulse(num);
            break;
            //电弧跟踪
        case 8:frame.push("127");frame.push("1");frame.push(String(num));break;
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
            //收弧回退距离
        case 21:frame.push("303");frame.push("1");frame.push(String(num*10));break;
            //收弧回退速度
        case 22:frame.push("304");frame.push("1");frame.push(String(num*10));break;
            //收弧回退时间
        case 23:frame.push("305");frame.push("1");frame.push(String(num*10));break;
            //回烧电压补偿
        case 24:frame.push("300");frame.push("1");frame.push(String(num));break;
            //回烧时间补偿1
        case 25:frame.push("301");frame.push("1");frame.push(String(num));break;
            //回烧时间补偿2
        case 26:frame.push("302");frame.push("1");frame.push(String(num));break;
        default:frame.length=0;break;
        }
        if(frame.length===4){
            //下发规范
            ERModbus.setmodbusFrame(frame)
        }
        if(flag){
            //存储数据
            Material.UserData.setValueFromFuncOfTable(root.objectName,index,num)
        }
        console.log(frame)
        //清空
        frame.length=0;
    }
    onKeyDec:{
        var num=Number(root.condition[selectedIndex]);
        switch(index){
            //余高层
        case 0:num-=1; if(num<-3)num=-3;break;
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
        case 8:num-=1; if(num<0)num=0;break;
            //起弧电压
        case 9:num-=0.1;num=num.toFixed(1); if(num<0)num=0;break;
            //收弧电流
        case 10:num-=1; if(num<0)num=0;break;
            //收弧电压
        case 11:num-=0.1;num=num.toFixed(1); if(num<0)num=0;break;
            //收弧回退距离
        case 12:num-=1; if(num<0)num=0;break;
            //收弧回退速度
        case 13:num-=0.1;num=num.toFixed(1);if(num<0)num=0;break;
            //收弧回退时间
        case 14:num-=0.1;num=num.toFixed(1); if(num<0)num=0;break;
            //回烧电压补偿
        case 15:
            //回烧时间补偿
        case 16:
            //回烧时间补偿
        case 17:num-=1; if(num<-50)num=-50;break;
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
        case 0:num+=1; if(num>3)num=3;break;
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
        case 8:num+=1; if(num>300)num=300;break;
            //起弧电压
        case 9:num+=0.1; num=num.toFixed(1);if(num>30)num=30;break;
            //收弧电流
        case 10:num+=1; if(num>300)num=300;break;
            //收弧电压
        case 11:num+=0.1;num=num.toFixed(1); if(num>30)num=30;break;
            //收弧回退距离
        case 12:num+=1; if(num>30)num=30;break;
            //收弧回退速度
        case 13:num+=0.1;num=num.toFixed(1);if(num>30)num=30;break;
            //收弧回退时间
        case 14:num+=0.1;num=num.toFixed(1);if(num>3)num=3;break;
            //回烧电压补偿
        case 15:
            //回烧时间补偿
        case 16:
            //回烧时间补偿
        case 17:num+=1;if(num>50)num=50;break;
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
            changeEnable(5,1,false)//mag disable
            changeEnable(6,1,false);//脉冲disable
        }
        if(condition[5]){//mag
            changeEnable(2,1,false)//药芯 disable
        }
        if(condition[6]){//maichong
            changeEnable(2,1,false) //药芯disable
            changeEnable(5,1,false) //CO2disable
        }
    }
}

//Item{
//    id:root
//    /*名称必须要有方便 nav打开后寻找焦点*/
//    objectName: "WeldCondition"
//    anchors{
//        left:parent.left
//        top:parent.top
//        bottom: parent.bottom
//        leftMargin:visible?0:Material.Units.dp(250)
//    }
//    width:parent.width
//    Behavior on anchors.leftMargin{NumberAnimation { duration: 400 }}

//    property var weldWireLengthModel:     ["10mm","15mm","20mm","25mm"];
//    property var swingWayModel:                ["无","左方","右方","左右"];
//    property var weldWireModel:                 ["实芯碳钢","药芯碳钢"];
//    property var robotLayoutModel:            ["坡口侧","非坡口侧"];
//    property var weldWireDiameterModel: ["1.2mm","1.6mm"];
//    property var weldGasModel:                   ["CO2","MAG"];
//    property var returnWayModel:               ["单向","往返"];
//    property var weldPowerModel:              ["关闭","打开"];
//    property var weldTrackModel:                ["关闭","打开"];

//    property bool type:AppConfig.currentUserType==="超级用户"?true:false

//    property var condition: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

//    property int selectedIndex:0

//    property var listName: ["焊丝伸出长度:","头部摇动方式:","焊丝种类:","机头放置侧:","焊丝直径:","保护气体:","焊接往返动作:","焊接脉冲状态:","电弧跟踪:","预期余高:","溶敷系数:","焊接电流偏置:","焊接电压偏置:","提前送气时间:","滞后送气时间","起弧停留时间:","收弧停留时间","起弧电流:","起弧电压:","收弧电流:","收弧电压:"
//        ,"收弧回退距离","收弧回退速度","收弧回退停留时间","回烧电压补偿","回烧时间补偿1","回烧时间补偿2"]

//    property var listValueName: [weldWireLengthModel,swingWayModel,weldWireModel,robotLayoutModel,weldWireDiameterModel,weldGasModel,returnWayModel,weldPowerModel,weldTrackModel]

//    property var listDescription: ["设定焊丝端部到导电嘴的长度。",
//        "设定在焊接的起始、端部头部是否摆动。",
//        "设定焊丝种类实芯碳钢或药芯碳钢。",
//        "设定机头相对于坡口的放置位置。",
//        "设定焊丝的直径。",
//        "设定焊接过程中使用保护气体。",
//        "设定焊接往返动作方向为往返方向或单向。",
//        "设定电源特性，直流或脉冲。",
//        "设定电弧跟踪是否开启。",
//        "设定焊接预期板面焊道堆起高度。",
//        "设定焊接过程中溶敷系数的大小，以方便推算更合适的焊接规范。",
//        "焊接条件所设定的电流和实际电流的微调整。",
//        "焊接条件所设定的电压和实际电压的微调整。",
//        "设定焊接提前送气时间。",
//        "设定焊接滞后送气时间。",
//        "设定焊接起弧停留时间。",
//        "设定焊接收弧停留时间。",
//        "设定焊接起弧电流。",
//        "设定焊接起弧电压。",
//        "设定焊接收弧电流。",
//        "设定焊接收弧电压。",
//        "设定焊接收弧回退距离。",
//        "设定焊接收弧回退速度。",
//        "设定焊接收弧回退停留时间。",
//        "设定回烧时间中的输出电压微调整(和焊丝的上燃量有关)。",
//        "设定回烧时间的微调整(和焊丝的上燃量有关)。",
//        "设定回烧时间的微调整(和焊丝的上燃量有关)。"]
//    property var valueType: ["mm","%","A","V","S","S","S","S","A","V","A","V","mm","cm/min","S","","",""]
//    //提示信息
//    property Item message

//    //负责选择
//    signal changeSelectedIndex(int index)
//    //负责处理 按键+触摸的 操作合并
//    signal changeGroup(int index,bool flag)
//    //负责处理 改变控件状态 +dowork
//    signal changeGroupCurrent(int index,bool flag)
//    //负责处理 TEXT
//    signal changeText(double value,bool flag)
//    //负责处理数据存储 数据的下发
//    signal doWork(int index,bool flag)
//    //负责处理 num相关
//    signal changeNum(int value)

//    function makeNum(){
//        //保护气体
//        var num=root.condition[5];
//        num<<=1;
//        //电源特性
//        num|=root.condition[7];
//        num<<=3;
//        //焊丝种类
//        num|=root.condition[2]===0?0:4;
//        num<<=4;
//        //焊丝直径
//        num|=root.condition[4]===0?4:6;
//        //发射信号
//        changeNum(num)
//        return String(num)
//    }

//    onChangeSelectedIndex: {
//        selectedIndex=index;
//    }
//    onChangeGroup: {
//        switch(selectedIndex){
//        case 5:
//            //切换到CO2变更显示但是不变更数据
//            changeGroupCurrent(index,true);
//            if((root.condition[7])&&(index===0)){
//                //选中脉冲 并关闭脉冲
//                selectedIndex=7;
//                changeGroupCurrent(0,true);
//                message.open("保护气体为CO2时自动关闭脉冲。");
//            }
//            break;
//        case 7:
//            //由脉冲有 切换到无
//            if((root.condition[5]===0)&&(index)){
//                //CO2提示
//                message.open("保护气体为CO2时不能打开脉冲。")
//            }else{
//                //变更显示但是不变更数据
//                changeGroupCurrent(index,true);
//            }
//            break;
//        default:
//            //变更显示但是不变更数据
//            changeGroupCurrent(index,true);
//            break;
//        }
//    }

//    onChangeGroupCurrent: {
//        root.condition[selectedIndex]=index;
//        if(!flag)
//            doWork(selectedIndex,true);
//    }
//    onChangeText: {
//        root.condition[selectedIndex]=index;
//        if(!flag)
//            doWork(selectedIndex,true);
//    }
//    onDoWork: {
//        var frame=new Array(0);
//        frame.push("W");
//        var num=Number(root.condition[index]);
//        switch(index){
//            //干伸长
//        case 0: frame.push("120");frame.push("1");frame.push(num ===0?"1":num===1?"3":num===2?"4":"6");break;
//            //头部摆动方式
//        case 1:frame.push("121");frame.push("1");frame.push(String(num));break;
//            // 焊丝种类
//        case 2:frame.push("126");frame.push("1");frame.push(num ===0?"0":"4");
//            if(flag)
//                makeNum();
//            break;
//            //机头放置侧
//        case 3:frame.push("122");frame.push("1");frame.push(String(num));
//            break;
//            //焊丝直径
//        case 4:frame.push("123");frame.push("1");frame.push(num ===0?"4":"6");
//            if(flag)
//                makeNum();
//            break;
//            //保护气体
//        case 5:frame.push("124");frame.push("1");frame.push(String(num ));
//            if(flag)
//                makeNum();
//            break;
//            //往返动作
//        case 6:frame.push("125");frame.push("1");frame.push(String(num ));break;
//            //电源特性
//        case 7:frame.push("119");frame.push("1");frame.push(String(num ));
//            if(flag)
//                makeNum();
//            break;
//            //电弧跟踪
//        case 8:frame.push("127");frame.push("1");frame.push(String(num));break;
//            //预期余高
//        case 9:
//            break;
//            //溶敷系数
//        case 10:
//            break;
//            //焊接电流偏置
//        case 11:frame.push("128");frame.push("1");frame.push(String(num));break;
//            //焊接电压偏置
//        case 12:frame.push("129");frame.push("1");frame.push(String(num*10));break;
//            //提前送气时间
//        case 13:frame.push("132");frame.push("1");frame.push(String(num*10));break;
//            //滞后送气时间
//        case 14:frame.push("133");frame.push("1");frame.push(String(num*10));break;
//            //起弧停留时间
//        case 15:frame.push("134");frame.push("1");frame.push(String(num*10));break;
//            //收弧停留时间
//        case 16:frame.push("135");frame.push("1");frame.push(String(num*10));break;
//            //起弧电流
//        case 17:frame.push("136");frame.push("1");frame.push(String(num));break;
//            //起弧电压
//        case 18:frame.push("137");frame.push("1");frame.push(String(num*10));break;
//            //收弧电流
//        case 19:frame.push("138");frame.push("1");frame.push(String(num));break;
//            //收弧电压
//        case 20:frame.push("139");frame.push("1");frame.push(String(num*10));break;
//            //收弧回退距离
//        case 21:frame.push("303");frame.push("1");frame.push(String(num*10));break;
//            //收弧回退速度
//        case 22:frame.push("304");frame.push("1");frame.push(String(num*10));break;
//            //收弧回退时间
//        case 23:frame.push("305");frame.push("1");frame.push(String(num*10));break;
//            //回烧电压补偿
//        case 24:frame.push("300");frame.push("1");frame.push(String(num));break;
//            //回烧时间补偿1
//        case 25:frame.push("301");frame.push("1");frame.push(String(num));break;
//            //回烧时间补偿2
//        case 26:frame.push("302");frame.push("1");frame.push(String(num));break;
//        default:frame.length=0;break;
//        }
//        if(frame.length===4){
//            //下发规范
//            ERModbus.setmodbusFrame(frame)
//        }
//        if(flag){
//            //存储数据
//            Material.UserData.setValueFromFuncOfTable(root.objectName,index,num)
//        }
//        //清空
//        frame.length=0;
//    }
//    //按键释放阶段写入或下发参数
//    Keys.onReleased: {
//        if((event.key===Qt.Key_Left)||(event.key===Qt.Key_Right)){
//            changeGroup(root.condition[selectedIndex],event.isAutoRepeat);
//        }else if((event.key===Qt.Key_VolumeDown)||(event.key===Qt.Key_VolumeUp)){
//            changeText(root.condition[selectedIndex],event.isAutoRepeat);
//        }
//        event.accpet=true;
//    }
//    Keys.onPressed: {
//        var temp;
//        var num=Number(root.condition[selectedIndex]);
//        if(event.key===Qt.Key_Down){
//            if(selectedIndex<(listName.length-1)){
//                selectedIndex++;
//            }
//        }else if(event.key===Qt.Key_Up){
//            if(selectedIndex>0){
//                selectedIndex--;
//            }
//        }else if(event.key===Qt.Key_Left){
//            if((num>0)&&(selectedIndex<listValueName.length)){
//                num-=1;
//                changeGroup(num,true);
//            }
//        }else if(event.key===Qt.Key_Right){
//            if((num<(listValueName[selectedIndex].length-1))&&(selectedIndex<listValueName.length)){
//                num+=1;
//                changeGroup(num,true);
//            }
//        }else if(event.key===Qt.Key_VolumeDown){
//            temp=selectedIndex-listValueName.length;
//            switch(temp){
//                //余高层
//            case 0:num-=1; if(num<-3)num=-3;break;
//                //溶敷系数
//            case 1:num-=1; if(num<50)num=50;break;
//                //电流偏置
//            case 2:num-=1; if(num<-100)num=-100;break;
//                //电压偏置
//            case 3:num-=0.1;num=num.toFixed(1); if(num<-10)num=-10;break;
//                //提前送气时间
//            case 4:
//                //滞后送气时间
//            case 5:
//                //起弧停留时间
//            case 6:
//                //收弧停留时间
//            case 7:num-=0.1;num=num.toFixed(1); if(num<0)num=0;break;
//                //起弧电流
//            case 8:num-=1; if(num<0)num=0;break;
//                //起弧电压
//            case 9:num-=0.1;num=num.toFixed(1); if(num<0)num=0;break;
//                //收弧电流
//            case 10:num-=1; if(num<0)num=0;break;
//                //收弧电压
//            case 11:num-=0.1;num=num.toFixed(1); if(num<0)num=0;break;
//                //收弧回退距离
//            case 12:num-=1; if(num<0)num=0;break;
//                //收弧回退速度
//            case 13:num-=0.1;num=num.toFixed(1);if(num<0)num=0;break;
//                //收弧回退时间
//            case 14:num-=0.1;num=num.toFixed(1); if(num<0)num=0;break;
//                //回烧电压补偿
//            case 15:
//                //回烧时间补偿
//            case 16:
//                //回烧时间补偿
//            case 17:num-=1; if(num<-50)num=-50;break;
//            }
//            if(temp>=0){
//                //变更显示但是不变更数据
//                changeText(num,true);
//            }
//        }else if(event.key===Qt.Key_VolumeUp){
//            temp=selectedIndex-listValueName.length;
//            switch(temp){
//                //余高层
//            case 0:num+=1; if(num>3)num=3;break;
//                //溶敷系数
//            case 1:num+=1; if(num>150)num=150;break;
//                //电流偏置
//            case 2:num+=1; if(num>100)num=100;break;
//                //电压偏置
//            case 3:num+=0.1; num=num.toFixed(1);if(num>10)num=10;break;
//                //提前送气时间
//            case 4:
//                //滞后送气时间
//            case 5:
//                //起弧停留时间
//            case 6:
//                //收弧停留时间
//            case 7:num+=0.1; num=num.toFixed(1);if(num>5)num=5;break;
//                //起弧电流
//            case 8:num+=1; if(num>300)num=300;break;
//                //起弧电压
//            case 9:num+=0.1; num=num.toFixed(1);if(num>30)num=30;break;
//                //收弧电流
//            case 10:num+=1; if(num>300)num=300;break;
//                //收弧电压
//            case 11:num+=0.1;num=num.toFixed(1); if(num>30)num=30;break;
//                //收弧回退距离
//            case 12:num+=1; if(num>30)num=30;break;
//                //收弧回退速度
//            case 13:num+=0.1;num=num.toFixed(1);if(num>30)num=30;break;
//                //收弧回退时间
//            case 14:num+=0.1;num=num.toFixed(1);if(num>3)num=3;break;
//                //回烧电压补偿
//            case 15:
//                //回烧时间补偿
//            case 16:
//                //回烧时间补偿
//            case 17:num+=1;if(num>50)num=50;break;
//            }
//            if(temp>=0){
//                //变更显示但是不变更数据
//                changeText(num,true);
//            }
//        }
//        event.accpet=true;
//    }
//    //滚屏
//    onSelectedIndexChanged: {
//        switch(selectedIndex){
//        case 0:flickable.contentY=0;break;
//        case 6:flickable.contentY=0;break;
//        case 7:flickable.contentY=Material.Units.dp(44)*7;break;
//        case 13:flickable.contentY=Material.Units.dp(44)*7;break;
//        case 14:flickable.contentY=Material.Units.dp(44)*14;break;
//        case 20:flickable.contentY=Material.Units.dp(44)*14;break;
//        case 21:flickable.contentY=Material.Units.dp(44)*21;break;
//        }
//    }
//    Material.Card{
//        anchors{ left:parent.left;right:parent.right;top:parent.top;bottom: descriptionCard.top;margins:Material.Units.dp(12)}
//        elevation: 2
//        Material.Label{
//            id:title
//            anchors.left: parent.left
//            anchors.leftMargin: Material.Units.dp(24)
//            height: Material.Units.dp(64)
//            verticalAlignment:Text.AlignVCenter
//            text:qsTr("焊接条件");
//            style:"subheading"
//            color: Material.Theme.light.shade(0.87)
//        }
//        Flickable{
//            id:flickable
//            anchors{top:title.bottom;left:parent.left;right:parent.right;bottom:parent.bottom}
//            interactive: false
//            clip: true
//            contentHeight: column.height
//            Behavior on contentY{NumberAnimation { duration: 200 }}
//            Column{
//                id:column
//                anchors{ left:parent.left;right:parent.right;top:parent.top}
//                Repeater{
//                    model: listValueName.length
//                    delegate:ListItem.Subtitled{
//                        id:sub
//                        property int subIndex:index
//                        text:listName[index]
//                        height: Material.Units.dp(44)
//                        selected: selectedIndex===index
//                        onPressed: changeSelectedIndex(index)
//                        Connections{
//                            target: root
//                            onChangeGroupCurrent:{
//                                if(sub.selected)
//                                    group.current=re.itemAt(index);
//                            }
//                        }
//                        secondaryItem:Row{
//                            anchors.verticalCenter: parent.verticalCenter
//                            QuickControls.ExclusiveGroup {id:group }
//                            Repeater{
//                                id:re
//                                model:sub.subIndex<listValueName.length?listValueName[sub.subIndex]:listName.length
//                                delegate:Material.RadioButton{
//                                    canToggle: false
//                                    text:modelData
//                                    checked:index===root.condition[sub.subIndex]
//                                    onClicked:{
//                                        //改变选择行
//                                        changeSelectedIndex(sub.subIndex);
//                                        //改变选择控件状态
//                                        changeGroup(index,true);
//                                    }
//                                    exclusiveGroup: group
//                                }
//                            }
//                        }
//                    }
//                }
//                Repeater{
//                    model:listName.length-listValueName.length
//                    delegate:ListItem.Subtitled{
//                        id:downSub
//                        property int num: listValueName.length+index
//                        text:listName[num]
//                        height: Material.Units.dp(44)
//                        selected: selectedIndex===num
//                        onPressed: changeSelectedIndex(num)
//                        Connections{
//                            target: root
//                            onChangeText:{
//                                if(downSub.selected){
//                                    valueLabel.text=String(value);
//                                }
//                            }
//                        }
//                        secondaryItem:Row{
//                            spacing: Material.Units.dp(16)
//                            anchors.verticalCenter: parent.verticalCenter
//                            Material.Label{id:valueLabel;
//                                text:String(root.condition[downSub.num]);
//                            }
//                            Material.Label{ text:valueType[index] }
//                        }
//                    }
//                }
//            }
//        }
//        Material.Scrollbar {id:scrollbar;flickableItem:flickable ;
//            onMovingChanged: {scrollbar.hide.stop();scrollbar.show.start();}
//            Component.onCompleted:{scrollbar.hide.stop();scrollbar.show.start();}
//        }
//    }
//    Material.Card{
//        id:descriptionCard
//        anchors{
//            left:parent.left
//            right:parent.right
//            bottom: parent.bottom
//            margins: Material.Units.dp(12)
//        }
//        elevation: 2
//        height:Material.Units.dp(110);
//        Column{
//            anchors.fill: parent
//            Material.Label{
//                id:descriptiontitle
//                anchors.left: parent.left
//                anchors.leftMargin: Material.Units.dp(24)
//                height: Material.Units.dp(64)
//                verticalAlignment:Text.AlignVCenter
//                text:qsTr("描述信息");
//                style:"subheading"
//                color: Material.Theme.light.shade(0.87)
//            }
//            Material.Label{
//                id:descriptionlabel
//                anchors.left: parent.left
//                anchors.leftMargin: Material.Units.dp(48)
//                text:selectedIndex<listDescription.length?listDescription[selectedIndex]:""
//            }
//        }
//    }
//    Component.onCompleted: {
//        condition=Material.UserData.getValueFromFuncOfTable("WeldCondition","","");
//        for(var i=0;i<listName.length;i++){
//            doWork(i,false);
//        }
//        //变更限制条件
//        makeNum();
//    }
//}
