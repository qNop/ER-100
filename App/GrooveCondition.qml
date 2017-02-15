import QtQuick 2.4
import Material 0.1 as Material
import Material.Extras 0.1 as JS
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
        ListModel{ListElement{ID:1;c1:"30~40";c2:"9~50";c3:"4~10" }
            ListElement{iD:2;c1:"45~60";c2:"9~32";c3:"0~2"}},
        ListModel{ListElement{ID:1;c1:"30~40";c2:"9~60";c3:"4~10" }
            ListElement{iD:2;c1:"45~60";c2:"9~32";c3:"0~2"}},
        ListModel{ListElement{ID:1;c1:"30~40";c2:"9~60";c3:"4~10" }},

        ListModel{ListElement{ID:1;c1:"30~40";c2:"12~55";c3:"4~10" }
            ListElement{ID:2;c1:"45~60";c2:"12~45";c3:"0~2"}},
        ListModel{ListElement{ID:1;c1:"30~40";c2:"12~60";c3:"4~10" }
            ListElement{ID:2;c1:"45~60";c2:"12~45";c3:"0~2"}},

        ListModel{ListElement{ID:1;c1:"30~40";c2:"9~40";c3:"4~10" }},
        ListModel{ListElement{ID:1;c1:"30~40";c2:"9~60";c3:"4~10" }},
        ListModel{ListElement{ID:1;c1:"30~40";c2:"9~60";c3:"4~10" }},
        ListModel{ListElement{ID:1;c1:"30~40";c2:"9~60";c3:"4~10" }},

        ListModel{ListElement{ID:1;c1:"90";c2:"6~";c3:"6~60" }}
    ]

    property var settings

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
                changeGroupCurrent(index,flag);
                if(!flag)
                    currentGroove=2;
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
                changeGroupCurrent(index,flag);
                if(!flag)
                    currentGroove=temp;
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
                changeGroupCurrent(index,flag)
                if(!flag)
                    currentGroove=temp;
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
                changeGroupCurrent(index,flag)
                if(!flag)
                    currentGroove=temp;
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
                changeGroupCurrent(index,flag);
                if(!flag)
                    currentGroove=7;
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
                changeGroupCurrent(index,flag);
                if(!flag)
                    currentGroove=temp;
            }break;
        case 3://水平角焊
            changeEnable(1,0,false)
            changeEnable(1,1,false)
            changeEnable(2,0,false)
            changeEnable(2,1,false)
            changeEnable(3,0,false)
            changeEnable(3,1,false)
            changeEnable(3,2,false)
            changeGroupCurrent(index,flag);
            if(!flag)
                currentGroove=8;
            break;
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
                settings.weldStyle=num
            WeldMath.setWeldStyle(num);
            frame.push("88");frame.push("1");frame.push(String(num));break;
        case 1://坡口形式
            if(flag)
                settings.grooveStyle=num
            WeldMath.setGrooveStyle(num)
            frame.push("89");frame.push("1");frame.push(String(num));break;
        case 2: //接头形式
            if(flag)
                settings.connectStyle=num
            WeldMath.setConnectStyle(num)
            frame.push("90");frame.push("1");frame.push(String(num));break;
        case 3: //衬垫形式
            if(flag)
                settings.bottomStyle=num;
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
                    mipmap: false
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
                        title: settings.weldStyle===3?"脚长ι\n(mm)":"根部间隙b\n     (mm)"
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
        temp.push(settings.weldStyle)
        temp.push(settings.grooveStyle)
        temp.push(settings.connectStyle)
        temp.push(settings.bottomStyle)
        condition=temp;
        console.log(objectName+condition)
        //获取currentGroove 初始化enable
        doNum(root.condition[0],false);
        for(var i=2;i>0;i--){
            selectedIndex=i;
            changeGroupCurrent(root.condition[i],false);
        }
        for( i=0;i<listName.length;i++)
            work(i,false);
    }
}
