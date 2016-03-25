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
    objectName: "TeachPreset"
    property int currentGroove: AppConfig.currentGroove

    property var teachmodemodel: ["自动","半自动","手动"];
    property var startendcheckmodel:["自动","手动"]
    property var teachfisrtpointmodel: ["右方","左方"];
    //坡口数据库英文名称
    property var grooveNameList: ["flatweldsinglebevelgroovet","flatweldsinglebevelgroove","flatweldvgroove","horizontalweldsinglebevelgroovet","horizontalweldsinglebevelgroove","verticalweldsinglebevelgroovet","verticalweldsinglebevelgroove","verticalweldvgroove","flatfillet"]

//    onCurrentGrooveChanged: {
//        console.log("teachset.currentGroove"+teachset.currentGroove);
//        var tablename= teachset.grooveNameList[teachset.currentGroove];
//        teachmodegroup.current=teachmoderepeater.itemAt(Number(Material.UserData.getValueFromFuncOfTable(tablename,"function","示教模式")));
//        if(startendcheck.visible) startendcheckgroup.current=startendcheckrepeater.itemAt(Number(Material.UserData.getValueFromFuncOfTable(tablename,"function","始终端检测")));
//        teachfisrtpointgroup.current=teachfirstpointrepeater.itemAt(Number(Material.UserData.getValueFromFuncOfTable(tablename,"function","示教第一点位置")));
//        teachpointnumlabel.text=Material.UserData.getValueFromFuncOfTable(tablename,"function","示教点数");
//        if(teachfirstpointtimelength.visible) teachfirstpointtimelengthglabel.text=Material.UserData.getValueFromFuncOfTable(tablename,"function","焊接长度");
//        groovecheckpointleftlengthlabel.text=Material.UserData.getValueFromFuncOfTable(tablename,"function","坡口检测点左");
//        groovecheckpointrightlengthlabel.text=Material.UserData.getValueFromFuncOfTable(tablename,"function","坡口检测点右");
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
            text:qsTr("示教条件");
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
                    id:teachmode
                    text:qsTr("示教模式:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    selected: focus;
                    KeyNavigation.down:startendcheck.visible?startendcheck:teachfirstpoint
                    Keys.onPressed: {
                        switch(event.key){
                        case Qt.Key_Right:
                            if(teachmodegroup.current){
                                switch(teachmodegroup.current.text){
                                case "自动": teachmodegroup.current = teachmoderepeater.itemAt(1);break;
                                case "半自动": teachmodegroup.current = teachmoderepeater.itemAt(2);break; }}
                            event.accepted = true;
                            break;
                        case Qt.Key_Left:
                            if(teachmodegroup.current){
                                switch(teachmodegroup.current.text){
                                case "手动": teachmodegroup.current = teachmoderepeater.itemAt(1);break;
                                case "半自动": teachmodegroup.current = teachmoderepeater.itemAt(0);break; }}
                            event.accepted = true;
                            break;}}
                    onClicked:forceActiveFocus();
                    onSelectedChanged: {
                        if(selected){descriptionlabel.text=text; if(teachmode.y<flickable.contentY) flickable.contentY=0;}}
                    secondaryItem:Row{
                        anchors.verticalCenter: parent.verticalCenter
                        QuickControls.ExclusiveGroup { id: teachmodegroup;
                            onCurrentChanged:{
                                if(teachmodegroup.current){
                                    var frame=["W","100","1"," "];
                                    frame[3]=teachmodegroup.current.text==="自动"?"0":teachmodegroup.current.text==="半自动"?"1":"2";
                                    if(teachmodegroup.current.text==="手动") startendcheck.visible=false;
                                    else startendcheck.visible=true;
                                    ERModbus.setmodbusFrame(frame);
                                    Material.UserData.setValueFromFuncOfTable(grooveNameList[currentGroove],"示教模式",frame[3]); }} }
                        Repeater{
                            id:teachmoderepeater
                            model:teachmodemodel
                            delegate:Material.RadioButton{
                                text:modelData
                                exclusiveGroup: teachmodegroup
                                onClicked: teachmode.forceActiveFocus()
                            }
                        }
                    }
                    Component.onCompleted: {forceActiveFocus();}
                }
                /*始终端检测*/
                ListItem.Subtitled{
                    id:startendcheck
                    text:qsTr("始终端检测:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: teachmode
                    KeyNavigation.down: teachfirstpoint
                    onClicked:forceActiveFocus();
                    onSelectedChanged: selected? descriptionlabel.text="设定终端的检测是自动或是手动" :null;
                    selected: focus;
                    Keys.onPressed: {
                        switch(event.key){
                        case Qt.Key_Right:
                            if(startendcheckgroup.current){
                                if(startendcheckgroup.current.text==="自动" ) startendcheckgroup.current = startendcheckrepeater.itemAt(1);}
                            event.accepted = true;
                            break;
                        case Qt.Key_Left:
                            if(startendcheckgroup.current){
                                if(startendcheckgroup.current.text==="手动" ) startendcheckgroup.current = startendcheckrepeater.itemAt(0);}
                            event.accepted = true;
                            break;} }
                    secondaryItem:Row{
                        anchors.verticalCenter: parent.verticalCenter
                        QuickControls.ExclusiveGroup { id: startendcheckgroup;
                            onCurrentChanged:{
                                if(startendcheckgroup.current){
                                    var frame=["W","117","1"," "];
                                    frame[3]=startendcheckgroup.current.text==="自动"?"0":"1";
                                    Material.UserData.setValueFromFuncOfTable(grooveNameList[currentGroove],"始终端检测",frame[3])
                                    ERModbus.setmodbusFrame(frame);}}}
                        Repeater{
                            id:startendcheckrepeater
                            model:startendcheckmodel
                            delegate:Material.RadioButton{
                                text:modelData
                                exclusiveGroup: startendcheckgroup
                                onClicked: startendcheck.forceActiveFocus()
                                Component.onCompleted: checked=Material.UserData.getValueFromFuncOfTable(grooveNameList[currentGroove],"function","始终端检测")==index; }}}
                }
                /*示教第一点位置*/
                ListItem.Subtitled{
                    id:teachfirstpoint
                    text:qsTr("示教第一点位置:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    selected: focus;
                    KeyNavigation.up: startendcheck
                    KeyNavigation.down: teachpointnum
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
                    secondaryItem:Row{
                        anchors.verticalCenter: parent.verticalCenter
                        QuickControls.ExclusiveGroup { id: teachfisrtpointgroup;
                            onCurrentChanged:{
                                if(teachfisrtpointgroup.current){
                                    var frame=["W","118","1"," "];
                                    frame[3]=teachfisrtpointgroup.current.text==="左方"?"0":"1";
                                    Material.UserData.setValueFromFuncOfTable(grooveNameList[currentGroove],"示教第1点位置",frame[3])
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
                            }
                        }
                    }
                }
                /*示教点数*/
                ListItem.Subtitled{
                    id:teachpointnum
                    text:qsTr("示教点数:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: teachfirstpoint
                    KeyNavigation.down: teachfirstpointtimelength.visible?teachfirstpointtimelength:null
                    selected: focus
                    onSelectedChanged:selected? descriptionlabel.text=text :null;                  
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
                            res= Number(teachpointnumlabel.text)-1
                            if(res<1) res=1;
                            teachpointnumlabel.text=res.toString();
                            event.accepted = true;
                            break;
                        }
                    }
                    secondaryItem:Row{
                        spacing: Material.Units.dp(8)
                        anchors.verticalCenter: parent.verticalCenter
                        Material.Label{
                            id: teachpointnumlabel
                            onTextChanged:{
                                var frame=["W","115","1",text];
                                Material.UserData.setValueFromFuncOfTable(grooveNameList[currentGroove],"示教点数",text);
                                ERModbus.setmodbusFrame(frame);
                            }
                            Component.onCompleted: text=Material.UserData.getValueFromFuncOfTable(grooveNameList[currentGroove],"function","示教点数");
                        }
                        Material.Label{text:"点";}
                    }
                }
                /*示教1点时焊接长(mm)*/
                ListItem.Subtitled{
                    id:teachfirstpointtimelength
                    text:qsTr("焊接长度:");
                    visible: teachpointnumlabel.text == 1;
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: teachpointnum
                    KeyNavigation.down: groovecheckpointleftlength.visible?groovecheckpointleftlength:null
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
                    selected: focus
                    secondaryItem:Row{
                        spacing: Material.Units.dp(8)
                        anchors.verticalCenter: parent.verticalCenter
                        Material.Label{
                            id: teachfirstpointtimelengthglabel
                            onTextChanged:{
                                Material.UserData.setValueFromFuncOfTable(grooveNameList[currentGroove],"焊接长度(mm)",text);
                                var frame=["W","116","1",text];
                                ERModbus.setmodbusFrame(frame);
                            }
                            Component.onCompleted: text=Material.UserData.getValueFromFuncOfTable(grooveNameList[currentGroove],"function","焊接长度(mm)");
                        }
                        Material.Label{text:"(mm)";}
                    }
                }
                /*坡口检测点左(mm)*/
                ListItem.Subtitled{
                    id:groovecheckpointleftlength
                    text:qsTr("坡口检测点左:");
                    visible:AppConfig.currentUserType=="SuperUser";
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: teachfirstpointtimelength.visible?teachfirstpointtimelength:teachpointnum
                    KeyNavigation.down: groovecheckpointrightlength
                    onSelectedChanged: selected? descriptionlabel.text="坡口检测点左" :null;
                    onClicked:forceActiveFocus();
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res=Number(groovecheckpointleftlengthlabel.text)+1;
                            if(res>1000) res=1000;
                            groovecheckpointleftlengthlabel.text=res.toString();
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            if(res<-1000) res=-1000;
                            res=Number(groovecheckpointleftlengthlabel.text)-1;
                            groovecheckpointleftlengthlabel.text=res.toString();
                            event.accepted = true;
                            break;
                        }
                    }                
                    selected: focus
                    secondaryItem:Row{
                        spacing: Material.Units.dp(8)
                        anchors.verticalCenter: parent.verticalCenter
                        Material.Label{
                            id: groovecheckpointleftlengthlabel
                            onTextChanged:{
                                if(text>1000) text=1000
                                else if(text<-1000) text=-1000
                                Material.UserData.setValueFromFuncOfTable(grooveNameList[currentGroove],"坡口检测点左(mm)",text);
                                var frame=["W","119","1"," "];
                                frame[3]=text+1000;
                                ERModbus.setmodbusFrame(frame);
                            }
                            Component.onCompleted: text=Material.UserData.getValueFromFuncOfTable(grooveNameList[currentGroove],"function","坡口检测点左(mm)");
                        }
                        Material.Label{text:"(mm)";}
                    }
                }
                /*坡口检测点右(mm)*/
                ListItem.Subtitled{
                    id:groovecheckpointrightlength
                    text:qsTr("坡口检测点右:");
                    visible:AppConfig.currentUserType=="SuperUser";
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: groovecheckpointleftlength.visible?groovecheckpointleftlength:null
                    onClicked:forceActiveFocus();
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res=Number(groovecheckpointrightlengthlabel.text)+1;
                            if(res>1000) res=1000;
                            groovecheckpointrightlengthlabel.text=res.toString();
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            if(res<-1000) res=-1000;
                            res=Number(groovecheckpointrightlengthlabel.text)-1;
                            groovecheckpointrightlengthlabel.text=res.toString();
                            event.accepted = true;
                            break;
                        }
                    }
                    selected: focus
                    onSelectedChanged: { if(selected){
                            descriptionlabel.text=text;
                            if(groovecheckpointrightlength.y+height>flickable.height+flickable.contentY){
                                flickable.contentY+=groovecheckpointrightlength.y+height-flickable.height
                            }
                        }
                    }
                    secondaryItem:Row{
                        spacing: Material.Units.dp(8)
                        anchors.verticalCenter: parent.verticalCenter
                        Material.Label{
                            id: groovecheckpointrightlengthlabel
                            onTextChanged:{
                                if(text>1000) text=1000
                                else if(text<-1000) text=-1000
                                var frame=["W","120","1"," "];
                                frame[3]=text+1000;
                                ERModbus.setmodbusFrame(frame);
                                Material.UserData.setValueFromFuncOfTable(grooveNameList[currentGroove],"坡口检测点右(mm)",text);
                            }
                            Component.onCompleted: text=Material.UserData.getValueFromFuncOfTable(grooveNameList[currentGroove],"function","坡口检测点右(mm)");
                        }
                        Material.Label{text:"(mm)";}
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
