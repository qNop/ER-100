import QtQuick 2.4
import Material 0.1 as Material
import Material.Extras 0.1 as JS
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0
import WeldSys.WeldMath 1.0
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.1

MyConditionView{
    id:root
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "GrooveCondition"
    property var weldDirList: ["平焊","横焊","立焊","水平角焊"]
    property var weldDirListEnable: [true,true,true,true]
    property var grooveStyleList: ["单边V形坡口","V形坡口"]
    property var grooveStyleListEnable:  [true,true]
    property var weldConnectList: ["T形接头","对接接头"]
    property var weldConnectListEnable:  [true,true]
    property var bottomStyleList: ["无衬垫","陶瓷衬垫","钢衬垫"]
    property var bottomStyleListEnable:[true,true,true]

    property list<ListModel> limitedModel:[
        ListModel{ListElement{ID:1;c1:"30~40";c2:"9~60";c3:"4~10" }
            ListElement{iD:2;c1:"45~60";c2:"9~45";c3:"0~2"}},
        ListModel{ListElement{ID:1;c1:"30~40";c2:"9~60";c3:"4~10" }
            ListElement{iD:2;c1:"45~60";c2:"9~45";c3:"0~2"}},
        ListModel{ListElement{ID:1;c1:"30~40";c2:"9~60";c3:"4~10" }},

        ListModel{ListElement{ID:1;c1:"30~40";c2:"12~55";c3:"4~10" }
            ListElement{ID:2;c1:"45~60";c2:"12~45";c3:"0~2"}},
        ListModel{ListElement{ID:1;c1:"30~40";c2:"12~60";c3:"4~10" }
            ListElement{ID:2;c1:"45~60";c2:"12~45";c3:"0~2"}},

        ListModel{ListElement{ID:1;c1:"30~40";c2:"9~40";c3:"4~10" }},
        ListModel{ListElement{ID:1;c1:"30~40";c2:"9~60";c3:"4~10" }},
        ListModel{ListElement{ID:1;c1:"30~40";c2:"9~60";c3:"4~10" }},
        ListModel{ListElement{ID:1;c1:"30~40";c2:"9~60";c3:"4~10" }},

        ListModel{ListElement{ID:1;c1:"30~40";c2:"16~60";c3:"4~10" }}
    ]

    property var grooveStyleName: [
        "平焊单边V形坡口T接头",  "平焊单边V形坡口平对接",  "平焊V形坡口平对接",
        "横焊单边V形坡口T接头",  "横焊单边V形坡口平对接",
        "立焊单边V形坡口T接头",  "立焊单边V形坡口平对接", "立焊V形坡口平对接",
        "水平角焊" ]
    //前两位代表焊接位置 1位代表坡口形式 1位代表街头样式 2位代表衬垫种类
    property int currentGroove

    titleName: "坡口条件"

    listValueName:[weldDirList,grooveStyleList,weldConnectList,bottomStyleList]
    listValueNameEnable:[weldDirListEnable,grooveStyleListEnable,weldConnectListEnable,bottomStyleListEnable]

    listName: ["焊接位置","坡口形式","接头形式","背部有无衬垫"]//,"衬垫焊槽宽度","衬垫焊槽深度"]

    description:file;

    descriptionCardHeight: Material.Units.dp(225);

    function doNum(index,flag){
        var oldIndex;
        var temp;
        switch(Number(root.condition[0])){
        case 0://平焊V形坡口
            changeEnable(1,0,true);// V行坡口有效 单边V行也有效
            changeEnable(1,1,true);
            changeEnable(3,0,true)
            changeEnable(3,1,true)
            changeEnable(3,2,true)
            if(Number(root.condition[1])){
                //第三行第1列无效
                changeEnable(2,0,false);
                changeEnable(2,1,true);
                if(!flag)
                    currentGroove=2;
                changeGroupCurrent(index,flag);
                //平焊V形坡口对接
                if(Number(root.condition[2])){

                }else{//无此种情况
                    oldIndex=selectedIndex;
                    selectedIndex=2;
                    changeGroupCurrent(1,false)
                    selectedIndex=oldIndex;
                }
            }else{ //平焊单边V
                //平焊单边V形坡口平对接
                changeEnable(2,0,true);// V行坡口有效 单边V行也有效
                changeEnable(2,1,true);
                if(Number(root.condition[2])){
                    temp=1;
                }else{//平焊单边V形坡口T对接
                    temp=0;
                }
                if(!flag)
                    currentGroove=temp;
                changeGroupCurrent(index,flag);
            }
            break;
        case 1://横焊V形坡口
            changeEnable(1,0,true)
            changeEnable(1,1,false)
            changeEnable(2,0,true)
            changeEnable(2,1,true)
            changeEnable(3,0,true)
            changeEnable(3,1,true)
            changeEnable(3,2,true)
            if(Number(root.condition[1])){
                //平焊单边V形坡口平对接
                if(Number(root.condition[2])){
                    temp=4;
                }else{//平焊单边V形坡口T对接
                    temp=3;
                }
                if(!flag)
                    currentGroove=temp;
                changeGroupCurrent(index,flag)
                //无此种情况 立即更改
                oldIndex=selectedIndex;
                selectedIndex=1;
                changeGroupCurrent(0,true)
                selectedIndex=oldIndex
            }else{ //平焊单边V
                //平焊单边V形坡口平对接
                if(Number(root.condition[2])){
                    temp=4;
                }else{//平焊单边V形坡口T对接
                    temp=3;
                }
                if(!flag)
                    currentGroove=temp;
                changeGroupCurrent(index,flag)
            }break;
        case 2: //立焊V形坡口
            changeEnable(1,0,true);// V行坡口有效 单边V行也有效
            changeEnable(1,1,true);
            changeEnable(3,0,true)
            changeEnable(3,1,true)
            changeEnable(3,2,true)
            if(Number(root.condition[1])){
                //第三行第1列无效
                changeEnable(2,0,false);
                changeEnable(2,1,true);
                if(!flag)
                    currentGroove=7;
                changeGroupCurrent(index,flag);
                //立焊V形坡口对接
                if(Number(root.condition[2])){
                   // temp=7;
                }else{//无此种情况
                    oldIndex=selectedIndex;
                    selectedIndex=2;
                    changeGroupCurrent(1,true)
                    selectedIndex=oldIndex
                }
            }else{ //立焊单边V
                //立焊单边V形坡口平对接
                //第三行第1列无效
                changeEnable(2,0,true);
                changeEnable(2,1,true);
                if(Number(root.condition[2])){
                    temp=6;
                }else{//立焊单边V形坡口T对接
                    temp=5;
                }
                if(!flag)
                    currentGroove=temp;
                changeGroupCurrent(index,flag);
            }break;
        case 3://水平角焊
            changeEnable(1,0,false)
            changeEnable(1,1,false)
            changeEnable(2,0,false)
            changeEnable(2,1,false)
            changeEnable(3,0,false)
            changeEnable(3,1,false)
            changeEnable(3,2,false)
            if(!flag)
                currentGroove=8;
            changeGroupCurrent(index,flag);break;
        }
    }
    onChangeGroup: {
        root.condition[selectedIndex]=index;
        //前三个需要这样处理
        if(selectedIndex<3)
            doNum(index,flag);
        else
            changeGroupCurrent(index,flag);
    }
    onWork:{
        var frame=new Array(0);
        frame.push("W");
        var num=Number(root.condition[index]);
        switch(index){
        case 0:  //焊接位置
            if(flag)
                AppConfig.setWeldDir(num)
            WeldMath.setWeldDir(num);
            frame.push("90");frame.push("1");frame.push(String(currentGroove));break;
        case 1://坡口形式
            if(flag)
                AppConfig.setGrooveStyle(num)
            WeldMath.setGrooveStyle(num)
            frame.push("90");frame.push("1");frame.push(String(currentGroove));break;
        case 2: //接头形式
            if(flag)
                AppConfig.setConnectStyle(num)
            WeldMath.setConnectStyle(num)
            frame.push("90");frame.push("1");frame.push(String(currentGroove));break;
        case 3: //衬垫形式
            if(flag)
                AppConfig.setBottomStyle(num);
            WeldMath.setCeramicBack(num);
            frame.push("91");frame.push("1");frame.push(String(num));break;
        default:frame.length=0;break;
        }
        if(frame.length===4){
            //下发规范
            ERModbus.setmodbusFrame(frame)
        }
        console.log(frame)
        //清空
        frame.length=0;
    }
    Component{
        id:file
        Item{
            anchors.fill: parent
            Material.Label{
                id:descriptiontitle
                anchors.left: parent.left
                anchors.leftMargin: Material.Units.dp(24)
                anchors.top: parent.top
                height: Material.Units.dp(48)
                verticalAlignment:Text.AlignVCenter
                text:qsTr("坡口形状及适用范围");
                style:"subheading"
                color: Material.Theme.light.shade(0.87)
            }
            RowLayout{
                anchors{
                    top:descriptiontitle.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    leftMargin: Material.Units.dp(64)
                    rightMargin: Material.Units.dp(24)
                }
                spacing:Material.Units.dp(64)
                Image{
                    source: "../Pic/"+grooveStyleName[currentGroove]+".png"
                    sourceSize.width: Material.Units.dp(200)
                    mipmap: true
                    width: Material.Units.dp(260)
                }
                Table{
                    id:tableview
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                    __listView.interactive:false
                    height:Material.Units.dp(152)
                    model:limitedModel[currentGroove];
                    Controls.TableViewColumn{
                        role: "c1"
                        title: "坡口角度α\n      (度)"
                        width:Material.Units.dp(100);
                        movable:false
                        resizable:false
                    }
                    Controls.TableViewColumn{
                        role: "c2"
                        title: "板厚δ\n (mm)"
                        width:Material.Units.dp(100);
                        movable:false
                        resizable:false
                    }
                    Controls.TableViewColumn{
                        role: "c3"
                        title: "根部间隙b\n     (mm)"
                        width:Material.Units.dp(100);
                        movable:false
                        resizable:false
                    }
                }
            }
        }
    }
    Component.onCompleted: {
        var temp=new Array(0);
        temp.push(AppConfig.weldDir);
        temp.push(AppConfig.grooveStyle);
        temp.push(AppConfig.connectStyle)
        temp.push(AppConfig.bottomStyle)
        condition=temp;
        //获取currentGroove 初始化enable
        doNum(false);
        for(var i=0;i<listName.length;i++)
            work(i,false);
    }
}

