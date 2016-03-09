import QtQuick 2.4
import Material 0.1 as Material
import Material.Extras 0.1
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.1
import QtQuick.LocalStorage 2.0
import QtQuick.Controls 1.4
//import "qrc:/Database.js" as DB
//import "CanvasPaint.js" as Paint
/*应用程序窗口*/
Material.ApplicationWindow{
    id: app;title: "app";visible: true
    /*主题默认颜色*/
    theme { primaryColor: AppConfig.themePrimaryColor;accentColor: AppConfig.themeAccentColor;backgroundColor:AppConfig.themeBackgroundColor
        tabHighlightColor: "white"  }
    property var preset:["TeachPreset","GroovePreset","WeldPreset"]
    property var presetName: ["示教预置","坡口预置","焊接预置"]
    property var presetIcon: ["action/android","awesome/road","user/MAG"]
    property var analyse: ["WeldAnalyse"]
    property var analyseName:["焊接分析"]
    property var analyseIcon: ["awesome/line_chart"]
    property var infor: ["SystemInfor"]
    property var inforName:["系统信息"]
    property var inforIcon: ["awesome/tasks"]
    property var test: ["CheckTest"]
    property var testName:["系统测试"]
    property var testIcon: ["awesome/tasks"]
    property var sections: [preset,analyse, infor,test]
    property var sectionsName:[presetName,analyseName,inforName,testName]
    property var sectionsIcon:[presetIcon,analyseIcon,inforIcon,testIcon]
    property var sectionTitles: ["焊接预置", "焊接分析", "系统信息","系统测试" ]
    property var tabiconname: ["awesome/windows","awesome/line_chart","awesome/tasks","action/settings_input_composite"]
    property int selectedIndex:0
    /*当前本地化语言*/
    property string local: "zh_CN"
    /*当前坡口形状*/
    property string currentgroove;
    /*Modbus重载*/
    property bool modbusExist:true;
    /*更新时间定时器*/
    Timer{ interval: 500; running: true; repeat: true;
        onTriggered:{datetime.name= new Date().toLocaleDateString(Qt.locale(app.local),"MMMdd ddd ")+new Date().toLocaleTimeString(Qt.locale(app.local),"h:mm");
            if(modbusExist){
                //      ERModbus.setmodbusFrame(["R","1","6"]);
            }
        }
    }
    /*初始化Ｔabpage*/
    initialPage: Material.TabbedPage {
        id: page
        /*标题*/
        title:qsTr("便携式MAG焊接机器人系统")
        /*最大action显示数量*/
        actionBar.maxActionCount: 6
        /*actions列表*/
        actions: [
            /*危险报警action*/
            Material.Action {iconName: "alert/warning";
                name: qsTr("警告");
                //onTriggered: demo.showError("Something went wrong", "Do you want to retry?", "Close", true)
            },
            /*背光控制插件action*/
            Material.Action{name: qsTr("背光"); iconName:"device/brightness_medium";
                onTriggered:backlight.show();
            },
            /*系统选择颜色action*/
            Material.Action {iconName: "image/color_lens";
                name: qsTr("色彩") ;
                onTriggered: colorPicker.show();
            },
            /*系统设置action*/
            Material.Action {iconName:"user/MAG";
                name: qsTr("设置");
                //onTriggered
            },
            /*时间action*/
            Material.Action{name: qsTr("时间"); id:datetime;
                onTriggered:datePickerDialog.show();
            },
            /*账户*/
            Material.Action {id:accountname;iconName: "awesome/user";
                onTriggered:changeuser.show();text:AppConfig.currentUserName;
            },
            /*语言*/
            Material.Action {iconName: "action/language";name: qsTr("语言");
                onTriggered: languagePicker.show();
            },
            /*系统电源*/
            Material.Action {iconName: "awesome/power_off";name: qsTr("关机")
                onTriggered: Qt.quit();
            }
        ]
        backAction: navigationDrawer.action
        actionBar.tabBar.leftKeyline: 0;
        actionBar.tabBar.isLargeDevice: true
        actionBar.tabBar.fullWidth:false
        Material.NavigationDrawer{
            id:navigationDrawer
            enabled: true
            clip: true
            Material.Card{
                id:header
                anchors.top:parent.top//tableview.bottom
                anchors.left: parent.left
                width: parent.width
                height:Material.Units.dp(64);
                Material.Label{
                    id:navlabel
                    anchors.left: parent.left
                    anchors.leftMargin: Material.Units.dp(24)
                    anchors.verticalCenter: parent.verticalCenter
                    text:sectionTitles[page.selectedTab]
                    style:"title"
                    color: Material.Theme.light.shade(0.87)
                }
            }
            Column{
                id:navDrawerContent
                anchors.top: header.bottom
                anchors.left: parent.left
                anchors.leftMargin: Material.Units.dp(24)
                anchors.bottom: parent.bottom
                width: parent.width
                Repeater{
                    id:navrep
                    model:sectionsName[page.selectedTab]
                    delegate:ListItem.Standard{
                        text:modelData
                        iconName: sectionsIcon[page.selectedTab][index]
                        selected:app.selectedIndex===index
                        onClicked: {
                            app.selectedIndex=index
                            navigationDrawer.close();
                        }
                    }
                }
            }
            Material.ThinDivider{
                anchors.bottom: navUser.top
            }
            ListItem.Standard{
                id:navUser
                height:Material.Units.dp(40);
                anchors.bottom: navUserType.top
                anchors.left: parent.left
                anchors.leftMargin: Material.Units.dp(16);
                iconName: "awesome/user"
                text:"用户名 : "+AppConfig.currentUserName
            }
            ListItem.Standard{
                id:navUserType
                height:Material.Units.dp(40);
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Material.Units.dp(8)
                anchors.left: parent.left
                anchors.leftMargin: Material.Units.dp(16);
                iconName: "awesome/group"
                text:"用户组 : "+AppConfig.currentUserType
            }
            Keys.onDownPressed: {if(app.selectedIndex !==navrep.count -1 ) app.selectedIndex++;else app.selectedIndex=navrep.count-1;event.accpet=true;}
            Keys.onUpPressed: {if(app.selectedIndex) app.selectedIndex-- ; else app.selectedIndex=0 ;event.accpet=true;}
            Keys.onSelectPressed: {navigationDrawer.toggle()
                event.accepted=true;}
            Keys.onPressed: {
                switch(event.key){
                case Qt.Key_F1:
                    navigationDrawer.toggle()
                    event.accepted=true;
                    break;
                }
            }

        }
        onSelectedTabChanged: {
            app.selectedIndex=0;
            Qt.inputMethod.hide()
        }
        Repeater {
            model: sectionTitles
            delegate: Material.Tab {
                title: modelData+ (index===0 ?"(I)":index===1?"(II)":index===2?"(III)":"(IV)")
                iconName:tabiconname[index];
                property int sectionsindex: index
                Item{
                    Flickable {
                        id: flickable
                        objectName: modelData
                        anchors.fill: parent
                        clip: true
                        Repeater{
                            model: sections[sectionsindex]
                            delegate:Item {
                                anchors.fill: parent
                                Loader {
                                    id:loader
                                    anchors.fill: parent
                                    asynchronous: true
                                    visible: app.selectedIndex === index && loader.status ===Loader.Ready
                                    source: { return Qt.resolvedUrl("%.qml").arg(modelData)}
                                    property QtObject comment: QtObject{
                                        property bool modbusCheck:modbusExist;
                                    }
                                }
                                Material.ProgressCircle {
                                    anchors.centerIn: parent
                                    visible: loader.status == Loader.Loading
                                    width:Material.Units.dp(64)
                                    height:width
                                }
                            }
                        }
                    }
                    Material.Scrollbar {
                        flickableItem: flickable
                    }
                }
            }
        }
        Keys.onDigit1Pressed: page.selectedTab=0;
        Keys.onDigit2Pressed: page.selectedTab=1;
        Keys.onDigit3Pressed: page.selectedTab=2;
        Keys.onDigit4Pressed: page.selectedTab=3;
        Keys.onPressed: {
            switch(event.key){
            case Qt.Key_F1:
                navigationDrawer.toggle()
                event.accepted=true;
                break;
            case Qt.Key_F2:
                event.accepted=true;
                break;
            }
        }
    }
    Connections{
        target: ERModbus
        onModbusFrameChanged:{
            debugTextArea.append(new Date().toLocaleTimeString(Qt.locale(app.local),"h:mm") +":"+frame)
            if(debugTextArea.length>1000){
                debugTextArea.remove(0,debugTextArea.length-1000)
            }
        }
    }
    Material.Sidebar{
        id:sidebar
        header:qsTr("调试信息")
        mode:"right"
        visible: false
        width:Material.Units.dp(300)
        contents:TextArea{
            id:debugTextArea
            readOnly: true
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
        Material.UserData.openDatabase();
        /*写入系统背光值*/
        AppConfig.backLight=AppConfig.backLight;
    }
    /*日历*/
    Material.Dialog {
        id:datePickerDialog; hasActions: true; contentMargins: 0;floatingActions: true
        negativeButtonText:qsTr("取消");positiveButtonText: qsTr("完成");
        Material.DatePicker {
            frameVisible: false;dayAreaBottomMargin : Material.Units.dp(48);isLandscape: true;
        }
    }
    /*背光调节*/
    Material.Dialog{
        id:backlight
        title: qsTr("背光调节");negativeButtonText:qsTr("取消");positiveButtonText: qsTr("完成");
        Material.Slider {
            id:backlightslider;height:Material.Units.dp(64);width:Material.Units.dp(240);Layout.alignment: Qt.AlignCenter;
            value:AppConfig.backLight;stepSize: 5;numericValueLabel: true;
            minimumValue: 0;maximumValue: 220; activeFocusOnPress: true;
        }
        Rectangle{
            width:Material.Units.dp(240);
            height:Material.Units.dp(10);
        }

        onAccepted: {AppConfig.backLight=backlightslider.value}
        onRejected: {backlightslider.value=AppConfig.backLight}
    }
    /*颜色选择对话框*/
    Material.Dialog {
        id: colorPicker;title: qsTr("主题");negativeButtonText:qsTr("取消");positiveButtonText: qsTr("完成");
        /*接受则存储系统颜色*/
        onAccepted:{AppConfig.themePrimaryColor=theme.primaryColor;AppConfig.themeAccentColor=theme.accentColor;AppConfig.themeBackgroundColor=theme.backgroundColor; }
        /*不接受则释放系统颜色*/
        onRejected: {theme.primaryColor=AppConfig.themePrimaryColor;theme.accentColor=AppConfig.themeAccentColor;theme.backgroundColor=AppConfig.themeBackgroundColor; }
        /*下拉菜单*/
        Material.MenuField { id: selection; model: ["基本色彩", "前景色彩", "背景色彩"]; width: Material.Units.dp(160)}
        Grid {
            columns: 7
            spacing: Material.Units.dp(8)
            Repeater {
                model: [
                    "red", "pink", "purple", "deepPurple", "indigo",
                    "blue", "lightBlue", "cyan", "teal", "green",
                    "lightGreen", "lime", "yellow", "amber", "orange",
                    "deepOrange", "grey", "blueGrey", "brown", "black",
                    "white"
                ]
                Rectangle {
                    width: Material.Units.dp(30)
                    height: Material.Units.dp(30)
                    radius: Material.Units.dp(2)
                    color: Material.Palette.colors[modelData]["500"]
                    border.width: modelData === "white" ? Material.Units.dp(2) : 0
                    border.color: Material.Theme.alpha("#000", 0.26)
                    Material.Ink {
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
    Material.Dialog{
        id:changeuser;
        title:qsTr("更换用户");negativeButtonText:qsTr("取消");positiveButtonText:qsTr("确定");
        positiveButtonEnabled:false;
        onAccepted: {
            AppConfig.currentUserName = changeuserFeildtext.selectedText;
            AppConfig.currentUserType = changeuserFeildtext.helperText; }
        onRejected: {
            changeuserFeildtext.helperText = AppConfig.currentUserType;
            for(var i=0;i<100;i++){
                if(accountname.text === usrnamemodel.get(i).text ){
                    changeuserFeildtext.selectedIndex = i;
                    break; }
            }
        }
        ListModel{id:usrnamemodel;ListElement{text:"user";}}
        Material.MenuField{id:changeuserFeildtext;
            floatingLabel:true;
            placeholderText:qsTr("用户名:");
            model:usrnamemodel;
            width:password.width
            onItemSelected:  {
                password.enabled=true;
                var data=usrnamemodel.get(index);
                var result =  DB.getuserpassword(data.text);
                AppConfig.currentUserPassword = result.rows.item(0).password;
                changeuserFeildtext.helperText = result.rows.item(0).type;
                password.text="";}}
        Material.TextField{id:password;
            floatingLabel:true;
            placeholderText:qsTr("密码:");
            characterLimit: 8;
            onTextChanged:{
                if(password.text=== AppConfig.currentUserPassword){
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
    Material.Dialog{  id:languagePicker;
        title:qsTr("更换语言");negativeButtonText:qsTr("取消");positiveButtonText:qsTr("确定");
        Column{
            width: parent.width
            spacing: 0
            Repeater{
                model: ["汉语","英语"]//[qsTr("汉语"),qsTr("英语")];
                ListItem.Standard{
                    text:modelData;
                    showDivider: true;
                }
            }
        }
    }
}
