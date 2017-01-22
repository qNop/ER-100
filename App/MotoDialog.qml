import QtQuick 2.0
import Material 0.1 as Material
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.4
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0

Material.Dialog{
    id:moto
    title: "机头相关设定"
    objectName: "motoDialog"
    property var send:[[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]]
    property var okName: ["设定     ","解除     ","启动     ","打开     "]
    property var noName: ["未设定 ","异常     ","停止     ","关闭     "]
    property int selectedMoto: 0
    property int oldSelectedIndex: 0
    property int selectedIndex: 0
    property int errorCode: 0
    negativeButtonText:qsTr("取消");
    positiveButtonText: qsTr("完成");
    signal changeSelectedMoto(int index);
    signal  changeSelectedIndex(int index);
    signal changeModbus(int index,var value);
    signal  changeValue(int value,int index)
    onChangeSelectedIndex: {
        moto.selectedIndex=index;
    }
    onChangeSelectedMoto: {
        selectedMoto=index;
        if(moto.selectedIndex<4)
            moto.oldSelectedIndex=moto.selectedIndex;
        moto.selectedIndex=5+moto.selectedMoto;
        moto.changeValue(moto.send[moto.selectedMoto][0],0)
        moto.changeValue(moto.send[moto.selectedMoto][1],1)
        moto.changeValue(moto.send[moto.selectedMoto][2],2)
        moto.changeValue(moto.send[moto.selectedMoto][3],3)
        moto.changeValue(moto.send[moto.selectedMoto][4],4)
        group.current=motoRepeater.itemAt(index).item
    }
    onChangeValue: {
        moto.send[moto.selectedMoto][index]=value;
    }
    onOpened:{
        moto.oldSelectedIndex=0;
        for(var i=0;i<4;i++){
            for(var j=0;j<5;j++){
                if(j<3)
                    send[i][j]=0;
                else if(j===3){
                    send[i][j]=i===0?AppConfig.swingMoto:i===1?AppConfig.zMoto:i===2?AppConfig.yMoto:AppConfig.xMoto;
                }
                else if(j===4){
                    send[i][j]=i===0?AppConfig.swingSpeed:i===1?AppConfig.zSpeed:i===2?AppConfig.ySpeed:AppConfig.xSpeed;
                }
            }
        }
        moto.changeSelectedMoto(0);
    }
    onAccepted:{
        //下发数据
        var res=new Array(20);
        res[0]=String(moto.send[0][4])
        res[1]=String(moto.send[1][4])
        res[2]=String(moto.send[2][4])
        res[3]=String(moto.send[3][4])

        res[4]=String(moto.send[0][0])
        res[5]=String(moto.send[1][0])
        res[6]=String(moto.send[2][0])
        res[7]=String(moto.send[3][0])

        res[8]=String(moto.send[0][1])
        res[9]=String(moto.send[1][1])
        res[10]=String(moto.send[2][1])
        res[11]=String(moto.send[3][1])

        res[12]=String(moto.send[0][2])
        res[13]=String(moto.send[1][2])
        res[14]=String(moto.send[2][2])
        res[15]=String(moto.send[3][2])

        res[16]=String(moto.send[0][3])
        res[17]=String(moto.send[1][3])
        res[18]=String(moto.send[2][3])
        res[19]=String(moto.send[3][3])

        ERModbus.setmodbusFrame(["W","26","20"].concat(res));
        //同时也保存数据
        AppConfig.setSwingSpeed(Number(send[0][4]));
        AppConfig.setZSpeed(Number(send[1][4]));
        AppConfig.setYSpeed(Number(send[2][4]));
        AppConfig.setXSpeed(Number(send[3][4]));

        AppConfig.setSwingMoto(Number(send[0][3]));
        AppConfig.setZMoto(Number(send[1][3]));
        AppConfig.setYMoto(Number(send[2][3]));
        AppConfig.setXMoto(Number(send[3][3]));

    }
    Keys.onPressed: {
        if((event.key===Qt.Key_F6)&&(moto.showing)){
            moto.close();
            event.accpet=true;
        }else if(event.key===Qt.Key_Up){
            if(moto.selectedIndex>4){
                if(moto.selectedMoto>0){
                    moto.selectedMoto--;
                    moto.selectedIndex--;
                    moto.changeSelectedMoto(moto.selectedMoto);
                }
            }else if(moto.selectedIndex>0)
                moto.selectedIndex--;
            event.accpet=true;
        }else if(event.key===Qt.Key_Down){
            if(moto.selectedIndex<4)
                moto.selectedIndex++;
            else if(moto.selectedIndex===4){

            }
            else if(moto.selectedIndex<9){
                if(moto.selectedMoto<3){
                    moto.selectedMoto++;
                    moto.selectedIndex++;
                    moto.changeSelectedMoto(moto.selectedMoto);
                }
            }
            event.accpet=true;
        }else if(event.key===Qt.Key_Left){
            if(moto.selectedIndex<5){
                moto.oldSelectedIndex=moto.selectedIndex;
                moto.selectedIndex=5+moto.selectedMoto;
            }
            event.accpet=true;
        }else if(event.key===Qt.Key_Right){
            if(moto.selectedIndex>4){
                moto.selectedIndex=moto.oldSelectedIndex;
                moto.oldSelectedIndex=0;
            }
            event.accpet=true;
        }else if(event.key===Qt.Key_VolumeUp){
            if(moto.selectedIndex<5){
                var num=moto.send[moto.selectedMoto][moto.selectedIndex];
                if(moto.selectedIndex<4)
                    if(num) num=0;
                    else num=1;
                else
                    if(num<400)
                        num+=10;
                moto.changeValue(num,moto.selectedIndex)
            }
            event.accpet=true;
        }else if(event.key===Qt.Key_VolumeDown){
            if(moto.selectedIndex<5){
                num=moto.send[moto.selectedMoto][moto.selectedIndex];
                if(moto.selectedIndex<4)
                    if(num) num=0;
                    else num=1;
                else
                    if(num>0)
                        num-=10;
                moto.changeValue(num,moto.selectedIndex)
            }
            event.accpet=true;
        }else if(event.key===Qt.Key_Plus){
            if(moto.selectedIndex<5){
                num=moto.send[moto.selectedMoto][moto.selectedIndex];
                if(moto.selectedIndex<4)
                    if(num) num=0;
                    else num=1;
                else
                    if(num<400)
                        num+=10;
                moto.changeValue(num,moto.selectedIndex)
            }
            event.accpet=true;
        }else if(event.key===Qt.Key_Minus){
            if(moto.selectedIndex<5){
                num=moto.send[moto.selectedMoto][moto.selectedIndex];
                if(moto.selectedIndex<4)
                    if(num) num=0;
                    else num=1;
                else
                    if(num>0)
                        num-=10;
                moto.changeValue(num,moto.selectedIndex)
            }
            event.accpet=true;
        }
    }
    ExclusiveGroup {id:group }
    Row{
        spacing: Material.Units.dp(8)
        Column{
            width: Material.Units.dp(140)
            Repeater{
                id:motoRepeater
                model:["摇动电机","摆动电机","上下电机","行走电机"]
                delegate:Item{
                    property alias item: radio
                    width:parent.width
                    height: radio.height
                    Rectangle {
                        id: rect
                        anchors.fill: parent
                        color:index===moto.selectedIndex-5?Material.Palette.colors["grey"]["400"] : "white"
                    }
                    Material.RadioButton{
                        id:radio
                        height: Material.Units.dp(32)
                        text:modelData
                        checked:index===moto.selectedMoto;
                        onClicked:moto.changeSelectedMoto(index);
                        exclusiveGroup: group
                    }
                }
            }
        }
        Rectangle{
            height: column.height
            width: 1
            color: Qt.rgba(0,0,0,0.2)
        }
        Column{
            id:column
            width: Material.Units.dp(250)
            Repeater{
                model:["原点设定:","异常解除:","原点搜索:","电机保护:"]
                delegate:ListItem.Subtitled{
                    id:sub
                    height: Material.Units.dp(32)
                    text:modelData
                    selected: index===moto.selectedIndex
                    onPressed: moto.changeSelectedIndex(index)
                    property int subIndex: index
                    Connections{
                        target: moto
                        onChangeValue:{
                            if((typeof(value)==="number")&&(index===sub.subIndex)){
                                checkeBox.checked=value?true:false;
                            }
                        }
                    }
                    secondaryItem: Material.CheckBox{
                        id:checkeBox
                        anchors.verticalCenter: parent.verticalCenter
                        text:checked?moto.okName[sub.subIndex]:moto.noName[sub.subIndex]
                        enabled: sub.subIndex===1?moto.selectedMoto===0?
                                                       errorCode&0x00000080?true:false:moto.selectedMoto===1?
                                                                                 errorCode&0x00001000?true:false:moto.selectedMoto===2?
                                                                                                           errorCode&0x00020000?true:false:errorCode&0x00400000?true:false:true
                        onCheckedChanged: {
                            if(moto.selectedIndex<4)
                                moto.changeSelectedIndex(sub.subIndex);
                            moto.changeValue(checked?1:0,sub.subIndex);
                        }
                    }
                }
            }
            ListItem.Subtitled{
                id:subSpeed
                text:"微动速度:"
                height: Material.Units.dp(32)
                selected: 4===moto.selectedIndex
                onPressed: moto.changeSelectedIndex(4)
                property int speed :0
                Connections{
                    target: moto
                    onChangeValue:{
                        if((typeof(value)==="number")&&(index===4)){
                            lab.text=value/10;
                        }
                    }
                }
                secondaryItem:Row{
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Material.Units.dp(12)
                    Material.Label{id:lab;text: String(moto.send[moto.selectedMoto][4]/10)}
                    Material.Label{text:"cm/min"}
                }
            }
        }
    }
}