import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.2 as Controls
import QtQuick.Window 2.2
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0
import WeldSys.WeldMath 1.0
import QtQuick.Layouts 1.1

Controls.TableView{
    id:tableview
    property alias firstData: firstColumnData
   // property bool transientScrollBars: true
    property int tableRowCount: 0
    height:tableRowCount*Units.dp(48)+Units.dp(56)
    sortIndicatorVisible:true
    //不是隔行插入色彩
    alternatingRowColors:false
    //显示表头
    headerVisible:true
    //Tableview样式
    style:TableStyle{id:style;transientScrollBars:false}
    //选择模式 单选
    selectionMode:Controls.SelectionMode.SingleSelection
    Controls.ExclusiveGroup{  id:checkboxgroup }
    ThinDivider{anchors.bottom:tableview.bottom;color:Palette.colors["grey"]["500"]}
    //不显示
    horizontalScrollBarPolicy:  Qt.ScrollBarAlwaysOff
    verticalScrollBarPolicy: Qt.ScrollBarAlwaysOn
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
    ///添加内外停留时间 两个参数
    Keys.onPressed: {
        var diff = event.key ===Qt.Key_Right ? Units.dp(70) : event.key === Qt.Key_Left ? -Units.dp(70) :  0
        if(diff !==0){
            tableview.__horizontalScrollBar.value +=diff;
            event.accept=true;
        }
    }
}
