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
    onHeightChanged:InputEngine.setKeyboardRectangle(Qt.rect(x, y, width, height));
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
    onVisibleChanged: {
        //无论打开或者关闭都关闭掉pop
        pop.close()    }

    Rectangle{
        id:pop
        visible: false
        radius: 2
        property alias text: popLabel.text
        property alias source:popIcon.source
        color: Theme.accentColor
        z:2
        Label {
            id: popLabel
            style: "title"
            color: Theme.lightDark(pop.color,Theme.light.textColor,Theme.dark.textColor)
            anchors.centerIn: parent
        }
        Icon {
            id: popIcon
            anchors.centerIn: parent
            size:Units.dp(48)
            visible: source!==""
            color: Theme.lightDark(pop.color,Theme.light.iconColor,Theme.dark.iconColor)
        }
        function open(button,inputPanel,offsetX, offsetY){
            width=button.width*1.2
            height=button.height*1.4
            text=button.text;
            if(typeof(offsetX) === "undefined")
                offsetX = 0
            if(typeof(offsetY) === "undefined")
                offsetY = 0
            var position = button.mapToItem(inputPanel, 0, 0)
            var x1 = position.x + (button.width / 2 - pop.width / 2) - offsetX
            if(x1 + width > root.width)
                x1 = root.width - width
            if (x1 < 0)
                x1 = 0
            pop.x=x1;
            var  y1 = position.y - height - offsetY
            if (y1 + pop.height > 480) {
                y1= position.y - pop.height - offsetY
            }
            pop.y=y1;
            visible=true;
            if(button.hasOwnProperty("source"))
                pop.source=button.source
            else
                pop.source="";
        }
        function close(){
            visible=false;
            pop.source="";
        }
    }
    /**
     * The delegate that paints the key buttons
     */
    Component {
        id: keyButtonDelegate
        View{
            id:view
            property alias text: label.text
            radius: 2
            width: buttonWidth;
            height:rowHeight;
            backgroundColor: ink.pressed&&pop.visible?Theme.accentColor:"white"
            elevation:1
            MouseArea{
                id:ink
                anchors.fill: parent
                onPressed: {
                    pop.open(view,root,0,verticalSpacing);
                    InputEngine.sendKeyToFocusItem(label.text);
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
            Label{
                id:label
                anchors.centerIn: parent
                text: ( shiftModifier ) ? letter.toUpperCase()  :  ( symbolModifier ) ? firstSymbol : letter
                color:ink.pressed&&pop.visible?"white":"black"
                style:"subheading"
            }
        }
    }
    Connections{target: InputEngine;
        onChineseListChanged:{listView.model = list;}
        onInputModeChanged:{
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
            anchors.topMargin:  Units.dp(8)
            anchors.left: parent.left
            anchors.leftMargin: Units.dp(16);
            anchors.right: parent.right
            anchors.rightMargin: Units.dp(16);
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Units.dp(8);
            spacing: verticalSpacing
            Row {
                height: rowHeight
                anchors.horizontalCenter:parent.horizontalCenter
                spacing: horizontalSpacing
                InputPanelButton{
                    id:leftButton;
                    elevation:1
                    width: buttonWidth
                    height:parent.height
                    onClicked: { listView.decrementCurrentIndex(); }
                    source:"icon://hardware/keyboard_arrow_left"
                    color: listView.currentIndex ? "#1e1b18" : Palette.colors["grey"]["500"]
                    input:root
                    pop:pop
                }
                ListView {
                    id:listView;
                    orientation: ListView.Horizontal
                    width:7*buttonWidth+6*horizontalSpacing
                    height:parent.height
                    clip:true
                    delegate:Item{
                        width:hanziTxt.width+20
                        height:parent.height
                        Ink{
                            anchors.fill: parent
                            onClicked: {listView.currentIndex=index;}
                        }
                        Label {
                            id: hanziTxt
                            anchors.centerIn: parent
                            text: modelData
                            style:"subheading"
                            color:  index === listView.currentIndex ? Theme.accentColor : Theme.lightDark(card.backgroundColor,"black",Theme.dark.textColor)
                        }
                    }
                }
                InputPanelButton{
                    id:rightButton;
                    height:parent.height
                    elevation:1
                    width:buttonWidth
                    onClicked: {listView.incrementCurrentIndex()}
                    source:"icon://hardware/keyboard_arrow_right"
                    color:  "#1e1b18"
                    input:root
                    pop:pop
                }
                InputPanelButton {
                    id: hide
                    width: buttonWidth
                    height: rowHeight
                    elevation:1
                    source: "icon://hardware/keyboard_hide"
                    onClicked:{
                        Qt.inputMethod.hide()

                    }
                    input:root
                    pop:pop
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
                InputPanelButton{
                    id:capsLock
                    input:root
                    pop:pop
                    elevation:1
                    anchors{left: parent.left;leftMargin: horizontalSpacing;right: thirdrow.left;rightMargin: horizontalSpacing}
                    height:rowHeight
                    onClicked: {
                        if (symbolModifier) symbolModifier = false;
                        shiftModifier = !shiftModifier;
                        if(shiftModifier)capsLock.backgroundColor=Qt.darker(capsLock.backgroundColor, 1.25)
                        else capsLock.backgroundColor=backspace.backgroundColor
                    }
                    source: shiftModifier ? "icon://hardware/keyboard_capslock": "icon://hardware/keyboard_arrow_up"
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
                InputPanelButton{
                    id:backspace
                    elevation:1
                    input:root
                    pop:pop
                    anchors{right: parent.right;leftMargin: horizontalSpacing;left: thirdrow.right;rightMargin: horizontalSpacing}
                    height:rowHeight
                    onClicked:   InputEngine.sendKeyToFocusItem("\x7F");//删除码
                    source: "icon://hardware/keyboard_backspace"
                }
            }
            Row {
                height: rowHeight
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: horizontalSpacing
                spacing: horizontalSpacing
                anchors.leftMargin: horizontalSpacing
                InputPanelButton{
                    id:inputmode
                    elevation:1
                    input:root
                    pop:pop
                    height: rowHeight
                    width:backspace.width
                    onClicked: {
                        if (shiftModifier) {
                            shiftModifier = false
                        }
                        symbolModifier = ! symbolModifier
                    }
                    text: (!symbolModifier) ? "?123" : "abc"
                    style:"subheading"
                }
                InputPanelButton {
                    elevation:1
                    input:root
                    pop:pop
                    width: buttonWidth
                    height: rowHeight
                    text:","
                    onClicked: InputEngine.sendKeyToFocusItem(text)
                }
                InputPanelButton {
                    id: spaceKey
                    elevation:1
                    input:root
                    pop:pop
                    width: parent.width-2*enterKey.width-2*buttonWidth-4*parent.spacing
                    height: rowHeight
                    source:"icon://editor/space_bar"
                    onClicked: InputEngine.sendKeyToFocusItem(text)
                }
                InputPanelButton {
                    elevation:1
                    input:root
                    pop:pop
                    width: buttonWidth
                    height: rowHeight
                    text:"."
                    onClicked: InputEngine.sendKeyToFocusItem(text)
                }
                InputPanelButton {
                    id: enterKey
                    elevation:1
                    input:root
                    pop:pop
                    width: backspace.width
                    height: rowHeight
                    onClicked: InputEngine.sendKeyToFocusItem("\x0D"+listView.currentIndex)//回车码
                    source:"icon://hardware/keyboard_return"
                }
            }
        }
    }
}
