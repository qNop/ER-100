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

FocusScope {
    id:root
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "WeldCondition"
    anchors.fill: parent

    property var swingWayModel: ["无","左方","右方","左右"];
    property var robotLayoutModel:["坡口侧","非坡口侧"]
    property var returnWayModel: ["单程","往返"];
    property var weldWireModel: ["实芯碳钢","药芯碳钢"]
    property var weldWireDiameterModel: ["1.2mm","1.6mm"]
    property var weldWireLengthModel: ["10mm","15mm","20mm","25mm"]
    property var weldGasModel: ["CO2","MAG"]

    property var condition: [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

    Component.onCompleted: {
        Material.UserData.openDatabase();
        condition=Material.UserData.getValueFromFuncOfTable(root.objectName,"","")
    }
    onVisibleChanged: {
        if(visible){
            //界面可见以后打开数据库
            Material.UserData.openDatabase();
        }
    }
    QuickControls.ExclusiveGroup { id: weldWireLengthGroup; onCurrentChanged:
            //10mm 1 12mm 2 15mm 3 20mm 4 25mm 6
            ERModbus.setmodbusFrame(["W","120","1",current.text ==="10mm"?"1":current.text==="15mm"?"3":current.text==="20mm"?"4":"6"]) }
    QuickControls.ExclusiveGroup { id: swingWayGroup; onCurrentChanged:
            ERModbus.setmodbusFrame(["W","121","1",current.text ==="无"?"0":current.text==="左方"?"1":current.text==="右方"?"2":"3"]) }
    QuickControls.ExclusiveGroup { id: robotLayoutGroup; onCurrentChanged:
            ERModbus.setmodbusFrame(["W","122","1",current.text ==="坡口侧"?"0":"1"]) }
    QuickControls.ExclusiveGroup { id: weldWireDiameterGroup; onCurrentChanged:{
            //1.2mm 4 1.6mm 6
            ERModbus.setmodbusFrame(["W","123","1",current.text ==="1.2mm"?"4":"6"])
            WeldMath.setWireD(current.text ==="1.2mm"?4:6)
        } }
    QuickControls.ExclusiveGroup { id: weldGasGroup;onCurrentChanged:{
            ERModbus.setmodbusFrame(["W","124","1",current.text ==="CO2"?"0":"1"])
            WeldMath.setGas(current.text==="CO2"?0:1);
        }}
    QuickControls.ExclusiveGroup { id: returnWayGroup; onCurrentChanged:
            ERModbus.setmodbusFrame(["W","125","1",current.text ==="单程"?"0":"1"]) }
    QuickControls.ExclusiveGroup { id: weldWireGroup; onCurrentChanged:{
            //0 实芯碳钢 4药芯碳钢
            ERModbus.setmodbusFrame(["W","126","1",current.text ==="实芯碳钢"?"0":"4"])
            WeldMath.setWireType(current.text ==="实芯碳钢"?0:4);
        }}
    Material.Card{
        anchors{ left:parent.left;right:parent.right;top:parent.top;bottom: descriptionCard.top;margins:Material.Units.dp(12)}
        elevation: 2
        Material.Label{
            id:title
            anchors.left: parent.left
            anchors.leftMargin: Material.Units.dp(24)
            height: Material.Units.dp(64)
            verticalAlignment:Text.AlignVCenter
            text:qsTr("焊接条件");
            style:"subheading"
            color: Material.Theme.light.shade(0.87)
        }
        Flickable{
            id:flickable
            anchors{top:title.bottom;left:parent.left;right:parent.right;bottom:parent.bottom}
            interactive: false
            clip: true
            contentHeight: column.height
            Behavior on contentY{NumberAnimation { duration: 200 }}
            Column{
                id:column
                anchors{ left:parent.left;right:parent.right;top:parent.top}
                /*焊丝伸出长度*/
                ListItem.Subtitled{
                    id:weldWireLength
                    text:qsTr("焊丝伸出长度:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    selected: focus;
                    KeyNavigation.down: swingWay
                    Keys.onPressed: {
                        switch(event.key){
                        case Qt.Key_Right:
                            switch(weldWireLengthGroup.current.text){
                            case "10mm": weldWireLengthGroup.current = weldWireLengthRepeater.itemAt(1);
                                Material.UserData.setValueFromFuncOfTable(root.objectName,0,3);
                                break;
                            case "15mm":weldWireLengthGroup.current = weldWireLengthRepeater.itemAt(2);
                                Material.UserData.setValueFromFuncOfTable(root.objectName,0,4);
                                break;
                            case "20mm":weldWireLengthGroup.current = weldWireLengthRepeater.itemAt(3);
                                Material.UserData.setValueFromFuncOfTable(root.objectName,0,6);
                                break;
                            }
                            event.accepted = true;
                            break;
                        case Qt.Key_Left:
                            switch(weldWireLengthGroup.current.text){
                            case "25mm": weldWireLengthGroup.current = weldWireLengthRepeater.itemAt(2);
                                Material.UserData.setValueFromFuncOfTable(root.objectName,0,4);
                                break;
                            case "20mm":weldWireLengthGroup.current = weldWireLengthRepeater.itemAt(1);
                                Material.UserData.setValueFromFuncOfTable(root.objectName,0,3);
                                break;
                            case "15mm":weldWireLengthGroup.current = weldWireLengthRepeater.itemAt(0);
                                Material.UserData.setValueFromFuncOfTable(root.objectName,0,1);
                                break;
                            }
                            event.accepted = true;
                            break;
                        }
                    }
                    onClicked:forceActiveFocus();
                    onSelectedChanged: selected? descriptionlabel.text="设定焊丝端部到导电嘴的长度。" :null;
                    secondaryItem:Row{
                        anchors.verticalCenter: parent.verticalCenter
                        Repeater{
                            id:weldWireLengthRepeater
                            model:weldWireLengthModel
                            delegate:Material.RadioButton{
                                text:modelData
                                onClicked:{
                                    Material.UserData.setValueFromFuncOfTable(root.objectName,0,index===0?1:index===1?3:index===2?4:6);
                                    weldWireLength.forceActiveFocus()}
                                      checked: (index===0)&&(Number(root.condition[0])===1)?true:
                                                                                       (index===1)&&(Number(root.condition[0])===3)?true:
                                                                                                                                     (index===2)&&(Number(root.condition[0])===4)?true:
                                                                                                                                                                                   (index===3)&&(Number(root.condition[0])===6)?true:false
                                exclusiveGroup: weldWireLengthGroup
                            }
                        }
                    }
                    Component.onCompleted: {forceActiveFocus();}
                }
                /*头部摆动方式*/
                ListItem.Subtitled{
                    id:swingWay
                    text:qsTr("头部摆动方式:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    selected: focus;
                    KeyNavigation.up: weldWireLength
                    KeyNavigation.down:weldWire
                    Keys.onPressed: {
                        switch(event.key){
                        case Qt.Key_Right:
                            switch(swingWayGroup.current.text){
                            case "无": swingWayGroup.current = swingWayRepeater.itemAt(1);
                                Material.UserData.setValueFromFuncOfTable(root.objectName,1,1);
                                break;
                            case "左方": swingWayGroup.current = swingWayRepeater.itemAt(2);
                                Material.UserData.setValueFromFuncOfTable(root.objectName,1,2);
                                break;
                            case "右方": swingWayGroup.current = swingWayRepeater.itemAt(3);
                                Material.UserData.setValueFromFuncOfTable(root.objectName,1,3);
                                break;
                            }
                            event.accepted = true;
                            break;
                        case Qt.Key_Left:
                            switch(swingWayGroup.current.text){
                            case "左右": swingWayGroup.current = swingWayRepeater.itemAt(2);
                                Material.UserData.setValueFromFuncOfTable(root.objectName,1,2);
                                break;
                            case "右方": swingWayGroup.current = swingWayRepeater.itemAt(1);
                                Material.UserData.setValueFromFuncOfTable(root.objectName,1,1);
                                break;
                            case "左方": swingWayGroup.current = swingWayRepeater.itemAt(0);
                                Material.UserData.setValueFromFuncOfTable(root.objectName,1,0);
                                break;}
                            event.accepted = true;
                            break;}}
                    onClicked:forceActiveFocus();
                    onSelectedChanged: {
                        if(selected){descriptionlabel.text="选择在端部是否摆动。"; if(swingWay.y<flickable.contentY) flickable.contentY=0;}}
                    secondaryItem:Row{
                        anchors.verticalCenter: parent.verticalCenter
                        Repeater{
                            id:swingWayRepeater
                            model:swingWayModel
                            delegate:Material.RadioButton{
                                text:modelData
                                exclusiveGroup: swingWayGroup
                                checked: root.condition[1]===index;
                                onClicked: {
                                    Material.UserData.setValueFromFuncOfTable(root.objectName,1,index);
                                    swingWay.forceActiveFocus()}
                            }
                        }
                    }
                }
                /*焊丝种类*/
                ListItem.Subtitled{
                    id:weldWire
                    text:qsTr("焊丝种类:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    selected: focus;
                    KeyNavigation.up: swingWay
                    KeyNavigation.down: robotLayout
                    Keys.onPressed: {
                        switch(event.key){
                        case Qt.Key_Right:
                            if(weldWireGroup.current.text==="实芯碳钢" ){
                                weldWireGroup.current = weldWireRepeater.itemAt(1);
                                Material.UserData.setValueFromFuncOfTable(root.objectName,6,4);
                            }
                            event.accepted = true;
                            break;
                        case Qt.Key_Left:
                            if(weldWireGroup.current.text==="药芯碳钢" ){
                                weldWireGroup.current = weldWireRepeater.itemAt(0);
                                Material.UserData.setValueFromFuncOfTable(root.objectName,6,0);
                            }
                            event.accepted = true;
                            break;
                        }
                    }
                    onClicked:forceActiveFocus();
                    onSelectedChanged: selected?( descriptionlabel.text="设定焊丝种类实芯碳钢或药芯碳钢。" ):null;
                    secondaryItem:Row{
                        anchors.verticalCenter: parent.verticalCenter
                        Repeater{
                            id:weldWireRepeater
                            model:weldWireModel
                            delegate:Material.RadioButton{
                                text:modelData
                                onClicked:{
                                    Material.UserData.setValueFromFuncOfTable(root.objectName,6,index===1?4:0);
                                    weldWire.forceActiveFocus()}
                                exclusiveGroup: weldWireGroup
                                checked: root.condition[6]===index;
                            }
                        }
                    }
                }
                /*机器人放置面*/
                ListItem.Subtitled{
                    id:robotLayout
                    text:qsTr("机器人放置面:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: weldWire
                    KeyNavigation.down: weldWireDiameter
                    onClicked:forceActiveFocus();
                    onSelectedChanged: selected? descriptionlabel.text="设定机器人相对于坡口的放置位置。" :null;
                    selected: focus;
                    Keys.onPressed: {
                        switch(event.key){
                        case Qt.Key_Right:
                            if(robotLayoutGroup.current.text==="坡口侧" ) {
                                Material.UserData.setValueFromFuncOfTable(root.objectName,2,1);
                                robotLayoutGroup.current = robotLayoutRepeater.itemAt(1);}
                            event.accepted = true;
                            break;
                        case Qt.Key_Left:
                            if(robotLayoutGroup.current.text==="非坡口侧" ){
                                Material.UserData.setValueFromFuncOfTable(root.objectName,2,0);
                                robotLayoutGroup.current = robotLayoutRepeater.itemAt(0);}
                            event.accepted = true;
                            break;} }
                    secondaryItem:Row{
                        anchors.verticalCenter: parent.verticalCenter
                        Repeater{
                            id:robotLayoutRepeater
                            model:robotLayoutModel
                            delegate:Material.RadioButton{
                                text:modelData
                                exclusiveGroup: robotLayoutGroup
                                checked: root.condition[2]===index;
                                onClicked: {
                                    Material.UserData.setValueFromFuncOfTable(root.objectName,2,index);
                                    robotLayout.forceActiveFocus()
                                }}}}
                }
                /*焊丝直径*/
                ListItem.Subtitled{
                    id:weldWireDiameter
                    text:qsTr("焊丝直径:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    selected: focus;
                    KeyNavigation.up: robotLayout
                    KeyNavigation.down: weldGas
                    Keys.onPressed: {
                        switch(event.key){
                        case Qt.Key_Right:
                            if(weldWireDiameterGroup.current.text==="1.2mm" ){
                                weldWireDiameterGroup.current = weldWireDiameterRepeater.itemAt(1);
                                Material.UserData.setValueFromFuncOfTable(root.objectName,3,6);
                            }
                            event.accepted = true;
                            break;
                        case Qt.Key_Left:
                            if(weldWireDiameterGroup.current.text==="1.6mm" ){
                                weldWireDiameterGroup.current = weldWireDiameterRepeater.itemAt(0);
                                Material.UserData.setValueFromFuncOfTable(root.objectName,3,4);
                            }
                            event.accepted = true;
                            break;
                        }
                    }
                    onClicked:forceActiveFocus();
                    onSelectedChanged: selected? descriptionlabel.text="设定焊丝的直径" :null;
                    secondaryItem:Row{
                        anchors.verticalCenter: parent.verticalCenter
                        Repeater{
                            id:weldWireDiameterRepeater
                            model:weldWireDiameterModel
                            delegate:Material.RadioButton{
                                text:modelData
                                exclusiveGroup: weldWireDiameterGroup
                                checked: root.condition[3]==index;
                                onClicked: {
                                    Material.UserData.setValueFromFuncOfTable(root.objectName,3,index===0?4:6);
                                    weldWireDiameter.forceActiveFocus()}
                            }
                        }
                    }
                }
                /*保护气体*/
                ListItem.Subtitled{
                    id:weldGas
                    text:qsTr("保护气体:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    selected: focus;
                    KeyNavigation.up: weldWireDiameter
                    KeyNavigation.down: returnWay
                    Keys.onPressed: {
                        switch(event.key){
                        case Qt.Key_Right:
                            if(weldGasGroup.current.text==="CO2" ){
                                weldGasGroup.current = weldGasRepeater.itemAt(1);
                                Material.UserData.setValueFromFuncOfTable(root.objectName,4,1);
                            }
                            event.accepted = true;
                            break;
                        case Qt.Key_Left:
                            if(weldGasGroup.current.text!=="CO2" ){
                                weldGasGroup.current = weldGasRepeater.itemAt(0);
                                Material.UserData.setValueFromFuncOfTable(root.objectName,4,0);
                            }
                            event.accepted = true;
                            break;
                        }
                    }
                    onClicked:forceActiveFocus();
                    onSelectedChanged: selected? descriptionlabel.text="设定焊接过程中使用保护气体。" :null;
                    secondaryItem:Row{
                        anchors.verticalCenter: parent.verticalCenter
                        Repeater{
                            id:weldGasRepeater
                            model:weldGasModel
                            delegate:Material.RadioButton{
                                text:modelData
                                onClicked: {
                                    Material.UserData.setValueFromFuncOfTable(root.objectName,4,index);
                                    weldGas.forceActiveFocus()}
                                exclusiveGroup: weldGasGroup
                                checked: root.condition[4]==index;
                            }
                        }
                    }
                }
                /*焊接往返动作*/
                ListItem.Subtitled{
                    id:returnWay
                    text:qsTr("焊接往返动作:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    selected: focus;
                    KeyNavigation.up: weldGas
                    KeyNavigation.down: arcTracking
                    Keys.onPressed: {
                        switch(event.key){
                        case Qt.Key_Right:
                            if(returnWayGroup.current.text==="单程" ) {
                                Material.UserData.setValueFromFuncOfTable(root.objectName,5,1);
                                returnWayGroup.current = returnWayRepeater.itemAt(1);
                            }
                            event.accepted = true;
                            break;
                        case Qt.Key_Left:
                            if(returnWayGroup.current.text==="往返" ) {
                                Material.UserData.setValueFromFuncOfTable(root.objectName,5,0);
                                returnWayGroup.current = returnWayRepeater.itemAt(0);
                            }
                            event.accepted = true;
                            break;
                        }
                    }
                    onClicked:forceActiveFocus();
                    onSelectedChanged: {if(selected){
                                           descriptionlabel.text="设定焊接方向为往返方向或单程方向。" ;
                                           flickable.contentY=0;
                                       }}
                    secondaryItem:Row{
                        anchors.verticalCenter: parent.verticalCenter
                        Repeater{
                            id:returnWayRepeater
                            model:returnWayModel
                            delegate:Material.RadioButton{
                                text:modelData
                                onClicked: {
                                    Material.UserData.setValueFromFuncOfTable(root.objectName,5,index);
                                    returnWay.forceActiveFocus()}
                                exclusiveGroup: returnWayGroup
                                checked: root.condition[5]==index;
                            }
                        }
                    }
                }
                /*电弧传感*/
                ListItem.Subtitled{
                    id:arcTracking
                    text:qsTr("电弧跟踪:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: returnWay
                    KeyNavigation.down: reinforcement
                    selected: focus;
                    onSelectedChanged:{if(selected){
                            descriptionlabel.text="设定电弧跟踪是否开启。" ;
                            flickable.contentY=height*7
                        }}
                    onClicked:forceActiveFocus();
                    Keys.onPressed: {
                        switch(event.key){
                        case Qt.Key_Right:
                            arcTrackingSwitch.checked=true;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,7,1);
                            event.accepted = true;
                            break;
                        case Qt.Key_Left:
                            arcTrackingSwitch.checked=false;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,7,0);
                            event.accepted = true;
                            break;
                        }
                    }
                    secondaryItem:Row{
                        spacing: Material.Units.dp(16)
                        anchors.verticalCenter: parent.verticalCenter
                        Material.Switch{
                            id:arcTrackingSwitch
                            checked: Number(root.condition[7])===1?true:0;
                            onClicked: {
                                arcTracking.forceActiveFocus()
                                Material.UserData.setValueFromFuncOfTable(root.objectName,7,checked);
                            }
                            onCheckedChanged: ERModbus.setmodbusFrame(["W","127","1",checked?"1":"0"])
                        }
                        Material.Label{
                            text:arcTrackingSwitch.checked?"打开":"关闭"
                        }
                    }
                }
                /*余高*/
                ListItem.Subtitled{
                    id:reinforcement
                    text:qsTr("预期余高:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: arcTracking
                    KeyNavigation.down: solubility
                    selected: focus;
                    onSelectedChanged:selected? descriptionlabel.text="设定焊接预期板面焊道堆起高度。" :null;
                    onClicked:forceActiveFocus();
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res=Number(reinforcementLabel.text)+1;
                            if(res>3) res=3;
                            reinforcementLabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,8,res);
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            res=Number(reinforcementLabel.text)-1;
                            if(res<-3) res=-3;
                            reinforcementLabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,8,res);
                            event.accepted = true;
                            break;
                        }
                    }
                    secondaryItem:Row{
                        spacing: Material.Units.dp(16)
                        anchors.verticalCenter: parent.verticalCenter
                        Material.Label{
                            id:reinforcementLabel
                            text: root.condition[8];
                            onTextChanged: {WeldMath.setReinforcement(Number(text))}
                        }
                        Material.Label{ text:"mm" }
                    }
                }
                /*溶敷系数*/
                ListItem.Subtitled{
                    id:solubility
                    text:qsTr("溶敷系数:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: reinforcement
                    KeyNavigation.down: currentOffset
                    onSelectedChanged: selected? descriptionlabel.text="设定焊接过程中溶敷系数大小。" :null;
                    onClicked:forceActiveFocus();
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res=Number(solubilityglabel.text)+1;
                            if(res>150) res=150;
                            solubilityglabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,9,res);
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            if(res<50) res=50;
                            res=Number(solubilityglabel.text)-1;
                            solubilityglabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,9,res);
                            event.accepted = true;
                            break;
                        }
                    }
                    selected: focus
                    secondaryItem:Row{
                        spacing: Material.Units.dp(8)
                        anchors.verticalCenter: parent.verticalCenter
                        Material.Label{
                            id: solubilityglabel
                            text: Number(root.condition[9]);
                            onTextChanged:{WeldMath.setMeltingCoefficient(Number(solubilityglabel.text))}  ///ERModbus.setmodbusFrame(["W","129","1",text.toString()])
                        }
                        Material.Label{text:"%";}
                    }
                }
                /*焊接电流偏置*/
                ListItem.Subtitled{
                    id:currentOffset
                    text:qsTr("焊接电流偏置:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: solubility
                    KeyNavigation.down: voltageOffset
                    onSelectedChanged: selected? descriptionlabel.text="焊接条件所设定的电流和实际电流的微调整。":null;
                    onClicked:forceActiveFocus();
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res=Number(currentOffsetlabel.text)+1;
                            if(res>100) res=100;
                            currentOffsetlabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,10,res);
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            if(res<-100) res=-100;
                            res=Number(currentOffsetlabel.text)-1;
                            currentOffsetlabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,10,res);
                            event.accepted = true;
                            break;
                        }
                    }
                    selected: focus
                    secondaryItem:Row{
                        spacing: Material.Units.dp(8)
                        anchors.verticalCenter: parent.verticalCenter
                        Material.Label{
                            id: currentOffsetlabel
                            text:root.condition[10]
                            onTextChanged:  ERModbus.setmodbusFrame(["W","128","1",text.toString()])
                        }
                        Material.Label{text:"A";}
                    }
                }
                /*焊接电压偏置*/
                ListItem.Subtitled{
                    id:voltageOffset
                    text:qsTr("焊接电压偏置:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: currentOffset
                    KeyNavigation.down: AppConfig.currentUserType=="SuperUser"?preGasTime:null
                    onClicked:forceActiveFocus();
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res=Number(voltageOffsetlabel.text)+0.1;
                            if(res>10) res=10;
                             res=res.toFixed(1);
                            voltageOffsetlabel.text=res;

                            Material.UserData.setValueFromFuncOfTable(root.objectName,11,res);
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            res=Number(voltageOffsetlabel.text)-0.1;
                            if(res<-10) res=-10;
                             res=res.toFixed(1);
                            voltageOffsetlabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,11,res);
                            event.accepted = true;
                            break;
                        }
                    }
                    selected: focus
                    onSelectedChanged: { if(selected){
                            descriptionlabel.text="焊接条件所设定的电压和实际电压的微调整。";
                        }
                    }
                    secondaryItem:Row{
                        spacing: Material.Units.dp(8)
                        anchors.verticalCenter: parent.verticalCenter
                        Material.Label{
                            id: voltageOffsetlabel
                            text: root.condition[11]
                            onTextChanged:  ERModbus.setmodbusFrame(["W","129","1",(Number(voltageOffsetlabel.text)*10).toString()])
                        }
                        Material.Label{text:"V";}
                    }
                }
                /*提前送气时间*/
                ListItem.Subtitled{
                    id:preGasTime
                    text:qsTr("提前送气时间:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: voltageOffset
                    KeyNavigation.down: afterGasTime
                    onClicked:forceActiveFocus();
                    visible: AppConfig.currentUserType=="SuperUser"?true:false
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res=Number(preGasTimelabel.text)+0.1;
                            if(res>5) res=5;
                             res=res.toFixed(1);
                            preGasTimelabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,12,res);
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            res=Number(preGasTimelabel.text)-0.1;
                            if(res<0) res=0;
                            res=res.toFixed(1);
                            preGasTimelabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,12,res);
                            event.accepted = true;
                            break;
                        }
                    }
                    selected: focus
                    onSelectedChanged: { if(selected){
                            descriptionlabel.text=text;
                        }
                    }
                    secondaryItem:Row{
                        spacing: Material.Units.dp(8)
                        anchors.verticalCenter: parent.verticalCenter
                        Material.Label{
                            id: preGasTimelabel
                            text:root.condition[12]
                            onTextChanged:  ERModbus.setmodbusFrame(["W","132","1",(Number(preGasTimelabel.text)*10).toString()])
                        }
                        Material.Label{text:"S";}
                    }
                }
                /*滞后送气时间*/
                ListItem.Subtitled{
                    id:afterGasTime
                    text:qsTr("滞后送气时间:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: preGasTime
                    KeyNavigation.down: startArcTime
                    onClicked:forceActiveFocus();
                     visible: AppConfig.currentUserType=="SuperUser"?true:false
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res=Number(afterGasTimelabel.text)+0.1;
                            if(res>5) res=5;
                            res=res.toFixed(1);
                            afterGasTimelabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,13,res);
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            res=Number(afterGasTimelabel.text)-0.1;
                            if(res<0) res=0;
                            res=res.toFixed(1);
                            afterGasTimelabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,13,res);
                            event.accepted = true;
                            break;
                        }
                    }
                    selected: focus
                    onSelectedChanged: { if(selected){
                            descriptionlabel.text=text;
                            flickable.contentY=height*7
                        }
                    }
                    secondaryItem:Row{
                        spacing: Material.Units.dp(8)
                        anchors.verticalCenter: parent.verticalCenter
                        Material.Label{
                            id: afterGasTimelabel
                            text:root.condition[13]
                            onTextChanged:  ERModbus.setmodbusFrame(["W","133","1",(Number(text)*10).toString()])
                        }
                        Material.Label{text:"S";}
                    }
                }
                /*起弧停留时间*/
                ListItem.Subtitled{
                    id:startArcTime
                    text:qsTr("起弧停留时间:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: afterGasTime
                    KeyNavigation.down: endArcTime
                    onClicked:forceActiveFocus();
                     visible: AppConfig.currentUserType=="SuperUser"?true:false
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res=Number(startArcTimelabel.text)+0.1;
                            if(res>5) res=5;
                            res=res.toFixed(1);
                            startArcTimelabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,14,res);
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            res=Number(startArcTimelabel.text)-0.1;
                            if(res<0) res=0;
                            res=res.toFixed(1);
                            startArcTimelabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,14,res);
                            event.accepted = true;
                            break;
                        }
                    }
                    selected: focus
                    onSelectedChanged: { if(selected){
                            descriptionlabel.text=text;
                            flickable.contentY=height*7*2
                        }
                    }
                    secondaryItem:Row{
                        spacing: Material.Units.dp(8)
                        anchors.verticalCenter: parent.verticalCenter
                        Material.Label{
                            id: startArcTimelabel
                            text:root.condition[14]
                            onTextChanged:  ERModbus.setmodbusFrame(["W","134","1",(Number(text)*10).toString()])
                        }
                        Material.Label{text:"S";}
                    }
                }
                /*收弧停留时间*/
                ListItem.Subtitled{
                    id:endArcTime
                    text:qsTr("收弧停留时间:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: startArcTime
                    KeyNavigation.down: startArcCurrent
                    onClicked:forceActiveFocus();
                     visible: AppConfig.currentUserType=="SuperUser"?true:false
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res=Number(endArcTimelabel.text)+0.1;
                            if(res>5) res=5;
                            res=res.toFixed(1);
                            endArcTimelabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,15,res);
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            res=Number(endArcTimelabel.text)-0.1;
                            if(res<0) res=0;
                            res=res.toFixed(1);
                            endArcTimelabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,15,res);
                            event.accepted = true;
                            break;
                        }
                    }
                    selected: focus
                    onSelectedChanged: { if(selected){
                            descriptionlabel.text=text;
                        }
                    }
                    secondaryItem:Row{
                        spacing: Material.Units.dp(8)
                        anchors.verticalCenter: parent.verticalCenter
                        Material.Label{
                            id: endArcTimelabel
                            text:root.condition[15]
                            onTextChanged:  ERModbus.setmodbusFrame(["W","135","1",(Number(text)*10).toString()])
                        }
                        Material.Label{text:"S";}
                    }
                }
                /*起弧电流*/
                ListItem.Subtitled{
                    id:startArcCurrent
                    text:qsTr("起弧电流:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: endArcTime
                    KeyNavigation.down: startArcVolagte
                    onClicked:forceActiveFocus();
                     visible: AppConfig.currentUserType=="SuperUser"?true:false
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res=Number(startArcCurrentlabel.text)+1;
                            if(res>300) res=300;
                            startArcCurrentlabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,16,res);
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            res=Number(startArcCurrentlabel.text)-1;
                            if(res<0) res=0;
                            startArcCurrentlabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,16,res);
                            event.accepted = true;
                            break;
                        }
                    }
                    selected: focus
                    onSelectedChanged: { if(selected){
                            descriptionlabel.text=text;
                        }
                    }
                    secondaryItem:Row{
                        spacing: Material.Units.dp(8)
                        anchors.verticalCenter: parent.verticalCenter
                        Material.Label{
                            id: startArcCurrentlabel
                            text:root.condition[16]
                            onTextChanged:  ERModbus.setmodbusFrame(["W","136","1",text])
                        }
                        Material.Label{text:"A";}
                    }
                }
                /*起弧电压*/
                ListItem.Subtitled{
                    id:startArcVolagte
                    text:qsTr("起弧电压:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: startArcCurrent
                    KeyNavigation.down: endArcCurrent
                    onClicked:forceActiveFocus();
                     visible: AppConfig.currentUserType=="SuperUser"?true:false
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res=Number(startArcVolagtelabel.text)+0.1;
                            if(res>30) res=30;
                            res=res.toFixed(1);
                            startArcVolagtelabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,17,res);
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            res=Number(startArcVolagtelabel.text)-0.1;
                            if(res<0) res=0;
                            res=res.toFixed(1);
                            startArcVolagtelabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,17,res);
                            event.accepted = true;
                            break;
                        }
                    }
                    selected: focus
                    onSelectedChanged: { if(selected){
                            descriptionlabel.text=text;
                        }
                    }
                    secondaryItem:Row{
                        spacing: Material.Units.dp(8)
                        anchors.verticalCenter: parent.verticalCenter
                        Material.Label{
                            id: startArcVolagtelabel
                            text:root.condition[17]
                            onTextChanged:  ERModbus.setmodbusFrame(["W","137","1",(Number(text)*10).toString()])
                        }
                        Material.Label{text:"V";}
                    }
                }
                /*收弧电流*/
                ListItem.Subtitled{
                    id:endArcCurrent
                    text:qsTr("收弧电流:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: startArcVolagte
                    KeyNavigation.down: endArcVolagte
                    onClicked:forceActiveFocus();
                     visible: AppConfig.currentUserType=="SuperUser"?true:false
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res=Number(endArcCurrentlabel.text)+1;
                            if(res>300) res=300;
                            endArcCurrentlabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,18,res);
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            res=Number(endArcCurrentlabel.text)-1;
                            if(res<0) res=0;
                            endArcCurrentlabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,18,res);
                            event.accepted = true;
                            break;
                        }
                    }
                    selected: focus
                    onSelectedChanged: { if(selected){
                            descriptionlabel.text=text;
                        }
                    }
                    secondaryItem:Row{
                        spacing: Material.Units.dp(8)
                        anchors.verticalCenter: parent.verticalCenter
                        Material.Label{
                            id: endArcCurrentlabel
                            text:root.condition[18]
                            onTextChanged:  ERModbus.setmodbusFrame(["W","138","1",text])
                        }
                        Material.Label{text:"A";}
                    }
                }
                /*收弧电压*/
                ListItem.Subtitled{
                    id:endArcVolagte
                    text:qsTr("收弧电压:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: endArcCurrent

                    onClicked:forceActiveFocus();
                     visible: AppConfig.currentUserType=="SuperUser"?true:false
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res=Number(endArcVolagtelabel.text)+0.1;
                            if(res>30) res=30;
                            res=res.toFixed(1);
                            endArcVolagtelabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,19,res);
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            res=Number(endArcVolagtelabel.text)-0.1;
                            if(res<0) res=0;
                            res=res.toFixed(1);
                            endArcVolagtelabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,19,res);
                            event.accepted = true;
                            break;
                        }
                    }
                    selected: focus
                    onSelectedChanged: { if(selected){
                            descriptionlabel.text=text;
                        }
                    }
                    secondaryItem:Row{
                        spacing: Material.Units.dp(8)
                        anchors.verticalCenter: parent.verticalCenter
                        Material.Label{
                            id: endArcVolagtelabel
                            text:root.condition[19]
                            onTextChanged:  ERModbus.setmodbusFrame(["W","139","1",(Number(text)*10).toString()])
                        }
                        Material.Label{text:"V";}
                    }
                }

            }
        }
        Material.Scrollbar {id:scrollbar;flickableItem:flickable ;
            onMovingChanged: {scrollbar.hide.stop();scrollbar.show.start();}
            Component.onCompleted:{scrollbar.hide.stop();scrollbar.show.start();}
        }
    }
    Material.Card{
        id:descriptionCard
        anchors{
            left:parent.left
            right:parent.right
            bottom: parent.bottom
            margins: Material.Units.dp(12)
        }
        elevation: 2
        height:Material.Units.dp(110);
        Column{
            anchors.fill: parent
            Material.Label{
                id:descriptiontitle
                anchors.left: parent.left
                anchors.leftMargin: Material.Units.dp(24)
                height: Material.Units.dp(64)
                verticalAlignment:Text.AlignVCenter
                text:qsTr("描述信息");
                style:"subheading"
                color: Material.Theme.light.shade(0.87)
            }
            Material.Label{
                id:descriptionlabel
                anchors.left: parent.left
                anchors.leftMargin: Material.Units.dp(48)
            }
        }
    }
}
