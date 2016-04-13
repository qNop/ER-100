import QtQuick 2.4
import Material 0.1 as Material
import Material.Extras 0.1 as JS
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0
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
    property var weldGasModel: ["CO2","混合气"]
    property alias weldsolubility:solubilityglabel.text

    property var condition: [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

    Component.onCompleted: {
        condition=Material.UserData.getValueFromFuncOfTable(root.objectName,"","")
        //ERModbus.setmodbusFrame(["W","120","7"].concat(condition))
    }

    QuickControls.ExclusiveGroup { id: weldWireLengthGroup; onCurrentChanged:
            //10mm 1 12mm 2 15mm 3 20mm 4 25mm 6
            ERModbus.setmodbusFrame(["W","120","1",current.text ==="10mm"?"1":current.text==="15mm"?"3":current.text==="20mm"?"4":"6"]) }
    QuickControls.ExclusiveGroup { id: swingWayGroup; onCurrentChanged:
            ERModbus.setmodbusFrame(["W","121","1",current.text ==="无"?"0":current.text==="左方"?"1":current.text==="右方"?"2":"3"]) }
    QuickControls.ExclusiveGroup { id: robotLayoutGroup; onCurrentChanged:
            ERModbus.setmodbusFrame(["W","122","1",current.text ==="坡口侧"?"0":"1"]) }
    QuickControls.ExclusiveGroup { id: weldWireDiameterGroup; onCurrentChanged:
            //1.2mm 4 1.6mm 6
            ERModbus.setmodbusFrame(["W","123","1",current.text ==="1.2mm"?"4":"6"]) }
    QuickControls.ExclusiveGroup { id: weldGasGroup;onCurrentChanged:
            ERModbus.setmodbusFrame(["W","124","1",current.text ==="CO2"?"0":"1"]) }
    QuickControls.ExclusiveGroup { id: returnWayGroup; onCurrentChanged:
            ERModbus.setmodbusFrame(["W","125","1",current.text ==="单程"?"0":"1"]) }
    QuickControls.ExclusiveGroup { id: weldWireGroup; onCurrentChanged:
            //0 实芯碳钢 4药芯碳钢
            ERModbus.setmodbusFrame(["W","126","1",current.text ==="实芯碳钢"?"0":"1"]) }

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
            style:"title"
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
                    onSelectedChanged: selected? descriptionlabel.text=text :null;
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
                                checked: root.condition[0]==index;
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
                    KeyNavigation.down:robotLayout.visible?robotLayout:returnWay
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
                        if(selected){descriptionlabel.text=text; if(swingWay.y<flickable.contentY) flickable.contentY=0;}}
                    secondaryItem:Row{
                        anchors.verticalCenter: parent.verticalCenter
                        Repeater{
                            id:swingWayRepeater
                            model:swingWayModel
                            delegate:Material.RadioButton{
                                text:modelData
                                exclusiveGroup: swingWayGroup
                                checked: root.condition[1]==index;
                                onClicked: {
                                    Material.UserData.setValueFromFuncOfTable(root.objectName,1,index);
                                    swingWay.forceActiveFocus()}
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
                    KeyNavigation.up: swingWay
                    KeyNavigation.down: weldWire
                    onClicked:forceActiveFocus();
                    onSelectedChanged: selected? descriptionlabel.text=text :null;
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
                                checked: root.condition[2]==index;
                                onClicked: {
                                    Material.UserData.setValueFromFuncOfTable(root.objectName,2,index);
                                    robotLayout.forceActiveFocus()
                                }}}}
                }
                /*焊丝种类*/
                ListItem.Subtitled{
                    id:weldWire
                    text:qsTr("焊丝种类:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    selected: focus;
                    KeyNavigation.up: robotLayout
                    KeyNavigation.down: weldWireDiameter
                    Keys.onPressed: {
                        switch(event.key){
                        case Qt.Key_Right:
                            if(weldWireGroup.current.text==="实碳钢芯" ){

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
                    onSelectedChanged: selected?( descriptionlabel.text=text ):null;
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
                                checked: root.condition[6]==index;
                            }
                        }
                    }
                }
                /*焊丝直径*/
                ListItem.Subtitled{
                    id:weldWireDiameter
                    text:qsTr("焊丝直径:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    selected: focus;
                    KeyNavigation.up: weldWire
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
                    onSelectedChanged: selected? descriptionlabel.text=text :null;
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
                    onSelectedChanged: selected? descriptionlabel.text=text :null;
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
                                           descriptionlabel.text=text ;
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
                    KeyNavigation.down: grooveCheck
                    selected: focus;
                    onSelectedChanged:{if(selected){
                            descriptionlabel.text=text ;
                            flickable.contentY=flickable.contentHeight/2
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
                            checked: root.condition[7];
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
                /*焊缝检测*/
                ListItem.Subtitled{
                    id:grooveCheck
                    text:qsTr("焊丝焊缝检测机能:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: arcTracking
                    KeyNavigation.down: solubility
                    selected: focus;
                    onSelectedChanged:selected? descriptionlabel.text=text :null;
                    onClicked:forceActiveFocus();
                    Keys.onPressed: {
                        switch(event.key){
                        case Qt.Key_Right:
                            grooveCheckSwitch.checked=true;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,8,1);
                            event.accepted = true;
                            break;
                        case Qt.Key_Left:
                            grooveCheckSwitch.checked=false;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,8,0);
                            event.accepted = true;
                            break;
                        }
                    }
                    secondaryItem:Row{
                        spacing: Material.Units.dp(16)
                        anchors.verticalCenter: parent.verticalCenter
                        Material.Switch{
                            id:grooveCheckSwitch
                            onClicked: {
                                Material.UserData.setValueFromFuncOfTable(root.objectName,8,checked);
                                grooveCheck.forceActiveFocus()}
                            checked: root.condition[8];
                            onCheckedChanged: ERModbus.setmodbusFrame(["W","128","1",checked?"1":"0"])
                        }
                        Material.Label{
                            text:grooveCheckSwitch.checked?"打开":"关闭"
                        }
                    }
                }
                /*溶敷系数*/
                ListItem.Subtitled{
                    id:solubility
                    text:qsTr("溶敷系数:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: grooveCheck
                    KeyNavigation.down: currentOffset
                    onSelectedChanged: selected? descriptionlabel.text=text :null;
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
                            text: root.condition[9];
                            onTextChanged:{}  ///ERModbus.setmodbusFrame(["W","129","1",text.toString()])
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
                    onSelectedChanged: selected? descriptionlabel.text=currentOffset.text:null;
                    onClicked:forceActiveFocus();
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res=Number(currentOffsetlabel.text)+5;
                            if(res>100) res=100;
                            currentOffsetlabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,10,res);
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            if(res<-100) res=-100;
                            res=Number(currentOffsetlabel.text)-5;
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
                            onTextChanged:  ERModbus.setmodbusFrame(["W","130","1",text.toString()])
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
                    KeyNavigation.down: weldLeft
                    onClicked:forceActiveFocus();
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res=Number(voltageOffsetlabel.text)+1;
                            if(res>10) res=10;
                            voltageOffsetlabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,11,res);
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            res=Number(voltageOffsetlabel.text)-1;
                            if(res<-10) res=-10;
                            voltageOffsetlabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,11,res);
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
                            id: voltageOffsetlabel
                            text: root.condition[11]
                            onTextChanged:  ERModbus.setmodbusFrame(["W","131","1",text.toString()])
                        }
                        Material.Label{text:"V";}
                    }
                }
                /*焊接始终端偏左*/
                ListItem.Subtitled{
                    id:weldLeft
                    text:qsTr("焊接始终端偏左:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: voltageOffset
                    KeyNavigation.down: weldRight
                    onClicked:forceActiveFocus();
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res=Number(weldLeftlabel.text)+1;
                            if(res>10) res=10;
                            weldLeftlabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,12,res);
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            res=Number(weldLeftlabel.text)-1;
                            if(res<-10) res=-10;
                            weldLeftlabel.text=res;
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
                            id: weldLeftlabel
                            text:root.condition[12]
                            onTextChanged:  ERModbus.setmodbusFrame(["W","132","1",text.toString()])
                        }
                        Material.Label{text:"mm";}
                    }
                }
                /*焊接始终端偏右*/
                ListItem.Subtitled{
                    id:weldRight
                    text:qsTr("焊接始终端偏右:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: weldLeft
                    onClicked:forceActiveFocus();
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res=Number(weldRightlabel.text)+1;
                            if(res>10) res=10;
                            weldRightlabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,13,res);
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            res=Number(weldRightlabel.text)-1;
                            if(res<-10) res=-10;
                            weldRightlabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,13,res);
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
                            id: weldRightlabel
                            text:root.condition[13]
                            onTextChanged:  ERModbus.setmodbusFrame(["W","133","1",text.toString()])
                        }
                        Material.Label{text:"mm";}
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
                style:"title"
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