//FocusScope {
//    id:root
//    /*名称必须要有方便 nav打开后寻找焦点*/
//    objectName: "GrooveCondition"
//    anchors{
//        left:parent.left
//        top:parent.top
//        bottom: parent.bottom
//        leftMargin:visible?0:Material.Units.dp(250)
//    }
//    width:parent.width
//    Behavior on anchors.leftMargin{NumberAnimation { duration: 400 }}
//    //改变陶瓷衬垫
//    signal changeCeramicBack(int value)

//    property var weldDirList: ["平焊","横焊","立焊","水平角焊"]
//    property var grooveStyleList: ["单边V形坡口","V形坡口"]
//    property var weldConnectList: ["T形接头","对接接头"]
//    property var bottomStyleList: ["无衬垫","陶瓷衬垫","钢衬垫"]

//    property var repeaterList:[weldDirList,grooveStyleList,weldConnectList,bottomStyleList]

//    property int grooveNum;

//    property var grooveStyleName: [
//         "平焊单边V形坡口T接头",  "平焊单边V形坡口平对接",  "平焊V形坡口平对接",
//        "横焊单边V形坡口T接头",  "横焊单边V形坡口平对接",
//        "立焊单边V形坡口T接头",  "立焊单边V形坡口平对接", "立焊V形坡口平对接",
//        "水平角焊" ]
//    //前两位代表焊接位置 1位代表坡口形式 1位代表街头样式 2位代表衬垫种类
//    property int currentGroove

