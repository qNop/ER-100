import QtQuick 2.4
import Material 0.1 as Material
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.2 as Controls
import QtQuick.Window 2.2

FocusScope{
    anchors.fill: parent
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "GroovePreset"
    /*坡口列表*/
    property var groovestyles: [
        qsTr( "平焊单边V型坡口T接头"), qsTr( "平焊单边V型坡口平对接"),  qsTr("平焊V型坡口平对接"),  qsTr("水平角焊"),
        qsTr("横焊单边V型坡口T接头"), qsTr( "横焊单边V型坡口平对接"),  qsTr("横焊V型坡口平对接"),  qsTr("立焊单边V型坡口平对接"), qsTr("立焊V型坡口平对接")  ]
    property var grooveStyleEnglish: [];
    Material.Card{
        id:card
        elevation: 2
        anchors{
            left:parent.left
            right:parent.right
            top:parent.top
            margins: Material.Units.dp(16)
        }
        height:250
        Material.Label{
            id:title
            anchors.left: parent.left
            anchors.leftMargin: Material.Units.dp(24)
            height: Material.Units.dp(64)
            verticalAlignment:Text.AlignVCenter
            text:"坡口条件"
            style:"title"
            color: Material.Theme.light.shade(0.87)
        }
        Material.Card{
            id:imageCard
            anchors{
                left:parent.left
                leftMargin: Material.Units.dp(16)
                top:title.bottom
            }
            width: grooveImage.width+2*Material.Units.dp(24)
            height:grooveImage.height+2*Material.Units.dp(24)
            flat: true
            Image{
                id:grooveImage
                anchors.centerIn: parent
                source: "../Pic/坡口参数图.png"
                sourceSize.width:  Material.Units.dp(300)
                sourceSize.height:Material.Units.dp(150)
                Material.Ink{
                    anchors.fill: parent
                    onClicked:  overlayView.open(grooveImage)
                }
            }
        }
        Material.OverlayView{
            id:overlayView
            width: 640-Material.Units.dp(64)
            height:480-Material.Units.dp(64)
            Image{
                anchors.fill: parent
                source: "../Pic/坡口参数图.png"
            }
        }
    }
    Material.Card{
        anchors{left:parent.left;right:parent.right;bottom: parent.bottom;top:card.bottom;margins: Material.Units.dp(16)}
        elevation: 2
        Column{
            anchors.fill: parent
            Material.Card{
                id:groovepresettitle
                width: parent.width
                height:Material.Units.dp(64);
                radius:2
                Material.Label{
                    anchors.left: parent.left
                    anchors.leftMargin: Material.Units.dp(24)
                    anchors.verticalCenter: parent.verticalCenter
                    text:"坡口参数"
                    style:"title"
                    color: Material.Theme.light.shade(0.87)
                }
                Row{
                    anchors.right: parent.right
                    anchors.rightMargin: Material.Units.dp(24)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Material.Units.dp(24)
                    Material.IconButton{
                        id:add
                        action: Material.Action{iconName:"content/add"}
                        color: Material.Theme.light.iconColor
                        size: Material.Units.dp(27)
                    }
                    Material.IconButton{
                        id:edit
                        action: Material.Action{iconName:"editor/mode_edit"}
                        color: Material.Theme.light.iconColor
                        size: Material.Units.dp(27)
                    }
                }
            }
            Controls.TableView{
                id:grooveTableview
                //不是隔行插入色彩
                alternatingRowColors:false
                anchors{
                    left:parent.left
                    right:parent.right
                    margins: Material.Units.dp(8)
                }
                //显示表头
                headerVisible:true
                //Tableview样式
                style:MyTableViewStyle{}
                //选择模式 单选
                selectionMode:Controls.SelectionMode.SingleSelection
                Controls.ExclusiveGroup{  id:checkboxgroup }
                Material.ThinDivider{anchors.bottom:grooveTableview.bottom;color:Material.Palette.colors["grey"]["500"]}
                Controls.TableViewColumn{
                    role:"ID"
                    title: "No."
                    width: Material.Units.dp(120);
                    //不可移动
                    movable:false
                    resizable:false
                    delegate: Item{
                        anchors.fill: parent
                        Material.CheckBox{
                            id:checkbox
                            anchors.left: parent.left
                            anchors.leftMargin: Material.Units.dp(16)
                            anchors.verticalCenter: parent.verticalCenter
                            checked: styleData.selected
                            exclusiveGroup:checkboxgroup
                        }
                        Material.Label{
                            anchors.left: checkbox.right
                            anchors.leftMargin:  Material.Units.dp(24)
                            anchors.verticalCenter: parent.verticalCenter
                            text:styleData.value
                            style:"body1"
                            color: Material.Theme.light.shade(0.87)
                        }
                    }
                }
                Controls.TableViewColumn{  role:"C1"; title: "板厚";width:Material.Units.dp(100);movable:false;resizable:false}
                Controls.TableViewColumn{  role:"C2"; title: "板厚差";width:Material.Units.dp(100);movable:false;resizable:false}
                Controls.TableViewColumn{  role:"C3"; title: "余高";width:Material.Units.dp(100);movable:false;resizable:false}
                Controls.TableViewColumn{  role:"C4"; title: "角度1";width:Material.Units.dp(100);movable:false;resizable:false}
                Controls.TableViewColumn{  role:"C5"; title: "角度2";width:Material.Units.dp(100);movable:false;resizable:false}
                Controls.TableViewColumn{  role:"C6"; title: "间隙b";width:Material.Units.dp(100);movable:false;resizable:false}
                model:ListModel{ListElement{ID:"1";C1:"2";C2:"3";C3:"4";C4:"5";C5:"6";C6:"7"}}
                Keys.onPressed: {
                    var diff = event.key ===Qt.Key_Right ? 50 : event.key === Qt.Key_Left ? -50 :  0
                    if(diff !==0){
                        tableview.__horizontalScrollBar.value +=diff;
                        event.accept=true;
                    }
                }
            }
        }
    }
}

