import QtQuick 2.4
import Material 0.1
import Material.Extras 0.1

View {
    id: iconButton
    property alias color: icon.color
    property alias size: icon.size
    property alias source: icon.source
    property alias text : label.text
    property alias style: label.style
    property Item pop;
    property Item input;
    signal clicked
    width: icon.width
    height: icon.height
    opacity: enabled ? 1 : 0.6
    elevation:0
    backgroundColor: "white"
    onVisibleChanged:{
        if(visible){
            rect1.color="white"
            pop.close();
        }
    }
    MouseArea{
        id:ink
        anchors.fill: parent
        enabled: iconButton.enabled
        onPressed:{ iconButton.elevation=0;
            iconButton.clicked()
            pop.open(iconButton,input,0,input.verticalSpacing);
            rect1.color=Theme.accentColor
        }
        onReleased: {iconButton.elevation=1;
            if(pop.visible){
                rect1.color="white"
                pop.close();
            }
        }
        onCanceled: {iconButton.elevation=1;
            if(pop.visible){
                rect1.color="white"
                pop.close();
            }
        }
    }
    Rectangle {
        id: rect1
        anchors.fill: parent
        color:"white"
        radius: parent.radius
        antialiasing: parent.rotation || radius > 0 ? true : false
        clip: true
    }
    Icon {
        id: icon
        anchors.centerIn: parent
        size:Units.dp(32)
        visible: source!==null
        color: Theme.lightDark(rect1.color,"black",Theme.dark.iconColor)
    }
    Label{
        id:label
        anchors.centerIn: parent
        color: Theme.lightDark(rect1.color,"black",Theme.dark.textColor)
        visible: text!==null
    }

}


