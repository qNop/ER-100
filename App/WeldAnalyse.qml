import QtQuick 2.5
import Material 0.1
import QtQuick.Controls 1.2  as Controls
import QtQuick.Controls.Private 1.0
import QtQuick.Controls.Styles 1.1
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0
FocusScope{
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "WeldAnalyse"
    anchors{
        left:parent.left
        right:parent.right
        top:parent.top
        bottom: parent.bottom
        leftMargin:visible?0:Units.dp(250)
    }
   Behavior on anchors.leftMargin{NumberAnimation { duration: 400 ;easing.type:Easing.InQuad }}
    property alias weldDataModel: tableview.model
   property var groovestyles: [
       qsTr( "平焊单边V型坡口T接头"), qsTr( "平焊单边V型坡口平对接"),  qsTr("平焊V型坡口平对接"),
       qsTr("横焊单边V型坡口T接头"), qsTr( "横焊单边V型坡口平对接"),
       qsTr("立焊单边V型坡口T接头"),  qsTr("立焊单边V型坡口平对接"), qsTr("立焊V型坡口平对接"),
       qsTr("水平角焊")  ]
    property list<Action> actions:[
        Action{iconName:"awesome/folder_open_o"},
        Action{iconName:"awesome/save"},
        Action{iconName:"awesome/copy"; visible:tableview.__listView.currentIndex!==-1?true:false},
        Action{iconName:"awesome/paste";visible:tableview.__listView.currentIndex!==-1?true:false},
        Action{iconName:"awesome/edit";visible:tableview.__listView.currentIndex!==-1?true:false}
    ]
    onFocusChanged: {
        if(focus){
            tableview.forceActiveFocus()
        }
    }
    Card{
        id:table
        anchors{
            fill: parent
            margins: Units.dp(12)
        }
        elevation: 2;
        radius: 2;
        Item{
            id:title
            anchors.top:parent.top//tableview.bottom
            anchors.left: parent.left
            width: parent.width
            height:Units.dp(64);
            Label{
                anchors.left: parent.left
                anchors.leftMargin: Units.dp(24)
                anchors.verticalCenter: parent.verticalCenter
                text:groovestyles[AppConfig.currentGroove]+"焊接规范"
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
            id:tableview
            objectName: "tableview"
            anchors{
                left:parent.left
                leftMargin: Units.dp(5)
                right:parent.right
                rightMargin: Units.dp(5)
                top:title.bottom
                bottom: footer.top
            }
            //不是隔行插入色彩
            alternatingRowColors:false
            //显示表头
            headerVisible:true
            //Tableview样式
            style:MyTableViewStyle{}
            //选择模式 单选
            selectionMode:Controls.SelectionMode.SingleSelection
            Controls.ExclusiveGroup{  id:checkboxgroup }
            ThinDivider{anchors.bottom:tableview.bottom;color:Palette.colors["grey"]["500"]}
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
            Controls.TableViewColumn{
                role: "C1"
                title: "  焊接\n层道数"
                width:Units.dp(70);
                movable:false
                resizable:false
            }
            Controls.TableViewColumn{
                role: "C2"
                title: "电流\n   A"
                width:Units.dp(70);
                movable:false
                resizable:false
            }
            Controls.TableViewColumn{
                role: "C3"
                title: "电压\n   V"
                width:Units.dp(70);
                movable:false
                resizable:false
            }
            Controls.TableViewColumn{
                role: "C4"
                title: "摆幅\n mm"
                width:Units.dp(70);
                movable:false
                resizable:false
            }
            Controls.TableViewColumn{
                role: "C5"
                title: "  摆频\n次/min"
                width:Units.dp(70);
                movable:false
                resizable:false
            }
            Controls.TableViewColumn{
                role: "C6"
                title: "焊接速度\n cm/min"
                width:Units.dp(80);
                movable:false
                resizable:false
            }
            Controls.TableViewColumn{
                role: "C7"
                title: "  焊接线\n  X  mm"
                width:Units.dp(80);
                movable:false
                resizable:false
            }
            Controls.TableViewColumn{
                role: "C8"
                title: "  焊接线\n  Y  mm"
                width:Units.dp(90);
                movable:false
                resizable:false
            }

            Controls.TableViewColumn{
                role: "C9"
                title: "预约\n停止"
                width:Units.dp(70);
                movable:false
                resizable:false
            }
            Keys.onPressed: {
                var diff = event.key ===Qt.Key_Right ? 50 : event.key === Qt.Key_Left ? -50 :  0
                if(diff !==0){
                    tableview.__horizontalScrollBar.value +=diff;
                    event.accept=true;
                }
            }
            Card{
                id:dropdown
                height:40
                visible: false
                TextField{
                    id:textField
                    inputMethodHints:Qt.ImhDigitsOnly
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
                // text:"当前焊接："+" 层"+" 道      "+"总计："+ tableview.columnCount+" 层 "+tableview.rowCount+" 道"
                Connections{
                    target:tableview
                    onRowCountChanged:{
                        var i;
                        for( i=tableview.rowCount-1;i>0;i--){
                            if(weldDataModel.get(i).ID!==""){
                                var str,row,num
                                str=weldDataModel.get(i).C1
                                i+=1;
                                footerLabel.text="当前焊接："+" 层"+" 道      "+"总计："+str.slice(0,1) +" 层 "+i+" 道"
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
}

