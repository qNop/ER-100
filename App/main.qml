import QtQuick 2.4
import Material 0.1 as Material
import Material.Extras 0.1
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0
import WeldSys.WeldMath 1.0
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.1
import QtQuick.LocalStorage 2.0
import QtQuick.Controls 1.4
//import WeldSys.SysInfor 1.0
import QtQuick.Window 2.2

/*应用程序窗口*/
Material.ApplicationWindow{
    id: app;title: "app";visible: true
    objectName: "App"
    /*主题默认颜色*/
    theme { primaryColor: AppConfig.themePrimaryColor;accentColor: AppConfig.themeAccentColor;backgroundColor:AppConfig.themeBackgroundColor
        tabHighlightColor: "#FFFFFF"  }
    property var grooveName: ["flatweldsinglebevelgroovet","flatweldsinglebevelgroove","flatweldvgroove","horizontalweldsinglebevelgroovet","horizontalweldsinglebevelgroove","verticalweldsinglebevelgroovet","verticalweldsinglebevelgroove","verticalweldvgroove","flatfillet"]
    //不需要解释
    property var grooveStyleName: [ "平焊单边V型坡口T接头",  "平焊单边V型坡口平对接", "平焊V型坡口平对接","横焊单边V型坡口T接头",  "横焊单边V型坡口平对接", "立焊单边V型坡口T接头",  "立焊单边V型坡口平对接", "立焊V型坡口平对接","水平角焊"  ]
    property var preset:["GrooveCondition","TeachCondition","WeldCondition","GrooveCheck","LimitedConditon"]
    property var presetName: ["坡口条件","示教条件","焊接条件","坡口参数","限制条件"]
    property var presetIcon: ["awesome/road","action/android","user/MAG","awesome/road","awesome/sliders"]
    property var analyse: ["WeldData","WeldAnalyse"]
    property var analyseName:["焊接参数","过程分析"]
    property var analyseIcon: ["awesome/tasks","awesome/pie_chart"]
    property var infor: ["SysErrorHistroy","UserAccount","SystemInfor"]
    property var inforName:["用户管理","历史错误","关于系统"]
    property var inforIcon: ["social/group","awesome/list_alt","awesome/desktop"]
    property var sections: [preset,analyse, infor]
    property var sectionsName:[presetName,analyseName,inforName]
    property var sectionsIcon:[presetIcon,analyseIcon,inforIcon]
    property var sectionTitles: ["预置条件", "焊接分析", "系统信息"]
    property var tabiconname: ["action/settings_input_composite","awesome/tasks","awesome/windows"]
    property var errorName: ["主控制器异常","CAN通讯异常","急停报警","摇动电机过热过流","摇动电机右限位","摇动电机左限位","摇动电机原点搜索","摇动电机堵转", "摆动电机过热过流","摆动电机内限位","摆动电机外限位","摆动电机原点搜索","摆动电机堵转", "上下电机过热过流","上下电机下限位","上下电机上限位","上下电机原点搜索","上下电机堵转", "行走电机过热过流","行走电机右限位","行走电机左限位","行走电机原点搜索","行走电机堵转","驱动器急停报警","手持盒通讯异常","示教器通讯异常","焊接电源通讯异常","未定义异常","未定义异常","未定义异常","未定义异常","未定义异常"]
    property int  page0SelectedIndex:0
    property int  page1SelectedIndex:0
    property int  page2SelectedIndex:0
    /*当前本地化语言*/
    property string local: "zh_CN"
    /*当前坡口形状*/
    property int currentGroove:0//AppConfig.currentGroove
    /*当前坡口形状的名称*/
    property string currentGrooveName
    /*Modbus重载*/
    property bool modbusBusy:false;
    /*系统信息采集标志*/
    property bool sysInforFlag: true;
    /*系统状态*/
    property string sysStatus:"未登录态"
    /*系统状态集合*/
    property var sysStatusList: ["空闲态","坡口检测态","坡口检测完成态","焊接态","焊接中间暂停态","焊接端部暂停态","停止态","未登录态"]
    /*焊接时间*/
    property var weldTime:[];
    /*上一次froceitem*/
    property Item lastFocusedItem:null
    /*错误*/
    property int errorCode:0
    /*上次错误*/
    property int oldErrorCode: 0
    /*焊接分析表格index*/
    property int weldTableIndex: -1
    /*坡口表格index*/
    property int grooveSelectIndex: 0
    /*line flag*/
    property bool dataActive: false
    /*开始采集时间*/
    property var startLine:new Date();
    /*刷新数据*/
    property var lineData;
    /*系统时间读取标志*/
    property bool readTime:false
    /*是否为修补焊接*/
    property bool weldFix: false
    /*bool 加载网络*/
    property bool loadInterNet: false
    /*焊接长度*/
    property int weldLength: 0
    /*teach初始化数据*/
    property var teachModel: [0,1,1,2,2,10,10,200,1,0,0,0]
    /*WeldCondition初始化数据*/
    property var weldConditionModel: [4,0,0,0,1,0,0,1,3,105,0,0,5,5,0.5,0.5,160,26,120,15,0,0,0,0,0,0,0,0]
    /*app加载完毕*/
    property bool completed:false
    /*account*/
    ListModel{id:accountmodel;}

    ListModel{id:initialListModel; ListElement{ID:0;C1:"无";C2:"0:00"}}

    /*当前用户名*/
    property string currentUser: AppConfig.currentUserName

    property string  weldRulesName
    /*更新时间定时器*/
    Timer{
        interval:1000;running:true;repeat: true;
        onTriggered:{
            var dateTime= new Date().toLocaleString(Qt.locale(app.local),"MMMdd ddd-h:mm")
            var timeD =dateTime.split("-");
            date.name=timeD[0]
            time.name=timeD[1]
            if(sysStatus=="未登录态"){
                switch(AppConfig.leds){
                case "start":AppConfig.setleds("stop");break;
                case "stop":AppConfig.setleds("ready");break;
                case "ready": AppConfig.setleds("start");break;
                default:AppConfig.setleds("start");break;}
            }
        }
    }
    //该页面下1000ms问一次检测参数是否有效
    Timer{ repeat: true;interval:sysStatus==="焊接态"?500:600;
        running:readTime
        onTriggered: {
            if(sysStatus=="坡口检测态")
                ERModbus.setmodbusFrame(["R","150","10"])
            else if(sysStatus=="焊接端部暂停态")
                ERModbus.setmodbusFrame(["R","200","1"]);
            else if(sysStatus=="焊接态")
                ERModbus.setmodbusFrame(["R","10","4"])
            else if(sysStatus=="未登录态"){}
            else
                ERModbus.setmodbusFrame(["R","0","3"]);
        }
    }
    //错误历史信息 ID：条数 C1 错误代码 C2 错误状态 C3 错误信息 C4: 操作用户 C5 错误发生/解除时刻
    ListModel{id:errorHistroy}
    onCurrentGrooveChanged: {
        console.log(objectName+" currentGroove "+currentGroove)
        ERModbus.setmodbusFrame(["W","90","1",currentGroove.toString()])
        var result=Material.UserData.getLastGrooveName(grooveStyleName[currentGroove]+"列表","EditTime")
        if(result){
            currentGrooveName=result
        }
        AppConfig.setcurrentGroove(currentGroove);
    }
    /*初始化Tabpage*/
    initialPage: Material.TabbedPage {
        id: page
        /*标题*/
        title:qsTr("全位置MAG焊接系统")
        /*最大action显示数量*/
        actionBar.maxActionCount: 5
        /*actions列表*/
        actions: [
            /*背光控制插件action*/
            Material.Action{name: qsTr("背光");
                iconName:backlightslider.value>41?"device/brightness_high":
                                                   backlightslider.value>19?"device/brightness_medium":"device/brightness_low";
                onTriggered:backlight.show();
            },
            /*系统选择颜色action*/
            Material.Action {iconName: "image/color_lens";
                name: qsTr("色彩") ;
                onTriggered: colorPicker.show();
            },
            /*时间action*/
            Material.Action{name: qsTr("日期"); id:date;
                onTriggered:datePickerDialog.show();
            },
            /*时间action*/
            Material.Action{name: qsTr("时间"); id:time;
                onTriggered:timePickerDialog.show();
            },
            /*账户*/
            Material.Action {id:accountname;iconName: "awesome/user";
                onTriggered:changeuser.show();text:AppConfig.currentUserName;
            },
            /*语言*/
            Material.Action {iconName: "action/language";name: qsTr("语言");
                onTriggered: languagePicker.show();
            },
            /*mount网络*/
            Material.Action {iconName:loadInterNet?"hardware/phonelink": "hardware/phonelink_off";name: qsTr("网络");
                onTriggered: {loadInterNet=!loadInterNet;AppConfig.setloadNet(loadInterNet);}
            },
            /*系统电源*/
            Material.Action {iconName: "awesome/power_off";name: qsTr("关机")
                onTriggered: {app.modbusBusy=false;app.sysInforFlag=false;Qt.quit();}
            }
        ]
        backAction: navigationDrawer.action
        actionBar.tabBar{leftKeyline: 0;isLargeDevice: false;fullWidth:false}
        Keys.onDigit1Pressed:  navigationDrawer.toggle();
        Keys.onDigit2Pressed: {if((page.selectedTab!=0)&&preConditionTab.enabled)page.selectedTab=0;}
        Keys.onDigit3Pressed: {if((page.selectedTab!=1)&&weldAnalyseTab.enabled)page.selectedTab=1;}
        Keys.onDigit4Pressed: {if((page.selectedTab!=2)&&(systemInforTab.enabled))page.selectedTab=2;}
        Keys.onPressed:{
            switch(event.key){
            case Qt.Key_F5:
                error.action.trigger();
                event.accpet=true;
                break;
            case Qt.Key_F6:
                robot.action.trigger();
                event.accpet=true;
                break;
            }
        }
        MyNavigationDrawer{
            id:navigationDrawer
            ListModel{id:listModel;ListElement{name:"";icon:""}}
            property bool openFinish: false
            onClosed: openFinish=false;
            //加载model进入listview
            onOpened: {
                listModel.clear();
                titleImage=app.tabiconname[page.selectedTab]
                titleLabel=app.sectionTitles[page.selectedTab]
                var type=AppConfig.currentUserType;
                for(var i=0;i<sectionsName[page.selectedTab].length;i++){
                    listModel.append({"name":sectionsName[page.selectedTab][i],"icon":sectionsIcon[page.selectedTab][i]})
                }
                if((page.selectedTab===0)&&(type==="用户"))
                    listModel.remove(4,1);
                model=listModel;
                oldIndex=page.selectedTab===0 ? page0SelectedIndex :page.selectedTab===1?page1SelectedIndex :page2SelectedIndex;
                selectedIndex=oldIndex;
                openFinish=true;
            }
            onSelectedIndexChanged: {
                if(openFinish)
                {switch(page.selectedTab){
                    case 0:page0SelectedIndex=selectedIndex;break;
                    case 1:page1SelectedIndex=selectedIndex;break;
                    case 2:page2SelectedIndex=selectedIndex;break;
                    }
                }
            }
            //Nav关闭时 将焦点转移到选择的Item上 方便按键的对焦//
            function close() {
                showing = false
                if (parent.hasOwnProperty("currentOverlay")) {
                    parent.currentOverlay = null
                }
                //找出本次选择的焦点//
                __lastFocusedItem=Utils.findChild(page.selectedTab===0 ?preConditionTab:page.selectedTab===1?
                                                                             weldAnalyseTab: systemInforTab
                                                  ,sections[page.selectedTab][page.selectedTab===0 ?
                                                                                  page0SelectedIndex  : page.selectedTab===1?
                                                                                      page1SelectedIndex :page2SelectedIndex])
                if (__lastFocusedItem !== null) {
                    __lastFocusedItem.forceActiveFocus()
                    lastFocusedItem=__lastFocusedItem;
                }
                closed()
            }
        }
        onSelectedTabChanged: {
            Qt.inputMethod.hide();
            /*找出本次选择的焦点*/
            lastFocusedItem=Utils.findChild(page.selectedTab === 0 ?preConditionTab:page.selectedTab===1?
                                                                         weldAnalyseTab: systemInforTab
                                            ,sections[page.selectedTab][page.selectedTab===0 ?
                                                                            page0SelectedIndex  : page.selectedTab===1?
                                                                                page1SelectedIndex :page2SelectedIndex])
            if (lastFocusedItem !== null) {
                lastFocusedItem.forceActiveFocus();
            }
        }
        Material.Tab{
            id:preConditionTab
            title: qsTr("预置条件(II)")
            iconName: "action/settings_input_composite"
            Item{
                anchors.fill: parent
                GrooveCondition{
                    id:grooveConditionPage
                    visible: page0SelectedIndex===0
                    onCurrentGrooveChanged:{
                        console.log("grooveConditionPage"+currentGroove)
                        switch(currentGroove&0x0000000F){
                        case 0: grooveNum=0;  break;
                        case 8: grooveNum=1;  break;
                        case 12: grooveNum=2;  break;

                        case 9: grooveNum=4; break;
                        case 1: grooveNum=3;  break;

                        case 2:   grooveNum=5;  break;
                        case 10: grooveNum=6;  break;
                        case 14: grooveNum=7;break;

                        case 3:   grooveNum=8;  break;
                        case 11: grooveNum=8;  break;
                        case 7:   grooveNum=8;break;
                        case 15: grooveNum=8;break;
                        }
                        app.currentGroove=grooveNum;
                    }
                    Component.onCompleted: {
                        Material.UserData.openDatabase()
                        var res=AppConfig.currentGroove
                        switch(res){
                        case 0: currentGroove=0;  break;
                        case 1: currentGroove=8;  break;
                        case 2: currentGroove=12;  break;

                        case 4: currentGroove=9; break;
                        case 3: currentGroove=1;  break;

                        case 5: currentGroove=2;  break;
                        case 7: currentGroove=14;  break;
                        case 6: currentGroove=10;break;

                        case 8:  currentGroove=3;  break;
                        }
                        lastFocusedItem=grooveConditionPage}
                }
                TeachCondition{
                    id:teachConditionPage
                    repeaterModel: app.teachModel
                    visible: page0SelectedIndex===1}
                WeldCondition{
                    id:weldConditionPage
                    condition: app.weldConditionModel
                    visible: page0SelectedIndex===2}
                GrooveCheck{
                    id:grooveCheckPage
                    visible: page0SelectedIndex===3
                    status: app.sysStatus
                    message:snackBar
                    currentGrooveName:app.currentGrooveName
                    grooveName: app.grooveStyleName[currentGroove]
                    //改变坡口名称
                    onChangedCurrentGroove: {
                        //更新坡口名称
                        app.currentGrooveName=name;
//                        //清空坡口数据
//                        grooveTableInit.clear();
//                        //获取坡口数据
//                        var listmodel=Material.UserData.getTableJson(name)
//                        //插入数据到grooveTableInit
//                        if(typeof(listmodel)==="object"){
//                            for(var i=0;i<listmodel.length;i++){
//                                grooveTableInit.append(listmodel[i])
//                            }
//                        }
                    }
                }
                LimitedCondition{
                    id:limitedConditionPage
                    visible: (page0SelectedIndex===4)&&(AppConfig.currentUserType==="超级用户")
                    currentGrooveName:app.currentGrooveName+"限制条件"
                    limitedRulesName: app.weldRulesName.replace("焊接规范","限制条件")
                    message: snackBar
                }
            }
        }
        Material.Tab{
            id:weldAnalyseTab
            title: qsTr("焊接分析(III)")
            iconName:"awesome/tasks"
            Item{
                anchors.fill: parent
                WeldData{
                    id:weldAnalysePage
                    visible: page1SelectedIndex===0;
                    status: app.sysStatus
                    message:snackBar
                    currentGrooveName: app.currentGrooveName
                    currentGroove:app.currentGroove
                    onWeldRulesNameChanged: {
                        weldDataPage.weldRulesName=weldRulesName.replace("焊接规范","过程分析");
                        app.weldRulesName=weldRulesName;
                    }
                    onWeldTableIndexChanged: {
                        app.weldTableIndex=weldTableIndex;
                    }
                }
                WeldAnalyse{
                    id:weldDataPage
                    visible: page1SelectedIndex===1;
                    message: snackBar
                    status: app.sysStatus
                    //获取weldDataModel数据
                    //weldDataModel: weldTable
                    //获取weldTableIndex 所在行
                    weldTableCurrentRow:app.weldTableIndex

                }
                //  WeldLine{
                //  id:wledLinePage
                //  visible: page1SelectedIndex===1;
                //  status: app.sysStatus
                //  lineActive: app.dataActive
                //  lineModel: app.lineData
                //  lineTime: app.startLine
                //  weldNum: weldAnalyseTab.currentWeldNum
                //  floorNum: weldAnalyseTab.currentFloorNum
                // }
            }
            // enabled: sysStatus=="空闲态"||sysStatus=="焊接态"||sysStatus=="焊接中间暂停态"||sysStatus=="焊接端部暂停态"||sysStatus=="停止态"
        }
        Material.Tab{
            id:systemInforTab
            title: qsTr("系统信息(IV)")
            iconName:"action/dashboard"
            Item{
                anchors.fill: parent
                UserAccount{
                    visible: page2SelectedIndex===0
                    model:accountmodel
                    onUserUpdate: changeuser.show()
                }
                SysErrorHistroy{
                    model:errorHistroy
                    visible: page2SelectedIndex===1
                    status:sysStatus
                    onRemoveall:{
                        errorHistroy.clear();
                        //清楚数据表格
                        Material.UserData.clearTable("SysErrorHistroy","","");
                        snackBar.open("错误历史记录已被清空！");
                    }
                    onRemove:{
                        if(seletedIndex!==-1){
                            var index=seletedIndex;
                            Material.UserData.clearTable("SysErrorHistroy","ID",errorHistroy.get(index).ID);
                            errorHistroy.remove(index);
                            snackBar.open("本条错误已移除！");
                        }else
                            snackBar.open("请选择要移除的信息条目！");
                    }
                }
                SystemInfor{visible: page2SelectedIndex===2}
            }
        }
    }
    onSysStatusChanged: {
        if(sysStatus=="空闲态"){
            //高压接触传感
            snackBar.open("焊接系统空闲！")
            //空闲态
            AppConfig.setleds("ready");
            //切换页面
            page.selectedTab=0;
            app.page0SelectedIndex=0;

        }else if(sysStatus=="坡口检测态"){
            //高压接触传感
            snackBar.open("坡口检测中，高压输出，请注意安全！")
            //切换指示灯
            AppConfig.setleds("start");
            //切换界面
            page.selectedTab=0;
            //切小页面
            app.page0SelectedIndex=3;
        }else if(sysStatus=="坡口检测完成态"){
            //检测完成
            snackBar.open("坡口检测完成！正在计算相关焊接规范。")
            //切换指示灯为准备好
            AppConfig.setleds("ready");
            ERModbus.setmodbusFrame(["R","104","1"])
            page.selectedTab=1;
            app.page1SelectedIndex=0;
        }else if(sysStatus=="焊接态"){
            //启动焊接
            AppConfig.setleds("start");
            //提示
            snackBar.open(weldFix?"焊接系统修补焊接中。":"焊接系统焊接中。")
            //切换到 焊接曲线页面下
            app.page1SelectedIndex=0;
            //切换到 焊接分析页面
            page.selectedTab=1;
            //把line的坐标更新到当前坐标
            app.startLine=new Date();
        }else if(sysStatus=="焊接端部暂停态"){
            //焊接暂停
            AppConfig.setleds("ready");
            //系统焊接中
            snackBar.open(weldFix?"焊接系统修补焊接端部暂停。":"焊接系统焊接端部暂停。")
            //切换到 表格
            app.page1SelectedIndex=0;
            //切换到 焊接分析页面
            page.selectedTab=1;
        }else if(sysStatus=="停止态"){
            //系统停止
            AppConfig.setleds("stop");
            //焊接系统停止
            snackBar.open("焊接系统停止。")
            //将状态切换成0
            ERModbus.setmodbusFrame(["W","0","1","0"]);
        }else if(sysStatus=="焊接中间暂停态"){
            //焊接中间暂停
            AppConfig.setleds("ready");
            //切换提示信息
            snackBar.open(weldFix?"焊接系统修补焊接中间暂停。":"焊接系统焊接中间暂停。")
        }
        /*找出本次选择的焦点*/
        lastFocusedItem=Utils.findChild(page.selectedTab === 0 ?preConditionTab:page.selectedTab===1?
                                                                     weldAnalyseTab: systemInforTab
                                        ,sections[page.selectedTab][page.selectedTab===0 ?
                                                                        page0SelectedIndex  : page.selectedTab===1?
                                                                            page1SelectedIndex :page2SelectedIndex])
        if (lastFocusedItem !== null) {
            lastFocusedItem.forceActiveFocus();
        }
    }
    Connections{
        target: ERModbus
        //frame[0] 代表状态 1代读取的寄存器地址 2代表返回的 第一个数据 3代表返回的第二个数据 依次递推
        onModbusFrameChanged:{
            var MathError=1;
            if(frame[0]!=="Success"){
                // app.showError("Modbus 通讯异常！",frame[0],"关闭","");
                MathError=1;
                MathError<<=25;
                errorCode=MathError;
            }else{
                //  app.closeError();
                //查询系统状态
                if(frame[1]==="0"){
                    //获取系统状态
                    sysStatus=sysStatusList[Number(frame[2])];
                    //获取系统错误警报
                    MathError=Number(frame[4]);
                    MathError<<=16;
                    MathError|=Number(frame[3]);
                    errorCode=MathError;
                }
                else  if((frame[1]==="200")&&(sysStatus==="焊接端部暂停态")){
                    console.log(frame)
                    if((frame[2]!==app.weldTableIndex.toString())&&(!weldFix)){
                        if(frame[2]!=="99"){
                            weldFix=false;
                        }else{
                            weldFix=true;
                        }
                        return;
                    }else if((weldFix)&&(frame[2]!=="99")){
                        weldFix=false;
                    }
                }
                else if((frame[1]==="10")&&(sysStatus==="焊接态")){
                    //将数据赋值
                    app.lineData=frame;
                    //变更数据有效状态
                    app.dataActive=!app.dataActive;
                    //发送握手信号
                    ERModbus.setmodbusFrame(["R","0","3"]);
                }
                else if(frame[1]==="510"){
                    if(!readTime){
                        //读取系统时间
                        ERModbus.setmodbusFrame(["R","510","6"])
                    }else{
                        console.log(frame);
                        AppConfig.setdateTime(frame.slice(2,8));
                    }
                    readTime=true;
                }
            }
        }
    }

    Material.ActionButton{
        id:robot
        visible: (!page.actionBar.overflowMenuShowing)&&(!myErrorDialog.showing)&&(!moto.showing)&&(!navigationDrawer.showing)&&(!changeuser.showing)
        Behavior on visible {NumberAnimation{duration: 200}}
        action:Material.Action{
            iconName:"action/android";name: qsTr("机头操作")
            onTriggered: {
                moto.open();
            }
        }
        anchors.right: snackBar.left
        anchors.rightMargin: Material.Units.dp(24)
        anchors.verticalCenter: snackBar.verticalCenter
        isMiniSize: true
    }
    /*危险报警action*/
    Material.ActionButton{
        id:error
        visible: (!page.actionBar.overflowMenuShowing)&&(!myErrorDialog.showing)&&(!navigationDrawer.showing)&&(!changeuser.showing)
        Behavior on anchors.right {NumberAnimation{duration: 200}}
        action:Material.Action {iconName:  errorCode?"alert/warning":sysStatus==="空闲态"?"awesome/play":
                                                                                        sysStatus==="坡口检测态"?"awesome/flash":
                                                                                                             sysStatus==="焊接态"?"user/MAG":"awesome/pause"
            name: qsTr("警告");
            onTriggered: myErrorDialog.show();}
        anchors.right: robot.visible? robot.left:snackBar.left
        anchors.rightMargin: Material.Units.dp(16)
        anchors.verticalCenter: snackBar.verticalCenter
        isMiniSize: true
    }
    // iconColor: errorCode?Material.Theme.primaryColor:Material.Theme.dark.iconColor}
    Material.Snackbar{
        id:snackBar
        anchors {
            left:parent.left;
            leftMargin: opened ? page.width - width : page.width
            right:undefined
            bottom:undefined
            bottomMargin: undefined
            top:parent.top
            topMargin:app.height-page.height-snackBar.height/2
            horizontalCenter:undefined
            Behavior on leftMargin {
                NumberAnimation { duration: 300 }
            }
        }
        property string status: "open"
        fullWidth:false
        duration:2000;
    }
    InputPanel{
        id:input
        objectName: "InputPanel"
        visible: Qt.inputMethod.visible
        y: Qt.inputMethod.visible ? parent.height - input.height:parent.height
        Behavior on y{
            NumberAnimation { duration: 200 }
        }
    }
    onErrorCodeChanged: {
        var MathError=errorCode;
        var MathXor=errorCode^oldErrorCode;
        var errorTime=Material.UserData.getSysTime();
        for(var i=0;i<errorName.length;i++){
            //如果变化存在
            if(MathXor&0x0001){
                //错误存在
                if(MathError&0x0001){
                    //如果无错误存在则 移除无错误
                    if(initialListModel.count){
                        if(initialListModel.get(0).ID===0)
                            initialListModel.remove(0,1);}
                    initialListModel.insert(0,{"ID":Number(i+1),"C1":errorName[i],"C2":errorTime })
                    errorHistroy.insert(0,{"ID":String(errorHistroy.count+1),"C1":String(i+1),"C2":"发生","C4":errorName[i],"C3":app.currentUser,"C5": errorTime})

                }else{
                    for(var j=0;j<initialListModel.count;j++){
                        //如果列表里面有则移除 解除错误
                        if((i+1)===(initialListModel.get(j).ID)){
                            initialListModel.remove(j,1);
                            //向数据库中插入
                            errorHistroy.insert(0,{"ID":String(errorHistroy.count+1),"C1":String(i+1),"C2":"解除","C4":errorName[i],"C3":app.currentUser,"C5": errorTime})
                            if(errorTable.__listView.currentIndex>=initialListModel.count){
                                errorTable.__listView.currentIndex=j;
                                errorTable.selection.select(j);
                            }
                        }
                    }
                }
                Material.UserData.insertTable("SysErrorHistroy","(?,?,?,?,?,?)",[errorHistroy.get(0).ID,errorHistroy.get(0).C1,errorHistroy.get(0).C2,errorHistroy.get(0).C3,errorHistroy.get(0).C4,errorHistroy.get(0).C5])
            }
            MathXor>>=1;
            MathError>>=1;
        }
        //显示系统错误对话框
        if((errorCode)&&(!myErrorDialog.showing))
            myErrorDialog.show();
        if(errorCode===0)
        {
            initialListModel.clear()
            initialListModel.append({"ID":0,"C1":"无","C2":"0:00"})
            errorTable.__listView.currentIndex=0;
            errorTable.selection.select(0);
        }
        oldErrorCode=errorCode;
    }
    Material.Dialog{
        id:myErrorDialog
        overlayLayer: "overlayLayer"
        overlayColor: Qt.rgba(0, 0, 0, 0.3)
        title: "系统错误"
        property alias errorModel:errorTable.model
        positiveButtonText: qsTr("错误历史信息");
        onAccepted: {
            page.selectedTab=2;
            page2SelectedIndex=1;
        }
        negativeButton.visible: false
        onOpened: {
            errorTable.__listView.currentIndex=0;
            errorTable.selection.clear();
            errorTable.selection.select(0);
        }
        globalMouseAreaEnabled:true;
        Table{
            id:errorTable
            model:initialListModel
            width:Material.Units.dp(570)
            height:initialListModel.count<6?initialListModel.count*Material.Units.dp(48)+Material.Units.dp(56):Material.Units.dp(344)
            firstData.title: "错误代码"
            TableViewColumn{role: "C1";title:"错误信息";width:Material.Units.dp(250);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter}
            TableViewColumn{role: "C2";title:"发生时间";width:Material.Units.dp(180);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter}
        }
    }
    Material.Dialog{
        id:moto
        title: "机头坐标设定"
        property var send:  ["0","0","0","0","0","0","0","0","0","0","0","0"]
        negativeButtonText:qsTr("取消");positiveButtonText: qsTr("完成");
        onAccepted:{
            //下发数据
            ERModbus.setmodbusFrame(["W","26","12"].concat(send));
            //同时也保存数据
            AppConfig.setSwingSpeed(Number(send[0]));
            AppConfig.setZSpeed(Number(send[1]));
            AppConfig.setYSpeed(Number(send[2]));
            AppConfig.setXSpeed(Number(send[3]));
        }
        Keys.onPressed: {
            if((event.keys===Qt.Key_F6)&&(moto.showing)){
                moto.close();
                event.accpet=true;
            }
        }
        onRejected: {
            send.length=0;
            send= ["0","0","0","0","0","0","0","0","0","0","0","0"];
            console.log("moto rejected")
        }
        dialogContent:[
            Column{
                id:motoColumn
                Repeater{
                    model:["摇动电机：  ","摆动电机：  ", "上下电机：  ","行走电机：  ",]
                    delegate:Row {
                        id:motoRow
                        Material.Label{
                            text:modelData;anchors.verticalCenter: parent.verticalCenter
                        }
                        Material.Label{
                            text:"原点设定";anchors.verticalCenter: parent.verticalCenter
                            style:"menu"
                        }
                        Material.CheckBox{
                            anchors.verticalCenter: parent.verticalCenter
                            onCheckedChanged: {
                                moto.send[index+4]=checked?"1":"0";
                            }
                            onVisibleChanged: {
                                if(visible)
                                    checked=false;
                            }
                        }
                        Material.Label{
                            text:"锁定解除";anchors.verticalCenter: parent.verticalCenter
                            style:"menu"
                        }
                        Material.CheckBox{
                            anchors.verticalCenter: parent.verticalCenter
                            onCheckedChanged: {
                                moto.send[index+8]=checked?"1":"0";
                            }
                            onVisibleChanged: {
                                if(visible)
                                    checked=false;
                            }
                        }
                        Material.Label{
                            text:"点动速度(cm/min)";anchors.verticalCenter: parent.verticalCenter
                            style:"menu"
                        }
                        Material.TextField{
                            anchors.verticalCenter: parent.verticalCenter
                            onVisibleChanged: {
                                if(visible){
                                    var num=index===0?AppConfig.swingSpeed:index===1?AppConfig.zSpeed:
                                                                                      index===2?AppConfig.ySpeed:AppConfig.xSpeed
                                    text=num/10;
                                }
                            }
                            onTextChanged: {
                                if(Number(text)<40)
                                    moto.send[index]=(Number(text)*10).toString();
                                else
                                    moto.send[index]="400";}
                            inputMethodHints: Qt.ImhDigitsOnly
                            horizontalAlignment:TextInput.AlignHCenter
                            width: Material.Units.dp(60)
                        }
                    }
                }
            }
        ]
    }
    /*日历*/
    Material.Dialog {
        id:datePickerDialog;
        property var dateTimeDialog:new Array();
        hasActions: true; contentMargins: 0;floatingActions: true
        negativeButtonText:qsTr("取消");positiveButtonText: qsTr("完成");
        dialogContent:Material.DatePicker {
            id:datePicker
            __locale:Qt.locale(app.local)
            frameVisible: false;dayAreaBottomMargin : Material.Units.dp(48);isLandscape: true;
            onClicked: {
                var current=date.toLocaleDateString(Qt.locale(app.local),"yy/M/d/");
                current =current+new Date().toLocaleTimeString(Qt.locale(app.local),"h/m/s");
                datePickerDialog.dateTimeDialog=current.split("/");
            }
        }
        onOpened: {
            dateTimeDialog[0]="";
            //更新一下 当前选择的date
            datePicker.selectedDate=new Date();
        }
        onAccepted: {
            if(dateTimeDialog[0]!==""){
                ERModbus.setmodbusFrame(["W","510","6"].concat(dateTimeDialog));
                AppConfig.setdateTime(dateTimeDialog);
            }
        }
    }
    /*时间*/
    Material.Dialog {
        id:timePickerDialog;
        property var timeDialog:new Array();
        hasActions: true; contentMargins: 0;
        negativeButtonText:qsTr("取消");positiveButtonText: qsTr("完成");
        dialogContent:Material.TimePicker {
            //存在bug 24小时制时 输出数据多减12
            id:timePicker
            prefer24Hour:false
        }
        onAccepted: {
            var current=new Date().toLocaleDateString(Qt.locale(app.local),"yy/M/d/");
            current= current+timePicker.getCurrentTime().toLocaleTimeString(Qt.locale(app.local),"h/m/s");
            timeDialog=current.split("/")
            console.log(timeDialog)
            ERModbus.setmodbusFrame(["W","510","6"].concat(timeDialog));
            AppConfig.setdateTime(timeDialog);
        }
    }
    /*背光调节*/
    Material.Dialog{
        id:backlight
        title: qsTr("背光调节");negativeButtonText:qsTr("取消");positiveButtonText: qsTr("完成");
        property int back: 0
        dialogContent: Item{
            height:Material.Units.dp(100);
            width:Material.Units.dp(240);
            Material.Slider {
                id:backlightslider;width:Material.Units.dp(240);anchors.top: parent.top;anchors.topMargin: Material.Units.dp(24)
                value:AppConfig.backLight;stepSize: 5;numericValueLabel: true;
                minimumValue: 5;maximumValue: 100; activeFocusOnPress: true;
                onVisibleChanged: {if(visible){forceActiveFocus();backlight.back=backlightslider.value}}
                onValueChanged: if(focus) AppConfig.backLight=backlightslider.value;
            }}
        //  onAccepted: {AppConfig.backLight=backlightslider.value}
        onRejected: {backlightslider.value=back}
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
        width:Material.Units.dp(350)
        title:qsTr("用户登录");
        negativeButtonText:qsTr("取消");positiveButtonText:qsTr("确定");
        positiveButtonEnabled:false;
        negativeButton.visible: false;
        globalMouseAreaEnabled: true
        dismissOnTap:positiveButtonEnabled
        overlayColor: Qt.rgba(0, 0, 0, 0.3)
        property string password
        property string user
        property string type

        function getIndex(name){
            for(var i=0;i<accountmodel.count;i++){
                if(accountmodel.get(i).C2===name)
                    return i;
            }
            return -1;
        }
        onAccepted: {
            if(changeuser.positiveButtonEnabled){
                AppConfig.currentUserPassword = changeuser.password
                AppConfig.currentUserName = changeuser.user;
                AppConfig.currentUserType = changeuser.type;
                if(app.sysStatus==="未登录态"){
                    app.sysStatus="空闲态";
                    //发送主控登录标志
                    ERModbus.setmodbusFrame(["W","25","1","3"])
                }
            }
        }
        onRejected: {
            changeuserFeildtext.selectedIndex=getIndex(AppConfig.currentUserName);
            changeuser.type=AppConfig.currentUserType;
        }
        onOpened: {
            if(accountmodel.count>0){
                changeuser.user=AppConfig.currentUserName;
                var index=getIndex(changeuser.user);
                if(index>=0){
                    changeuser.password=accountmodel.get(index).C3;
                    changeuser.type=accountmodel.get(index).C4
                    changeuserFeildtext.selectedIndex=index;
                }else
                    snackBar.open("当前用户不存在！")
            }
            password.text="";
            password.placeholderText="请输入密码..."
            password.helperText=""
        }
        Column{
            spacing: Material.Units.dp(4)
            RowLayout{
                id:fLayout
                spacing: Material.Units.dp(12)
                Material.Label{
                    id:nameLabel
                    text:qsTr("用户名:");
                    style:"subheading"
                    color: Material.Theme.light.shade(0.54)
                    Layout.alignment: Qt.AlignVCenter
                }
                Material.MenuField{
                    id:changeuserFeildtext;
                    textRole: "C2"
                    model:accountmodel
                    implicitWidth:Material.Units.dp(220)
                    onItemSelected:  {
                        password.enabled=true;
                        var data=accountmodel.get(index);
                        changeuser.user=data.C2
                        changeuser.password = data.C3;
                        changeuser.type = data.C4;
                        password.text="";}}
            }
            RowLayout{
                spacing: Material.Units.dp(12)
                Material.Label{
                    text:qsTr("密    码:");
                    style:"subheading"
                    color: Material.Theme.light.shade(0.54)
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                }
                Material.TextField{id:password;
                    placeholderText:qsTr("请输入密码...");
                    characterLimit: 8;
                    implicitWidth:Material.Units.dp(220)
                    color: Material.Theme.light.shade(0.54)
                    onTextChanged:{
                        if(password.text=== changeuser.password){
                            changeuser.positiveButtonEnabled=true;
                            password.helperText=qsTr("密码正确");}
                        else{
                            changeuser.positiveButtonEnabled=false;}}
                    onHasErrorChanged: {
                        if(password.hasError === true){
                            password.helperText =qsTr( "密码超过最大限制");}
                        else
                            password.helperText=""
                    }
                }
            }
            Item{
                width:parent.width
                height: 10
            }
        }

    }
    /*语言对话框*/
    Material.Dialog{  id:languagePicker;
        title:qsTr("更换语言");negativeButtonText:qsTr("取消");positiveButtonText:qsTr("确定");
        Column{
            width: Material.Units.dp(200)
            spacing: 0
            Repeater{
                model: [qsTr("汉语"),qsTr("英语")];
                ListItem.Standard{
                    text:modelData;
                    showDivider:true;
                    onClicked: {
                        if(index==1){
                            app.local="en_US";
                        }
                        else{
                            app.local="zh_CN";
                        }
                    }
                }
            }
        }
    }
    Component.onCompleted: {
        ERModbus.setmodbusFrame(["R","510","6"]);
        /*打开数据库*/
        //Material.UserData.openDatabase();
        var res = Material.UserData.getTableJson("AccountTable");
        if(res!==-1){
            for(var i=0;i<res.length;i++){
                if(i<accountmodel.count)
                    accountmodel.set(i,res[i]);
                else
                    accountmodel.append(res[i]);
            }
        }
        changeuser.show();
        teachModel.length=0;
        teachModel=Material.UserData.getValueFromFuncOfTable("TeachCondition","","");
        weldConditionModel.length=0;
        weldConditionModel=Material.UserData.getValueFromFuncOfTable("WeldCondition","","");
        //创建错误历史记录
        Material.UserData.createTable("SysErrorHistroy","ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT");
        var res=Material.UserData.getTableJson("SysErrorHistroy","","")
        if(res!==-1){
            for(var i=res.length-1;i>=0;i--)
                errorHistroy.append(res[i])
        }
        var time=Material.UserData.getSysTime();
        //创建9个表格
        //  for(i=0;i<9;i++){
        //if(i)
        //删除列表
        //Material.UserData.deleteTable(grooveStyleName[i]+"列表")
        //创建列表
        //Material.UserData.createTable(grooveStyleName[i]+"列表","Teach TEXT,Weld TEXT,Groove TEXT,Data TEXT,CheckError TEXT,CreatTime TEXT,Creator TEXT,EditTime TEXT,Editor TEXT")
        //清除数据
        //Material.UserData.clearTable(grooveStyleName[i]+"列表","","")
        //初始化列表
        //Material.UserData.insertTable(grooveStyleName[i]+"列表","(?,?,?,?,?,?,?,?,?)",[grooveStyleName[i]+"示教条件",grooveStyleName[i]+"焊接条件",grooveStyleName[i],grooveStyleName[i]+"次列表",grooveStyleName[i]+"错误检测",time,"TKSW",time,"TKSW"])
        //创建坡口条件
        //Material.UserData.createTable(grooveStyleName[i],"ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT")
        //删除坡口限制条件
        //  Material.UserData.deleteTable(grooveStyleName[i]+"限制条件")
        //创建坡口限制条件
        //  Material.UserData.createTable(grooveStyleName[i]+"限制条件","ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT")
        //删除次列表
        // Material.UserData.deleteTable(grooveStyleName[i]+"次列表")
        //创建次列表
        // Material.UserData.createTable(grooveStyleName[i]+"次列表","Rules TEXT,Limited TEXT,Analyse TEXT,Line TEXT,CreatTime TEXT,Creator TEXT,EditTime TEXT,Editor TEXT")
        //初始化次列表
        // Material.UserData.insertTable(grooveStyleName[i]+"次列表","(?,?,?,?,?,?,?,?)",[grooveStyleName[i]+"焊接规范",grooveStyleName[i]+"限制条件",grooveStyleName[i]+"过程分析",grooveStyleName[i]+"焊接曲线",time,"TKSW",time,"TKSW"])
        //创建过程分析列表
        //  Material.UserData.createTable(grooveStyleName[i]+"过程分析","ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT")
        //     }
        //删除用户管理列表
        //   Material.UserData.deleteTable("accountTable");
        //创建用户管理列表
        //  Material.UserData.createTable("accountTable","ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT")
        //获取最近的坡口条件 包含名称
        res=Material.UserData.getLastGrooveName(grooveStyleName[currentGroove]+"列表","EditTime")
        if(res!==-1){currentGrooveName=res}
    }
}