//    property list<ListModel> limitedModel:[
//        ListModel{ListElement{ID:1;c1:"30~40";c2:"9~60";c3:"4~10" }
//            ListElement{iD:2;c1:"45~60";c2:"9~45";c3:"0~2"}},
//        ListModel{ListElement{ID:1;c1:"30~40";c2:"9~60";c3:"4~10" }
//            ListElement{iD:2;c1:"45~60";c2:"9~45";c3:"0~2"}},
//        ListModel{ListElement{ID:1;c1:"30~40";c2:"9~60";c3:"4~10" }},

//        ListModel{ListElement{ID:1;c1:"30~40";c2:"12~55";c3:"4~10" }
//            ListElement{ID:2;c1:"45~60";c2:"12~45";c3:"0~2"}},
//        ListModel{ListElement{ID:1;c1:"30~40";c2:"12~60";c3:"4~10" }
//            ListElement{ID:2;c1:"45~60";c2:"12~45";c3:"0~2"}},

//        ListModel{ListElement{ID:1;c1:"30~40";c2:"9~40";c3:"4~10" }},
//        ListModel{ListElement{ID:1;c1:"30~40";c2:"9~60";c3:"4~10" }},
//        ListModel{ListElement{ID:1;c1:"30~40";c2:"9~60";c3:"4~10" }},
//        ListModel{ListElement{ID:1;c1:"30~40";c2:"9~60";c3:"4~10" }},

