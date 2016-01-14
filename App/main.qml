import QtQuick 2.2
import Material 0.1
import Material.Extras 0.1
import WeldSys.APPConfig 1.0
import WeldSys.ERModbus 1.0
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.1
import QtQuick.LocalStorage 2.0
import "qrc:/Database.js" as DB
import "CanvasPaint.js" as Paint


/*应用程序窗口*/
ApplicationWindow{
    id: app;title: "app";visible: true
    /*Modbus*/
    ERModbus{id:ermodbus;
        onModbus_statusChanged: {
            console.log(status);
        }
    }
    APPConfig{id:appconfig}
    /*主题默认颜色*/
    theme { primaryColor: appconfig.themePrimaryColor;accentColor: appconfig.themeAccentColor;backgroundColor:appconfig.themeBackgroundColor
        tabHighlightColor: "white"  }
    property var sections: [ "grooveset", "weldset", "welding" ]
    property var sectionTitles: [ "焊接预置(I)", "焊接分析(II)", "系统信息(III)" ]
    property var tabiconname: ["awesome/windows","awesome/line_chart","awesome/tasks"]
    property string selectedComponent: sections[0]
    /*当前本地化语言*/
    property string local: "zh_CN"
    /*当前坡口形状*/
    property string currentgroove;
    /*更新时间定时器*/
    Timer{ interval: 500; running: true; repeat: true;
        onTriggered:{datetime.name= new Date().toLocaleDateString(Qt.locale(app.local),"MMMdd ddd ")+new Date().toLocaleTimeString(Qt.locale(app.local),"h:mm");
        }
    }
    /*发送action*/
    ActionButton{id:send;anchors {left: parent.left;bottom: parent.bottom;bottomMargin:  input.visible ? input.height+Units.dp(16):Units.dp(16) ;
            leftMargin: visible ? Units.dp(16):Units.dp(600)}iconName:"awesome/send";
        visible: if(page.selectedTab === 0) return true; else return false ;
        Behavior on anchors.leftMargin {
            NumberAnimation { duration: 600 }
        }
        Behavior on anchors.bottomMargin {
            NumberAnimation { duration: 200 }
        }

        onClicked: {
            /*显示进度条*/
            slider.show();
            /*发送数据*/

        }}
    /*初始化Ｔabpage*/
    initialPage: TabbedPage {
        id: page
        /*标题*/
        title:qsTr("便携式MAG焊接机器人系统")
        /*最大action显示数量*/
        actionBar.maxActionCount: 6
        /*actions列表*/
        actions: [
            /*危险报警action*/
            Action {iconName:"action/android" // "alert/warning";
                name: qsTr("警告");
                //onTriggered: demo.showError("Something went wrong", "Do you want to retry?", "Close", true)
            },
            /*背光控制插件action*/
            Action{name: qsTr("背光"); iconName: "image/flash_off"//"device/brightness_medium";
                onTriggered:backlight.show();
            },
            /*系统选择颜色action*/
            Action {iconName: "awesome/calculator"//"image/color_lens";
                name: qsTr("色彩") ;
                onTriggered: colorPicker.show();
            },
            /*系统设置action*/
            Action {iconName:"user/MAG";
                name: qsTr("设置");
                //onTriggered
            },
            /*时间action*/
            Action{name: qsTr("时间"); id:datetime;
                onTriggered:datePickerDialog.show();
            },
            /*账户*/
            Action {id:accountname;iconName: "action/account_circle";
                onTriggered:changeuser.show();text:appconfig.currentUserName;
            },
            /*语言*/
            Action {iconName: "action/language";name: qsTr("语言");
                onTriggered: languagePicker.show();
            },
            /*系统电源*/
            Action {iconName: "awesome/power_off";name: qsTr("关机")
                onTriggered: Qt.quit();
            }
        ]
        Repeater {
            model: sections
            delegate: Tab {
                title: sectionTitles[index]
                property string selectedComponent: modelData
                iconName:tabiconname[index];
                Item{
                    Flickable {
                        id: flickable
                        objectName: sectionTitles[index]
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            bottom: parent.bottom
                        }
                        clip: true
                        contentHeight: Math.max(loader.implicitHeight + 40, height)
                        Loader {
                            id: loader
                            anchors.fill: parent
                            asynchronous: true
                            visible: status == Loader.Ready
                            source: { return Qt.resolvedUrl("%.qml").arg(selectedComponent)}
                        }
                        ProgressCircle {
                            anchors.centerIn: parent
                            visible: loader.status == Loader.Loading
                        }
                    }
                    Scrollbar {
                        flickableItem: flickable
                    }
                }
            }
        }
        Keys.onDigit1Pressed: page.selectedTab=0;
        Keys.onDigit2Pressed: page.selectedTab=1;
        Keys.onDigit3Pressed: page.selectedTab=2;
        Keys.onPressed: {
            switch(event.key){
            case Qt.Key_F1:
                slider.show();
                event.accepted=true;
                break;
            }
        }
    }
    InputPanel{
        id:input
        visible:Qt.inputMethod.visible
        objectName: "InputPanel"
        y: visible ? parent.height - input.height:parent.height
        Behavior on y{
            NumberAnimation { duration: 200 }
        }
    }
    /**/
    Component.onCompleted: {
        /*打开数据库*/
        DB.openDatabase();
        var result = DB.getusrname();
        for(var i=0;i<result.rows.length;i++){
            var name = result.rows.item(i).name;
            usrnamemodel.append( {"text":name});
            if(name === accountname.text){
                changeuserFeildtext.selectedIndex = i+1;
                changeuserFeildtext.helperText=result.rows.item(i).type;}
        }
        usrnamemodel.remove(0);
        /*建立modbus*/
        ermodbus.modbus_status="setup";
    }
    /*日历*/
    Dialog {
        id:datePickerDialog; hasActions: true; contentMargins: 0;floatingActions: true
        negativeButtonText:qsTr("取消");positiveButtonText: qsTr("完成");
        DatePicker {
            frameVisible: false;dayAreaBottomMargin : Units.dp(48);isLandscape: true;
        }
    }
    /*背光调节*/
    Dialog{
        id:backlight
        title: qsTr("背光调节");negativeButtonText:qsTr("取消");positiveButtonText: qsTr("完成");
        Slider {
            id:backlightslider;height:Units.dp(64);width:Units.dp(240);Layout.alignment: Qt.AlignCenter;
            value:appconfig.backLight;stepSize: 5;focus: true;numericValueLabel: true;
            minimumValue: 0;maximumValue: 220; activeFocusOnPress: true;
        }
        Rectangle{
            width:Units.dp(240);
            height:Units.dp(10);
        }
        onAccepted: {appconfig.backLight=backlightslider.value}
        onRejected: {backlightslider.value=appconfig.backLight}
    }
    /*颜色选择对话框*/
    Dialog {
        id: colorPicker;title: qsTr("主题");negativeButtonText:qsTr("取消");positiveButtonText: qsTr("完成");
        /*接受则存储系统颜色*/
        onAccepted:{appconfig.themePrimaryColor=theme.primaryColor;appconfig.themeAccentColor=theme.accentColor;appconfig.themeBackgroundColor=theme.backgroundColor; }
        /*不接受则释放系统颜色*/
        onRejected: {theme.primaryColor=appconfig.themePrimaryColor;theme.accentColor=appconfig.themeAccentColor;theme.backgroundColor=appconfig.themeBackgroundColor; }
        /*下拉菜单*/
        MenuField { id: selection; model: ["基本色彩", "前景色彩", "背景色彩"]; width: Units.dp(160)}
        Grid {
            columns: 7
            spacing: Units.dp(8)
            Repeater {
                model: [
                    "red", "pink", "purple", "deepPurple", "indigo",
                    "blue", "lightBlue", "cyan", "teal", "green",
                    "lightGreen", "lime", "yellow", "amber", "orange",
                    "deepOrange", "grey", "blueGrey", "brown", "black",
                    "white"
                ]
                Rectangle {
                    width: Units.dp(30)
                    height: Units.dp(30)
                    radius: Units.dp(2)
                    color: Palette.colors[modelData]["500"]
                    border.width: modelData === "white" ? Units.dp(2) : 0
                    border.color: Theme.alpha("#000", 0.26)
                    Ink {
                        anchors.fill: parent
                        onPressed: {
                            switch(selection.selectedIndex) {
                            case 0:
                                theme.primaryColor = parent.color
                                break;
                            case 1:
                                theme.accentColor = parent.color
                                break;
                            case 2:
                                theme.backgroundColor = parent.color
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    /*更换用户对话框*/
    Dialog{
        id:changeuser;
        title:qsTr("更换用户");negativeButtonText:qsTr("取消");positiveButtonText:qsTr("确定");
        positiveButtonEnabled:false;
        onAccepted: {
            appconfig.currentUserName = changeuserFeildtext.selectedText;
            appconfig.currentUserType = changeuserFeildtext.helperText; }
        onRejected: {
            changeuserFeildtext.helperText = appconfig.currentUserType;
            for(var i=0;i<100;i++){
                if(accountname.text === usrnamemodel.get(i).text ){
                    changeuserFeildtext.selectedIndex = i;
                    break; }
            }
        }
        ListModel{id:usrnamemodel;ListElement{text:"user";}}
        MenuField{id:changeuserFeildtext;
            floatingLabel:true;
            placeholderText:qsTr("用户名:");
            model:usrnamemodel;
            width:password.width
            onItemSelected:  {
                password.enabled=true;
                var data=usrnamemodel.get(index);
                var result =  DB.getuserpassword(data.text);
                appconfig.currentUserPassword = result.rows.item(0).password;
                changeuserFeildtext.helperText = result.rows.item(0).type;
                password.text="";}}
        TextField{id:password;
            floatingLabel:true;
            placeholderText:qsTr("密码:");
            characterLimit: 8;
            onTextChanged:{
                if(password.text=== appconfig.currentUserPassword){
                    changeuser.positiveButtonEnabled=true;
                    password.helperText.color="green";
                    password.helperText=qsTr("密码正确");}
                else{changeuser.positiveButtonEnabled=false;
                    password.helperText=qsTr("请输入密码...");}}
            onHasErrorChanged: {
                if(password.hasError === true){
                    console.log("length changed");
                    password.helperText =qsTr( "密码超过最大限制");}}
            Keys.onPressed: {
                switch(event.key){
                case Qt.Key_F1:
                    password.insert(password.length,"1");
                    event.accepted=true;
                    break;
                case Qt.Key_F2:
                    password.insert(password.length,"2");
                    event.accepted=true;
                    break;
                }
            }
        }
    }
    /*语言对话框*/
    Dialog{  id:languagePicker;
        title:qsTr("更换语言");negativeButtonText:qsTr("取消");positiveButtonText:qsTr("确定");
        Column{
            width: parent.width
            spacing: 0
            Repeater{
                model: [qsTr("汉语"),qsTr("英语")];
                ListItem.Standard{
                    text:modelData;
                    showDivider: true;
                }
            }
        }
    }
    /*send*/
    Popslider{
        id:slider
    }
}
