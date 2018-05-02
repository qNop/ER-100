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
    backgroundColor: ink.pressed&&pop.visible?Theme.accentColor:"white"

    MouseArea{
        id:ink
        anchors.fill: parent
        enabled: iconButton.enabled
        onPressed:{
            pop.open(iconButton,input,0,input.verticalSpacing);
            iconButton.clicked()
        }
        onReleased: {
            if(pop.visible){
                pop.close();
            }
        }
        onCanceled: {
            if(pop.visible){
                pop.close();
            }
        }
        onExited: {
            if(pop.visible){
                pop.close();
            }
        }
    }
    Icon {
        id: icon
        anchors.centerIn: parent
        size:Units.dp(32)
        visible: source!==null
        color:ink.pressed&&pop.visible?"white":"black"
    }
    Label{
        id:label
        anchors.centerIn: parent
        color:ink.pressed&&pop.visible?"white":"black"
        visible: text!==null
    }
}


