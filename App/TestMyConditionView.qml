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
    property var weldDirList: ["平焊","横焊","立焊","水平角焊"]
    property var weldDirListEnable: [true,true,true,true]
    property var grooveStyleList: ["单边V形坡口","V形坡口"]
    property var grooveStyleListEnable:  [true,true]
    property var weldConnectList: ["T形接头","对接接头"]
    property var weldConnectListEnable:  [true,true]
    property var bottomStyleList: ["无衬垫","陶瓷衬垫","钢衬垫"]
    property var bottomStyleListEnable:[true,true,true]

    property var groupModel: [weldDirList,grooveStyleList,weldConnectList,bottomStyleList]

    property var listName:["焊接位置","坡口形式","接头形式","背部有无衬垫"]
    //选中行
    property alias selectIndex:listView.currentIndex;
    //选中页
    property int selectPage:0

    property var model: grooveModel

    property var message

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

    function updatePage(){
            if(selectPage<=(model.count/7)){
                 displayModel.clear();
                for(var i=0;i<7;i++)
                displayModel.append(model.get(selectPage*7+i));
            }else
                message.open("超出最大队列！")
    }
 /*   function updateModel(data){

        displayModel.setProperty(selectIndex,"value",String(data));

    }*/

    Component.onCompleted: {
           updatePage()
    }

    ListModel{
            id:displayModel
            ListElement{name:"";
                groupOrText:true;
                value:"0"
                valueType:""
                min:0
                max:100
                increment:0.1
                description:""
            }
        }

    ListModel{
        id:grooveModel
        ListElement{name:"焊接位置";
            groupOrText:true;
            value:"0"
            valueType:""
            min:0
            max:100
            increment:0.1
            description:""
        }
        ListElement{name:"坡口形式";
            groupOrText:true;
            value:"1"
            valueType:""
            min:0
            max:100
            increment:0.1
            description:""
        }
        ListElement{name:"接头形式";
            groupOrText:true;
            value:"1"
            valueType:""
            min:0
            max:100
            increment:0.1
            description:""
        }
        ListElement{name:"背部有无衬垫";
            groupOrText:true;
            value:"2"
            valueType:""
            min:0
            max:100
            increment:0.1
            description:""
        }
        ListElement{name:"接头位置";
            groupOrText:false;
            value:"50"
            valueType:"MM"
            min:1
            max:100
            increment:0.1
            description:""
        }
        ListElement{name:"接头位置";
            groupOrText:false;
            value:"50"
            valueType:"MM"
            min:1
            max:100
            increment:0.1
            description:""
        }

        ListElement{name:"接头位置";
            groupOrText:false;
            value:"50"
            valueType:"MM"
            min:1
            max:100
            increment:0.1
            description:""
        }
        ListElement{name:"接头位置";
            groupOrText:false;
            value:"50"
            valueType:"MM"
            min:1
            max:100
            increment:0.1
            description:""
        }
        ListElement{name:"接头位置";
            groupOrText:false;
            value:"50"
            valueType:"MM"
            min:1
            max:100
            increment:0.1
            description:""
        }
        ListElement{name:"接头位置";
            groupOrText:false;
            value:"50"
            valueType:"MM"
            min:1
            max:100
            increment:0.1
            description:""
        }
        ListElement{name:"接头位置";
            groupOrText:false;
            value:"50"
            valueType:"MM"
            min:1
            max:100
            increment:0.1
            description:""
        }
        ListElement{name:"接头位置";
            groupOrText:false;
            value:"50"
            valueType:"MM"
            min:1
            max:100
            increment:0.1
            description:""
        }
        ListElement{name:"接头位置";
            groupOrText:false;
            value:"50"
            valueType:"MM"
            min:1
            max:100
            increment:0.1
            description:""
        }
        ListElement{name:"接头位置";
            groupOrText:false;
            value:"50"
            valueType:"MM"
            min:1
            max:100
            increment:0.1
            description:""
        }
        ListElement{name:"接头位置";
            groupOrText:false;
            value:"50"
            valueType:"MM"
            min:1
            max:100
            increment:0.1
            description:""
        }
    }
    ColumnLayout{
        anchors{ left:parent.left;right:parent.right;top:parent.top;bottom: parent.bottom;margins:Material.Units.dp(12)}
        spacing: Material.Units.dp(12)
        Material.Card{
            anchors{ left:parent.left;right:parent.right;}
            Layout.fillHeight: true
        }
        Material.Card{id:dcr
            anchors{ left:parent.left;right:parent.right;}
            height: Material.Units.dp(110)
        }
    }



    ListView{
        id:listView
        anchors{ left:parent.left;right:parent.right;top:parent.top;bottom:parent.bottom;}
        model:displayModel
        clip:true
        header:   Material.Label{
            id:title
            anchors.left:parent.left
            anchors.leftMargin: Material.Units.dp(24)
            height: Material.Units.dp(64)
            verticalAlignment:Text.AlignVCenter
            style:"subheading"
            text:"坡口条件"
            color: Material.Theme.light.shade(0.87)
        }
        footerPositioning:ListView.PullBackFooter
        footer:Material.Label{
            id:title1
            anchors.left:parent.left
            anchors.leftMargin: Material.Units.dp(24)

            height: Material.Units.dp(64)
            verticalAlignment:Text.AlignVCenter
            style:"subheading"
            text:"坡口条件"
            color: Material.Theme.light.shade(0.87)
        }
        highlight:Rectangle{
            anchors {
                left: parent.left
                leftMargin:Material.Units.dp(12)
                right:parent.right
                rightMargin:Material.Units.dp(12)
            }
            height:Material.Units.dp(44);
            color: Material.Palette.colors["grey"]["400"]
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
            Material.Label{
                id: subLabel
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.fillWidth: true
                anchors.verticalCenter: parent.verticalCenter
                text:name
                elide: Text.ElideRight
                style: "subheading"

            }
            Row{
                Layout.alignment: Qt.AlignVCenter
                spacing: sub.subGroupOrText?0:Material.Units.dp(16)
                anchors.verticalCenter: parent.verticalCenter
                QuickControls.ExclusiveGroup {id:group; }
                Repeater{
                    id:re
                    visible: groupOrText
                    model:sub.subGroupOrText?subgroupModel[(sub.subIndex+selectPage*7)]:0
                    delegate:Material.RadioButton{
                        canToggle: false
                        checked: index===Number(sub.subValue)
                        text:modelData
                        onClicked:{
                            listView.currentIndex=sub.subIndex
                            //sub.subValue=index;
                           displayModel.setProperty(listView.currentIndex,"value",String(index));
                        }
                        exclusiveGroup: group
                    }
                }
                Material.Label{id:valueLabel;visible:!sub.subGroupOrText;text:sub.subValue}
                Material.Label{ text:sub.subValueType;visible:!sub.subGroupOrText }
            }
        }
        Keys.onLeftPressed:{
            if((listView.currentIndex+selectPage*7)<groupModel.length){
                var num=Number(listView.currentItem.subValue);
                if(num===0) num=0;
                else
                    num--;
                displayModel.setProperty(listView.currentIndex,"value",String(num));
            }
        }
        Keys.onRightPressed:{
            if((listView.currentIndex+selectPage*7)<groupModel.length){
                var num=Number(listView.currentItem.subValue);
                var max=groupModel[listView.currentIndex].length-1
                if(num>=max) num=max;
                else
                    num++;
                displayModel.setProperty(listView.currentIndex,"value",String(num));
            }
        }
        Keys.onVolumeUpPressed: {}
        Keys.onVolumeDownPressed: {}
        Keys.onPressed: {
            var obj,min,max,increment,num,n;
            if(event.key===Qt.Key_Plus){
                if((listView.currentIndex+selectPage*7)>=groupModel.length){
                    obj=listView.currentItem;
                    min=obj.subMin;
                    max=obj.subMax;
                    increment=obj.subIncrement;
                    num=Number(obj.subValue);
                    n=getN(increment);
                    if(num<max) num+=increment;
                    else num=max;
                    num=num.toFixed(n);
                    displayModel.setProperty(listView.currentIndex,"value",String(num));
                    event.accpet=true;
                }
            }else if(event.key===Qt.Key_Minus){
                if((listView.currentIndex+selectPage*7)>=groupModel.length){
                    obj=listView.currentItem;
                    min=obj.subMin;
                    max=obj.subMax;
                    increment=obj.subIncrement;
                    num=Number(obj.subValue);
                    n=getN(increment);
                    if(num>min) num-=increment;
                    else num=min;
                    num=num.toFixed(n);
                    displayModel.setProperty(listView.currentIndex,"value",String(num));
                    event.accpet=true;
                }
            }
        }
    }

    /* ListItem.Subtitled {
            id:sub
            text:name
            height: Material.Units.dp(44)
            property int subIndex:index
            secondaryItem:Row{
                anchors.verticalCenter: parent.verticalCenter
                QuickControls.ExclusiveGroup {id:group }
                Repeater{
                    id:re
                    visible: groupOrText
                    model:groupModel[sub.subIndex]
                    delegate:Material.RadioButton{
                        text:modelData
                        onClicked:{
                            console.log(text)
                        }
                        exclusiveGroup: group
                    }
                }
                Material.Label{id:valueLabel;
                    visible: groupOrText
                    text: valueText
                }
            }
        }
    }*/

}
