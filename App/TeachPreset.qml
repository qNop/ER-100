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
    property var teachmodemodel: ["自动","半自动","手动"];
    property var startendcheckmodel:["自动","手动"]
    property var teachfisrtpointmodel: ["右方","左方"];
    property Item __lastFocusedItem: null
    onVisibleChanged: {
        if(visible){
            __lastFocusedItem.forceActiveFocus()
        }else{
             __lastFocusedItem=Window.activeFocusItem;
        }
    }
    Material.Card{
        anchors{
            left:parent.left
            right:parent.right
            top:parent.top
            bottom: descriptionCard.top
            margins:Material.Units.dp(16)
        }
        elevation: 2
        Material.Label{
            id:title
            anchors.left: parent.left
            anchors.leftMargin: Material.Units.dp(24)
            height: Material.Units.dp(64)
            verticalAlignment:Text.AlignVCenter
            text:qsTr("示教设置");
            style:"title"
            color: Material.Theme.light.shade(0.87)
        }
        Material.Scrollbar {
            flickableItem: fickable
        }
        Flickable{
            id:fickable
            anchors.top:title.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            clip: true
            //  Material.ThinDivider{anchors.top:parent.top}
            Column{
                id:column
                anchors.fill: parent
                /*示教模式设置*/
                ListItem.Subtitled{
                    id:teachmode
                    text:qsTr("示教模式:");
                    x:  teachmode.visible ? Material.Units.dp(48): Material.Units.dp(148) ;
                    leftMargin: Material.Units.dp(48);
                    height: Material.Units.dp(48)
                    selected: focus;
                    KeyNavigation.down:startendcheck
                    Keys.onPressed: {
                        switch(event.key){
                        case Qt.Key_Right:
                            if(teachmodegroup.current){
                                switch(teachmodegroup.current.text){
                                case "自动": teachmodegroup.current = teachmoderepeater.itemAt(1);break;
                                case "半自动": teachmodegroup.current = teachmoderepeater.itemAt(2);break;
                                }
                            }
                            event.accepted = true;
                            break;
                        case Qt.Key_Left:
                            if(teachmodegroup.current){
                                switch(teachmodegroup.current.text){
                                case "手动": teachmodegroup.current = teachmoderepeater.itemAt(1);break;
                                case "半自动": teachmodegroup.current = teachmoderepeater.itemAt(0);break;
                                }
                            }
                            event.accepted = true;
                            break;
                        }
                    }
                    onClicked:forceActiveFocus();
                    onSelectedChanged: selected? descriptionlabel.text=text :null;
                    Behavior on x{ NumberAnimation { duration: 200 } }
                    secondaryItem:Row{
                        anchors.verticalCenter: parent.verticalCenter
                        QuickControls.ExclusiveGroup { id: teachmodegroup;onCurrentChanged:{
                                if(teachmodegroup.current){
                                    Material.UserData.setValueFromFuncOfTable("teachpreset","示教模式",teachmodegroup.current.text);
                                    var frame=["W","100","1"," "];
                                    frame[3]=teachmodegroup.current.text==="自动"?"0":
                                                                                 teachmodegroup.current.text==="半自动"?"1":"2";
                                    ERModbus.setmodbusFrame(frame);
                                }
                            }}
                        Repeater{
                            id:teachmoderepeater
                            model:teachmodemodel
                            delegate:Material.RadioButton{
                                text:modelData
                                darkBackground:Material.Theme.isDarkColor(Material.Theme.backgroundColor)
                                exclusiveGroup: teachmodegroup
                                onClicked: teachmode.forceActiveFocus()
                                Component.onCompleted:{
                                    checked=Material.UserData.getValueFromFuncOfTable("teachpreset","function","示教模式")===modelData;
                                }
                            }
                        }
                    }
                    Component.onCompleted: forceActiveFocus();
                }
                /*始终端检测*/
                ListItem.Subtitled{
                    id:startendcheck
                    text:qsTr("始终端检测:");
                    x: visible ? Material.Units.dp(48) : Material.Units.dp(148) ;
                    height: Material.Units.dp(48)
                    leftMargin: Material.Units.dp(48);
                    Behavior on x{NumberAnimation { duration: 200 } }
                    backgroundColor: Material.Theme.backgroundColor
                    KeyNavigation.up: teachmode
                    KeyNavigation.down: teachfirstpoint
                    onClicked:forceActiveFocus();
                    onSelectedChanged: selected? descriptionlabel.text="设定终端的检测是自动或是手动" :null;
                    visible: (teachset.mode!== "手动")
                    selected: focus;
                    Keys.onPressed: {
                        switch(event.key){
                        case Qt.Key_Right:
                            if(startendcheckgroup.current){
                                if(startendcheckgroup.current.text==="自动" ) startendcheckgroup.current = startendcheckrepeater.itemAt(1);
                            }
                            event.accepted = true;
                            break;
                        case Qt.Key_Left:
                            if(startendcheckgroup.current){
                                if(startendcheckgroup.current.text==="手动" ) startendcheckgroup.current = startendcheckrepeater.itemAt(0);
                            }
                            event.accepted = true;
                            break;
                        }
                    }
                    secondaryItem:Row{
                        anchors.verticalCenter: parent.verticalCenter
                        QuickControls.ExclusiveGroup { id: startendcheckgroup;onCurrentChanged:{
                                if(startendcheckgroup.current){
                                    Material.UserData.setValueFromFuncOfTable("teachpreset","始终端检测",startendcheckgroup.current.text)
                                    var frame=["W","117","1"," "];
                                    frame[3]=startendcheckgroup.current.text==="自动"?"0":"1";
                                    ERModbus.setmodbusFrame(frame);
                                }
                            }}
                        Repeater{
                            id:startendcheckrepeater
                            model:startendcheckmodel
                            delegate:Material.RadioButton{
                                text:modelData
                                exclusiveGroup: startendcheckgroup
                                onClicked: startendcheck.forceActiveFocus()
                                Component.onCompleted: checked=Material.UserData.getValueFromFuncOfTable("teachpreset","function","始终端检测")===modelData;
                            }
                        }
                    }
                }
                /*示教第一点位置*/
                ListItem.Subtitled{
                    id:teachfirstpoint
                    text:qsTr("示教第一点位置:");
                    x: visible ? Material.Units.dp(48) : Material.Units.dp(148) ;
                    leftMargin: Material.Units.dp(48);
                    height: Material.Units.dp(48)
                    Behavior on x{NumberAnimation { duration: 200 }}
                    selected: focus;
                    KeyNavigation.up: startendcheck
                    KeyNavigation.down: teachfirstpointtimelength
                    Keys.onPressed: {
                        switch(event.key){
                        case Qt.Key_Right:
                            if(teachfisrtpointgroup.current){
                                if(teachfisrtpointgroup.current.text==="右方" ) teachfisrtpointgroup.current = teachfirstpointrepeater.itemAt(1);
                            }
                            event.accepted = true;
                            break;
                        case Qt.Key_Left:
                            if(teachfisrtpointgroup.current){
                                if(teachfisrtpointgroup.current.text==="左方" ) teachfisrtpointgroup.current = teachfirstpointrepeater.itemAt(0);
                            }
                            event.accepted = true;
                            break;
                        }
                    }
                    onClicked:forceActiveFocus();
                    onSelectedChanged: selected? descriptionlabel.text="设定第一点从左右哪边开始" :null;
                    backgroundColor: Material.Theme.backgroundColor
                    secondaryItem:Row{
                        anchors.verticalCenter: parent.verticalCenter
                        QuickControls.ExclusiveGroup { id: teachfisrtpointgroup;
                            onCurrentChanged:{
                                if(teachfisrtpointgroup.current){
                                    Material.UserData.setValueFromFuncOfTable("teachpreset","示教第1点位置",teachfisrtpointgroup.current.text)
                                    var frame=["W","118","1"," "];
                                    frame[3]=teachfisrtpointgroup.current.text==="左方"?"0":"1";
                                    ERModbus.setmodbusFrame(frame);
                                }
                            }
                        }
                        Repeater{
                            id:teachfirstpointrepeater
                            model:teachfisrtpointmodel
                            delegate:Material.RadioButton{
                                text:modelData
                                onClicked: teachfirstpoint.forceActiveFocus()
                                exclusiveGroup: teachfisrtpointgroup
                                Component.onCompleted: checked=Material.UserData.getValueFromFuncOfTable("teachpreset","function","示教第1点位置")===modelData;
                            }
                        }
                    }
                }
                /*示教1点时焊接长(mm)*/
                ListItem.Subtitled{
                    id:teachfirstpointtimelength
                    text:qsTr("示教一点时焊接长:");
                    x: teachfirstpointtimelength.visible ? Material.Units.dp(48) : Material.Units.dp(148) ;
                    leftMargin: Material.Units.dp(48);
                    height: Material.Units.dp(48)
                    KeyNavigation.up: teachfirstpoint
                    KeyNavigation.down: teachpointnum
                    onSelectedChanged: selected? descriptionlabel.text="示教点数为1点时,设定至第二点的焊接距离" :null;
                    onClicked:forceActiveFocus();
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res=Number(teachfirstpointtimelengthglabel.text)+2;
                            if(res>10000) res=10000;
                            teachfirstpointtimelengthglabel.text=res.toString();
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            if(res<10) res=10;
                            res=Number(teachfirstpointtimelengthglabel.text)-2;
                            teachfirstpointtimelengthglabel.text=res.toString();
                            event.accepted = true;
                            break;
                        }
                    }
                    Behavior on x{NumberAnimation { duration: 200 }}
                    backgroundColor: Material.Theme.backgroundColor
                    selected: focus || teachfirstpointtimelengthglabel.focus;
                    secondaryItem:Row{
                        spacing: Material.Units.dp(8)
                        anchors.verticalCenter: parent.verticalCenter
                        Material.TextField{
                            id: teachfirstpointtimelengthglabel
                            showBorder:false
                            inputMethodHints: Qt.ImhDigitsOnly
                            width: 4*Material.Units.dp(12)
                            hasError: Number(text)>10000 || Number(text) <10;
                            onTextChanged:{
                                Material.UserData.setValueFromFuncOfTable("teachpreset","示教1点时焊接长(mm)",text);
                                var frame=["W","116","1"," "];
                                frame[3]=text;
                                ERModbus.setmodbusFrame(frame);
                            }
                            Component.onCompleted: text=Material.UserData.getValueFromFuncOfTable("teachpreset","function","示教1点时焊接长(mm)");
                        }
                        Material.Label{text:"(mm)";style: "subheading";}
                    }
                }
                /*示教点数*/
                ListItem.Subtitled{
                    id:teachpointnum
                    text:qsTr("示教点数:");
                    x: teachpointnum.visible ? Material.Units.dp(48) : Material.Units.dp(148) ;
                    leftMargin: Material.Units.dp(48);
                    height: Material.Units.dp(48)
                    KeyNavigation.up: teachfirstpointtimelength
                    Behavior on x{  NumberAnimation { duration: 200 } }
                    selected: focus ||teachpointnumlabel.focus;
                    onSelectedChanged:selected? descriptionlabel.text=text :null;
                    backgroundColor: Material.Theme.backgroundColor
                    onClicked:forceActiveFocus();
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res= Number(teachpointnumlabel.text)+1
                            if(res>30) res=30;
                            teachpointnumlabel.text=res.toString();
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            if(res<1) res=1;
                            res= Number(teachpointnumlabel.text)-1
                            teachpointnumlabel.text=res.toString();
                            event.accepted = true;
                            break;
                        }
                    }
                    secondaryItem:Row{
                        spacing: Material.Units.dp(8)
                        anchors.verticalCenter: parent.verticalCenter
                        Material.TextField{
                            id: teachpointnumlabel
                            showBorder:false
                            width:2*Material.Units.dp(12)
                            inputMethodHints: Qt.ImhDigitsOnly
                            hasError: Number(text)>30 || Number(text) <1;
                            onTextChanged:{
                                Material.UserData.setValueFromFuncOfTable("teachpreset","示教点数",text);
                                var frame=["W","115","1"," "];
                                frame[3]=text;
                                ERModbus.setmodbusFrame(frame);
                            }
                            Component.onCompleted: text=Material.UserData.getValueFromFuncOfTable("teachpreset","function","示教点数");
                        }
                        Material.Label{text:"点";style: "subheading";}
                    }
                }
            }
        }
    }
    Material.Card{
        id:descriptionCard
        anchors{
            left:parent.left
            right:parent.right
            bottom: parent.bottom
            margins: Material.Units.dp(16)
        }
        elevation: 2
        height:Material.Units.dp(140);
        Column{
            anchors.fill: parent
            spacing: Material.Units.dp(16)
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
