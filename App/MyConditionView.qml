import QtQuick 2.4
import Material 0.1 as Material
import Material.Extras 0.1 as JS
import WeldSys.ERModbus 1.0
import WeldSys.WeldMath 1.0
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.3 as QuickControls
import QtQuick.LocalStorage 2.0
import QtQuick.Window 2.2

Item{
    id:root
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "MyConditionView"
    anchors{
        left:parent.left
        top:parent.top
        bottom: parent.bottom
        leftMargin:visible?0:Material.Units.dp(250)
    }
    width:parent.width
    Behavior on anchors.leftMargin{NumberAnimation { duration: 400 }}

    property bool writeEnable: false
    //用户类别
    property bool superUser
    //作为数据的临时缓存数组 condition必须在加载后一次性赋值。
    property var condition:[]
    //选定的行
    property int selectedIndex
    //行名称
    property var listName
    //带radioButton的行数据
    property var listValueName
    //带radioButton的行的数据有效
    property var listValueNameEnable
    //描述信息
    property var listDescription
    //行内数据单位
    property var valueType
    //提示信息
    property Item message
    //标题名称
    property alias titleName:title.text

    property alias descriptionCardHeight: descriptionCard.height
    //负责选择
    signal changeSelectedIndex(int index)
    //负责处理 按键+触摸的 操作合并
    signal changeGroup(int index,bool flag)
    //负责处理 改变控件状态 +dowork
    signal changeGroupCurrent(int index,bool flag)
    //负责处理 TEXT
    signal changeText(double value,bool flag)
    //负责处理数据存储 数据的下发
    signal work(int index,bool flag)
    //负责处理按键减 对text 里面一定要 发生 changeText 信号
    signal keyDec(int index,bool flag)
    //负责处理俺家加 对text
    signal keyInc(int index,bool flag)
    //负责处理enable subIndex 第几行 index第几列 value 数值
    signal changeEnable(int subIndex,int index,bool value)
    signal changeEnableList(int subIndex,int index,bool value)
    //描述空间
    property var description:null

    function getEnable(subIndex,index,value){
        return root.listValueNameEnable[subIndex][index];
    }

    onChangeEnable: {
        if(getEnable(subIndex,index,value)!==value)
            changeEnableList(subIndex,index,value)
    }

    onChangeSelectedIndex: {
        selectedIndex=index;
    }

    onChangeGroupCurrent: {
        root.condition[selectedIndex]=index;
        if(!flag)
            work(selectedIndex,true);
    }

    onChangeText:{
        root.condition[selectedIndex]=value;
        if(!flag)
            work(selectedIndex,true);
    }

    //按键释放阶段写入或下发参数
    Keys.onReleased: {
        var left=Number(root.condition[selectedIndex]-1);
        var right=Number(root.condition[selectedIndex]+1);
        if(left<0) left=0;
        if((writeEnable)&&(!event.isAutoRepeat)){//按键写使能打开且 不是连续触发则关闭写使能
                writeEnable=false;
        }
        if(selectedIndex<listValueNameEnable.length)
            if(right>=listValueNameEnable[selectedIndex].length) right=listValueNameEnable[selectedIndex].length-1;
        if((event.key===Qt.Key_Left)||(event.key===Qt.Key_Right)){
            if((selectedIndex<listValueName.length)&&
                    (listValueNameEnable[selectedIndex][
                         event.key===Qt.Key_Left?left:right])){
                changeGroup(event.key===Qt.Key_Left?left:right,event.isAutoRepeat);
            }else{
                message.open("该选项无效！")
            }
        }else if((event.key===Qt.Key_VolumeDown)||(event.key===Qt.Key_VolumeUp)||(event.key===Qt.Key_Plus)||(event.key===Qt.Key_Minus)){
            if(selectedIndex>=(listValueName.length))
                changeText(root.condition[selectedIndex],event.isAutoRepeat);
        }
        event.accpet=true;
    }
    Keys.onPressed: {
        var temp;
        var num=Number(root.condition[selectedIndex]);
        writeEnable=true;
        if(event.key===Qt.Key_Down){
            if(selectedIndex<(listName.length-1)){
                selectedIndex++;
            }
        }else if(event.key===Qt.Key_Up){
            if(selectedIndex>0){
                selectedIndex--;
            }
        }else if(event.key===Qt.Key_VolumeDown){
            if(selectedIndex>=(listValueName.length)){
                keyDec(selectedIndex-listValueName.length,event.isAutoRepeat);
            }
        }else if(event.key===Qt.Key_VolumeUp){
            if(selectedIndex>=(listValueName.length)){
                keyInc(selectedIndex-listValueName.length,event.isAutoRepeat)
            }
        }else if(event.key===Qt.Key_Plus){
            if(selectedIndex>=(listValueName.length)){
                keyInc(selectedIndex-listValueName.length,event.isAutoRepeat);
            }
        }else if(event.key===Qt.Key_Minus){
            if(selectedIndex>=(listValueName.length)){
                keyDec(selectedIndex-listValueName.length,event.isAutoRepeat)
            }
        }

        event.accpet=true;
    }
    //滚屏
    onSelectedIndexChanged: {
        switch(selectedIndex){
        case 0:flickable.contentY=0;break;
        case 6:flickable.contentY=0;break;
        case 7:flickable.contentY=Material.Units.dp(44)*7;break;
        case 13:flickable.contentY=Material.Units.dp(44)*7;break;
        case 14:flickable.contentY=Material.Units.dp(44)*14;break;
        case 20:flickable.contentY=Material.Units.dp(44)*14;break;
        case 21:flickable.contentY=Material.Units.dp(44)*21;break;
        case 27:flickable.contentY=Material.Units.dp(44)*21;break;
        case 28:flickable.contentY=Material.Units.dp(44)*28;break;
        case 34:flickable.contentY=Material.Units.dp(44)*28;break;
        case 35:flickable.contentY=Material.Units.dp(44)*34;break;
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
                Repeater{
                    model: listValueName.length
                    delegate:ListItem.Subtitled{
                        id:sub
                        property int subIndex:index
                        text:listName[index]
                        height: Material.Units.dp(44)
                        selected: selectedIndex===index
                        onPressed: changeSelectedIndex(index)
                        Connections{
                            target: root
                            onChangeGroupCurrent:{
                                if(sub.selected)
                                    group.current=re.itemAt(index);
                            }
                            onChangeEnableList:{
                                if(sub.subIndex===subIndex){
                                    re.itemAt(index).enabled=value;
                                    listValueNameEnable[subIndex][index]=value;
                                }
                            }
                        }
                        secondaryItem:Row{
                            anchors.verticalCenter: parent.verticalCenter
                            QuickControls.ExclusiveGroup {id:group }
                            Repeater{
                                id:re
                                model:sub.subIndex<listValueName.length?listValueName[sub.subIndex]:listName.length
                                delegate:Material.RadioButton{
                                    canToggle: false
                                    text:modelData
                                    checked:index===root.condition[sub.subIndex]
                                    onClicked:{
                                        //改变选择行
                                        changeSelectedIndex(sub.subIndex);
                                        //改变选择控件状态 下发命令
                                        changeGroup(index,false);
                                    }
                                    exclusiveGroup: group
                                }
                            }
                        }
                    }
                }
                Repeater{
                    model:listName.length-listValueName.length
                    delegate:ListItem.Subtitled{
                        id:downSub
                        property int num: listValueName.length+index
                        text:listName[num]
                        height: Material.Units.dp(44)
                        selected: selectedIndex===num
                        onPressed: changeSelectedIndex(num)
                        Connections{
                            target: root
                            onChangeText:{
                                if(downSub.selected){
                                    valueLabel.text=String(value);
                                }
                            }
                        }
                        secondaryItem:Row{
                            spacing: Material.Units.dp(16)
                            anchors.verticalCenter: parent.verticalCenter
                            Material.Label{id:valueLabel;
                                text:String(root.condition[downSub.num]);
                            }
                            Material.Label{ text:valueType[index] }
                        }
                    }
                }
            }
        }
        Material.Scrollbar {id:scrollbar;flickableItem:flickable ;
            onMovingChanged: {scrollbar.hide.stop();scrollbar.show.start();}
            Component.onCompleted:{scrollbar.hide.stop();scrollbar.show.start();}
        }
    }
    Component{
        id:file
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
                text:selectedIndex<listDescription.length?listDescription[selectedIndex]:""
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
        height:Material.Units.dp(110);
        Loader{
            anchors.fill: parent;
            sourceComponent: root.description===null?file:root.description
        }
    }
}
