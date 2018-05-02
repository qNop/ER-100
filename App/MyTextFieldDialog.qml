import QtQuick 2.0
import  Material 0.1
import QtQuick.Layouts 1.1
import "MyMath.js" as MyMath
/*
      model 必须为 {name:"";show:true;min:;max:;isNum:;step:;}
*/
Dialog{
    id:root
    objectName: "MyTextFieldDialog"
    property alias repeaterModel:repeater.model
    property int focusIndex: 0
    property bool isTextInput:false
    property alias sourceComponent: loader.sourceComponent
    property bool keyStatus: false

    property Item message

    signal changeFocus(int index)
    signal changeFocusIndex(int index)
    signal updateText()

    function getText(index){
        return String(index<repeater.count?repeater.itemAt(index).text:"0")
    }

    negativeButtonText:qsTr("取消")
    positiveButtonText:qsTr("确定")
    globalMouseAreaEnabled:false

    onChangeFocusIndex: {
        focusIndex=index;
    }

    Keys.onUpPressed: {
        if((focusIndex>0)&&(focusIndex<repeaterModel.count)){
            focusIndex--;
            //如果该选项不显示则跳过寻找显示菜单
            while(repeater.itemAt(focusIndex).visible===false){
                focusIndex--;
            }
            keyStatus=false;
            changeFocus(focusIndex);
        }
    }
    Keys.onDownPressed: {
        if(focusIndex<(repeaterModel.count-1)){
            focusIndex++;//
            //如果该选项不显示则跳过寻找显示菜单
            while(repeater.itemAt(focusIndex).visible===false){
                focusIndex++;
            }
            keyStatus=true;
            changeFocus(focusIndex);
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
                    property alias text: textField.text
                    visible: show
                    spacing:Units.dp(8)
                    Label{text:name;anchors.bottom: parent.bottom;style: "button"}
                    TextField{
                        id:textField
                        property string tempValue: value
                        Connections{
                            target:root
                            onChangeFocus:{
                                if(index===row.rowIndex){
                                    textField.forceActiveFocus(); //激活
                                }
                            }
                            onUpdateText:{
                                textField.text=textField.tempValue;
                            }
                        }
                        onActiveFocusChanged: {
                            if(activeFocus){
                                root.focusIndex=index;
                            }
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
                                if(num<min) num=min;
                                text=String(num);
                            }
                        }
                        horizontalAlignment:TextInput.AlignHCenter
                        width:isTextInput? Units.dp(150):Units.dp(60)
                        inputMethodHints:Qt.ImhDigitsOnly
                    }
                }
            }
        }
    }
}
