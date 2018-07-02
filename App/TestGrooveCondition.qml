import QtQuick 2.4
import Material 0.1 as Material
import Material.Extras 0.1 as JS
import WeldSys.ERModbus 1.0
import WeldSys.WeldMath 1.0
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.1

TestMyConditionView{
    id:root
    objectName:"TestMyConditionView"
    model:grooveModel
    titleName:"坡口条件"
    descriptionComponent: file
    displayColumn: 4

    onUpdateModel: {
        grooveModel.setProperty(selectIndex,"value",value);
    }

    ListModel{
        id:grooveModel
        ListElement{name:"焊接位置";
            groupOrText:true;value:"0";valueType:"";min:0;max:3;increment:1;description:"";modbusReg:0;}
        ListElement{name:"坡口形式";
            groupOrText:true;value:"0";valueType:"";min:0;max:1;increment:1;description:"";modbusReg:0;}
        ListElement{name:"接头形式";
            groupOrText:true;value:"0";valueType:"";min:0;max:1;increment:1;description:"";modbusReg:0;}
        ListElement{name:"背部有无衬垫";
            groupOrText:true;value:"0";valueType:"";min:0;max:2;increment:1;description:"";modbusReg:0;}
    }

    groupModel: groupModels

    property list<ListModel> groupModels:[
        ListModel{ListElement{name:"平焊";enable:true}ListElement{name:"横焊";enable:true}ListElement{name:"立焊";enable:true}ListElement{name:"水平角焊";enable:true}}
        ,ListModel{ListElement{name:"单边V形坡口";enable:true}ListElement{name:"V形坡口";enable:true}}
        ,ListModel{ListElement{name:"T形接头";enable:true}ListElement{name:"对接接头";enable:true}}
        ,ListModel{ListElement{name:"无衬垫";enable:true}ListElement{name:"陶瓷衬垫";enable:true}ListElement{name:"钢衬垫";enable:true}}]

    property var settings

    property var grooveStyleName: [
        "平焊单边V形坡口T接头",  "平焊单边V形坡口平对接",  "平焊V形坡口平对接",
        "横焊单边V形坡口T接头",  "横焊单边V形坡口平对接",
        "立焊单边V形坡口T接头",  "立焊单边V形坡口平对接", "立焊V形坡口平对接",
        "水平角焊" ]
    //前两位代表焊接位置 1位代表坡口形式 1位代表街头样式 2位代表衬垫种类
    property int currentGroove:5

    property list<ListModel> limitedModel:[
        ListModel{
            ListElement{ID:1;c1:"30~40";c2:"9~50";c3:"4~10"}
            ListElement{iD:2;c1:"45~60";c2:"9~32";c3:"0~2"}},
        ListModel{
            ListElement{ID:1;c1:"30~40";c2:"9~60";c3:"4~10"}
            ListElement{iD:2;c1:"45~60";c2:"9~32";c3:"0~2"}},
        ListModel{
            ListElement{ID:1;c1:"30~40";c2:"9~60";c3:"4~10" }},
        ListModel{
            ListElement{ID:1;c1:"30~40";c2:"12~45";c3:"4~10" }
            ListElement{ID:2;c1:"45~60";c2:"12~32";c3:"0~2"}},
        ListModel{
            ListElement{ID:1;c1:"30~40";c2:"12~60";c3:"4~10" }
            ListElement{ID:2;c1:"45~60";c2:"12~32";c3:"0~2"}},
        ListModel{
            ListElement{ID:1;c1:"30~40";c2:"9~40";c3:"4~10" }},
        ListModel{
            ListElement{ID:1;c1:"30~40";c2:"9~60";c3:"4~10" }},
        ListModel{
            ListElement{ID:1;c1:"30~40";c2:"9~60";c3:"4~10" }},
        ListModel{
            ListElement{ID:1;c1:"30~40";c2:"9~60";c3:"9~60" }}
    ]

    onChangeValue: {
        switch(selectIndex){
        case 0:
            var temp=groupModel[1];
            var groove0=temp.get(0).enable;
            var groove1=temp.get(1).enable;
            temp=groupModel[2];
            var connect0=temp.get(0).enable;
            var connect1=temp.get(1).enable;
            var value=selectItem.subValue;
            switch(value){
            case 0:
                if(!groove0) {
                    groupModels[1].setProperty(0,"enable",true);}
                if(!groove1) {
                    groupModels[1].setProperty(1,"enable",true);}
                break;
            case 1:
                break;
            case 2:
                break;
            case 3:
                break;
            }
            break;
        case 1:
            break;
        case 2:
            break;
        case 3:
            break;
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
                    source: "../Pic/"+grooveStyleName[currentGroove>8?0:currentGroove]+".png"
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
                        visible: settings.weldStyle!==3
                        movable:false
                        resizable:false
                    }
                    Controls.TableViewColumn{
                        role: "c2"
                        title: "板厚δ\n (mm)"
                        width:Material.Units.dp(100);
                        visible: settings.weldStyle!==3
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

}
