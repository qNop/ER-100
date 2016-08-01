import QtQuick 2.4
import Material 0.1 as Material
import Material.Extras 0.1 as JS
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.3 as QuickControls
import QtQuick.LocalStorage 2.0
import QtQuick.Window 2.2
/*
  * 寄存器地址 100~120
  */
FocusScope {
    id:root
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "TeachCondition"
    anchors.fill: parent
    property var repeaterModel:[0,0,0,300,2,-10,-10]
    property var listName: [qsTr("示教模式:"),qsTr("始终端检测:"),qsTr("示教第一点位置:"),qsTr("示教点数:"),qsTr("焊接长度:"),qsTr("坡口检测点左:"),qsTr("坡口检测点右:")]
    property var teachmodemodel: ["自动","半自动","手动"];
    property var startendcheckmodel:["自动","手动"]
    property var teachfisrtpointmodel: ["左方","右方"];

    QuickControls.ExclusiveGroup { id: teachmodegroup; onCurrentChanged:
            ERModbus.setmodbusFrame(["W","100","1",current.text ==="自动"?"0":current.text ==="半自动"?"1":"2"]) }
    QuickControls.ExclusiveGroup { id: startendcheckgroup;onCurrentChanged:
            ERModbus.setmodbusFrame(["W","101","1",current.text ==="自动"?"0":"1"]) }
    QuickControls.ExclusiveGroup { id: teachfisrtpointgroup;onCurrentChanged:
            ERModbus.setmodbusFrame(["W","102","1",current.text ==="左方"?"0":"1"]) }

    //坡口数据库英文名称
    Component.onCompleted: {
        Material.UserData.openDatabase();
        //读取数据库数据
        root.repeaterModel=Material.UserData.getValueFromFuncOfTable(root.objectName,"","");
        // ERModbus.setmodbusFrame(["W","100","7"].concat(repeaterModel))
    }
    //页面不可见的时候保存数据
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
            style:"subheading"
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
                //示教模式设置
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
                                case "自动": teachmodegroup.current = teachmoderepeater.itemAt(1);
                                    Material.UserData.setValueFromFuncOfTable(root.objectName,0,1);break;
                                case "半自动": teachmodegroup.current = teachmoderepeater.itemAt(2);
                                    Material.UserData.setValueFromFuncOfTable(root.objectName,0,2);break; }}
                            event.accepted = true;
                            break;
                        case Qt.Key_Left:
                            if(teachmodegroup.current){
                                switch(teachmodegroup.current.text){
                                case "手动": teachmodegroup.current = teachmoderepeater.itemAt(1);
                                    Material.UserData.setValueFromFuncOfTable(root.objectName,0,1)
                                    break;
                                case "半自动": teachmodegroup.current = teachmoderepeater.itemAt(0);
                                    Material.UserData.setValueFromFuncOfTable(root.objectName,0,0)
                                    break; }}
                            event.accepted = true;
                            break;}}
                    onClicked:forceActiveFocus();
                    onSelectedChanged: {
                        if(selected){descriptionlabel.text="选择全自动、半自动、或手动模式。"; }}
                    secondaryItem:Row{
                        anchors.verticalCenter: parent.verticalCenter
                        Repeater{
                            id:teachmoderepeater
                            model:teachmodemodel
                            delegate:Material.RadioButton{
                                text:modelData
                                exclusiveGroup: teachmodegroup
                                checked: Number(root.repeaterModel[0]) ===index
                                onClicked: {
                                    teachmode.forceActiveFocus();
                                    Material.UserData.setValueFromFuncOfTable(root.objectName,0,index)
                                }
                            }
                        }
                    }
                    Component.onCompleted: {forceActiveFocus();}
                }
                //始终端检测
                ListItem.Subtitled{
                    id:startendcheck
                    text:qsTr("始终端检测:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: teachmode
                    KeyNavigation.down: teachfirstpoint
                    onClicked:forceActiveFocus();
                    onSelectedChanged: selected? descriptionlabel.text="设定终端的检测是自动或是手动。" :null;
                    selected: focus;
                    Keys.onPressed: {
                        switch(event.key){
                        case Qt.Key_Right:
                            if(startendcheckgroup.current){
                                if(startendcheckgroup.current.text==="自动" ){
                                    startendcheckgroup.current = startendcheckrepeater.itemAt(1);
                                    Material.UserData.setValueFromFuncOfTable(root.objectName,1,1);
                                }
                            }
                            event.accepted = true;
                            break;
                        case Qt.Key_Left:
                            if(startendcheckgroup.current){
                                if(startendcheckgroup.current.text==="手动" ){
                                    startendcheckgroup.current = startendcheckrepeater.itemAt(0);
                                    Material.UserData.setValueFromFuncOfTable(root.objectName,1,0);
                                }
                            }
                            event.accepted = true;
                            break;}}
                    secondaryItem:Row{
                        anchors.verticalCenter: parent.verticalCenter
                        Repeater{
                            id:startendcheckrepeater
                            model:startendcheckmodel
                            delegate:Material.RadioButton{
                                text:modelData
                                checked: Number(root.repeaterModel[1]) ===index
                                exclusiveGroup: startendcheckgroup
                                onClicked: {startendcheck.forceActiveFocus()
                                    Material.UserData.setValueFromFuncOfTable(root.objectName,1,index);
                                }
                            }}}
                }
                //示教第一点位置
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
                                if(teachfisrtpointgroup.current.text==="左方" ){
                                    teachfisrtpointgroup.current = teachfirstpointrepeater.itemAt(1);
                                    Material.UserData.setValueFromFuncOfTable(root.objectName,2,1);
                                }
                            }
                            event.accepted = true;
                            break;
                        case Qt.Key_Left:
                            if(teachfisrtpointgroup.current){
                                if(teachfisrtpointgroup.current.text==="右方" ){
                                    teachfisrtpointgroup.current = teachfirstpointrepeater.itemAt(0);
                                    Material.UserData.setValueFromFuncOfTable(root.objectName,2,0);
                                }
                            }
                            event.accepted = true;
                            break;
                        }
                    }
                    onClicked:forceActiveFocus();
                    onSelectedChanged: selected? descriptionlabel.text="设定第一点从左右哪边开始。" :null;
                    secondaryItem:Row{
                        anchors.verticalCenter: parent.verticalCenter
                        Repeater{
                            id:teachfirstpointrepeater
                            model:teachfisrtpointmodel
                            delegate:Material.RadioButton{
                                text:modelData
                                checked:  Number(root.repeaterModel[2] )===index
                                exclusiveGroup: teachfisrtpointgroup
                                onClicked:{
                                    teachfirstpoint.forceActiveFocus();
                                    Material.UserData.setValueFromFuncOfTable(root.objectName,2,index);}
                            }
                        }
                    }
                }
                //示教点数
                ListItem.Subtitled{
                    id:teachpointnum
                    text:qsTr("示教点数:");
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: teachfirstpoint
                    KeyNavigation.down: teachfirstpointtimelength.visible?teachfirstpointtimelength:groovecheckpointleftlength
                    selected: focus
                    onSelectedChanged:selected? descriptionlabel.text="设定示教点数（1~10点任意）。" :null;
                    onClicked:forceActiveFocus();
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res= Number(teachpointnumlabel.text)+1
                            if(res>30) res=30;
                            teachpointnumlabel.text=res.toString();
                            Material.UserData.setValueFromFuncOfTable(root.objectName,3,res);
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            res= Number(teachpointnumlabel.text)-1
                            if(res<1) res=1;
                            teachpointnumlabel.text=res.toString();
                            Material.UserData.setValueFromFuncOfTable(root.objectName,3,res);
                            event.accepted = true;
                            break;
                        }
                    }
                    secondaryItem:Row{
                        spacing: Material.Units.dp(8)
                        anchors.verticalCenter: parent.verticalCenter
                        Material.Label{
                            id: teachpointnumlabel
                            text:root.repeaterModel[3]
                            onTextChanged: ERModbus.setmodbusFrame(["W","103","1",text.toString()])
                        }
                        Material.Label{text:"点";}
                    }
                }
                //示教1点时焊接长(mm)
                ListItem.Subtitled{
                    id:teachfirstpointtimelength
                    text:qsTr("焊接长度:");
                    visible: teachpointnumlabel.text == 1;
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: teachpointnum
                    KeyNavigation.down: groovecheckpointleftlength.visible?groovecheckpointleftlength:groovecheckpointleftlength
                    onSelectedChanged: selected? descriptionlabel.text="示教点数为1点时,设定至第二点的焊接距离。" :null;
                    onClicked:forceActiveFocus();
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res=Number(teachfirstpointtimelengthglabel.text)+2;
                            if(res>10000) res=10000;
                            teachfirstpointtimelengthglabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,4,res);
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            if(res<10) res=10;
                            res=Number(teachfirstpointtimelengthglabel.text)-2;
                            teachfirstpointtimelengthglabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,4,res);
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
                            text:root.repeaterModel[4]
                            onTextChanged: ERModbus.setmodbusFrame(["W","104","1",text.toString()])
                        }
                        Material.Label{text:"(mm)";}
                    }
                }
                //坡口检测点左(mm)
                ListItem.Subtitled{
                    id:groovecheckpointleftlength
                    text:qsTr("坡口检测点左:");
                    visible:AppConfig.currentUserType=="SuperUser";
                    leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                    Behavior on leftMargin{NumberAnimation { duration: 200 }}
                    height: Material.Units.dp(44)
                    KeyNavigation.up: teachfirstpointtimelength.visible?teachfirstpointtimelength:teachpointnum
                    KeyNavigation.down: groovecheckpointrightlength
                    onSelectedChanged: selected? descriptionlabel.text="设定左端部的延长、缩短量。" :null;
                    onClicked:forceActiveFocus();
                    Keys.onPressed: {
                        var res;
                        switch(event.key){
                        case Qt.Key_Plus:
                            res=Number(groovecheckpointleftlengthlabel.text)+1;
                            if(res>1000) res=1000;
                            groovecheckpointleftlengthlabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,5,res);
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            if(res<-1000) res=-1000;
                            res=Number(groovecheckpointleftlengthlabel.text)-1;
                            groovecheckpointleftlengthlabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,5,res);
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
                            text:root.repeaterModel[5]
                            onTextChanged: ERModbus.setmodbusFrame(["W","105","1",text.toString()])
                        }
                        Material.Label{text:"(mm)";}
                    }
                }
                //坡口检测点右(mm)
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
                            groovecheckpointrightlengthlabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,6,res);
                            event.accepted = true;
                            break;
                        case Qt.Key_Minus:
                            if(res<-1000) res=-1000;
                            res=Number(groovecheckpointrightlengthlabel.text)-1;
                            groovecheckpointrightlengthlabel.text=res;
                            Material.UserData.setValueFromFuncOfTable(root.objectName,6,res);
                            event.accepted = true;
                            break;
                        }
                    }
                    selected: focus
                    onSelectedChanged: { if(selected){
                            descriptionlabel.text="设定右端部的延长、缩短量。";
                        }
                    }
                    secondaryItem:Row{
                        spacing: Material.Units.dp(8)
                        anchors.verticalCenter: parent.verticalCenter
                        Material.Label{
                            id: groovecheckpointrightlengthlabel
                            text:root.repeaterModel[6]
                            onTextChanged: ERModbus.setmodbusFrame(["W","106","1",text.toString()])
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
