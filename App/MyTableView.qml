import QtQuick 2.4
import Material 0.1 as Material
import Material.Extras 0.1
import QtQuick.Controls 1.2
import QtQuick.Controls.Private 1.0
import QtQuick.Controls.Styles 1.1

Material.Card{
    id:table
    anchors.top:parent.top
    anchors.right:parent.right
    anchors.topMargin: 5
    anchors.left: parent.left
    anchors.leftMargin: 20
    anchors.rightMargin: 20
    elevation: 2;
    radius: 2;

    property string titleName;
    property alias table: tableview

    Material.Card{
        id:title
        anchors.top:parent.top//tableview.bottom
        anchors.left: parent.left
        width: parent.width
        height:Material.Units.dp(64);
        radius: parent.radius
        Material.Label{
            anchors.left: parent.left
            anchors.leftMargin: Material.Units.dp(24)
            anchors.verticalCenter: parent.verticalCenter
            text:titleName
            style:"title"
            color: Material.Theme.light.shade(0.87)
        }
        Material.IconButton{
            id:edit
            action: Material.Action{iconName:"editor/mode_edit"}
            color: Material.Theme.light.iconColor
            size: Material.Units.dp(24)
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: Material.Units.dp(24)
        }
        Material.IconButton{
            id:add
            action: Material.Action{iconName:"content/add"}
            color: Material.Theme.light.iconColor
            size: Material.Units.dp(24)
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: edit.left
            anchors.rightMargin: Material.Units.dp(24)
        }
    }
    TableView{
        id:tableview
        objectName: "tableview"
        anchors.top:title.bottom
        //anchors.bottom: parent.bottom
       // anchors.bottomMargin: Material.Units.dp(5);
        anchors.right:parent.right
        anchors.left: parent.left
        anchors.leftMargin: Material.Units.dp(5);
        anchors.rightMargin:Material.Units.dp(5);
        height: Material.Units.dp(200)
        //不是隔行插入色彩
        alternatingRowColors:false
        //显示表头
        headerVisible:true
        //Tableview样式
        style:MyTableViewStyle{}
        //选择模式 单选
        selectionMode:SelectionMode.SingleSelection
        ExclusiveGroup{  id:checkboxgroup }
        Material.ThinDivider{anchors.bottom:tableview.bottom;color:Material.Palette.colors["grey"]["500"]}
        TableViewColumn{
            role:"iD"
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
        TableViewColumn{
            role: "c1"
            title: "  焊接\n层道数"
            width:Material.Units.dp(100);
            movable:false
            resizable:false
        }
        TableViewColumn{
            role: "c2"
            title: "电流\n   A"
            width:Material.Units.dp(90);
            movable:false
            resizable:false
        }
        TableViewColumn{
            role: "c3"
            title: "电压\n   V"
            width:Material.Units.dp(90);
            movable:false
            resizable:false
        }
        TableViewColumn{
            role: "c4"
            title: "摆幅\n mm"
            width:Material.Units.dp(90);
            movable:false
            resizable:false
        }
        TableViewColumn{
            role: "c5"
            title: "  摆频\n次/min"
            width:Material.Units.dp(100);
            movable:false
            resizable:false
        }
        TableViewColumn{
            role: "c6"
            title: "焊接速度\n cm/min"
            width:Material.Units.dp(100);
            movable:false
            resizable:false
        }
        TableViewColumn{
            role: "c7"
            title: "停止预约"
            width:Material.Units.dp(100);
            movable:false
            resizable:false
        }
        model: ListModel{
            id:listModel
            ListElement{
                iD:"1"
                c1:"1/1"
                c2:"300"
                c3:"30.8"
                c4:"3"
                c5:"160"
                c6:"43"
                c7:"连续"
            }
            ListElement{
                iD:"2"
                c1:"2/1"
                c2:"310"
                c3:"31.8"
                c4:"5"
                c5:"100"
                c6:"29"
                c7:"停止"
            }
            ListElement{
                iD:"3"
                c1:"3/1"
                c2:"310"
                c3:"31.8"
                c4:"10"
                c5:"50"
                c6:"20"
                c7:"连续"
            }
            ListElement{
                iD:"4"
                c1:"4/1"
                c2:"220"
                c3:"22.2"
                c4:"6"
                c5:"80"
                c6:"20"
                c7:"连续"
            }
            ListElement{
                iD:"5"
                c1:"4/2"
                c2:"220"
                c3:"22.2"
                c4:"6"
                c5:"80"
                c6:"20"
                c7:"停止"
            }
        }
        Keys.onPressed: {
            var diff = event.key ===Qt.Key_Right ? 50 : event.key === Qt.Key_Left ? -50 :  0
            if(diff !==0){
                tableview.__horizontalScrollBar.value +=diff;
                event.accept=true;
            }
        }
        Material.Card{
            id:dropdown
            height:40
            visible: false
            Material.TextField{
                id:textField
                inputMethodHints:Qt.ImhDigitsOnly
            }
        }
//        onDoubleClicked: {
//             var  columnItem=tableview.getColumn(tableview.__mouseArea.pressedColumn)
//             var mod=listModel.get(tableview.__mouseArea.pressedRow)
//             textField.text=mod[columnItem.role];
//           //  dropdown.open(tableview.__listView.currentItem,Material.Units.dp(4),Material.Units.dp(-4));
//           dropdown.width=tableview.__listView.currentItem.width
//            var rect=tableview.__listView.currentItem.mapToItem(tableview,0,0);
//            console.log(rect);

//            dropdown.visible=true
//        }
    }
}




