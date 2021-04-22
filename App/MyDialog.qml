/*
 * QML Material - An application framework implementing Material Design.
 * Copyright (C) 2014-2015 Michael Spencer <sonrisesoftware@gmail.com>
 *               2015 Bogdan Cuza <bogdan.cuza@hotmail.com>
 *               2015 Mikhail Ivchenko <ematirov@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, either version 2.1 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import QtQuick.Layouts 1.1
import Material 0.1
import Material.Extras 0.1
import "MyMath.js" as MyMath

/*!
   \qmltype Dialog
   \inqmlmodule Material 0.1
   \brief Dialogs inform users about critical information, require users to make
   decisions, or encapsulate multiple tasks within a discrete process
 */
PopupBase {
    id: dialog
    objectName: "Dialog"
    overlayLayer: "dialogOverlayLayer"

    // overlayColor: Qt.rgba(0, 0, 0, 0.3)
    // opacity: showing ? 1 : 0
    visible: false//opacity > 0

    width: Math.max(Units.dp(260) ,
                    rowLayout.width +  2*contentMargins)

    height: Math.min(parent.height - Units.dp(64),
                     titleview.height +
                     rowLayout.height + contentMargins+
                     (floatingActions ? 0 : buttonContainer.height))

    property int contentMargins: Units.dp(24)

    property alias loaderSource: loader

    property alias title: titleLabel.text

    property alias repeaterModel: listView.model

    property alias index: listView.currentIndex

    /*!
       \qmlproperty Button negativeButton
       The negative button, displayed as the leftmost button on the right of the dialog buttons.
       This is usually used to dismiss the dialog.
     */
    property alias negativeButton: negativeButton

    /*!
       \qmlproperty Button primaryButton
       The primary button, displayed as the rightmost button in the dialog buttons row. This is
       usually used to accept the dialog's action.
     */
    property alias positiveButton: positiveButton

    //globalMouseAreaEnabled:false
    property string negativeButtonText: "取消"
    property string positiveButtonText: "确定"
    property alias positiveButtonEnabled: positiveButton.enabled

    property bool hasActions: true
    property bool floatingActions: false

    property alias sourceComponent: loader.sourceComponent
    property alias loaderVisible: loader.visible

    property Item message

    signal updateText(int index,var text)

    signal changeText(int index,var text)

    signal accepted()

    signal rejected()

    anchors {
        centerIn: parent
        verticalCenterOffset: visible ? 0 : -(dialog.height/3)

        Behavior on verticalCenterOffset {
            NumberAnimation { duration: 200 }
        }
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Escape) {
            closeKeyPressed(event);
            rejected();
        }
        if (event.key === Qt.Key_Enter){
            if(positiveButtonEnabled){
                closeKeyPressed(event);
                accepted();
            }else
                event.accepted = true
        }
        if (event.key === Qt.Key_Return){
            if(positiveButtonEnabled){
                closeKeyPressed(event);
                accepted();
            }else
                event.accepted = true
        }
    }

    Keys.onReleased: {
        if (event.key === Qt.Key_Back) {
            closeKeyPressed(event)
        }
    }

    function closeKeyPressed(event) {
        if (dialog.visible) {
            if (dialog.dismissOnTap) {
                dialog.close()
            }
            event.accepted = true
        }
    }

    function show() {
        listView.maxRowWidth=-1;
        open()
        visible=true;
    }

    onVisibleChanged:{
        if(visible)
            listView.forceActiveFocus()
    }

    function getText(index){
        return repeaterModel.get(index).value
    }

    onChangeText: {
        repeaterModel.setProperty(index,"value",text);
    }

    function close() {
        visible = false

        if (parent.hasOwnProperty("currentOverlay")) {
            parent.currentOverlay = null
        }

        if (__lastFocusedItem !== null) {
            __lastFocusedItem.forceActiveFocus()
        }
        closed()
    }

    View {
        id: dialogContainer
        anchors.fill: parent
        elevation: 5
        radius: Units.dp(2)
        backgroundColor: "white"

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: false

            onClicked: {
                mouse.accepted = false
            }
        }

        View {
            id:titleview
            backgroundColor: Theme.primaryColor
            elevation: listView.atYBeginning ? 0 : 1
            fullWidth: true
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top

            }

            height:Units.dp(64)

            Label {
                id: titleLabel
                anchors {
                    left: parent.left
                    right: parent.right

                    leftMargin: contentMargins
                    rightMargin: contentMargins
                }
                width: parent.width
                wrapMode: Text.Wrap
                anchors.verticalCenter: parent.verticalCenter
                style: "dialog"
                color: Theme.lightDark(titleview.backgroundColor,Theme.light.textColor,Theme.dark.textColor)
            }
        }
        RowLayout{
            id:rowLayout
            anchors{
                top:titleview.bottom
                left: parent.left
                leftMargin: contentMargins
                topMargin: contentMargins/2
            }
            spacing: contentMargins
            height:Math.max((listView.count>10?10:listView.count)*Units.dp(32),loader.height)

            Loader{
                id:loader
                Layout.alignment: Qt.AlignVCenter
            }

            Rectangle{
                id:line
                width:1
                height: parent.height
                Layout.alignment: Qt.AlignVCenter
                visible:loader.visible
                color: Theme.light.textColor
            }

            ListView{
                id:listView
                clip:true
                Layout.fillHeight: true
                Layout.preferredWidth: width
                property int maxRowWidth: -1
                delegate: Row{
                    id:row
                    property alias rowText:textField.text
                    property int rowIndex: index
                    Connections{
                        target: dialog
                        onUpdateText:{
                            if(index===row.rowIndex){
                                row.rowText=text;
                            }
                        }
                    }
                    spacing:Units.dp(12)
                    onWidthChanged:{
                        if(width>listView.maxRowWidth) listView.maxRowWidth=width;
                        if(index===(listView.count-1)){
                            listView.width=listView.maxRowWidth
                        }
                    }
                    Label{id:label;text:name;anchors.bottom: parent.bottom;style: "button";}
                    TextField{
                        id:textField
                        text:value
                        horizontalAlignment:TextInput.AlignHCenter
                        width:isNum? Units.dp(60):Units.dp(150)
                        focus: index===listView.currentIndex
                        inputMethodHints:isNum?Qt.ImhPreferNumbers:Qt.ImhNone
                        errorColor: Theme.primaryColor
                        onTextChanged:{
                            var num;
                            if(isNum){
                                if(isNaN(text)){
                                    textField.hasError=true;
                                    positiveButtonEnabled=false;
                                    message.open("请输入汉字！");
                                }else{
                                    num=Number(text)
                                    if(num>max) text=String(max);
                                    if(num<min) text=String(min);
                                    if(textField.hasError===true){
                                        positiveButtonEnabled=true;
                                        textField.hasError=false;
                                    }
                                }
                            }
                            changeText(index,text);
                        }
                        Keys.onVolumeDownPressed: {
                            var num,temp;
                            Qt.inputMethod.hide()
                            num=Number(text)
                            if(!isNaN(num)&&isNum){//是数值进行加减操作
                                if(event.isAutoRepeat)
                                    temp=step*10;
                                else
                                    temp=step;
                                num=MyMath.subMath(num,temp);
                                if(num>max) num=max;
                                if(num<min) num=min;
                                text=String(num);
                            }
                        }
                        Keys.onVolumeUpPressed:{
                            var num,temp;
                            Qt.inputMethod.hide()
                            num=Number(text)
                            if(!isNaN(num)&&isNum){//是数值进行加减操作
                                if(event.isAutoRepeat)
                                    temp=step*10;
                                else
                                    temp=step;
                                num=MyMath.addMath(num,temp);
                                if(num>max) num=max;
                                if(num<min)  num=min;
                                text=String(num);
                            }
                        }
                    }
                }
            }
        }
        Item {
            id: buttonContainer
            anchors {
                bottom: parent.bottom
                right: parent.right
                left: parent.left
            }

            height: hasActions ? Units.dp(52) : Units.dp(2)

            View {
                id: buttonView
                height: parent.height
                backgroundColor: floatingActions ? "transparent" : "white"
                elevation: listView.atYEnd ? 0 : 1
                fullWidth: true
                radius: dialogContainer.radius
                elevationInverted: true

                anchors {
                    bottom: parent.bottom
                    right: parent.right
                    left: parent.left
                }

                Button {
                    id: negativeButton
                    visible: hasActions
                    text: negativeButtonText
                    textColor: Theme.accentColor
                    context: "dialog"

                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: Units.dp(8)
                    }

                    onClicked: {
                        close();
                        rejected();
                    }
                }

                Button {
                    id: positiveButton
                    visible: hasActions
                    text: positiveButtonText
                    textColor: Theme.accentColor
                    context: "dialog"
                    anchors {
                        verticalCenter: parent.verticalCenter
                        rightMargin: Units.dp(8)
                        right: negativeButton.visible ? negativeButton.left : parent.right
                    }
                    onClicked: {
                        close()
                        accepted();
                    }
                }
            }
        }
    }
}

