import QtQuick 2.0
import  Material 0.1
import QtQuick.Layouts 1.1
Dialog{
    id:root
    objectName: "MyTextFieldDialog"
    property alias repeaterModel:repeater.model
    property int focusIndex: 0
    property bool isTextInput:false

    property alias sourceComponent: loader.sourceComponent

    signal changeText(int index,string text)
    signal openText(int index,string text)
    signal changeFocus(int index)
    signal changeFocusIndex(int index)
    signal keysonVolumeDown(int index,bool flag)
    signal keysonVolumeUp(int index,bool flag)

    negativeButtonText:qsTr("取消")
    positiveButtonText:qsTr("确定")
    globalMouseAreaEnabled:false

    onChangeFocusIndex: {
        focusIndex=index;
    }
    Keys.onUpPressed: {
        if((focusIndex>0)&&(focusIndex<repeaterModel.length)){
            focusIndex--;
            changeFocus(focusIndex);
        }
    }
    Keys.onDownPressed: {
        if(focusIndex<(repeaterModel.length-1)){
            focusIndex++;
            changeFocus(focusIndex);
        }
    }
    Keys.onVolumeDownPressed: {
        if(focusIndex<(repeaterModel.length-1)){
            Qt.inputMethod.hide()
            keysonVolumeDown(focusIndex,event.isAutoRepeat);
        }
    }
    Keys.onVolumeUpPressed:{
        if(focusIndex<(repeaterModel.length-1)){
            Qt.inputMethod.hide()
            keysonVolumeUp(focusIndex,event.isAutoRepeat);
        }
    }
    RowLayout{
        spacing: Units.dp(24)
        Loader {
            id:loader
            Layout.alignment: Qt.AlignVCenter
            visible: sourceComponent!==null
            height: sourceComponent!==null?sourceComponent.height:0
            width: sourceComponent!==null?sourceComponent.width:0
        }
        Rectangle{
            Layout.alignment: Qt.AlignVCenter
            visible: loader.visible
            height: parent.height-Units.dp(24)
            width: 1
            color: Qt.rgba(0,0,0,0.2)
        }
        Column{
            id:column
            Layout.alignment: Qt.AlignVCenter
            Repeater{
                id:repeater
                delegate:Row{
                    id:row
                    property int rowIndex:index
                    spacing: Units.dp(8)
                    Label{text:modelData;anchors.bottom: parent.bottom
                        style: "button"
                    }
                    TextField{
                        id:textField
                        Connections{
                            target:root
                            onOpenText:{
                                if(index===row.rowIndex)
                                    textField.text=text;
                            }
                            onChangeFocus:{
                                if(index===row.rowIndex){
                                    textField.forceActiveFocus();
                                }
                            }
                        }
                        onActiveFocusChanged: {
                            if(activeFocus){
                                root.changeFocusIndex(index)
                            }
                        }
                        horizontalAlignment:TextInput.AlignHCenter
                        width:isTextInput? Units.dp(150):Units.dp(60)
                        inputMethodHints: Qt.ImhDigitsOnly
                        onTextChanged: {
                            changeText(index,text);
                        }
                    }
                }
            }
        }
    }
}
