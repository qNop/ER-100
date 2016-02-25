import QtQuick 2.4
import Material 0.1 as Material
import Material.Extras 0.1
import QtQuick.Controls 1.2
import Material.ListItems 0.1

Material.Card{
    anchors.top:parent.top//tableview.bottom
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 24
    anchors.right:parent.right
    anchors.topMargin: 24
    anchors.left: parent.left
    anchors.leftMargin: 24
    anchors.rightMargin: 24
    elevation: 2;
    radius: 5;
    Material.Card{
        id:title
        anchors.top:parent.top//tableview.bottom
        anchors.left: parent.left
        width: parent.width
        height:Material.Units.dp(64);
        Material.Label{
            anchors.left: parent.left
            anchors.leftMargin:  24
            anchors.verticalCenter: parent.verticalCenter
            text:"MyTableView-Material"
            style:"title"
            color: Material.Theme.light.shade(0.87)
        }
        Material.IconButton{
            id:edit
            action: Material.Action{iconName:"editor/mode_edit"}
            color: Material.Theme.lght.iconColor
            size: Material.Units.dp(24)
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 24
        }
        Material.IconButton{
            id:add
            action: Material.Action{iconName:"content/add"}
            color: Material.Theme.light.iconColor
            size: Material.Units.dp(24)
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: edit.left
            anchors.rightMargin: 24
        }
    }

    TableView{
        id:tabview

        anchors.top:title.bottom
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right:parent.right
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.rightMargin: 5

        alternatingRowColors:false
        headerVisible:true
        style:MyTableViewStyle{}

        TableViewColumn{
            role:"iD"
            title: "ID"
            width: Material.Units.dp(120);
            delegate: Item{
                anchors.fill: parent
                Material.CheckBox{
                    id:checkbox
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    anchors.verticalCenter: parent.verticalCenter
                    checked: styleData.selected
                    onCheckedChanged: {
                        if(checked)
                            tabview.selection.select(styleData.row)
                        else
                            tabview.selection.deselect(styleData.row)
                    }
                }
                Material.Label{
                    anchors.left: checkbox.right
                    anchors.leftMargin:  24
                    anchors.verticalCenter: parent.verticalCenter
                    text:styleData.value
                    style:"body1"
                    color: Material.Theme.light.shade(0.87)
                }
            }
        }

        TableViewColumn{
            role: "weldLayer"
            title: "焊接层数"
            width:Material.Units.dp(100);
        }
        TableViewColumn{
            role: "weldNum"
            title: "焊接道数"
            width:Material.Units.dp(100);
        }
        model: ListModel{
            ListElement{
                iD:"1"
                weldLayer:"1"
                weldNum:"陈是好"
            }
            ListElement{
                iD:"2"
                weldLayer:"1"
                weldNum:"2"
            }
            ListElement{
                iD:"3"
                weldLayer:"2"
                weldNum:"1"
            }
            ListElement{
                iD:"4"
                weldLayer:"1"
                weldNum:"陈是好"
            }
            ListElement{
                iD:"5"
                weldLayer:"1"
                weldNum:"2"
            }
            ListElement{
                iD:"6"
                weldLayer:"2"
                weldNum:"1"
            }
            ListElement{
                iD:"7"
                weldLayer:"1"
                weldNum:"陈是好"
            }
            ListElement{
                iD:"8"
                weldLayer:"1"
                weldNum:"2"
            }
            ListElement{
                iD:"9"
                weldLayer:"2"
                weldNum:"1"
            }



        }

    }
}

