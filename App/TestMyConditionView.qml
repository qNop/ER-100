import QtQuick 2.4
import Material 0.1 as Material
import Material.Extras 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.3 as QuickControls

Item {
    id:root
    /*名称必须要有方便 nav打开后寻找焦点*/
    // objectName: "MyConditionView"
    anchors{
        left:parent.left
        top:parent.top
        bottom: parent.bottom
        leftMargin:visible?0:Material.Units.dp(250)
    }
    width:parent.width
    property int margins:Material.Units.dp(16)
    onFocusChanged:{
        if(focus){
            listView.forceActiveFocus()
        }
    }

    Behavior on anchors.leftMargin{NumberAnimation { duration: 400 }}

    property int  displayColumn:7

    property var groupModel

    property var listName:["焊接位置","坡口形式","接头形式","背部有无衬垫"]

    property alias model:listView.model

    property alias titleName: title.text

    property var message

    property var descriptionComponent: null

    property alias selectItem: listView.currentItem

    property alias selectIndex: listView.currentIndex

    function getN(num){
        var data=num.toString().split(".");
        if(data.length===0){
            return -1;
        }else if(data.length===1){
            return 0;
        }else{
            return data[1].length;
        }
    }
    signal updateModel(string value)
    signal changeValue()

    function getEnableNum(num,dir){
        var model=groupModel[selectIndex];
        var i;
        if(dir){
            for(i=num+1;i<model.count;i++){
                if(model.get(i).enable)
                    return i
            }
            message.open("该选项无效！")
        }else{
            for(i=num-1;i>=0;i--){
                if(model.get(i).enable)
                    return i
            }
            message.open("该选项无效！")
        }
        return num;
    }

    Material.Card{id:viewCard
        anchors{ left:parent.left;right:parent.right;top:parent.top;margins:Material.Units.dp(12)}
        height:title.height+Material.Units.dp(44)*displayColumn+Material.Units.dp(12)
        elevation: 2
        Material.Label{
            id:title
            anchors.left:parent.left
            anchors.leftMargin:Material.Units.dp(24)
            anchors.top:parent.top
            height: Material.Units.dp(64)
            verticalAlignment:Text.AlignVCenter
            style:"subheading"
            color: Material.Theme.light.shade(0.87)
        }
        ListView{
            id:listView
            anchors{ left:parent.left;right:parent.right;top:title.bottom;}
            height:Material.Units.dp(44)*displayColumn
            clip:true
            highlight:Rectangle{
                anchors {
                    left:parent.left
                    right:parent.right
                }
                height:Material.Units.dp(44);
                color:Material.Palette.colors["grey"]["400"]
            }
            delegate:RowLayout {
                id:sub
                anchors {
                    left: parent.left
                    leftMargin:margins
                    right:parent.right
                    rightMargin:margins
                }
                spacing: Material.Units.dp(16)
                height: Material.Units.dp(44)
                property int subIndex:index
                property string subValue:value
                property bool subGroupOrText: groupOrText
                property string subValueType: valueType
                property int subMin: min
                property int subMax: max
                property double subIncrement: increment
                property string subDescription: description
                property int subModbusReg : modbusReg
                property alias subCurrentGroup: group.current
                Material.Label{
                    id: subLabel
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    Layout.fillWidth: true
                    anchors.verticalCenter: parent.verticalCenter
                    text:name
                    elide: Text.ElideRight
                    style: "subheading"
                    MouseArea{
                        anchors.fill: parent
                        onPressed: {
                            listView.currentIndex=index;
                        }
                    }
                }
                QuickControls.ExclusiveGroup {id:group; }
                Row{
                    Layout.alignment: Qt.AlignVCenter
                    spacing: sub.subGroupOrText?0:Material.Units.dp(16)
                    anchors.verticalCenter: parent.verticalCenter
                    Repeater{
                        id:re
                        visible: groupOrText
                        model:sub.subGroupOrText?groupModel[sub.subIndex]:0
                        delegate:Material.RadioButton{
                            canToggle: false
                            checked: index===Number(sub.subValue)
                            text:name
                            enabled:enable
                            onClicked:{
                                listView.currentIndex=sub.subIndex
                                updateModel(String(index))
                                changeValue()
                            }
                            exclusiveGroup: group
                        }
                    }
                    Material.Label{id:valueLabel;visible:!sub.subGroupOrText;text:sub.subValue}
                    Material.Label{ text:sub.subValueType;visible:!sub.subGroupOrText }
                }
            }
            Keys.onLeftPressed:{
                if(listView.currentIndex<groupModel.length){
                    var num=Number(listView.currentItem.subValue);
                    if(num===0) num=0;
                    else{
                        num=getEnableNum(num,false);
                    }
                    updateModel(String(num))
                }
            }
            Keys.onRightPressed:{
                if(listView.currentIndex<groupModel.length){
                    var num=Number(listView.currentItem.subValue);
                    var max=groupModel[listView.currentIndex].count-1
                    if(num>=max) num=max;
                    else
                        num=getEnableNum(num,true);
                    updateModel(String(num))
                }
            }
            Keys.onVolumeUpPressed: {}
            Keys.onVolumeDownPressed: {}
            Keys.onPressed: {
                var obj,min,max,increment,num,n;
                if(event.key===Qt.Key_Plus){
                    if(listView.currentIndex>=groupModel.length){
                        obj=listView.currentItem;
                        min=obj.subMin;
                        max=obj.subMax;
                        increment=obj.subIncrement;
                        num=Number(obj.subValue);
                        n=getN(increment);
                        if(num<max) num+=increment;
                        else num=max;
                        num=num.toFixed(n);
                        updateModel(String(num))
                        event.accpet=true;
                    }
                }else if(event.key===Qt.Key_Minus){
                    if(listView.currentIndex>=groupModel.length){
                        obj=listView.currentItem;
                        min=obj.subMin;
                        max=obj.subMax;
                        increment=obj.subIncrement;
                        num=Number(obj.subValue);
                        n=getN(increment);
                        if(num>min) num-=increment;
                        else num=min;
                        num=num.toFixed(n);
                        updateModel(String(num))
                        event.accpet=true;
                    }
                }
            }
            Keys.onReleased: {
                if((event.key===Qt.Key_Left)||(event.key===Qt.Key_Right)||(event.key===Qt.Key_VolumeDown)||(event.key===Qt.Key_VolumeUp)||(event.key===Qt.Key_Plus)||(event.key===Qt.Key_Minus)){
                    if((!event.isAutoRepeat))
                        changeValue();
                     event.accpet=true;
                }
            }
        }
    }
    Material.Card{
        id:descriptionCard
        anchors{
            left:parent.left
            right:parent.right
            top:viewCard.bottom
            bottom: parent.bottom
            margins:Material.Units.dp(12)
        }
        elevation: 2
        Loader{
            id:loader
            anchors.fill: parent
            sourceComponent: root.descriptionComponent===null?file:root.descriptionComponent
        }
    }
    Component{
        id:file
        Item{
            anchors.fill: parent
            Material.Label{
                id:descriptiontitle
                anchors.left: parent.left
                anchors.leftMargin: Material.Units.dp(24)
                anchors.top:parent.top
                height: Material.Units.dp(64)
                verticalAlignment:Text.AlignVCenter
                text:"描述信息";
                style:"subheading"
                color: Material.Theme.light.shade(0.87)
            }
            Material.Label{
                id:descriptionlabel
                anchors.left: parent.left
                anchors.leftMargin: Material.Units.dp(48)
                anchors.top:descriptiontitle.bottom
                text:selectItem.subDescription
            }
        }
    }

}
