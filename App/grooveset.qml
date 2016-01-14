import QtQuick 2.2
import Material 0.1
import Material.Extras 0.1 as JS
import WeldSys.APPConfig 1.0
import WeldSys.ERModbus 1.0
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.3 as QuickControls
import QtQuick.LocalStorage 2.0
import "qrc:/Database.js" as DB
import "CanvasPaint.js" as Paint
Item {
    id:grooveset
    property int currentGroove:9;
    property var teachmodemodel: ["自动","半自动","手动"];
    property var startendcheckmodel:["自动","手动"]
    property var teachfisrtpointmodel: ["右方","左方"];
    /*坡口列表*/
    property var groovestyles: [
        qsTr( "平焊单边V型坡口T接头"), qsTr( "平焊单边V型坡口平对接"),  qsTr("平焊V型坡口平对接"),  qsTr("水平角焊"),
        qsTr("横焊单边V型坡口T接头"), qsTr( "横焊单边V型坡口平对接"),  qsTr("横焊V型坡口平对接"),  qsTr("立焊单边V型坡口平对接"), qsTr("立焊V型坡口平对接")  ]
    /*数据库参数列表*/
    property var teachSetList: [qsTr( "示教模式"),qsTr( "始终端检测"),qsTr( "示教第一点位置"),qsTr( "示教第一点时焊接长"),
        qsTr( "示教点数"),qsTr( "板厚"),qsTr( "余高"),qsTr( "坡口检测点左"),qsTr( "坡口检测点右"),qsTr( "板厚补正"),qsTr( "角度补正"),qsTr( "间隙补正"),]
    property int keyindex: 0;
    property string mode: "";
    APPConfig{id:appconfig}
    anchors.left: parent.left

    onKeyindexChanged: {
        console.log("keyindexchanged")
    }
    Keys.onPressed: {
        switch(event.key){
        case Qt.Key_1:
            if(grooveset.visible){
                changeindex();
                event.accepted = true;
            }
            break;
        }
    }
    /*当前坡口改变即处理数据*/
    onCurrentGrooveChanged: {
        appconfig.currentGroove=grooveset.currentGroove;
        switch(DB.getValueFromFuncOfTable(grooveset.currentGroove,"function","示教模式")){
        case "自动":teachmodegroup.current=teachmoderepeater.itemAt(0);break;
        case "半自动":teachmodegroup.current=teachmoderepeater.itemAt(1);break;
        case "手动":teachmodegroup.current=teachmoderepeater.itemAt(2);break;
        };
        switch(DB.getValueFromFuncOfTable(grooveset.currentGroove,"function","示教第1点位置")){
        case "右方":teachfisrtpointgroup.current=teachfirstpointrepeater.itemAt(0);break;
        case "左方":teachfisrtpointgroup.current=teachfirstpointrepeater.itemAt(1);break;
        }
        switch(DB.getValueFromFuncOfTable(grooveset.currentGroove,"function","始终端检测")){
        case "自动":startendcheckgroup.current=startendcheckrepeater.itemAt(0);break;
        case "手动":startendcheckgroup.current=startendcheckrepeater.itemAt(1);break;
        }
    }
    Component.onCompleted: {
        teachmodeset.forceActiveFocus();
        grooveset.currentGroove=appconfig.currentGroove;
    }
    function changeindex() {
        repeat.itemAt(grooveset.currentGroove).selected=false;
        grooveset.currentGroove++;
        if(grooveset.currentGroove>8){
            grooveset.currentGroove=0;
        }
        repeat.itemAt(grooveset.currentGroove).selected=true;
    }
    Sidebar{
        id:groovelist
        anchors{
            left:parent.left
            top:parent.top
            bottom: parent.bottom
        }
        style: "dark"
        width:Units.dp(255);
        Column{
            id:stand
            width:parent.width
            Repeater{
                id:repeat
                model:groovestyles;
                delegate:ListItem.Standard{
                    id:groove
                    text:modelData;
                    textColor: groove.selected ? Theme.lightDark(groovelist.backgroundColor,Theme.light.accentColor,Theme.dark.textColor)
                                               :Theme.lightDark(groovelist.backgroundColor,Theme.light.shade(0.6),Theme.dark.shade(0.6))
                    onClicked: {
                        for(var i=0;i<9;i++){
                            if(i===index) groove.selected=true;
                            else repeat.itemAt(i).selected=false
                        }
                        grooveset.currentGroove=index;
                    }

                }
            }
        }
    }
    Scrollbar {
        flickableItem: fickable
    }
    Flickable{
        id:fickable
        objectName: "groove"
        anchors {
            left: groovelist.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        clip: true
        contentHeight: Math.max(parent.implicitHeight + 40, height)
        Column{
            id:column
            anchors.fill: parent
            ListItem.SectionHeader{
                id:teachmodeset;
                style: "subheading";showDivider: true;iconName: "awesome/gears"; expanded: true;
                text:qsTr("示教设置");  selected: focus;
                KeyNavigation.down:expanded ? teachmode : weldset
                Keys.onPressed: {
                    if(event.key === Qt.Key_Plus){
                        expanded = !expanded;
                        event.accepted = true;
                    }
                    else if(event.key === Qt.Key_Minus){
                        expanded = false;
                        event.accepted = true;
                    }
                }
            }
            /*示教模式设置*/
            ListItem.Subtitled{
                id:teachmode
                text:qsTr("示教模式:");
                anchors.leftMargin:  teachmode.visible ? Units.dp(48): Units.dp(148) ;
                height:teachmodeset.height
                selected: focus;
                KeyNavigation.down:teachmodeset
                visible: teachmodeset.expanded
                Behavior on anchors.leftMargin{ NumberAnimation { duration: 200 } }
                secondaryItem:Row{
                    QuickControls.ExclusiveGroup { id: teachmodegroup;onCurrentChanged:{
                            DB.setValueFromFuncOfTable(grooveset.currentGroove,"示教模式",teachmodegroup.current.text);
                            teachmode.focus=true;
                            grooveset.mode=teachmodegroup.current.text;
                        }}
                    Repeater{
                        id:teachmoderepeater
                        model:teachmodemodel
                        delegate:RadioButton{
                            text:modelData
                            darkBackground:Theme.isDarkColor(Theme.backgroundColor)
                            exclusiveGroup: teachmodegroup
                        }
                    }
                }
            }
            /*始终端检测*/
            ListItem.Subtitled{
                id:startendcheck
                text:qsTr("始终端检测:");
                anchors.left: parent.left
                anchors.leftMargin: teachfirstpointtimelength.visible ? Units.dp(48) : Units.dp(148) ;
                Behavior on anchors.leftMargin{
                    NumberAnimation { duration: 200 }
                }
                backgroundColor: Theme.backgroundColor
                height:teachmodeset.height
                visible: teachmodeset.expanded&&(grooveset.mode!== "手动")
                secondaryItem:Row{
                    anchors.verticalCenter: parent.verticalCenter
                    QuickControls.ExclusiveGroup { id: startendcheckgroup;onCurrentChanged:
                            DB.setValueFromFuncOfTable(grooveset.currentGroove,"始终端检测",startendcheckgroup.current.text)}
                    Repeater{
                        id:startendcheckrepeater
                        model:startendcheckmodel
                        delegate:RadioButton{
                            text:modelData
                            darkBackground:Theme.isDarkColor(Theme.backgroundColor)
                            exclusiveGroup: startendcheckgroup
                        }
                    }
                }
            }
            /*示教第一点位置*/
            ListItem.Subtitled{
                id:teachfirstpoint
                text:qsTr("示教第一点位置:");
                anchors.left: parent.left
                anchors.leftMargin: teachfirstpoint.visible ? Units.dp(48) : Units.dp(148) ;
                Behavior on anchors.leftMargin{
                    NumberAnimation { duration: 200 }
                }
                backgroundColor: Theme.backgroundColor
                height:teachmodeset.height
                visible: teachmodeset.expanded
                secondaryItem:Row{
                    anchors.verticalCenter: parent.verticalCenter
                    QuickControls.ExclusiveGroup { id: teachfisrtpointgroup;onCurrentChanged:
                            DB.setValueFromFuncOfTable(grooveset.currentGroove,"示教第1点位置",teachfisrtpointgroup.current.text)}
                    Repeater{
                        id:teachfirstpointrepeater
                        model:teachfisrtpointmodel
                        delegate:RadioButton{
                            text:modelData
                            darkBackground:Theme.isDarkColor(Theme.backgroundColor)
                            exclusiveGroup: teachfisrtpointgroup
                        }
                    }
                }
            }
            /*示教1点时焊接长(mm)*/
            ListItem.Subtitled{
                id:teachfirstpointtimelength
                text:qsTr("示教一点时焊接长:");
                anchors.left: parent.left
                anchors.leftMargin: teachfirstpointtimelength.visible ? Units.dp(48) : Units.dp(148) ;
                Behavior on anchors.leftMargin{
                    NumberAnimation { duration: 200 }
                }
                backgroundColor: Theme.backgroundColor
                height:teachmodeset.height
                visible: teachmodeset.expanded
                secondaryItem:Label{
                    id: teachfirstpointtimelengthglabel
                    anchors.verticalCenter: parent.verticalCenter
                    text:DB.getValueFromFuncOfTable(grooveset.currentGroove,"function","示教1点时焊接长(mm)")+"(mm)"
                    style:"subheading"
                }
            }
            /*示教点数*/
            ListItem.Subtitled{
                id:teachpointnum
                text:qsTr("示教点数:");
                anchors.left: parent.left
                anchors.leftMargin: teachpointnum.visible ? Units.dp(48) : Units.dp(148) ;
                Behavior on anchors.leftMargin{
                    NumberAnimation { duration: 200 }
                }
                backgroundColor: Theme.backgroundColor
                height:teachmodeset.height
                visible: teachmodeset.expanded
                secondaryItem:Label{
                    id: teachpointnumlabel
                    anchors.verticalCenter: parent.verticalCenter
                    text:DB.getValueFromFuncOfTable(grooveset.currentGroove,"function","示教点数")+"点"
                    style:"subheading"
                }
            }
            /*板厚(mm)*/
            ListItem.Subtitled{
                id:thick
                text:qsTr("板厚:");
                anchors.left: parent.left
                anchors.leftMargin: thick.visible ? Units.dp(48) : Units.dp(148) ;
                Behavior on anchors.leftMargin{
                    NumberAnimation { duration: 200 }
                }
                backgroundColor: Theme.backgroundColor
                height:teachmodeset.height
                visible: teachmodeset.expanded&&(grooveset.mode=== "自动")
                secondaryItem:Label{
                    id: thicklabel
                    anchors.verticalCenter: parent.verticalCenter
                    text:DB.getValueFromFuncOfTable(grooveset.currentGroove,"function","板厚(mm)") === "测定" ?"测定":DB.getValueFromFuncOfTable(grooveset.currentGroove,"function","板厚(mm)")+"(mm)"
                    style:"subheading"
                }
            }
            /*余高(mm)*/
            ListItem.Subtitled{
                id:restheight
                text:qsTr("余高:");
                anchors.left: parent.left
                anchors.leftMargin: restheight.visible ? Units.dp(48) : Units.dp(148) ;
                Behavior on anchors.leftMargin{
                    NumberAnimation { duration: 200 }
                }
                backgroundColor: Theme.backgroundColor
                height:teachmodeset.height
                visible: teachmodeset.expanded&&(grooveset.mode=== "自动")
                secondaryItem:Label{
                    id: restheightabel
                    anchors.verticalCenter: parent.verticalCenter
                    text:DB.getValueFromFuncOfTable(grooveset.currentGroove,"function","余高(mm)")+"(mm)"
                    style:"subheading"
                }
            }
            /*坡口检测点左(mm)*/
            ListItem.Subtitled{
                id:groovecheckleft
                text:qsTr("坡口检测点左:");
                anchors.left: parent.left
                anchors.leftMargin: groovecheckleft.visible ? Units.dp(48) : Units.dp(148) ;
                Behavior on anchors.leftMargin{
                    NumberAnimation { duration: 200 }
                }
                backgroundColor: Theme.backgroundColor
                height:teachmodeset.height
                visible: teachmodeset.expanded&&(grooveset.mode=== "自动")
                secondaryItem:Label{
                    id: groovecheckleftlabel
                    anchors.verticalCenter: parent.verticalCenter
                    text:DB.getValueFromFuncOfTable(grooveset.currentGroove,"function","坡口检测点左(mm)")+"(mm)"
                    style:"subheading"
                }
            }
            /*坡口检测点右(mm)*/
            ListItem.Subtitled{
                id:groovecheckright
                text:qsTr("坡口检测点右:");
                anchors.left: parent.left
                anchors.leftMargin: groovecheckright.visible ? Units.dp(48) : Units.dp(148) ;
                Behavior on anchors.leftMargin{
                    NumberAnimation { duration: 200 }
                }
                backgroundColor: Theme.backgroundColor
                height:teachmodeset.height
                visible: teachmodeset.expanded&&(grooveset.mode=== "自动")
                secondaryItem:Label{
                    id: groovecheckrightabel
                    anchors.verticalCenter: parent.verticalCenter
                    text:DB.getValueFromFuncOfTable(grooveset.currentGroove,"function","坡口检测点右(mm)")+"(mm)"
                    style:"subheading"
                }
            }
            /*板厚补正(mm)*/
            ListItem.Subtitled{
                id:thickfix
                text:qsTr("板厚补正:");
                anchors.left: parent.left
                anchors.leftMargin: thickfix.visible ? Units.dp(48) : Units.dp(148) ;
                Behavior on anchors.leftMargin{
                    NumberAnimation { duration: 200 }
                }
                backgroundColor: Theme.backgroundColor
                height:teachmodeset.height
                visible: teachmodeset.expanded&&(grooveset.mode=== "半自动")
                secondaryItem:Label{
                    id: thickfixlabel
                    anchors.verticalCenter: parent.verticalCenter
                    text:DB.getValueFromFuncOfTable(grooveset.currentGroove,"function","板厚补正(mm)")+"(mm)"
                    style:"subheading"
                }
            }
            /*角度补正(mm)*/
            ListItem.Subtitled{
                id:anglefix
                text:qsTr("角度补正:");
                anchors.left: parent.left
                anchors.leftMargin:  anglefix.visible ? Units.dp(48) : Units.dp(148) ;
                Behavior on anchors.leftMargin{
                    NumberAnimation { duration: 200 }
                }
                backgroundColor: Theme.backgroundColor
                height:teachmodeset.height
                visible: teachmodeset.expanded&&(grooveset.mode=== "半自动")
                secondaryItem:Label{
                    id: anglefixlabel
                    anchors.verticalCenter: parent.verticalCenter
                    text:DB.getValueFromFuncOfTable(grooveset.currentGroove,"function","角度补正(度)")+"(度)"
                    style:"subheading"
                }
            }
            /*间隙补正(mm)*/
            ListItem.Subtitled{
                id:gapfix
                text:qsTr("间隙补正:");
                anchors.left: parent.left
                anchors.leftMargin: gapfix.visible ? Units.dp(48) : Units.dp(148) ;
                Behavior on anchors.leftMargin{
                    NumberAnimation { duration: 200 }
                }
                backgroundColor: Theme.backgroundColor
                height:teachmodeset.height
                visible: teachmodeset.expanded&&(grooveset.mode=== "半自动")
                secondaryItem:Label{
                    id: gapfixlabel
                    anchors.verticalCenter: parent.verticalCenter
                    text:DB.getValueFromFuncOfTable(grooveset.currentGroove,"function","间隙补正(mm)")+"(mm)"
                    style:"subheading"
                }
            }
            /**/
            ListItem.SectionHeader{
                id:weldset
                text:qsTr("焊接设置")
                style: "subheading"
                showDivider: true;
                iconName: "awesome/gears"
                expanded: true;
                selected: focus
                KeyNavigation.down: teachmodeset
            }
            /*间隙补正(mm)*/
            ListItem.Subtitled{
                id:test
                text:qsTr("间隙补正:");
                anchors.left: parent.left
                anchors.leftMargin: test.visible ? Units.dp(48) : Units.dp(148) ;
                Behavior on anchors.leftMargin{
                    NumberAnimation { duration: 200 }
                }
                backgroundColor: Theme.backgroundColor
                height:teachmodeset.height
                visible: weldset.expanded
                secondaryItem:TextField{
                    id: testfield
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
