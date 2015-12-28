import QtQuick 2.0
import Material 0.1
import Material.Extras 0.1


Rectangle {
    color: Theme.backgroundColor
    anchors.leftMargin: title.visible ? 0 :100
    Behavior on anchors.leftMargin {
        NumberAnimation { duration: 200 }
    }
   Button{
       text: "button"
       onClicked: {Qt.inputMethod.show() ;}
   }
}