//        ListModel{ListElement{ID:1;c1:"30~40";c2:"16~60";c3:"4~10" }}
//    ]
//    Controls.ExclusiveGroup { id: weldDirGroup; }
//    Controls.ExclusiveGroup { id: grooveStyleGroup;}
//    Controls.ExclusiveGroup { id: weldConnectGroup;}
//    Controls.ExclusiveGroup { id: bottomStylegroup;}
//    Material.Card{
//        anchors{ left:parent.left;right:parent.right;top:parent.top;bottom: descriptionCard.top;margins:Material.Units.dp(12)}
//        elevation: 2
//        Material.Label{
//            id:title
//            anchors.left: parent.left
//            anchors.leftMargin: Material.Units.dp(24)
//            height: Material.Units.dp(64)
//            verticalAlignment:Text.AlignVCenter
//            text:qsTr("坡口条件");
//            style:"subheading"
//            color: Material.Theme.light.shade(0.87)
//        }
//        Column{
//            id:column
//            anchors{top:title.bottom;left:parent.left;right:parent.right;bottom:parent.bottom}
//            /*焊接位置*/
//            ListItem.Subtitled{
//                id:weldDir
//                text:qsTr("焊接位置:");
//                height: Material.Units.dp(48)
//                KeyNavigation.down:grooveStyle.visible?grooveStyle:bottomStyle
//                Keys.onPressed: {
//                    var i = currentGroove & 0x00000003;
//                    switch(event.key){
//                    case Qt.Key_Right:if(i<3) i++;
//                        event.accepted = true;
//                        break;
//                    case Qt.Key_Left: if(i>0) i--;
//                        event.accepted = true;
//                        break; }
//                    currentGroove = ( currentGroove & 0xFFFFFFFC ) | i ;}
//                selected: activeFocus
//                onPressed:forceActiveFocus()
//                secondaryItem:Row{
//                    anchors.verticalCenter: parent.verticalCenter
//                    Repeater{
//                        id:weldDirRepeater
//                        model:weldDirList
//                        delegate:Material.RadioButton{
//                            text:modelData
//                            exclusiveGroup: weldDirGroup
//                            onClicked:{
//                                weldDir.forceActiveFocus()
//                                //与掉低位将index插入进来
//                                currentGroove=(currentGroove&0xFFFFFFFC)|index;}
//                            canToggle: false
//                            //低两位中存在与index相当的数即checked
//                            checked:(currentGroove&0x03)===index?true:false }}}
//                Component.onCompleted: forceActiveFocus();
//            }
//            /*坡口型式*/
//            ListItem.Subtitled{
//                id:grooveStyle
//                text:qsTr("坡口形式:");
//                height: Material.Units.dp(48)
//                KeyNavigation.up: weldDir
//                KeyNavigation.down:weldConnect.visible?weldConnect:bottomStyle
//                selected: activeFocus
//                onPressed:forceActiveFocus()
//                Keys.onPressed: {
//                    var i = currentGroove & 0x00000004;
//                    i>>=2;
//                    switch(event.key){
//                    case Qt.Key_Right: if(i<1) i++;
//                        event.accepted = true; break;
//                    case Qt.Key_Left: if(i>0) i--;
//                        event.accepted = true;break;
//                    }
//                    i<<=2;
//                    currentGroove = ( currentGroove & 0xFFFFFFFB ) | i
//                }
//                onClicked:forceActiveFocus();
//                secondaryItem:Row{
//                    anchors.verticalCenter: parent.verticalCenter
//                    Repeater{
//                        id:grooveStyleRepeater
//                        model:grooveStyleList
//                        delegate:Material.RadioButton{
//                            text:modelData
//                            exclusiveGroup: grooveStyleGroup
//                            onClicked:{
//                                if(enabled)
//                                    currentGroove= ( currentGroove&0xFFFFFFFB)|(index<<2 );
//                                grooveStyle.forceActiveFocus()}
//                            canToggle: false
//                            enabled: {
//                                if(weldDirGroup.current.text==="水平角焊"){
//                                    return false;
//                                }else if((weldDirGroup.current.text==="横焊")&&(index===1)){
//                                    return false;
//                                }else
//                                    return true;
//                            }
//                            onEnabledChanged: {if((!enabled)&&(checked)) currentGroove= currentGroove&0xFFFFFFFB }
//                            checked: ( currentGroove & 0x00000004 ) === (index<<2) ? true : false
//                        }
//                    }
//                }
//            }
//            /*接头形式*/
//            ListItem.Subtitled{
//                id:weldConnect
//                text:qsTr("接头形式:");
//                height: Material.Units.dp(48)
//                KeyNavigation.up: grooveStyle
//                KeyNavigation.down:bottomStyle
//                Keys.onPressed: {
//                    var i = currentGroove & 0x00000008;
//                    i>>=3;
//                    switch(event.key){
//                    case Qt.Key_Right: if(i<1) i++;
//                        event.accepted = true; break;
//                    case Qt.Key_Left: if(i>0) i--;
//                        event.accepted = true;break;
//                    }
//                    i<<=3;
//                    currentGroove = ( currentGroove & 0xFFFFFFF7 ) | i
//                }
//                selected: activeFocus
//                onPressed:forceActiveFocus()
//                secondaryItem:Row{
//                    anchors.verticalCenter: parent.verticalCenter
//                    Repeater{
//                        id:weldConnectRepeater
//                        model:weldConnectList
//                        delegate:Material.RadioButton{
//                            text:modelData
//                            exclusiveGroup: weldConnectGroup
//                            canToggle: false
//                            onClicked:{
//                                if(enabled)
//                                    currentGroove= ( currentGroove&0xFFFFFFF7)|(index<<3 );
//                                weldConnect.forceActiveFocus()}
//                            enabled:{
//                                if((((weldDirGroup.current.text==="平焊")||(weldDirGroup.current.text==="立焊"))&&(grooveStyleGroup.current.text==="V形坡口"))&&(index===0)){
//                                    return false;
//                                }else if(weldDirGroup.current.text==="水平角焊"){
//                                    return false;
//                                }else
//                                    return true;
//                            }
//                            onEnabledChanged: {if((!enabled)&&(checked)) currentGroove=(currentGroove&0xFFFFFFF7)|(1<<3)}
//                            checked:( currentGroove & 0x00000008 ) === (index<<3) ? true : false
//                        }
//                    }
//                }
//            }
//            /*背部有无衬垫*/
//            ListItem.Subtitled{
//                id:bottomStyle
//                text:qsTr("背部有无衬垫:");
//                height: Material.Units.dp(48)
//                KeyNavigation.up: weldConnect.visible?weldConnect:weldDir
//                Keys.onPressed: {
//                    var i = currentGroove & 0x00000030;
//                    i>>=4;
//                    switch(event.key){
//                    case Qt.Key_Right: if(i<3) i++;
//                        event.accepted = true; break;
//                    case Qt.Key_Left: if(i>0) i--;
//                        event.accepted = true;break;
//                    }
//                    i<<=4;
//                    currentGroove = ( currentGroove & 0xFFFFFFCF ) | i
//                }
//                selected: activeFocus
//                onPressed:forceActiveFocus();
//                secondaryItem:Row{
//                    anchors.verticalCenter: parent.verticalCenter
//                    Repeater{
//                        id:bottomStylerepeater
//                        model:bottomStyleList
//                        delegate:Material.RadioButton{
//                            text:modelData
//                            exclusiveGroup: bottomStylegroup
//                            canToggle: false
//                            onClicked:{
//                                if(enabled){
//                                    currentGroove= ( currentGroove&0xFFFFFFCF)|(index<<4 );
//                                    ERModbus.setmodbusFrame(["W","91","1",String(index)]);
//                                     WeldMath.setCeramicBack(index);
//                                    AppConfig.bottomStyle=index;
//                                    console.log(["W","91","1",String(index)]);
//                                }
//                                bottomStyle.forceActiveFocus()}
//                            enabled:true /*{
//                                if((weldDirGroup.current.text==="横焊")&&(index===1)){
//                                    return false;
//                                }else if((grooveStyleGroup.current.text==="单边V形坡口")&&(index===1)){
//                                    return false;
//                                }else if(weldDirGroup.current.text==="水平角焊"){
//                                    return false;
//                                }else
//                                    return true;
//                            }*/
//                            checked: ( currentGroove & 0x00000030 ) === (index<<4) ? true : false
//                        }
//                    }
//                }
//            }
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
//        height:Material.Units.dp(225);
//        Item{
//            id:item
//            anchors{
//                left:parent.left
//                top:parent.top
//                bottom: parent.top
//            }
//            width: Material.Units.dp(260)
//            Column{
//                anchors.fill: parent
//                Material.Label{
//                    id:descriptiontitle
//                    anchors.left: parent.left
//                    anchors.leftMargin: Material.Units.dp(24)
//                    height: Material.Units.dp(64)
//                    verticalAlignment:Text.AlignVCenter
//                    text:qsTr("坡口形状及适用范围");
//                    style:"subheading"
//                    color: Material.Theme.light.shade(0.87)
//                }
//                Image{
//                    anchors.left: parent.left
//                    anchors.leftMargin: Material.Units.dp(64)
//                    source: "../Pic/"+grooveStyleName[grooveNum]+".png"
//                    sourceSize.width: Material.Units.dp(200)
//                    mipmap: true
//                }
//            }
//        }
//        Item{
//            anchors{
//                left:item.right
//                right: parent.right
//                top:parent.top
//                bottom: parent.bottom
//            }
//            Table{
//                id:tableview
//                anchors{
//                    left:parent.left
//                    leftMargin:Material.Units.dp(64)
//                    right:parent.right
//                    rightMargin: Material.Units.dp(24)
//                    verticalCenter: parent.verticalCenter
//                }
//                __listView.interactive:false
//                height:Material.Units.dp(152)
//                model:limitedModel[grooveNum];
//                Controls.TableViewColumn{
//                    role: "c1"
//                    title: "坡口角度α\n      (度)"
//                    width:Material.Units.dp(100);
//                    movable:false
//                    resizable:false
//                }
//                Controls.TableViewColumn{
//                    role: "c2"
//                    title: "板厚δ\n (mm)"
//                    width:Material.Units.dp(100);
//                    movable:false
//                    resizable:false
//                }
//                Controls.TableViewColumn{
//                    role: "c3"
//                    title: "根部间隙b\n     (mm)"
//                    width:Material.Units.dp(100);
//                    movable:false
//                    resizable:false
//                }
//            }
//        }
//    }
//}

