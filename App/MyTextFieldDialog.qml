import QtQuick 2.0
import  Material 0.1
Dialog{
    id:root
    objectName: "MyTextFieldDialog"
    property alias repeaterModel:repeater.model
    property int focusIndex: 0

    signal changeText(int index,string text)
    signal openText(int index,string text)
    signal changeFocus(int index)
    signal changeFocusIndex(int index)

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
    Column{
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
                    width: Units.dp(60)
                    inputMethodHints: Qt.ImhDigitsOnly
                    onTextChanged: {
                        changeText(index,text);
                    }
                }
            }
        }
    }
}
