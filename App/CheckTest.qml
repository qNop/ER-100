import QtQuick 2.4
Item {
    anchors.fill: parent
     /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "CheckTest"
Column{
    Repeater{
        model: 6
   delegate: TextEdit{
            text:"chen"
    }
    }
}
}
