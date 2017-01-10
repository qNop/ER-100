import QtQuick 2.4
import Material 0.1
import Material.Extras 0.1
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0
import WeldSys.WeldMath 1.0
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.1
import QtQuick.LocalStorage 2.0
//import WeldSys.SysInfor 1.0
import QtQuick.Window 2.2


PopupBase {
    id:root
    objectName: "MyNavigationDrawer"
    overlayLayer: "dialogOverlayLayer"
    overlayColor: Qt.rgba(0, 0, 0, 0.3)

    anchors{
        left:leftMode ? parent.left :undefined
        right:leftMode ? undefined:parent.right
        top:parent.top
        bottom: parent.bottom
        leftMargin: showing ? 0 : -width - Units.dp(10)
        rightMargin: showing ? 0 : -width - Units.dp(10)
        Behavior on leftMargin {
            NumberAnimation { duration: 200 }
        }
    }

    width:interWidth

    visible: showing

    property bool leftMode: true;

    property int interWidth: Math.min(parent.width - Units.gu(1), Units.gu(7))

    property alias enabled: action.visible

    readonly property Action action: action

    property string titleImage;
    property string titleLabel;

    property int oldIndex:0

    property alias model: listView.model

    onEnabledChanged: {
        if (!enabled)
            close()
    }

    property alias selectedIndex: listView.currentIndex

    Action {
        id: action
        iconName: "navigation/menu"
        name: "Navigation Drawer"
        onTriggered: root.toggle()
    }

    View {
        anchors.fill: parent
        fullHeight: true
        elevation: 3
        backgroundColor: "white"
    }

    ListView{
        id:listView
        anchors.fill: parent
        header:Card{
            id:header
            width: root.width
            height:Units.dp(64);
            backgroundColor:Theme.primaryColor
            Row{
                anchors{left: parent.left;leftMargin: Units.dp(24)}
                height: parent.height
                spacing: Units.dp(16)
                Icon{
                    id:navIcon
                    size:Units.dp(27)
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.light.shade(0.87)
                    name:titleImage
                }
                Label{
                    id:navlabel
                    style:"subheading"
                    color: Theme.light.shade(0.87)
                    anchors.verticalCenter: parent.verticalCenter
                    text:titleLabel
                }
            }
        }
        delegate:ListItem.Standard{
            text:name
            itemLabel.style: "body1"
            leftMargin: Units.dp(24)
            textColor: selected?Theme.accentColor:Theme.light.textColor;
            iconColor: selected?Theme.accentColor:Theme.light.iconColor;
            iconName: icon
            selected: listView.currentIndex===index
            onPressed: {
                listView.currentIndex=index;
                root.toggle()
            }
        }
        footer:Item{
            height: Units.dp(100)
            width:parent.width
            Column {
                anchors.fill: parent
                spacing: Units.dp(2)
                Repeater{
                    model:["awesome/user","awesome/group"]
                    delegate: ListItem.Standard{
                        anchors.leftMargin: Units.dp(16);
                        height:Units.dp(40);
                        itemLabel.style: "body1"
                        iconName:modelData
                        text:index?"用户组："+AppConfig.currentUserType:"用户名："+AppConfig.currentUserName
                        ThinDivider{anchors.top: parent.Top;visible: index===0}
                    }
                }
            }
        }
        footerPositioning: ListView.OverlayFooter
    }
    Keys.onUpPressed: {
        listView.decrementCurrentIndex()
    }
    Keys.onDownPressed: {
        listView.incrementCurrentIndex()
    }
    Keys.onDigit1Pressed:{
        selectedIndex=oldIndex;
        root.toggle();}
    Keys.onEnterPressed:{
        oldIndex=selectedIndex;
        root.toggle();}
    Keys.onReturnPressed: {
        oldIndex=selectedIndex;
        root.toggle();
    }
    Keys.onEscapePressed: {
        selectedIndex=oldIndex;
        root.toggle();
    }
}
