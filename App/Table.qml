import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.2 as Controls
import QtQuick.Window 2.2
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0
import WeldSys.WeldMath 1.0
import QtQuick.Layouts 1.1

Card{
    property alias firstColumn: firstColumnData
    property list<Action> actions
    property alias header: title
    property alias footer: footerItem
    property alias table: tableview
    property alias tableData: tableview.data
    property int tableRowCount: 0
    anchors{left:parent.left;right:parent.right;top:parent.top;margins: Units.dp(12)}
    height: title.height+tableview.height+footer.height
    elevation: 2
    Item{
        id:title
        property alias text: titleLabel.text
        anchors{left:parent.left;right:parent.right;top:parent.top}
        height:Units.dp(64);
        Label{id:titleLabel
            anchors{left: parent.left;leftMargin: Units.dp(24);verticalCenter: parent.verticalCenter}
            style:"subheading"
            color: Theme.light.shade(0.87)
            text:"header"
            wrapMode: Text.WordWrap
            width: Units.dp(400)
        }
        Row{
            anchors{right: parent.right;rightMargin: Units.dp(14);verticalCenter: parent.verticalCenter}
            spacing: Units.dp(8);
            Repeater{
                model:actions.length
                delegate:View{
                    width: row.width+Units.dp(4)
                    enabled: actions[index].enabled
                    opacity: enabled ? 1 : 0.6
                    height:Units.dp(36)
                    Ink{id:ink
                        anchors.fill: parent
                        onPressed: actions[index].triggered();
                        enabled: actions[index].enabled
                        circular: true
                        centered: true
                    }
                    Tooltip{
                        text:actions[index].summary
                        mouseArea: ink
                    }
                    Row{
                        id:row
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Units.dp(4);
                        Icon{
                            id:icon
                            source:actions[index].iconSource
                            color: Theme.accentColor
                            size: Units.dp(27)
                        }
                        Label{
                            style: "button"
                            text:actions[index].name;
                        }
                    }
                }
            }
        }
    }
    Controls.TableView{
        id:tableview
        anchors{left:parent.left;leftMargin: Units.dp(5);right:parent.right;rightMargin: Units.dp(5);top:title.visible?title.bottom:parent.top}
        height:tableRowCount*Units.dp(48)+Units.dp(56)
        sortIndicatorVisible:true
        //不是隔行插入色彩
        alternatingRowColors:false
        //显示表头
        headerVisible:true
        //Tableview样式
        style:TableStyle{}
        //选择模式 单选
        selectionMode:Controls.SelectionMode.SingleSelection
        Controls.ExclusiveGroup{  id:checkboxgroup }
        ThinDivider{anchors.bottom:tableview.bottom;color:Palette.colors["grey"]["500"]}
        Controls.TableViewColumn{
            id:firstColumnData
            role:"ID"
            title: "No."
            width: Units.dp(120);
            //不可移动
            movable:false
            resizable:false
            delegate: Item{
                anchors.fill: parent
                CheckBox{
                    id:checkbox
                    anchors.left: parent.left
                    anchors.leftMargin: Units.dp(16)
                    anchors.verticalCenter: parent.verticalCenter
                    checked: styleData.selected
                    visible: label.text!==""
                    exclusiveGroup:checkboxgroup
                }
                Label{
                    id:label
                    anchors.left: checkbox.right
                    anchors.leftMargin:  Units.dp(24)
                    anchors.verticalCenter: parent.verticalCenter
                    text:styleData.value
                    style:"body1"
                    color: Theme.light.shade(0.87)
                }
            }
        }
        __listView.add:Transition{
            NumberAnimation { properties: "x"; from:tableview.width-100;duration: 200 }
        }
        __listView.removeDisplaced:Transition{
            NumberAnimation { properties: "y";duration: 200 }
        }
        ///添加内外停留时间 两个参数
        Keys.onPressed: {
            var diff = event.key ===Qt.Key_Right ? Units.dp(70) : event.key === Qt.Key_Left ? -Units.dp(70) :  0
            if(diff !==0){
                tableview.__horizontalScrollBar.value +=diff;
                event.accept=true;
            }
        }
    }
    Item{
        id:footerItem
        anchors{top:tableview.bottom;left:parent.left;right:parent.right;}
        property alias text: footerLabel.text
        height: Units.dp(47)
        Label{
            id:footerLabel
            anchors.left: parent.left
            anchors.leftMargin: Units.dp(16)
            anchors.verticalCenter: parent.verticalCenter
            style:"body1"
            text:"footer"
        }
//        Row{
//            anchors{right:parent.right;rightMargin: Units.dp(14);verticalCenter: parent.verticalCenter}
//            spacing: Units.dp(24);
//            layoutDirection:Qt.RightToLeft
//            IconButton{
//                action:Action{
//                    iconName: "hardware/keyboard_arrow_right"
//                }
//                size: Units.dp(24)
//            }
//            IconButton{
//                action:Action{
//                    iconName: "hardware/keyboard_arrow_left"
//                }
//                size: Units.dp(24)
//            }
//            Label{
//                style:"body1"
//            }
//        }
    }
}
