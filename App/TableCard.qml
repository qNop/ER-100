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
    id:root
    objectName: "TableCard"
    anchors{left:parent.left;right:parent.right;top:parent.top;margins: Units.dp(12)}
    height: title.height+tableview.height+footerItem.height
    elevation: 2

    property alias firstColumn: firstColumnData

    property string headerTitle: "header"
    property string footerText: "footer"
    property alias table: tableview
    property alias tableData: tableview.data
    property int tableRowCount: 0
    property alias model: tableview.model
    property alias currentRow: tableview.currentRow
    property alias __listview: tableview.__listView

    property alias header: title
    property alias footer: footerItem

    property list<Action> fileMenu;
    property list<Action> editMenu;
    property list<Action> inforMenu;
    property list<Action> funcMenu;

    property list<Action>  actions: [
        Action{iconName:"awesome/file_text_o";name:"文件";hoverAnimation:true;summary: "F1"
            onTriggered: {
                //source为triggered的传递参数
                dropDown.actions=fileMenu;
                dropDown.open(source,0,source.height+3);
                dropDown.place=0;
            }
        },
        Action{iconName:"awesome/edit"; name:"修改";hoverAnimation:true;summary: "F2";
            onTriggered:{
                dropDown.actions=editMenu;
                dropDown.open(source,0,source.height+3);
                dropDown.place=1;
            }
        },
        Action{iconName:"awesome/sticky_note_o";name:"信息";hoverAnimation:true;summary: "F3"
            onTriggered:{
                dropDown.actions=inforMenu;
                dropDown.open(source,0,source.height+3);
                dropDown.place=2;
            }
        },
        Action{iconName:"awesome/stack_overflow";  name:"工具";hoverAnimation:true;summary: "F4"
            onTriggered:{
                dropDown.actions=funcMenu;
                dropDown.open(source,0,source.height+3);
                dropDown.place=3;
            }
        }
    ]

    Item{
        id:title
        anchors{left:parent.left;right:parent.right;top:parent.top}
        height:Units.dp(64);
        Label{id:titleLabel
            anchors{left: parent.left;leftMargin: Units.dp(24);verticalCenter: parent.verticalCenter}
            style:"subheading"
            color: Theme.light.shade(0.87)
            text:headerTitle
            wrapMode: Text.WordWrap
            width: Units.dp(400)
        }
        Row{
            anchors{right: parent.right;rightMargin: Units.dp(14);verticalCenter: parent.verticalCenter}
            spacing: Units.dp(4);
            Repeater{
                id:repeater
                model:actions.length
                delegate:View{
                    id:view
                    width: row.width+Units.dp(8)
                    enabled: actions[index].enabled
                    opacity: enabled ? 1 : 0.6
                    height:Units.dp(36)
                    radius: 4
                    Ink{id:ink
                        anchors.fill: parent
                        onPressed: actions[index].triggered(view);
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
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Units.dp(4);
                        Icon{
                            id:icon
                            source:actions[index].iconSource
                            color: dropDown.place===index&& dropDown.showing ?Theme.accentColor : Theme.light.iconColor
                            size: Units.dp(27)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Label{
                            style: "button"
                            text:actions[index].name;
                            anchors.verticalCenter: parent.verticalCenter
                            color: dropDown.place===index&& dropDown.showing ?Theme.accentColor : Theme.light.textColor
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
                    visible: (typeof(styleData.value)==="number")
                    exclusiveGroup:checkboxgroup
                }
                Label{
                    id:label
                    anchors.left: checkbox.visible?checkbox.right: undefined
                    anchors.leftMargin: checkbox.visible? Units.dp(24) : undefined
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: checkbox.visible?undefined:parent.horizontalCenter
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
    }
    Item{
        id:footerItem
        anchors{top:tableview.bottom;left:parent.left;right:parent.right;}
        height: Units.dp(47)
        Label{
            id:footerLabel
            anchors.left: parent.left
            anchors.leftMargin: footerItem.width-width-Units.dp(16)
            anchors.verticalCenter: parent.verticalCenter
            style:"body1"
            text:footerText
        }
    }
    MenuDropdown{
        id:dropDown
        property int place: 0
    }
    Keys.onPressed: {
        switch(event.key){
        case Qt.Key_F1:
            if(dropDown.showing)
                dropDown.close();
            else{
                actions[0].triggered(repeater.itemAt(0));
                dropDown.place=0;
            }
            event.accepted=true;
            break;
        case Qt.Key_F2:
            if(dropDown.showing)
                dropDown.close();
            else{
                actions[1].triggered(repeater.itemAt(1));
                dropDown.place=1;
            }
            event.accepted=true;
            break;
        case Qt.Key_F3:
            if(dropDown.showing)
                dropDown.close();
            else{
                actions[2].triggered(repeater.itemAt(2));
                dropDown.place=2;
            }
            event.accepted=true;
            break;
        case Qt.Key_F4:
            if(dropDown.showing)
                dropDown.close();
            else{
                actions[3].triggered(repeater.itemAt(3));
                dropDown.place=3;
            }
            event.accepted=true;
            break;
        case Qt.Key_Down:
            if(tableview.currentRow<(tableview.rowCount-1))
                tableview.__incrementCurrentIndex();
            event.accept=true;
            break;
        case Qt.Key_Up:
            if(tableview.currentRow>0)
                tableview.__decrementCurrentIndex();
            event.accept=true;
            break;
        case Qt.Key_Right:
            tableview.__horizontalScrollBar.value +=Units.dp(70);
            event.accept=true;
            break;
        case Qt.Key_Left:
            tableview.__horizontalScrollBar.value -=Units.dp(70);
            event.accept=true;
            break;
        }
    }
}
