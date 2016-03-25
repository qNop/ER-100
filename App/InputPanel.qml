import QtQuick 2.4
import VirtualKeyboard 1.0
import Material 0.1
import Material.Extras 0.1

/**
 * This is the QML input panel that provides the virtual keyboard UI
 * The code has been derived from
 * http://tolszak-dev.blogspot.de/2013/04/qplatforminputcontext-and-virtual.html
 * Copyright 2015 Uwe Kindler
 * Licensed under MIT see LICENSE.MIT in project root
 */
FocusScope {
    id:root
    width: parent.width
    height: width / 3
    onHeightChanged:    InputEngine.setKeyboardRectangle(Qt.rect(x, y, width, height));
    Component.onCompleted: {
        listView.model=[""];
        InputEngine.setInputPanel(root);
    }
    property bool shiftModifier: false
    property bool symbolModifier: false
    property int verticalSpacing: root.height / 40
    property int horizontalSpacing: verticalSpacing
    property int rowHeight: column.height/5 -verticalSpacing
    property int buttonWidth:  column.width/10 - horizontalSpacing
    /**
    *键盘显示数据
   */
    ListModel {
        id:first
        ListElement { letter: "q"; firstSymbol: "1"; }
        ListElement { letter: "w"; firstSymbol: "2"; }
        ListElement { letter: "e"; firstSymbol: "3"; }
        ListElement { letter: "r"; firstSymbol: "4"; }
        ListElement { letter: "t"; firstSymbol: "5"; }
        ListElement { letter: "y"; firstSymbol: "6"; }
        ListElement { letter: "u"; firstSymbol: "7"; }
        ListElement { letter: "i"; firstSymbol: "8"; }
        ListElement { letter: "o"; firstSymbol: "9"; }
        ListElement { letter: "p"; firstSymbol: "0"; }
    }
    ListModel {
        id:second
        ListElement { letter: "a"; firstSymbol: "!"}
        ListElement { letter: "s"; firstSymbol: "@"}
        ListElement { letter: "d"; firstSymbol: "#"}
        ListElement { letter: "f"; firstSymbol: "$"}
        ListElement { letter: "g"; firstSymbol: "%"}
        ListElement { letter: "h"; firstSymbol: "&"}
        ListElement { letter: "j"; firstSymbol: "*"}
        ListElement { letter: "k"; firstSymbol: "?"}
        ListElement { letter: "l"; firstSymbol: "/"}
    }
    ListModel {
        id:third
        ListElement { letter: "z"; firstSymbol: "_"}
        ListElement { letter: "x"; firstSymbol: "\""}
        ListElement { letter: "c"; firstSymbol: "'"}
        ListElement { letter: "v"; firstSymbol: "("}
        ListElement { letter: "b"; firstSymbol: ")"}
        ListElement { letter: "n"; firstSymbol: "-"}
        ListElement { letter: "m"; firstSymbol: "+"}
    }
    /**
     * The delegate that paints the key buttons
     */
    Component {
        id: keyButtonDelegate
        Button {
            id: button
            elevation:1
            width: buttonWidth
            height: rowHeight
           // text:  ( shiftModifier ) ? letter.toUpperCase()  :  ( symbolModifier ) ? firstSymbol : letter
            onPressedChanged:{
                if(pressed){
                    InputEngine.sendKeyToFocusItem(label.text);
                }
            }
            Label{
                id:label
                anchors.centerIn: parent
                text: ( shiftModifier ) ? letter.toUpperCase()  :  ( symbolModifier ) ? firstSymbol : letter
                style:"subheading"
            }
        }
    }
    Connections{target: InputEngine;onChineseListChanged:{listView.model = list;}}
    Connections{target: InputEngine;onInputModeChanged:{
            if(Mode === InputEngine.Numeric){
                shiftModifier=0;
                symbolModifier=1;
            } else
            {symbolModifier=0};}}
    Card{
        id:card
        anchors.fill: parent
        elevation:2
        Column {
            id:column
            anchors.top:parent.top
            anchors.topMargin: verticalSpacing
            anchors.left: parent.left
            anchors.leftMargin: Units.dp(16);
            anchors.right: parent.right
            anchors.rightMargin: Units.dp(16);
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Units.dp(12);
            spacing: verticalSpacing
            Row {
                height: rowHeight
                width:  parent.width
                anchors.left:parent.left
                anchors.right: parent.right
                spacing: horizontalSpacing
                Button{
                    id:leftButton;
                    width: buttonWidth
                    height:parent.height
                    onClicked: { listView.decrementCurrentIndex();InputEngine.sendKeyToFocusItem("\x0F") }//SO 代表<<
                    Icon{
                        anchors.centerIn:leftButton
                        source: "icon://awesome/caret_left"
                        color: listView.currentIndex ? "#1e1b18" : Palette.colors["grey"]["500"]
                        visible: listView.model.length>1
                        size:Units.dp(32)
                    }
                    Timer{interval: 800;running: leftButton.pressed; repeat: true;
                        onTriggered: { listView.decrementCurrentIndex();InputEngine.sendKeyToFocusItem("\x0F");}
                    }
                }
                ListView {
                    id:listView;
                    orientation: ListView.Horizontal
                    width:parent.width-3*buttonWidth-3*horizontalSpacing
                    height:parent.height
                    clip:true
                    delegate:Item{
                        width:hanziTxt.width+20
                        height:parent.height
                        Label {
                            id: hanziTxt
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData
                            style:"subheading"
                            color:  index === listView.currentIndex ? Theme.accentColor : Theme.lightDark(card.backgroundColor,Theme.light.textColor,Theme.dark.textColor)
                        }
                    }
                }
                Button{
                    id:rightButton;
                    height:parent.height
                    width:buttonWidth
                    onPressedChanged:{if(pressed)
                        listView.incrementCurrentIndex();InputEngine.sendKeyToFocusItem("\x0E") }//SO 代表<<
                    Icon{
                        anchors.centerIn:rightButton
                        source: "icon://awesome/caret_right"
                        color:  "#1e1b18"
                        visible: listView.model.length>1
                        size:Units.dp(32)
                    }
                    Timer{interval: 800;running: rightButton.pressed; repeat: true;
                        onTriggered:{ listView.incrementCurrentIndex();InputEngine.sendKeyToFocusItem("\x0E");}
                    }
                }
                Button {
                    id: hide
                    width: buttonWidth
                    height: rowHeight
                    Icon{
                        anchors.centerIn:hide
                        source: "icon://hardware/keyboard_hide"
                        color: "#1e1b18"
                        size:Units.dp(32)
                    }
                   onClicked:{if(pressed)Qt.inputMethod.hide()}
                }
            }
            Row {
                height: rowHeight
                spacing: horizontalSpacing
                anchors.horizontalCenter:parent.horizontalCenter
                Repeater {
                    model: first
                    delegate: keyButtonDelegate
                }
            }
            Row {
                height: rowHeight
                spacing: horizontalSpacing
                anchors.horizontalCenter:parent.horizontalCenter
                Repeater {
                    model: second
                    delegate: keyButtonDelegate
                }
            }
            Item {
                height: rowHeight
                width:parent.width
                Button{
                    id:capsLock
                    elevation:1
                    anchors{left: parent.left;leftMargin: horizontalSpacing;right: thirdrow.left;rightMargin: horizontalSpacing}
                    height:rowHeight
                    onClicked: {
                        if (symbolModifier) symbolModifier = false;
                        shiftModifier = !shiftModifier;
                        if(shiftModifier)capsLock.backgroundColor=Qt.darker(capsLock.backgroundColor, 1.25)
                        else capsLock.backgroundColor=backspace.backgroundColor
                    }
                    Icon{
                        anchors.centerIn:capsLock
                        source: "icon://awesome/arrow_up"
                        color: "#1e1b18"
                        size:Units.dp(27)
                    }
                }
                Row {
                    id:thirdrow
                    height: rowHeight
                    spacing: horizontalSpacing
                    anchors.horizontalCenter:parent.horizontalCenter
                    Repeater {
                        anchors.horizontalCenter: parent.horizontalCenter
                        model: third
                        delegate: keyButtonDelegate
                    }
                }
                Button{
                    id:backspace
                    elevation:1
                    anchors{right: parent.right;leftMargin: horizontalSpacing;left: thirdrow.right;rightMargin: horizontalSpacing}
                    height:rowHeight
                    onPressedChanged: {
                        if(pressed)
                        InputEngine.sendKeyToFocusItem("\x7F");//删除码
                    }
                    Icon{
                        anchors.centerIn:backspace
                        source: "icon://awesome/arrow_left"
                        color: "#1e1b18"
                        size:Units.dp(27)
                    }
                    Timer{interval: 800;running: backspace.pressed; repeat: true;
                        onTriggered: InputEngine.sendKeyToFocusItem("\x7F");
                    }
                }
            }
            Row {
                height: rowHeight
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: horizontalSpacing
                spacing: horizontalSpacing
                anchors.leftMargin: horizontalSpacing
                Button{
                    id:inputmode
                    elevation:1
                    height: rowHeight
                    width:backspace.width
                    onClicked: {
                        if (shiftModifier) {
                            shiftModifier = false
                        }
                        symbolModifier = ! symbolModifier
                    }
                    Label{
                        anchors.centerIn: parent
                        text: (!symbolModifier) ? "?123" : qsTr("返回")
                        style:"subheading"
                    }
                }
                Button {
                    elevation:1
                    width: buttonWidth
                    height: rowHeight
                    text:","
                    onClicked: InputEngine.sendKeyToFocusItem(text)
                }
                Button {
                    id: spaceKey
                    elevation:1
                    width: parent.width-2*enterKey.width-2*buttonWidth-4*parent.spacing
                    height: rowHeight
                    text: " "
                    onClicked: InputEngine.sendKeyToFocusItem(text)
                }
                Button {
                    elevation:1
                    width: buttonWidth
                    height: rowHeight
                    text: "."
                    onClicked: InputEngine.sendKeyToFocusItem(text)
                }
                Button {
                    id: enterKey
                    elevation:1
                    width: backspace.width
                    height: rowHeight                
                    onClicked: InputEngine.sendKeyToFocusItem("\x0D")//回车码
                    Label{
                        anchors.centerIn: parent
                        text:qsTr("确认")
                        style:"subheading"
                    }
                }
            }
        }
    }
}
