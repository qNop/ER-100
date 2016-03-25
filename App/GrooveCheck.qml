import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.2 as Controls
import QtQuick.Window 2.2
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0

FocusScope{
     /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "GrooveCheck"
    anchors{
        left:parent.left
        right:parent.right
        top:parent.top
        bottom: parent.bottom
        leftMargin:visible?0:Units.dp(250)
    }
   Behavior on anchors.leftMargin{NumberAnimation { duration: 200 }}
    /*坡口列表*/
    property var groovestyles: [
       qsTr( "平焊单边V型坡口T接头"), qsTr( "平焊单边V型坡口平对接"),  qsTr("平焊V型坡口平对接"),
       qsTr("横焊单边V型坡口T接头"), qsTr( "横焊单边V型坡口平对接"),
       qsTr("立焊单边V型坡口T接头"),  qsTr("立焊单边V型坡口平对接"), qsTr("立焊V型坡口平对接"),
       qsTr("水平角焊") ]
    property var grooveStyleEnglish: [];
    property list<Action> actions:[
        Action{iconName:"awesome/folder_open_o"},
        Action{iconName:"awesome/save"},
        Action{iconName:"awesome/copy"; visible:grooveTableview.__listView.currentIndex!==-1?true:false},
        Action{iconName:"awesome/paste";visible:grooveTableview.__listView.currentIndex!==-1?true:false},
        Action{iconName:"awesome/edit";visible:grooveTableview.__listView.currentIndex!==-1?true:false}
    ]
    Card{
        anchors{left:parent.left;right:parent.right;bottom: parent.bottom;top:parent.top;margins: Units.dp(12)}
        elevation: 2
        Item{
            id:groovepresettitle
            anchors.top:parent.top
            anchors.left: parent.left
            width: parent.width
            height:Units.dp(64);
            Label{
                anchors.left: parent.left
                anchors.leftMargin: Units.dp(24)
                anchors.verticalCenter: parent.verticalCenter
                text:groovestyles[AppConfig.currentGroove]+"坡口参数"
                style:"title"
                color: Theme.light.shade(0.87)
            }
            Row{
                anchors.right: parent.right
                anchors.rightMargin: Units.dp(24)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Units.dp(24);
                Repeater{
                    model:actions.length
                    delegate: IconButton{
                        action: actions[index]
                        color: Theme.light.iconColor
                        size: Units.dp(27)
                        visible: action.visible
                    }
                }
            }
        }
        Controls.TableView{
            id:grooveTableview
            //不是隔行插入色彩
            alternatingRowColors:false
            anchors{
                left:parent.left
                leftMargin: Units.dp(5)
                right:parent.right
                rightMargin: Units.dp(5)
                top:groovepresettitle.bottom
                bottom: footer.top
            }
            //显示表头
            headerVisible:true
            //Tableview样式
            style:MyTableViewStyle{}
            //选择模式 单选
            selectionMode:Controls.SelectionMode.SingleSelection
            Controls.ExclusiveGroup{  id:checkboxgroup }
            ThinDivider{anchors.bottom:grooveTableview.bottom;color:Palette.colors["grey"]["500"]}
            Controls.TableViewColumn{
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
                        exclusiveGroup:checkboxgroup
                        visible:label.text!==""?true:false
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
            Controls.TableViewColumn{  role:"C1"; title: "板厚 δ\n (mm)";width:Units.dp(100);movable:false;resizable:false}
            Controls.TableViewColumn{  role:"C2"; title: "板厚差 e\n   (mm)";width:Units.dp(100);movable:false;resizable:false}
            Controls.TableViewColumn{  role:"C3"; title: "余高 h\n (mm)";width:Units.dp(100);movable:false;resizable:false}
            Controls.TableViewColumn{  role:"C4"; title: "角度 β1\n  (deg)";width:Units.dp(100);movable:false;resizable:false}
            Controls.TableViewColumn{  role:"C5"; title: "角度 β2\n  (deg)";width:Units.dp(100);movable:false;resizable:false}
            Controls.TableViewColumn{  role:"C6"; title: "间隙 b\n (mm)";width:Units.dp(100);movable:false;resizable:false}
            model:ListModel{id:listItem;
                ListElement{ID:"";C1:"";C2:"";C3:"";C4:"";C5:"";C6:""}
                ListElement{ID:"";C1:"";C2:"";C3:"";C4:"";C5:"";C6:""}
                ListElement{ID:"";C1:"";C2:"";C3:"";C4:"";C5:"";C6:""}
                ListElement{ID:"";C1:"";C2:"";C3:"";C4:"";C5:"";C6:""}
                ListElement{ID:"";C1:"";C2:"";C3:"";C4:"";C5:"";C6:""}
                ListElement{ID:"";C1:"";C2:"";C3:"";C4:"";C5:"";C6:""}
                ListElement{ID:"";C1:"";C2:"";C3:"";C4:"";C5:"";C6:""}
                ListElement{ID:"";C1:"";C2:"";C3:"";C4:"";C5:"";C6:""}}
            Keys.onPressed: {
                var diff = event.key ===Qt.Key_Right ? 50 : event.key === Qt.Key_Left ? -50 :  0
                if(diff !==0){
                    grooveTableview.__horizontalScrollBar.value +=diff;
                    event.accept=true;
                }
            }
        }
        Item{
            id:footer
            height: Units.dp(47)
            anchors{
                left:parent.left
                right:parent.right
                bottom: parent.bottom
            }
            Label{
                id:footerLabel
                anchors.right: parent.right
                anchors.rightMargin: Units.dp(24)
                anchors.verticalCenter: parent.verticalCenter
                text:"总计："+grooveTableview.rowCount+" 条"
            }
        }
    }
}

