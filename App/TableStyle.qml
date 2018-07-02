import QtQuick 2.4
import Material 0.1 as Material
import Material.Extras 0.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Private 1.0
import QtQuick.Controls.Styles 1.2

TableViewStyle{
    //corner commpent 指 两个横纵滚动条之间的 部件
    id:root
    corner: Item{visible: false}
    //decrementControl 指滚动条 减 箭头 部件
    decrementControl:Item{visible: false}
    //handle 滚动条滑块儿
    handle:Rectangle{
        implicitWidth: !styleData.horizontal ? 5:Math.round(5) + 1
        implicitHeight: styleData.horizontal ? 5:Math.round(5) + 1
        width: !styleData.horizontal && transientScrollBars ? 5 : parent.width-10
        height: styleData.horizontal && transientScrollBars ? 5 : parent.height- 4
        color: Material.Theme.accentColor//Material.Palette.colors["grey"]["400"]
        anchors.centerIn: parent
        radius: styleData.horizontal ? height/2 : width/2
    }
    //incrementControl 指滚动条 加 箭头 部件
    incrementControl:Item{visible: false}
    //minimumHandleLength 滚动条滑块儿
    minimumHandleLength:30
    //scrollBarBackground 滚动条滑块儿外的颜色
    scrollBarBackground:Rectangle{
        property bool sticky: false
        property bool hovered: styleData.hovered
        implicitWidth: !styleData.horizontal ? 5:Math.round(5) + 1
        implicitHeight: styleData.horizontal ? 5:Math.round(5) + 1
        clip: true
        opacity: transientScrollBars ? 0.0 : 1.0
        visible: !Settings.hasTouchScreen && (!transientScrollBars || sticky)
        radius: styleData.horizontal ? height/2 : width/2
        onHoveredChanged: if (hovered) sticky = true
        onVisibleChanged: if (!visible) sticky = false
    }
    //transientScrollBars 滚动条一直存在还是短暂存在
    transientScrollBars:true
    //frame 滚动条外围组件
    frame:Item{visible: false}
    //以上是SCROLLBAR 外观设置
    //以下是TableView设置
    headerDelegate:Rectangle{
        height:Material.Units.dp(56);
        Material.Label{
            anchors.centerIn: parent
            text:typeof(styleData.value)!=="string"?"":styleData.value
            style:"menu"
            color:Material.Theme.light.shade(0.54)
        }
        Material.ThinDivider{anchors.bottom: parent.bottom ;color:Material.Palette.colors["grey"]["500"]}
    }
    itemDelegate: Item{
        id:itemdelegate
        anchors.fill: parent
        Material.Label{
            anchors.centerIn: parent
            text:typeof(styleData.value)!=="string"?"":styleData.value
            style:"body1"
        }
    }
    rowDelegate: Rectangle{
        height: Material.Units.dp(48);
        color: styleData.selected ?  Material.Palette.colors["grey"]["400"] : "white"
        Material.ThinDivider{anchors.bottom: parent.bottom}
    }
}
