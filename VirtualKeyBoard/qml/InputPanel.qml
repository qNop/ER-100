import QtQuick 2.2
import QtQuick.Window 2.2

Rectangle {
    id:root
    property color background: "#282828"
    width: Screen.width
    height: Screen.height
    color: "#00000000"
    //opacity: 0.5

    MouseArea {
        anchors.fill: parent
        onClicked: {
            pinyinTxt.text = ""
            Qt.inputMethod.hide()
        }
    }
    KeyModel {
        id:keyModel
    }
    QtObject {
        id:pimpl
        property bool pinyinModifier: true
        property bool symbolModifier: false
        property bool shiftModifier: false
        property int verticalSpacing: 10
        property int horizontalSpacing: 5
        property int rowHeight: keyboard.height/4 - verticalSpacing
        property int buttonWidth:  (keyboard.width-column.anchors.margins)/10 - horizontalSpacing
    }
    Component {
        id: keyButtonDelegate
        KeyButton {
            width: pimpl.buttonWidth
            height: pimpl.rowHeight
            text: pimpl.shiftModifier ? letter.toUpperCase() : (pimpl.symbolModifier ?  firstSymbol : letter)
            onClicked:
            {
                if (pimpl.shiftModifier || pimpl.symbolModifier || !pimpl.pinyinModifier)
                {
                    keyEventDispatcher.sendKeyToFocusItem(text)
                }
                else
                {
                    pinyinTxt.text += text;
                    pinyinInput.Matching(pinyinTxt.text)
                }
            }
        }
    }

    // 中文拼音
    Rectangle {
        id: pinyinRect
        height: 30
        width: pinyinTxt.width ? pinyinTxt.width + 10 : 0
        anchors.bottom: hanziRect.top
        color: "#a0ffffff"
        border.color: "gray"
        border.width: 1
        radius: 5
        Text {
            id: pinyinTxt
            x : 5
            //visible: false
            height: pinyinRect.height
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            //text: "zwpy"
            font.pixelSize: 20
            color: "black"
        }
    }

    // 中文汉字
    Rectangle {
        id: hanziRect
        height: 40
        width: pinyinTxt.width ? root.width : 0
        anchors.bottom: keyboard.top
        color: "#434343"
        ListView {
            anchors.fill: parent
            orientation: ListView.Horizontal
            model: hanziModel
            delegate: Item {
                width: hanziTxt.width ? hanziTxt.width + 60 : 0
                height: hanziRect.height
                opacity: pinyinTxt.width > 0
                Text {
                    id: hanziTxt
                    anchors.horizontalCenter:parent.horizontalCenter
                    height: hanziRect.height
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 24
                    color: "#54a0c7"
                    text: model.modelData
                    MouseArea {
                        id: itemMouseArea
                        anchors.fill: parent;
                        onClicked:
                        {
                            keyEventDispatcher.sendKeyToFocusItem(hanziTxt.text)
                            pinyinTxt.text = ""
                        }
                    }
                }
                Rectangle {
                    width: 1
                    anchors.verticalCenter: parent.verticalCenter
                    height: 20
                    color: "#1F1F1F"
                    anchors.right: parent.right
                }
            }
        }
    }

    Rectangle {
        id: keyboard
        color: root.background
        width: parent.width
        height: parent.height / 3
        anchors.bottom: parent.bottom
        MouseArea {
            anchors.fill: parent
        }

        Column {
            id:column
            anchors.margins: 5
            anchors.fill: parent
            spacing: pimpl.verticalSpacing

            // 第一行
            Row {
                height: pimpl.rowHeight
                spacing: pimpl.horizontalSpacing
                anchors.horizontalCenter:parent.horizontalCenter
                Repeater {
                    model: keyModel.firstRowModel
                    delegate: keyButtonDelegate
                }
            }
            // 第二行
            Row {
                height: pimpl.rowHeight
                spacing: pimpl.horizontalSpacing
                anchors.horizontalCenter:parent.horizontalCenter
                Repeater {
                    model: keyModel.secondRowModel
                    delegate: keyButtonDelegate
                }
            }
            // 第三行
            Row {
                height: pimpl.rowHeight
                spacing: pimpl.horizontalSpacing
                anchors.horizontalCenter:parent.horizontalCenter

                // shift
                KeyButton {
                    id: shiftBtn
                    //anchors.left: parent.left
                    width: 1.25*pimpl.buttonWidth
                    height: pimpl.rowHeight

                    textColor: (pimpl.shiftModifier)? "yellow": "black"
                    text: "\uf0aa"
                    onClicked: {
                        pimpl.shiftModifier = !pimpl.shiftModifier
                        pimpl.symbolModifier = false
                        pinyinTxt.text = ""
                    }
                }

                Repeater {
                    anchors.horizontalCenter: parent.horizontalCenter
                    model: keyModel.thirdRowModel
                    delegate: keyButtonDelegate
                }
                // backspace
                KeyButton {
                    //anchors.right: parent.right
                    width: 1.25*pimpl.buttonWidth
                    height: pimpl.rowHeight

                    text: "\uf060"
                    onClicked: {
                        if (pimpl.shiftModifier || pimpl.symbolModifier || !pimpl.pinyinModifier)
                            keyEventDispatcher.sendKeyToFocusItem("\x7F")
                        else
                        {
                            if (pinyinTxt.text.length)
                                pinyinInput.Matching(pinyinTxt.text = pinyinTxt.text.substring(0, pinyinTxt.text.length-1))
                            else
                            {
                                pinyinTxt.text = ""
                                keyEventDispatcher.sendKeyToFocusItem("\x7F")
                            }
                        }
                    }
                }
            }
            Row {
                height: pimpl.rowHeight
                spacing: pimpl.horizontalSpacing
                anchors.horizontalCenter:parent.horizontalCenter
                KeyButton {
                    width: 1.25*pimpl.buttonWidth
                    height: pimpl.rowHeight
                    text: pimpl.symbolModifier ? "返回" : "123#"
                    onClicked: {
                        pimpl.symbolModifier = !pimpl.symbolModifier;
                        if (pimpl.shiftModifier)
                            pimpl.shiftModifier = false;
                        pinyinTxt.text = ""
                        console.log(pimpl.symbolModifier);
                    }
                }
                // 切换输入法
                KeyButton {
                    id: changeBtn
                    width: 1.25*pimpl.buttonWidth
                    height: pimpl.rowHeight

                    text: "\uf0ac"
                    onClicked: {
                        pimpl.pinyinModifier = !pimpl.pinyinModifier
                        pimpl.shiftModifier = false
                        pimpl.symbolModifier = false
                        if (pimpl.pinyinModifier)
                        {
                            pinyinTxt.text = ""
                        }
                        hanziRect.opacity = pinyinRect.opacity = pimpl.pinyinModifier
                        console.log(pimpl.pinyinModifier);
                    }
                }
                KeyButton {
                    width: pimpl.buttonWidth
                    height: pimpl.rowHeight
                    text: ","
                    onClicked: keyEventDispatcher.sendKeyToFocusItem(text)
                }
                KeyButton {
                    width: 3*pimpl.buttonWidth
                    height: pimpl.rowHeight
                    text: pimpl.symbolModifier ? "数字" : (pimpl.pinyinModifier ? "拼音" : "英文")
                    onClicked: keyEventDispatcher.sendKeyToFocusItem(" ")
                }
                KeyButton {
                    width: pimpl.buttonWidth
                    height: pimpl.rowHeight
                    text: "."
                    onClicked: keyEventDispatcher.sendKeyToFocusItem(text)
                }
                KeyButton {
                    width: 1.25*pimpl.buttonWidth
                    height: pimpl.rowHeight
                    text: "Enter"
                    onClicked: {
                        if (pinyinTxt.text != "")
                        {
                            keyEventDispatcher.sendKeyToFocusItem(pinyinTxt.text)
                            pinyinTxt.text = ""
                        }
                        else
                            keyEventDispatcher.sendKeyToFocusItem("\n")
                    }
                }
                KeyButton {
                    width: 1.25*pimpl.buttonWidth
                    height: pimpl.rowHeight

                    text: "\uf078"
                    onClicked: {
                        Qt.inputMethod.hide()
                    }
                }
            }
        }
    }
}
