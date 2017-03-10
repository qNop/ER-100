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

    property double min;
    property double max;
    property double step;
    property bool isNum;
    property bool keyStatus: false

    property Item message

    signal openText(int index,string text)
    signal changeFocus(int index)
    signal changeFocusIndex(int index)

    function getText(index){
        return String(repeater.itemAt(index).text)
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
            keyStatus=false;
            changeFocus(focusIndex);
        }
    }
    Keys.onDownPressed: {
        if(focusIndex<(repeaterModel.count-1)){
            focusIndex++;
            keyStatus=true;
            changeFocus(focusIndex);
        }
    }
    Keys.onVolumeDownPressed: {
        var num,temp;
        if(focusIndex<(repeaterModel.count)){
            Qt.inputMethod.hide()
            num=Number(repeater.itemAt(focusIndex).text)
            if(!isNaN(num)&&isNum){//是数值进行加减操作
                if(event.isAutoRepeat)
                    temp=step*10;
                else
                    temp=step;
                num=MyMath.subMath(num,temp);
                if(num>max) num=max;
                if(num<min) num=min;
                openText(focusIndex,String(num))
            }
        }
    }
    Keys.onVolumeUpPressed:{
        var num,temp;
        if(focusIndex<(repeaterModel.count)){
            Qt.inputMethod.hide()
            num=Number(repeater.itemAt(focusIndex).text)
            if(!isNaN(num)&&isNum) {//是数值进行加减操作
                if(event.isAutoRepeat)
                    temp=step*10;
                else
                    temp=step;
                num=MyMath.addMath(num,temp);
                if(num>max) num=max;
                if(num<min) num=min;
                openText(focusIndex,String(num))
            }
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
                        property string lastText
                        Connections{
                            target:root
                            onOpenText:{
                                if(index===row.rowIndex)
                                    if(isNum){
                                        if(Number(text)<min){
                                            textField.text=String(min);
                                        }else if(Number(text)>max){
                                            textField.text=String(max);
                                        }else
                                             textField.text=text;
                                    }else
                                        textField.text=text;
                            }
                            onChangeFocus:{
                                if(index===row.rowIndex){
                                    if(show) //如果当前值为有效则对焦但前值否则index+1 激活下一个控件
                                        textField.forceActiveFocus();
                                    else
                                        root.changeFocus(keyStatus?index+1>repeater.model.count?0:index+1:index-1<0?0:index-1);
                                }
                            }
                        }
                        onTextChanged: {
                            var temp=Number(text);
                            console.log("text"+text+"temp"+temp)
                            if((!isNaN(temp))&&(text.length)){//判断是否是数字
                                if(temp>root.max){
                                    message.open("设置数值 "+temp+" 超过最大限制值 "+root.max+" !");
                                }else if(temp<root.min){
                                    message.open("设置数值 "+temp+" 小于最小限制值 "+root.min+" !");
                                }
                                lastText=text;
                            }else if((root.isNum)&&(text!=="-")&&(text!==".")&&(text.length)){
                                text=lastText;
                                message.open("请输入数字 !")
                            }
                        }
                        onActiveFocusChanged: {
                            if(activeFocus){
                                root.changeFocusIndex(index)
                                root.min=min;
                                root.max=max;
                                root.isNum=isNum;
                                root.step=step;
                            }
                        }
                        horizontalAlignment:TextInput.AlignHCenter
                        width:isTextInput? Units.dp(150):Units.dp(60)
                        inputMethodHints: Qt.ImhDigitsOnly
                    }
                }
            }
        }
    }
}
