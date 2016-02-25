import QtQuick 2.4
import Material 0.1
import Material.Extras 0.1
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Controls.Private 1.0
import Material.ListItems 0.1

TableView{
    id:tabview

    anchors.top:parent.top//tableview.bottom
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 24
    anchors.right:parent.right
    anchors.topMargin: 24
    anchors.left: parent.left
    anchors.leftMargin: 24
    anchors.rightMargin: 24

    alternatingRowColors:false
    headerVisible:true
    style:MyTableViewStyle{}

    TableViewColumn{
        role: "weldLayer"
        title: "焊接层数"
        width:Units.dp(100);
    }
    TableViewColumn{
        role: "weldNum"
        title: "焊接道数"
        width:Units.dp(100);
    }
    model: ListModel{
        ListElement{
            weldLayer:"1"
            weldNum:"陈是好"
        }
        ListElement{
            weldLayer:"1"
            weldNum:"2"
        }
        ListElement{
            weldLayer:"2"
            weldNum:"1"
        }
        ListElement{
            weldLayer:"2"
            weldNum:"2"
        }
        ListElement{
            weldLayer:"1"
            weldNum:"1"
        }
        ListElement{
            weldLayer:"1"
            weldNum:"2"
        }
        ListElement{
            weldLayer:"2"
            weldNum:"1"
        }
        ListElement{
            weldLayer:"2"
            weldNum:"2"
        }
        ListElement{
            weldLayer:"1"
            weldNum:"1"
        }
        ListElement{
            weldLayer:"1"
            weldNum:"2"
        }
        ListElement{
            weldLayer:"2"
            weldNum:"1"
        }
        ListElement{
            weldLayer:"2"
            weldNum:"2"
        }
        ListElement{
            weldLayer:"1"
            weldNum:"1"
        }
        ListElement{
            weldLayer:"1"
            weldNum:"2"
        }
        ListElement{
            weldLayer:"2"
            weldNum:"1"
        }
        ListElement{
            weldLayer:"2"
            weldNum:"2"
        }
        ListElement{
            weldLayer:"1"
            weldNum:"1"
        }
        ListElement{
            weldLayer:"1"
            weldNum:"2"
        }
        ListElement{
            weldLayer:"2"
            weldNum:"1"
        }
        ListElement{
            weldLayer:"2"
            weldNum:"2"
        }
    }
}


