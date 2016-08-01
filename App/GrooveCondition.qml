import QtQuick 2.4
import Material 0.1 as Material
import Material.Extras 0.1 as JS
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.3 as Controls
import QtQuick.LocalStorage 2.0
import QtQuick.Window 2.2

FocusScope {
    id:root
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "GrooveCondition"
    anchors.fill: parent
    property var teachmodemodel: ["自动","半自动","手动"];
    property var startendcheckmodel:["自动","手动"]
    property var teachfisrtpointmodel: ["右方","左方"];
    //坡口数据库英文名称
    property var grooveNameList: ["flatweldsinglebevelgroovet","flatweldsinglebevelgroove","flatweldvgroove","horizontalweldsinglebevelgroovet","horizontalweldsinglebevelgroove","verticalweldsinglebevelgroovet","verticalweldsinglebevelgroove","verticalweldvgroove","flatfillet"]
    property var weldDirList: ["平焊","横焊","立焊","水平角焊"]
    property var grooveStyleList: ["单边V形坡口","V形坡口"]
    property var weldConnectList: ["T形接头","对接接头"]
    property var bottomStyleList: ["无衬垫","陶瓷衬垫","钢衬垫"]
    property var grooveNameCh: ["平焊单边V形坡口T接头","平焊单边V形坡口平对接","平焊V形坡口平对接","横焊单边V形坡口T接头","横焊单边V形坡口平对接","立焊单边V形坡口T接头","立焊单边V形坡口平对接","立焊V形坡口平对接","水平角焊"]

    property string ruleslistName;
    property list<ListModel> limitedModel:[
        ListModel{ListElement{iD:"1";c1:"30~40";c2:"9~70";c3:"4~10" }
            ListElement{iD:"2";c1:"45~60";c2:"9~45";c3:"0~2"}},
        ListModel{ListElement{iD:"1";c1:"30~40";c2:"9~80";c3:"4~10" }
            ListElement{iD:"2";c1:"45~60";c2:"9~45";c3:"0~2"}},
        ListModel{ListElement{iD:"1";c1:"30~40";c2:"9~80";c3:"4~10" }},

        ListModel{ListElement{iD:"1";c1:"30~40";c2:"12~55";c3:"4~10" }
            ListElement{iD:"2";c1:"45~60";c2:"12~45";c3:"0~2"}},
        ListModel{ListElement{iD:"1";c1:"30~40";c2:"12~80";c3:"4~10" }
            ListElement{iD:"2";c1:"45~60";c2:"12~45";c3:"0~2"}},

        ListModel{ListElement{iD:"1";c1:"30~40";c2:"9~50";c3:"4~10" }},
        ListModel{ListElement{iD:"1";c1:"30~40";c2:"9~80";c3:"4~10" }},
        ListModel{ListElement{iD:"1";c1:"30~40";c2:"9~80";c3:"4~10" }},
        ListModel{ListElement{iD:"1";c1:"30~40";c2:"9~80";c3:"4~10" }},

        ListModel{ListElement{iD:"1";c1:"30~40";c2:"16~80";c3:"4~10" }}

    ]
    Connections {
        target:AppConfig
        onCurrentGrooveChanged:{
            ERModbus.setmodbusFrame(["W","90","1",AppConfig.currentGroove.toString()])
            tableview.model=limitedModel[AppConfig.currentGroove];
            var str=Material.UserData.getLastWeldRulesName("weldRulesList"+AppConfig.currentGroove.toString());
            if(str){
                root.ruleslistName=str.toString();
            }
        }
    }
    Component.onCompleted: {
        Material.UserData.openDatabase();
        ERModbus.setmodbusFrame(["W","90","1",AppConfig.currentGroove.toString()])
        tableview.model=limitedModel[AppConfig.currentGroove];
        var str=Material.UserData.getLastWeldRulesName("weldRulesList"+AppConfig.currentGroove.toString());
        if(str){
            root.ruleslistName=str.toString();
        }
    }
    Material.Card{
        anchors{ left:parent.left;right:parent.right;top:parent.top;bottom: descriptionCard.top;margins:Material.Units.dp(12)}
        elevation: 2
        Material.Label{
            id:title
            anchors.left: parent.left
            anchors.leftMargin: Material.Units.dp(24)
            height: Material.Units.dp(64)
            verticalAlignment:Text.AlignVCenter
            text:qsTr("坡口条件");
            style:"subheading"
            color: Material.Theme.light.shade(0.87)
        }
        Column{
            id:column
            anchors{top:title.bottom;left:parent.left;right:parent.right;bottom:parent.bottom}
            /*焊接位置*/
            ListItem.Subtitled{
                id:weldDir
                text:qsTr("焊接位置:");
                leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                Behavior on leftMargin{NumberAnimation { duration: 200 }}
                height: Material.Units.dp(48)
                selected: focus;
                KeyNavigation.down:grooveStyle.visible?grooveStyle:bottomStyle
                Keys.onPressed: {
                    switch(event.key){
                    case Qt.Key_Right:
                        if(weldDirGroup.current){
                            switch(weldDirGroup.current.text){
                            case "平焊":weldDirGroup.current=weldDirRepeater.itemAt(1);break;
                            case "横焊":weldDirGroup.current=weldDirRepeater.itemAt(2);break;
                            case "立焊":weldDirGroup.current=weldDirRepeater.itemAt(3);break; }}
                        event.accepted = true;
                        break;
                    case Qt.Key_Left:
                        if(weldDirGroup.current){
                            switch(weldDirGroup.current.text){
                            case "横焊":weldDirGroup.current=weldDirRepeater.itemAt(0);break;
                            case "立焊":weldDirGroup.current=weldDirRepeater.itemAt(1);break;
                            case "水平角焊":weldDirGroup.current=weldDirRepeater.itemAt(2);break; }}
                        event.accepted = true;
                        break; }}
                onClicked:forceActiveFocus();
                secondaryItem:Row{
                    anchors.verticalCenter: parent.verticalCenter
                    Controls.ExclusiveGroup { id: weldDirGroup;
                        onCurrentChanged:{
                            if((weldDirGroup.current)){
                                switch(weldDirGroup.current.text){
                                case "平焊":
                                    if(grooveStyleGroup.current!==null){
                                        if(grooveStyleGroup.current.text==="单边V形坡口"){
                                            if(weldConnectGroup.current.text!==null){
                                                if(weldConnectGroup.current.text==="T形接头")
                                                    AppConfig.currentGroove=0;
                                                else
                                                    AppConfig.currentGroove=1;}
                                            else
                                                AppConfig.currentGroove=1;
                                        } else{
                                            AppConfig.currentGroove=2;
                                            weldConnectGroup.current=weldConnectRepeater.itemAt(1);
                                        }
                                    }
                                    else{
                                        AppConfig.currentGroove=2;
                                        grooveStyleGroup.current=grooveStyleRepeater.itemAt(1);
                                        weldConnectGroup.current=weldConnectRepeater.itemAt(1);
                                    }
                                    break;
                                case "横焊":
                                    if(grooveStyleGroup.current!==null){
                                        if(grooveStyleGroup.current.text==="单边V形坡口"){
                                            if(weldConnectGroup.current!==null){
                                                if(weldConnectGroup.current.text==="T形接头")
                                                    AppConfig.currentGroove=3;
                                                else
                                                    AppConfig.currentGroove=4;}
                                            else{
                                                AppConfig.currentGroove=4;
                                                weldConnectGroup.current=weldConnectRepeater.itemAt(1);
                                            }}
                                    }
                                    else{
                                        AppConfig.currentGroove=4;
                                        grooveStyleGroup.current=grooveStyleRepeater.itemAt(0);
                                        weldConnectGroup.current=weldConnectRepeater.itemAt(1);
                                    }
                                    break;
                                case "立焊":
                                    if(grooveStyleGroup.current!==null){
                                        if(grooveStyleGroup.current.text==="单边V形坡口"){
                                            if(weldConnectGroup.current!==null){
                                                if(weldConnectGroup.current.text==="T形接头")
                                                    AppConfig.currentGroove=5;
                                                else AppConfig.currentGroove=6;}
                                            else AppConfig.currentGroove=6;}
                                        else {AppConfig.currentGroove=7;
                                            weldConnectGroup.current=weldConnectRepeater.itemAt(1);
                                        }
                                    }else{
                                        AppConfig.currentGroove=7;
                                        grooveStyleGroup.current=grooveStyleRepeater.itemAt(1);
                                        weldConnectGroup.current=weldConnectRepeater.itemAt(1);
                                    }
                                    break;
                                case "水平角焊":AppConfig.currentGroove=8;break; }}}
                    }
                    Repeater{
                        id:weldDirRepeater
                        model:weldDirList
                        delegate:Material.RadioButton{
                            text:modelData
                            exclusiveGroup: weldDirGroup
                            onClicked: weldDir.forceActiveFocus()
                            Component.onCompleted: {
                                if(((AppConfig.currentGroove<3)&&(index===0))||(((AppConfig.currentGroove>2)&&(AppConfig.currentGroove<5))&&(index===1))||(((AppConfig.currentGroove>4)&&(AppConfig.currentGroove<8))&&(index===2))||((AppConfig.currentGroove===8)&&(index===3)))
                                    checked=true;
                            }}}}
                Component.onCompleted: forceActiveFocus();
            }
            /*坡口型式*/
            ListItem.Subtitled{
                id:grooveStyle
                text:qsTr("坡口形式:");
                leftMargin: visible ? Material.Units.dp(48): Material.Units.dp(250) ;
                Behavior on leftMargin{NumberAnimation { duration: 200 }}
                height: Material.Units.dp(48)
                selected: focus;
                KeyNavigation.up: weldDir
                KeyNavigation.down:weldConnect.visible?weldConnect:bottomStyle
                Keys.onPressed: {
                    switch(event.key){
                    case Qt.Key_Right:
                        if(grooveStyleGroup.current)
                            if((grooveStyleGroup.current.text==="单边V形坡口")&&(grooveStyleRepeater.itemAt(1).enabled))
                                grooveStyleGroup.current=grooveStyleRepeater.itemAt(1);
                        event.accepted = true;
                        break;
                    case Qt.Key_Left:
                        if(grooveStyleGroup.current)
                            if(grooveStyleGroup.current.text==="V形坡口")
                                grooveStyleGroup.current=grooveStyleRepeater.itemAt(0);
                        event.accepted = true;
                        break;
                    }
                }
                onClicked:forceActiveFocus();
                secondaryItem:Row{
                    anchors.verticalCenter: parent.verticalCenter
                    Controls.ExclusiveGroup { id: grooveStyleGroup;
                        onCurrentChanged:{
                            if((grooveStyleGroup.current)&&(weldConnectGroup.current)&&(weldDirGroup.current)){
                                if(grooveStyleGroup.current.text==="单边V形坡口"){
                                    if(weldDirGroup.current.text==="平焊"){
                                        if(weldConnectGroup.current.text==="T形接头")
                                            AppConfig.currentGroove=0;
                                        else
                                            AppConfig.currentGroove=1;}
                                    else if(weldDirGroup.current.text==="横焊"){
                                        if(weldConnectGroup.current.text==="T形接头")
                                            AppConfig.currentGroove=3;
                                        else
                                            AppConfig.currentGroove=4; }
                                    else if(weldDirGroup.current.text==="立焊"){
                                        if(weldConnectGroup.current.text==="T形接头")
                                            AppConfig.currentGroove=5;
                                        else
                                            AppConfig.currentGroove=6; }
                                }else if(grooveStyleGroup.current.text==="V形坡口"){
                                    if(weldDirGroup.current.text==="平焊"){
                                        if(weldConnectGroup.current.text!=="T形接头")
                                            AppConfig.currentGroove=2;}
                                    else if(weldDirGroup.current.text==="立焊") {
                                        if(weldConnectGroup.current.text!=="T形接头")
                                            AppConfig.currentGroove=7;}
                                }}
                        }
                    }
                    Repeater{
                        id:grooveStyleRepeater
                        model:grooveStyleList
                        delegate:Material.RadioButton{
                            text:modelData
                            exclusiveGroup: grooveStyleGroup
                            onClicked: grooveStyle.forceActiveFocus()
                            enabled: {
                                if(weldDirGroup.current.text==="水平角焊"){
                                    return false;
                                }else if((weldDirGroup.current.text==="横焊")&&(index===1)){
                                    return false;
                                }else
                                    return true;
                            }
                            onEnabledChanged: {if((!enabled)&&(checked)) grooveStyleGroup.current=grooveStyleRepeater.itemAt(0)}
                            Component.onCompleted: {
                                if((((AppConfig.currentGroove===0)||(AppConfig.currentGroove===1)||(AppConfig.currentGroove===3)||(AppConfig.currentGroove===4)||(AppConfig.currentGroove===5)||(AppConfig.currentGroove===6))&&(index===0))||(((AppConfig.currentGroove===2)||(AppConfig.currentGroove===7))&&(index===1)))
                                    checked=true;
                            }
                        }
                    }
                }
            }
            /*接头形式*/
            ListItem.Subtitled{
                id:weldConnect
                text:qsTr("接头形式:");
                leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                Behavior on leftMargin{NumberAnimation { duration: 200 }}
                height: Material.Units.dp(48)
                selected: focus;
                KeyNavigation.up: grooveStyle
                KeyNavigation.down:bottomStyle
                Keys.onPressed: {
                    switch(event.key){
                    case Qt.Key_Right:
                        if(weldConnectGroup.current)
                            if((weldConnectGroup.current.text==="T形接头")&&(weldConnectRepeater.itemAt(1).enabled))
                                weldConnectGroup.current=weldConnectRepeater.itemAt(1);
                        event.accepted = true;
                        break;
                    case Qt.Key_Left:
                        if(weldConnectGroup.current)
                            if((weldConnectGroup.current.text==="对接接头")&&(weldConnectRepeater.itemAt(0).enabled))
                                weldConnectGroup.current=weldConnectRepeater.itemAt(0);
                        event.accepted = true;
                        break;
                    }
                }
                onClicked:forceActiveFocus();
                secondaryItem:Row{
                    anchors.verticalCenter: parent.verticalCenter
                    Controls.ExclusiveGroup { id: weldConnectGroup;onCurrentChanged:{
                            if((weldConnectGroup.current)&&(weldDirGroup.current)&&(grooveStyleGroup.current)){
                                if(weldConnectGroup.current.text==="T形接头"){
                                    if(weldDirGroup.current.text==="平焊"){
                                        if(grooveStyleGroup.current.text==="单边V形坡口")
                                            AppConfig.currentGroove=0;}
                                    else if(weldDirGroup.current.text==="横焊"){
                                        if(grooveStyleGroup.current.text==="单边V形坡口")
                                            AppConfig.currentGroove=3;}
                                    else if(weldDirGroup.current.text==="立焊"){
                                        if(grooveStyleGroup.current.text==="单边V形坡口")
                                            AppConfig.currentGroove=5;}}
                                else if(weldConnectGroup.current.text==="对接接头"){
                                    if(weldDirGroup.current.text==="平焊"){
                                        if(grooveStyleGroup.current.text==="单边V形坡口")
                                            AppConfig.currentGroove=1;
                                        else AppConfig.currentGroove=2;}
                                    else if(weldDirGroup.current.text==="横焊") {
                                        if(grooveStyleGroup.current.text==="单边V形坡口")
                                            AppConfig.currentGroove=4;}
                                    else if(weldDirGroup.current.text==="立焊"){
                                        if(grooveStyleGroup.current.text==="单边V形坡口")
                                            AppConfig.currentGroove=6;
                                        else AppConfig.currentGroove=7;}}}
                        }}
                    Repeater{
                        id:weldConnectRepeater
                        model:weldConnectList
                        delegate:Material.RadioButton{
                            text:modelData
                            exclusiveGroup: weldConnectGroup
                            onClicked: weldConnect.forceActiveFocus()
                            enabled:{
                                if((((weldDirGroup.current.text==="平焊")||(weldDirGroup.current.text==="立焊"))&&(grooveStyleGroup.current.text==="V形坡口"))&&(index===0)){
                                    return false;
                                }else if(weldDirGroup.current.text==="水平角焊"){
                                    return false;
                                }else
                                    return true;
                            }
                            onEnabledChanged: {if((!enabled)&&(checked)) weldConnectGroup.current=weldConnectRepeater.itemAt(1)}
                            Component.onCompleted: {
                                if((((AppConfig.currentGroove===0)||(AppConfig.currentGroove===4)||(AppConfig.currentGroove===6))&&(index===0))||(((AppConfig.currentGroove===1)||(AppConfig.currentGroove===2)||(AppConfig.currentGroove===4)||(AppConfig.currentGroove===6)||(AppConfig.currentGroove===7))&&(index===1)))
                                    checked=true;
                            }
                        }
                    }
                }
            }
            /*背部有无衬垫*/
            ListItem.Subtitled{
                id:bottomStyle
                text:qsTr("背部有无衬垫:");
                leftMargin: visible ?Material.Units.dp(48): Material.Units.dp(250) ;
                Behavior on leftMargin{NumberAnimation { duration: 200 }}
                height: Material.Units.dp(48)
                selected: focus;
                KeyNavigation.up: weldConnect.visible?weldConnect:weldDir
                Keys.onPressed: {
                    switch(event.key){
                    case Qt.Key_Right:
                        if(bottomStylegroup.current){
                            switch(bottomStylegroup.current.text){
                            case "无衬垫": bottomStylegroup.current = bottomStylerepeater.itemAt(1).enabled?bottomStylerepeater.itemAt(1):bottomStylerepeater.itemAt(2)
                                break;
                            case "陶瓷衬垫": bottomStylegroup.current = bottomStylerepeater.itemAt(2);break; }}
                        event.accepted = true;
                        break;
                    case Qt.Key_Left:
                        if(bottomStylegroup.current){
                            switch(bottomStylegroup.current.text){
                            case "钢衬垫": bottomStylegroup.current = bottomStylerepeater.itemAt(1).enabled?bottomStylerepeater.itemAt(1):bottomStylerepeater.itemAt(0);
                                break;
                            case "陶瓷衬垫": bottomStylegroup.current = bottomStylerepeater.itemAt(0);break; }}
                        event.accepted = true;
                        break;}}
                onClicked:forceActiveFocus();
                secondaryItem:Row{
                    anchors.verticalCenter: parent.verticalCenter
                    Controls.ExclusiveGroup { id: bottomStylegroup;
                        onCurrentChanged:{
                            var frame=["W","91","1"," "];
                            frame[3]=bottomStylegroup.current.text==="无衬垫"?"0":bottomStylegroup.current.text==="陶瓷衬垫"?"1":"2";
                            ERModbus.setmodbusFrame(frame);
                            AppConfig.bottomStyle=Number(frame[3]);
                        }}
                    Repeater{
                        id:bottomStylerepeater
                        model:bottomStyleList
                        delegate:Material.RadioButton{
                            text:modelData
                            exclusiveGroup: bottomStylegroup
                            onClicked: bottomStyle.forceActiveFocus()
                            enabled: {
                                if((weldDirGroup.current.text==="横焊")&&(index===1)){
                                    return false;
                                }else if((grooveStyleGroup.current.text==="单边V形坡口")&&(index===1)){
                                    return false;
                                }else if(weldDirGroup.current.text==="水平角焊"){
                                    return false;
                                }else
                                    return true;
                            }
                            Component.onCompleted: {
                                checked=AppConfig.bottomStyle===index?true:false
                            }
                        }
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
            margins: Material.Units.dp(12)
        }
        elevation: 2
        height:Material.Units.dp(225);
        Item{
            id:item
            anchors{
                left:parent.left
                top:parent.top
                bottom: parent.top
            }
            width: Material.Units.dp(260)
            Column{
                anchors.fill: parent
                Material.Label{
                    id:descriptiontitle
                    anchors.left: parent.left
                    anchors.leftMargin: Material.Units.dp(24)
                    height: Material.Units.dp(64)
                    verticalAlignment:Text.AlignVCenter
                    text:qsTr("坡口形状及适用范围");
                    style:"subheading"
                    color: Material.Theme.light.shade(0.87)
                }
                Image{
                    anchors.left: parent.left
                    anchors.leftMargin: Material.Units.dp(64)
                    source: "../Pic/"+grooveNameCh[AppConfig.currentGroove]+".png"
                    sourceSize.width: Material.Units.dp(200)
                }
            }
        }
        Item{
            anchors{
                left:item.right
                right: parent.right
                top:parent.top
                bottom: parent.bottom
            }
            Controls.TableView{
                id:tableview
                anchors{
                    left:parent.left
                    leftMargin:Material.Units.dp(64)
                    right:parent.right
                    rightMargin: Material.Units.dp(24)
                    verticalCenter: parent.verticalCenter
                }
                height:Material.Units.dp(152)
                //不是隔行插入色彩
                alternatingRowColors:false
                //显示表头
                headerVisible:true
                //Tableview样式
                style:TableStyle{}
                //选择模式 单选
                selectionMode:Controls.SelectionMode.NoSelection
                Material.ThinDivider{anchors.bottom:tableview.bottom;color:Material.Palette.colors["grey"]["500"]}
                Controls.TableViewColumn{
                    role:"iD"
                    title: "No."
                    width: Material.Units.dp(120);
                    //不可移动
                    movable:false
                    resizable:false
                    delegate: Item{
                        anchors.fill: parent
                        Material.CheckBox{
                            id:checkbox
                            anchors.left: parent.left
                            anchors.leftMargin: Material.Units.dp(16)
                            anchors.verticalCenter: parent.verticalCenter
                            checked: true
                            visible: label.text!==""
                        }
                        Material.Label{
                            id:label
                            anchors.left: checkbox.right
                            anchors.leftMargin:  Material.Units.dp(24)
                            anchors.verticalCenter: parent.verticalCenter
                            text:styleData.value
                            style:"body1"
                            color: Material.Theme.light.shade(0.87)
                        }
                    }
                }
                Controls.TableViewColumn{
                    role: "c1"
                    title: "坡口角度A\n      (度)"
                    width:Material.Units.dp(100);
                    movable:false
                    resizable:false
                }
                Controls.TableViewColumn{
                    role: "c2"
                    title: "板厚T\n (mm)"
                    width:Material.Units.dp(100);
                    movable:false
                    resizable:false
                }
                Controls.TableViewColumn{
                    role: "c3"
                    title: "根部间隙G\n     (mm)"
                    width:Material.Units.dp(100);
                    movable:false
                    resizable:false
                }
            }
        }
    }
}

