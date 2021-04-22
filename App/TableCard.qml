import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.2 as Controls
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1

Card{
    id:root
    objectName: "TableCard"
    anchors{
        left:parent.left;
        top:parent.top;
        leftMargin:visible?Units.dp(12):Units.dp(250)
        topMargin: Units.dp(12)
    }
    width:parent.width-2*Units.dp(12);

    Behavior on anchors.leftMargin{NumberAnimation { duration: 400 ;easing.type:Easing.InOutQuad }}
    height: title.height+tableView.height+footerItem.height
    elevation: 2

    property alias firstColumn: firstColumnData

    property string headerTitle: "header"
    property string footerText: "footer"
    property alias table: tableView
    property alias tableData: tableView.data
    property int tableRowCount: 0
    property alias model: tableView.model
    property alias currentRow: tableView.currentRow
    property alias __listview: tableView.__listView

    property alias header: title
    property alias footer: footerItem

    property Item message


    //外部更新数据
    signal updateModel(string str,var data);
    signal updateListModel(string str,var data);

    function selectIndex(index){
        if(index<model.count){
            table.selection.clear();
            table.selection.select(index);
        }else{
            message.open("索引超过条目上限！")
        }
    }

    Item{
        id:title
        anchors{left:parent.left;right:parent.right;top:parent.top}
        height:Units.dp(64);
        Label{id:titleLabel
            anchors{left: parent.left;leftMargin: Units.dp(24);verticalCenter: parent.verticalCenter}
            style:"subheading"
            color: Theme.light.shade(0.87)
            text:headerTitle
            width: Units.dp(400)
        }
    }
    Controls.TableView{
        id:tableView
        anchors{left:parent.left;leftMargin: Units.dp(5);right:parent.right;rightMargin: Units.dp(5);top:title.visible?title.bottom:parent.top}
        height:tableRowCount*Units.dp(48)+Units.dp(56)
        sortIndicatorVisible:true
        //不是隔行插入色彩
        alternatingRowColors:false
        //显示表头
        headerVisible:true
        //tableView样式
        style:TableStyle{}
        //选择模式 单选
        selectionMode:Controls.SelectionMode.SingleSelection
        Controls.ExclusiveGroup{  id:checkboxgroup }
        ThinDivider{anchors.bottom:tableView.bottom;color:Palette.colors["grey"]["500"]}

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
            NumberAnimation { properties: "x"; from:tableView.width-100;duration: 200 }
        }
        __listView.removeDisplaced:Transition{
            NumberAnimation { properties: "y";duration: 200 }
        }
        Keys.onPressed: {
                switch(event.key){
                case Qt.Key_Right:
                    __horizontalScrollBar.value +=Units.dp(70);
                    event.accept=true;
                    break;
                case Qt.Key_Left:
                     __horizontalScrollBar.value -=Units.dp(70);
                    event.accept=true;
                    break;
                }
        }
    }
    Item{
        id:footerItem
        anchors{top:tableView.bottom;left:parent.left;right:parent.right;}
        height: Units.dp(47)
        Label{
            id:footerLabel
            anchors.left: parent.left
            anchors.leftMargin: footerItem.width-width-Units.dp(16)
            anchors.verticalCenter: parent.verticalCenter
            style:"menu"
            text:footerText
        }
    }
    onFocusChanged: {
        if(focus){tableView.forceActiveFocus()}
    }
}
