import QtQuick 2.4
import Material 0.1
import QtQuick.Controls 1.3 as Controls
import QtQuick.Controls.Styles.Material 0.1 as MaterialStyle
import QtQuick.Window 2.2
/*仅显示进度条*/
PopupBase {
    id:popslider
    overlayLayer: "dialogOverlayLayer"
    overlayColor: Qt.rgba(0, 0, 0, 0.5)
    opacity: showing ? 1 : 0
    visible: opacity > 0
    globalMouseAreaEnabled:false
    anchors {
        centerIn: parent
        verticalCenterOffset: showing ? 0 : -(popslider.height/3)
        Behavior on verticalCenterOffset {
            NumberAnimation { duration: 200 }
        }
    }
    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }
    function show() {
        open();
        progressbar.value=0;
    }
    /*重写close函数解决焦点丢失问题*/
    function close(){
        showing = false;
        if (parent.hasOwnProperty("currentOverlay")) {
            parent.currentOverlay = null
        }
        if (__lastFocusedItem !== null) {
                    __lastFocusedItem.forceActiveFocus()
                }
        closed()
    }
    Timer{ interval: 100; running: true; repeat: true;
        onTriggered: {
            progressbar.value+=10;
            if(progressbar.value === progressbar.maximumValue){
                progressbar.value=100;
                if(popslider.showing){
                         close();
                }
            }
        }}
    Controls.ProgressBar {
        id:progressbar;
        property color color: Theme.light.accentColor
        width:480;anchors.centerIn: popslider;
        height: Units.dp(2)
        minimumValue:0;
        maximumValue:100;
        style: MaterialStyle.ProgressBarStyle {
            id: progressBarStyle
            progress: Rectangle {
                color: control.color
                Rectangle {
                    id:rec
                    y:parent.y-rec.implicitHeight/2
                    x:parent.width-rec.implicitWidth/2
                    implicitHeight: Units.dp(32)
                    implicitWidth: Units.dp(32)
                    color:  Theme.alpha(control.color, 0.2)
                    radius: implicitHeight / 2
                    Rectangle {
                        anchors.centerIn:  parent
                        color: control.value === control.minimumValue ?Theme.backgroundColor : control.color
                        border.color: control.value === control.minimumValue? control.darkBackground ?
                                                                                  Theme.alpha("#FFFFFF", 0.3) : Theme.alpha("#000000", 0.26) : control.color
                        border.width: Units.dp(2)
                        implicitHeight:  Units.dp(16)
                        implicitWidth:  Units.dp(16)
                        radius: implicitWidth / 2
                    }
                }

            }
            panel: Item {
                property bool horizontal: control.orientation === Qt.Horizontal
                implicitWidth: horizontal ? backgroundLoader.implicitWidth : backgroundLoader.implicitHeight
                implicitHeight: horizontal ? backgroundLoader.implicitHeight : backgroundLoader.implicitWidth
                Item {
                    width: horizontal ? parent.width : parent.height
                    height: !horizontal ? parent.width : parent.height
                    y: horizontal ? 0 : width
                    rotation: horizontal ? 0 : -90
                    transformOrigin: Item.TopLeft
                    Rectangle {
                        id: backgroundLoader
                        implicitWidth: control.width
                        implicitHeight: control.height
                        color:Theme.lightDark(Theme.backgroundColor,Theme.alpha("#000000", 0.26),Theme.alpha("#FFFFFF", 0.3))
                        opacity: 0.2
                    }
                    Loader {
                        sourceComponent: progressBarStyle.progress
                        anchors.topMargin: padding.top
                        anchors.leftMargin: padding.left
                        anchors.rightMargin: padding.right
                        anchors.bottomMargin: padding.bottom
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        width: currentProgress * (parent.width - padding.left - padding.right)
                    }
                }
            }
        }
    }
}

