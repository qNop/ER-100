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
    id:teachset
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "WeldPreset"
    property int currentGroove: AppConfig.currentGroove

    property var swingWayModel: ["无","左方","右方","左右"];
    property var robotLayoutModel:["坡口侧","非坡口侧"]
    property var returnWayModel: ["单程","往返"];

    //坡口数据库英文名称
    property var grooveNameList: ["flatweldsinglebevelgroovet","flatweldsinglebevelgroove","flatweldvgroove","horizontalweldsinglebevelgroovet","horizontalweldsinglebevelgroove","verticalweldsinglebevelgroovet","verticalweldsinglebevelgroove","verticalweldvgroove","flatfillet"]

//    onCurrentGrooveChanged: {
//        console.log("teachset.currentGroove"+teachset.currentGroove);
//        var tablename= teachset.grooveNameList[teachset.currentGroove];
//        swingWayGroup.current=swingWayRepeater.itemAt(Number(Material.UserData.getValueFromFuncOfTable(tablename,"function","示教模式")));
//        if(robotLayout.visible) robotLayoutGroup.current=robotLayoutRepeater.itemAt(Number(Material.UserData.getValueFromFuncOfTable(tablename,"function","始终端检测")));
//        returnWayGroup.current=returnWayRepeater.itemAt(Number(Material.UserData.getValueFromFuncOfTable(tablename,"function","示教第一点位置")));
//        arcTrackinglabel.text=Material.UserData.getValueFromFuncOfTable(tablename,"function","示教点数");
//        if(solubility.visible) solubilityglabel.text=Material.UserData.getValueFromFuncOfTable(tablename,"function","焊接长度");
//        currentOffsetlabel.text=Material.UserData.getValueFromFuncOfTable(tablename,"function","坡口检测点左");
//        voltageOffsetlabel.text=Material.UserData.getValueFromFuncOfTable(tablename,"function","坡口检测点右");
//    }

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
            clip: true
            contentHeight: column.height
            Column{
                id:column
                anchors{ left:parent.left;right:parent.right;top:parent.top}
                /*示教模式设置*/
                ListItem.Subtitled{
                    id:swingWay
                    text:qsTr("头部摆动方式:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    selected: focus;
                    KeyNavigation.down:robotLayout.visible?robotLayout:returnWay
                    Keys.onPressed: {
                        switch(event.key){
                        case Qt.Key_Right:
                            if(swingWayGroup.current){
                                switch(swingWayGroup.current.text){
                                case "无": swingWayGroup.current = swingWayRepeater.itemAt(1);break;
                                case "左方": swingWayGroup.current = swingWayRepeater.itemAt(2);break;
                                case "右方": swingWayGroup.current = swingWayRepeater.itemAt(3);break;
                                }}
                            event.accepted = true;
                            break;
                        case Qt.Key_Left:
                            if(swingWayGroup.current){
                                switch(swingWayGroup.current.text){
                                case "左右": swingWayGroup.current = swingWayRepeater.itemAt(2);break;
                                case "右方": swingWayGroup.current = swingWayRepeater.itemAt(1);break;
                                case "左方": swingWayGroup.current = swingWayRepeater.itemAt(0);break;}}
                            event.accepted = true;
                            break;}}
                    onClicked:forceActiveFocus();
                    onSelectedChanged: {
                        if(selected){descriptionlabel.text=text; if(swingWay.y<flickable.contentY) flickable.contentY=0;}}
                    secondaryItem:Row{
                        anchors.verticalCenter: parent.verticalCenter
                        QuickControls.ExclusiveGroup { id: swingWayGroup;
                            onCurrentChanged:{
                                if(swingWayGroup.current){
                                    var frame=["W","119","1"," "];
                                    frame[3]=swingWayGroup.current.text==="无"?"0":swingWayGroup.current.text==="左方"?"1":swingWayGroup.current.text==="右方"?"2":"3";
                                    ERModbus.setmodbusFrame(frame);
                                    Material.UserData.setValueFromFuncOfTable(grooveNameList[currentGroove],"头部摆动",frame[3]); }} }
                        Repeater{
                            id:swingWayRepeater
                            model:swingWayModel
                            delegate:Material.RadioButton{
                                text:modelData
                                exclusiveGroup: swingWayGroup
                                onClicked: swingWay.forceActiveFocus()
                            }
                        }
                    }
                    Component.onCompleted: {forceActiveFocus();}
                }
                /*机器人放置面*/
                ListItem.Subtitled{
                    id:robotLayout
                    text:qsTr("机器人放置面:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: swingWay
                    KeyNavigation.down: returnWay
                    onClicked:forceActiveFocus();
                    onSelectedChanged: selected? descriptionlabel.text=text :null;
                    selected: focus;
                    Keys.onPressed: {
                        switch(event.key){
                        case Qt.Key_Right:
                            if(robotLayoutGroup.current){
                                if(robotLayoutGroup.current.text==="坡口侧" ) robotLayoutGroup.current = robotLayoutRepeater.itemAt(1);}
                            event.accepted = true;
                            break;
                        case Qt.Key_Left:
                            if(robotLayoutGroup.current){
                                if(robotLayoutGroup.current.text==="非坡口侧" ) robotLayoutGroup.current = robotLayoutRepeater.itemAt(0);}
                            event.accepted = true;
                            break;} }
                    secondaryItem:Row{
                        anchors.verticalCenter: parent.verticalCenter
                        QuickControls.ExclusiveGroup { id: robotLayoutGroup;
                            onCurrentChanged:{
                                if(robotLayoutGroup.current){
                                    var frame=["W","122","1"," "];
                                    frame[3]=robotLayoutGroup.current.text==="坡口侧"?"0":"1";
                                    Material.UserData.setValueFromFuncOfTable(grooveNameList[currentGroove],"机器人设置面",frame[3])
                                    ERModbus.setmodbusFrame(frame);}}}
                        Repeater{
                            id:robotLayoutRepeater
                            model:robotLayoutModel
                            delegate:Material.RadioButton{
                                text:modelData
                                exclusiveGroup: robotLayoutGroup
                                onClicked: robotLayout.forceActiveFocus()
                                Component.onCompleted: checked=Material.UserData.getValueFromFuncOfTable(grooveNameList[currentGroove],"function","机器人设置面")==index; }}}
                }
                /*焊接往返动作*/
                ListItem.Subtitled{
                    id:returnWay
                    text:qsTr("焊接往返动作:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    selected: focus;
                    KeyNavigation.up: robotLayout
                    KeyNavigation.down: arcTracking
                    Keys.onPressed: {
                        switch(event.key){
                        case Qt.Key_Right:
                            if(returnWayGroup.current){
                                if(returnWayGroup.current.text==="单程" ) returnWayGroup.current = returnWayRepeater.itemAt(1);
                            }
                            event.accepted = true;
                            break;
                        case Qt.Key_Left:
                            if(returnWayGroup.current){
                                if(returnWayGroup.current.text==="往返" ) returnWayGroup.current = returnWayRepeater.itemAt(0);
                            }
                            event.accepted = true;
                            break;
                        }
                    }
                    onClicked:forceActiveFocus();
                    onSelectedChanged: selected? descriptionlabel.text=text :null;
                    secondaryItem:Row{
                        anchors.verticalCenter: parent.verticalCenter
                        QuickControls.ExclusiveGroup { id: returnWayGroup;
                            onCurrentChanged:{
                                if(returnWayGroup.current){
                                    var frame=["W","123","1"," "];
                                    frame[3]=returnWayGroup.current.text==="单程"?"0":"1";
                                    Material.UserData.setValueFromFuncOfTable(grooveNameList[currentGroove],"焊接动作(往返/单程)",frame[3])
                                    ERModbus.setmodbusFrame(frame);
                                }
                            }
                        }
                        Repeater{
                            id:returnWayRepeater
                            model:returnWayModel
                            delegate:Material.RadioButton{
                                text:modelData
                                onClicked: returnWay.forceActiveFocus()
                                exclusiveGroup: returnWayGroup
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
                    KeyNavigation.down: solubility
                    selected: focus;
                    onSelectedChanged:selected? descriptionlabel.text=text :null;
                    onClicked:forceActiveFocus();
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Right:
                            arcTrackingSwitch.checked=true;
                            event.accepted = true;
                            break;
                        case Qt.Key_Left:
                            arcTrackingSwitch.checked=false;
                            event.accepted = true;
                            break;
                        }
                    }
                    secondaryItem:Row{
                        spacing: Material.Units.dp(12)
                        anchors.verticalCenter: parent.verticalCenter
                        Material.Switch{
                         id:arcTrackingSwitch
                         onCheckedChanged: {
                             var frame=["W","124","1",checked?"1":"0"];
                             Material.UserData.setValueFromFuncOfTable(grooveNameList[currentGroove],"电弧跟踪",checked?"1":"0");
                             ERModbus.setmodbusFrame(frame);
                         }
                         Component.onCompleted: checked=Material.UserData.getValueFromFuncOfTable(grooveNameList[currentGroove],"function","电弧跟踪")==0?true:false;
                        }
                        Material.Label{
                            text:arcTrackingSwitch.enabled?"打开":"关闭"
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
                    KeyNavigation.up: arcTracking
                    KeyNavigation.down: currentOffset
                    onSelectedChanged: selected? descriptionlabel.text=text :null;
                    onClicked:forceActiveFocus();
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res=Number(solubilityglabel.text)+1;
                            if(res>150) res=150;
                            solubilityglabel.text=res.toString();
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            if(res<50) res=50;
                            res=Number(solubilityglabel.text)-1;
                            solubilityglabel.text=res.toString();
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
                            onTextChanged:{
                                Material.UserData.setValueFromFuncOfTable(grooveNameList[currentGroove],"溶敷系数",text);
                            }
                            Component.onCompleted: text=Material.UserData.getValueFromFuncOfTable(grooveNameList[currentGroove],"function","溶敷系数");
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
                    onSelectedChanged: selected? descriptionlabel.text="坡口检测点左" :null;
                    onClicked:forceActiveFocus();
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res=Number(currentOffsetlabel.text)+5;
                            if(res>100) res=100;
                            currentOffsetlabel.text=res.toString();
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            if(res<-100) res=-100;
                            res=Number(currentOffsetlabel.text)-5;
                            currentOffsetlabel.text=res.toString();
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
                            onTextChanged:{
                                if(text>100) text=100
                                else if(text<-100) text=-100
                                Material.UserData.setValueFromFuncOfTable(grooveNameList[currentGroove],"焊接电流偏置(A)",text);
                                var frame=["W","125","1"," "];
                                frame[3]=text+100;
                                ERModbus.setmodbusFrame(frame);
                            }
                            Component.onCompleted: text=Material.UserData.getValueFromFuncOfTable(grooveNameList[currentGroove],"function","焊接电流偏置(A)");
                        }
                        Material.Label{text:"A";}
                    }
                }
                /*坡口检测点右(mm)*/
                ListItem.Subtitled{
                    id:voltageOffset
                    text:qsTr("焊接电压偏置:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: currentOffset
                    onClicked:forceActiveFocus();
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res=Number(voltageOffsetlabel.text)+0.1;
                            if(res>10) res=10;
                            voltageOffsetlabel.text=res.toString();
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            if(res<-10) res=-10;
                            res=Number(voltageOffsetlabel.text)-0.1;
                            voltageOffsetlabel.text=res.toString();
                            event.accepted = true;
                            break;
                        }
                    }
                    selected: focus
                    onSelectedChanged: { if(selected){
                            descriptionlabel.text=text;
                            if(voltageOffset.y+height>flickable.height+flickable.contentY){
                                flickable.contentY+=voltageOffset.y+height-flickable.height
                            }
                        }
                    }
                    secondaryItem:Row{
                        spacing: Material.Units.dp(8)
                        anchors.verticalCenter: parent.verticalCenter
                        Material.Label{
                            id: voltageOffsetlabel
                            onTextChanged:{
                                if(text>10) text=10
                                else if(text<-10) text=-10
                                var frame=["W","126","1"," "];
                                frame[3]=text*10;
                                ERModbus.setmodbusFrame(frame);
                                Material.UserData.setValueFromFuncOfTable(grooveNameList[currentGroove],"焊接电压偏置(V)",text);
                            }
                            Component.onCompleted: text=Material.UserData.getValueFromFuncOfTable(grooveNameList[currentGroove],"function","焊接电压偏置(V)");
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
