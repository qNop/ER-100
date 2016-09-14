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
    property var analyse: ["WeldAnalyse","WeldLine"]
    property var analyseName:["焊接参数","焊接曲线"]
    property var analyseIcon: ["awesome/line_chart","awesome/line_chart"]
    property var infor: ["SysErrorHistroy","HandleInfor","RoboInfor","ControlInfor","HighVolagteInfor","WeldPowerInfor"]
    property var inforName:["系统错误历史信息","手持盒信息","机器人信息","控制器信息","高压检测信息","焊接电源信息"]
    property var inforIcon: ["awesome/list_alt","awesome/windows","awesome/windows","awesome/windows","awesome/windows","awesome/windows"]
    property var sections: [preset,analyse, infor]
    property var sectionsName:[presetName,analyseName,inforName]
    property var sectionsIcon:[presetIcon,analyseIcon,inforIcon]
    property var sectionTitles: ["预置条件", "焊接分析", "系统信息"]
    property var tabiconname: ["action/settings_input_composite","awesome/line_chart","awesome/windows"]
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
    ListModel{id:accountmodel;ListElement{name:"user";type:"user";password:"user"}}

    ListModel{id:initialListModel; ListElement{ID:0;C1:"无";C2:"0:00"}}
    /*更新时间定时器*/
    Timer{
        interval:1000;running:true;repeat: true;
        onTriggered:{
            dateTime.name= new Date().toLocaleString(Qt.locale(app.local),"MMMdd ddd h:mm")
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
    Timer{ repeat: true;interval:sysStatus==="焊接态"?500:400;
        running:readTime
        onTriggered: {
            if(sysStatus=="坡口检测态")
                ERModbus.setmodbusFrame(["R","150","6"])
            else if(sysStatus=="焊接端部暂停态")
                ERModbus.setmodbusFrame(["R","200","1"]);
            else if(sysStatus=="焊接态")
                ERModbus.setmodbusFrame(["R","10","4"])
            else if(sysStatus=="未登录态"){}
            else
                ERModbus.setmodbusFrame(["R","0","3"]);
        }
    }
    //坡口参数 初始表格
    ListModel{id:grooveTableInit;ListElement{ID:"";C1:"";C2:"";C3:"";C4:"";C5:"";C6:"";C7:"";C8:""}}
    //焊接规范表格
    ListModel{id:weldTable;ListElement{ID:"";C1:"";C2:"";C3:"";C4:"";C5:"";C6:"";C7:"";C8:"";C9:"";C10:"";C11:"";C12:"";C13:"";C14:"";C15:"";C16:""}}
    //错误历史信息 ID：条数 C1 错误代码 C2 错误状态 C3 错误信息 C4: 操作用户 C5 错误发生/解除时刻
    ListModel{id:errorHistroy}
    onCurrentGrooveChanged: {
        console.log(objectName+" currentGroove "+currentGroove)
        ERModbus.setmodbusFrame(["W","90","1",currentGroove.toString()])
        var result=Material.UserData.getLastGrooveName(grooveStyleName[currentGroove]+"列表","EditTime")
        if(result){currentGrooveName=result}
        AppConfig.setcurrentGroove(currentGroove);
    }
    onCurrentGrooveNameChanged:{
        console.log(objectName+" currentGrooveName "+currentGrooveName)
    }
    /*初始化Tabpage*/
    initialPage: Material.TabbedPage {
        id: page
        /*标题*/
        title:qsTr("全位置MAG焊接机器人系统")
        /*最大action显示数量*/
        actionBar.maxActionCount: 4
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
            Material.Action{name: qsTr("时间"); id:dateTime;
                //  onTriggered:datePickerDialog.show();
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
        Keys.onReleased: {
            if(event.key===Qt.Key_F7){
                console.log(" Qt.Key_Close.Released!")
                event.accept=true;
            }
        }
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
            //加载model进入listview
            onOpened: {
                listModel.clear();
                titleImage=app.tabiconname[page.selectedTab]
                titleLabel=app.sectionTitles[page.selectedTab]
                console.log(navigationDrawer.objectName+"sectionsName[page.selectedTab].length"+sectionsName[page.selectedTab].length)
                for(var i=0;i<sectionsName[page.selectedTab].length;i++){
                    listModel.append({"name":sectionsName[page.selectedTab][i],"icon":sectionsIcon[page.selectedTab][i]})
                }
                model=listModel;
                oldIndex=page.selectedTab===0 ? page0SelectedIndex :page.selectedTab===1?page1SelectedIndex :page2SelectedIndex;
                selectedIndex=oldIndex;
            }
            onSelectedIndexChanged: {switch(page.selectedTab){
                case 0:page0SelectedIndex=selectedIndex;break;
                case 1:page1SelectedIndex=selectedIndex;break;
                case 2:page2SelectedIndex=selectedIndex;break;
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
        property string connectWeldRule;
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
                        console.log(objectName+" currentGroove "+currentGroove);
                        switch(grooveConditionPage.currentGroove&0x0000000F){
                        case 0: grooveNum=0;  break;
                        case 4: grooveNum=1;  break;
                        case 8: grooveNum=2;  break;

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
                        currentGroove=AppConfig.currentGroove
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
                    grooveModel: grooveTableInit
                    selectedIndex: grooveSelectIndex
                    currentGrooveName:app.currentGrooveName
                    grooveName: app.grooveStyleName[currentGroove]
                    //改变坡口名称
                    onChangedCurrentGroove: {
                        //更新坡口名称
                        app.currentGrooveName=name;
                        //清空坡口数据
                        grooveTableInit.clear();
                        //获取坡口数据
                        var listmodel=Material.UserData.getTableJson(name)
                        //插入数据到grooveTableInit
                        if(typeof(listmodel)==="object"){
                            for(var i=0;i<listmodel.length;i++){
                                grooveTableInit.append(listmodel[i])
                            }
                        }
                    }
                }
                LimitedCondition{
                    id:limitedConditionPage
                    visible: page0SelectedIndex===4
                    currentGrooveName:app.currentGrooveName
                    //visible时加载数据

                }
            }
        }
        Material.Tab{
            id:weldAnalyseTab
            title: qsTr("焊接分析(III)")
            iconName:"awesome/line_chart"
            property int currentFloorNum;
            property int  currentWeldNum;
            Item{
                anchors.fill: parent
                WeldAnalyse{
                    id:weldAnalysePage
                    visible: page1SelectedIndex===0;
                    status: app.sysStatus
                    weldTableCurrentRow: app.weldTableIndex
                    weldDataModel: weldTable
                    message:snackBar
                    weldRulesName: page.connectWeldRule
                    currentGroove: app.currentGroove
                    onWeldNumChanged: weldAnalyseTab.currentWeldNum=weldNum
                    onFloorNumChanged: weldAnalyseTab.currentFloorNum=floorNum
                    weldLength: app.weldLength
                    weldTime: app.weldTime
                }
                WeldLine{
                    id:wledLinePage
                    visible: page1SelectedIndex===1;
                    status: app.sysStatus
                    lineActive: app.dataActive
                    lineModel: app.lineData
                    lineTime: app.startLine
                    weldNum: weldAnalyseTab.currentWeldNum
                    floorNum: weldAnalyseTab.currentFloorNum
                }
            }
            // enabled: sysStatus=="空闲态"||sysStatus=="焊接态"||sysStatus=="焊接中间暂停态"||sysStatus=="焊接端部暂停态"||sysStatus=="停止态"
        }
        Material.Tab{
            id:systemInforTab
            title: qsTr("系统信息(IV)")
            iconName:"action/dashboard"
            Item{
                anchors.fill: parent
                SysErrorHistroy{
                    model:errorHistroy
                    visible: page2SelectedIndex===0
                    onRemoveall:{
                        errorHistroy.clear();
                        //清楚数据表格
                        Material.UserData.clearTable("SysErrorHistroy","","");
                        snackBar.open("错误历史记录已被清空！");
                    }
                    onRemove:{
                        if(seletedIndex!==-1){
                            errorHistroy.remove(seletedIndex);
                            Material.UserData.clearTable("SysErrorHistroy","ID",(seletedIndex+1).toString());
                            snackBar.open("本条错误已移除！");
                        }else
                            snackBar.open("请选择要移除的信息条目！");
                    }
                }
                HandleInfor{visible: page2SelectedIndex===1}
                RoboInfor{visible: page2SelectedIndex===2}
                ControlInfor{visible: page2SelectedIndex===3}
                HighVolagteInfor{visible: page2SelectedIndex===4}
                WeldPowerInfor{visible: page2SelectedIndex===5}
            }
            enabled: sysStatus=="空闲态"
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
            //清除 坡口参数选择
            grooveSelectIndex=1;
        }else if(sysStatus=="坡口检测态"){
            //高压接触传感
            snackBar.open("坡口检测中，高压输出，请注意安全！")
            //切换指示灯
            AppConfig.setleds("start");
            //清除坡口参数表格
            grooveTableInit.set(0,{"ID":"","C1":"","C2":"","C3":"","C4":"","C5":"","C6":""});
            //如果坡口数大于1则有必要清除掉其他行
            if(grooveTableInit.count>1)
                grooveTableInit.remove(1,grooveTableInit.count-1);
            //切换界面
            page.selectedTab=0;
            //切小页面
            app.page0SelectedIndex=3;
        }else if(sysStatus=="坡口检测完成态"){
            //检测完成
            snackBar.open("坡口检测完成！正在计算相关焊接规范。")
            //切换指示灯为准备好
            AppConfig.setleds("ready");
            // page.selectedTab=1;
            // app.page1SelectedIndex=0;
            app.weldTableIndex=-1;
            ERModbus.setmodbusFrame(["R","104","1"])
        }else if(sysStatus=="焊接态"){

            //启动焊接
            AppConfig.setleds("start");
            //提示
            snackBar.open(weldFix?"焊接系统修补焊接中。":"焊接系统焊接中。")
            //切换到 焊接曲线页面下
            app.page1SelectedIndex=1;
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
            var currentID;
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
                else if((frame[1]==="150")&&(sysStatus==="坡口检测态")){
                    //间隔跳示教点允许删除示教点操作尚未加入
                    console.log(frame);
                    if(frame[2]!=="0"){
                        //遍寻 ID有没有相等
                        for(var i=0;i<grooveTableInit.count;i++){
                            //ID相等则退出
                            if(frame[2]===grooveTableInit.get(i).ID){
                                currentID="false"
                                break;
                            }else {
                                currentID="true"
                            }
                        }
                        //遍寻之后表格内没有该ID 则插入该ID
                        if(currentID==="true"){
                            if(grooveTableInit.get(0).ID===""){
                                grooveTableInit.append({
                                                           "ID":frame[2],
                                                           "C1":(Number(frame[3])/10).toString(),
                                                           "C2":(Number(frame[4])/10).toString(),
                                                           "C3":(Number(frame[5])/10).toString(),
                                                           "C4":(Number(frame[6])/10).toString(),
                                                           "C5":(Number(frame[7])/10).toString(),
                                                           "C6":(Number(frame[8])/10).toString(),
                                                           "C7":(Number(frame[9])/10).toString(),
                                                           "C8":(Number(frame[10])/10).toString()})
                            }
                        }
                    }
                    ERModbus.setmodbusFrame(["R","0","3"]);
                }
                else if((frame[1]==="104")&&(sysStatus=="坡口检测完成态")){
                    //读取焊接长度
                    console.log(frame)
                    weldLength=Number(frame[2]);
                    //如果坡口参数里面有数据 则进行计算数据
                    if(grooveTableInit.get(0).ID!==""){
                        if(AppConfig.currentGroove===7){
                            WeldMath.setGrooveRules([grooveTableInit.get(0).C1,
                                                     grooveTableInit.get(0).C2,
                                                     grooveTableInit.get(0).C3,
                                                     grooveTableInit.get(0).C4,
                                                     grooveTableInit.get(0).C5]);
                        }else if(AppConfig.currentGroove===4){
                            //清除焊接规范表格
                            weldTable.set(0,{"ID":"","C1":"","C2":"","C3":"","C4":"","C5":"","C6":"","C7":"","C8":"","C9":"","C10":"","C11":"","C12":"","C13":"","C14":"","C15":"","C16":"",});
                            weldTable.remove(1,weldTable.count-1);
                        }
                    }
                }
                else  if((frame[1]==="200")&&(sysStatus==="焊接端部暂停态")){
                    console.log(frame)
                    if((frame[2]!==app.weldTableIndex.toString())&&(!weldFix)){
                        if(frame[2]!=="99"){
                            //当前焊道号与实际焊道号不符 更换当前焊道
                            weldTableIndex=Number(frame[2]);
                            weldFix=false;
                        }else{
                            weldFix=true;
                        }
                        //选择行数据有效
                        if((weldTableIndex<weldTable.count)&&(weldTableIndex>-1)){
                            //分离层/道
                            var floor=weldTable.get(weldTableIndex).C1.split("/");
                            ERModbus.setmodbusFrame(["W","201","17",
                                                     (Number(floor[0])*100+Number(floor[1])).toString(),
                                                     weldTable.get(weldTableIndex).C2,
                                                     weldTable.get(weldTableIndex).C3*10,
                                                     weldTable.get(weldTableIndex).C4*10,
                                                     weldTable.get(weldTableIndex).C5,
                                                     weldTable.get(weldTableIndex).C6*10,
                                                     weldTable.get(weldTableIndex).C7*10,
                                                     weldTable.get(weldTableIndex).C8*10,
                                                     weldTable.get(weldTableIndex).C9*10,
                                                     weldTable.get(weldTableIndex).C10*10,
                                                     weldTable.get(weldTableIndex).C11==="连续"?"0":"1",
                                                                                               weldTable.get(weldTableIndex).C12*10,//层面积
                                                                                               weldTable.get(weldTableIndex).C13*10,//单道面积
                                                                                               weldTable.get(weldTableIndex).C14*10,//起弧位置偏移
                                                                                               weldTable.get(weldTableIndex).C15*10,//起弧
                                                                                               weldTable.get(weldTableIndex).C16*10,//起弧
                                                                                               weldTable.count//总共焊道号
                                                    ]);
                        }else{
                            //发送全0数据
                            ERModbus.setmodbusFrame((["W","201","17","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0"]));
                        }
                        return;
                    }else if((weldFix)&&(frame[2]!=="99")){
                        weldFix=false;
                    }
                    ERModbus.setmodbusFrame(["R","0","3"]);
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
    //链接 weldmath
    Connections{
        target: WeldMath
        onWeldRulesChanged:{
            console.log(value);
            //确保数组数值正确
            if((typeof(value)==="array")&&(value.length=16))
                weldTable.append({
                                     "ID":value[0],
                                     "C1":value[1],
                                     "C2":value[2],
                                     "C3":value[3],
                                     "C4":value[4],
                                     "C5":value[5],
                                     "C6":value[6],
                                     "C7":value[7],
                                     "C8":value[8],
                                     "C9":value[9],
                                     "C10":value[10],
                                     "C11":value[11],
                                     "C12":value[12],
                                     "C13":value[13],
                                     "C14":value[14],
                                     "C15":value[15],
                                     "C16":value[16],
                                 })

            app.weldLength=480;
            var res =(app.weldLength*360)/(Number(value[5])*Number(value[6])*(Number(value[9])+Number(value[10])));
            weldTime.push(res);
            console.log(weldTime.length)
        }
        onGrooveRulesChanged:{
            console.log(value);
            if(value[0]==="Clear"){
                weldTime.length=0;
                if(weldTable.get(0).ID!==""){
                    //清除焊接规范表格
                    weldTable.set(0,{"ID":"","C1":"","C2":"","C3":"","C4":"","C5":"","C6":"","C7":"","C8":"","C9":"","C10":"","C11":"","C12":"","C13":"","C14":"","C15":"","C16":"",});
                    weldTable.remove(1,weldTable.count-1);
                }
            }
            else if(value[0]==="Finish"){
                // 切换状态为端部暂停
                if(sysStatus==="坡口检测完成态"){
                    //下发端部暂停态
                    //  ERModbus.setmodbusFrame(["W","0","1","5"]);
                }
                var res=0;
                for(var i=0;i<weldTime.length;i++){
                    res+=weldTime[i];
                }
                weldTime.push(res)
                console.log(weldTime)
            }
        }
    }
    Material.ActionButton{
        id:robot
        visible: (!page.actionBar.overflowMenuShowing)&&(!myErrorDialog.showing)&&(!moto.showing)&&(!navigationDrawer.showing)&&(!changeuser.showing)
        Behavior on visible {NumberAnimation{duration: 200}}
        action:Material.Action{
            iconName:"action/android";name: qsTr("机器人操作")
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
        action:Material.Action {iconName: "alert/warning";
            name: qsTr("警告");
            onTriggered: myErrorDialog.show();}
        anchors.right: robot.visible? robot.left:snackBar.left
        anchors.rightMargin: Material.Units.dp(16)
        anchors.verticalCenter: snackBar.verticalCenter
        isMiniSize: true
    }
    Material.Snackbar{
        id:snackBar
        anchors {
            left:parent.left;
            leftMargin: opened ? page.width - width : page.width
            right:undefined
            bottom:undefined
            bottomMargin: undefined
            top:parent.top
            topMargin:app.height-page.height-snackBar.height/2-5
            horizontalCenter:undefined
            Behavior on leftMargin {
                NumberAnimation { duration: 300 }
            }
        }
        fullWidth:false
        duration:4000;
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
                    initialListModel.append({"ID":Number(i+1),"C1":errorName[i],"C2":errorTime })
                    errorHistroy.append({"ID":errorHistroy.count+1,"C1":Number(i+1),"C2":"发生","C4":errorName[i],"C3":AppConfig.currentUserName,"C5": errorTime})
                }else{
                    for(var j=0;j<initialListModel.count;j++){
                        //如果列表里面有则移除 解除错误
                        if((i+1)===(initialListModel.get(j).ID)){
                            initialListModel.remove(j,1);
                            errorHistroy.append({"ID":errorHistroy.count+1,"C1":Number(i+1),"C2":"解除","C4":errorName[i],"C3":AppConfig.currentUserName,"C5": errorTime})
                            if(errorTable.__listView.currentIndex>=initialListModel.count){
                                errorTable.__listView.currentIndex=j-1;
                                errorTable.selection.__selectOne(j-1);}
                        }
                    }
                }
                //想数据库中插入
                var count=errorHistroy.count-1;
                Material.UserData.insertTable("SysErrorHistroy","(?,?,?,?,?,?)",[String(errorHistroy.get(count).ID),errorHistroy.get(count).C1,errorHistroy.get(count).C2,errorHistroy.get(count).C3,errorHistroy.get(count).C4,errorHistroy.get(count).C5])
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
            errorTable.selection.__selectOne(0);
        }
        oldErrorCode=errorCode;
    }
    Material.Dialog{
        id:myErrorDialog
        overlayLayer: "overlayLayer"
        overlayColor: Qt.rgba(0, 0, 0, 0.3)
        title: "系统错误"
        property alias errorModel:errorTable.model
        positiveButtonText: qsTr("查看错误历史信息");
        onAccepted: {
            page.selectedTab=2;
            page2SelectedIndex=0;
        }
        negativeButton.visible: false
        onOpened: {
            errorTable.__listView.currentIndex=0;
            errorTable.selection.__selectOne(0);
        }
        globalMouseAreaEnabled:true;
        dismissOnTap:false
        //按键优先队列
        Keys.forwardTo: [errorTable]
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
        title: "机器人本体设定"
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
                console.log(current);
                current =current+new Date().toLocaleTimeString(Qt.locale(app.local),"h/m/s");
                datePickerDialog.dateTimeDialog=current.split("/");
                console.log(datePickerDialog.dateTimeDialog);
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
        dismissOnTap:false
        overlayColor: Qt.rgba(0, 0, 0, 0.3)
        Keys.onPressed: {
            if (event.key === Qt.Key_Escape) {
                closeKeyPressed(event);
                rejected();
            }
            if (event.key === Qt.Key_Enter){
                closeKeyPressed(event);
                accepted();
            }
        }
        function closeKeyPressed(event) {
            if (changeuser.showing) {
                //          if ((changeuser.dismissOnTap)&&(changeuser.positiveButtonEnabled)) {
                changeuser.close()
                //       }
                event.accepted = true
            }
        }
        onAccepted: {
            if(changeuser.positiveButtonEnabled){
                AppConfig.currentUserName = changeuserFeildtext.selectedText;
                AppConfig.currentUserType = changeuserFeildtext.helperText;
                app.sysStatus="空闲态";
            }
        }
        onRejected: {
            changeuserFeildtext.helperText = AppConfig.currentUserType;
            app.sysStatus="空闲态";
        }
        dialogContent: [
            Material.Label{
                text:qsTr("用户名:");
                style:"subheading"
                color: Material.Theme.light.shade(0.54)
            },
            Material.MenuField{id:changeuserFeildtext;
                textRole: "name"
                model:accountmodel
                width:parent.width
                onItemSelected:  {
                    password.enabled=true;
                    var data=accountmodel.get(index);
                    AppConfig.currentUserPassword = data.password;
                    AppConfig.currentUserType=changeuserFeildtext.helperText = data.type;
                    password.text="";}},
            Material.Label{
                text:qsTr("密码:");
                style:"subheading"
                color: Material.Theme.light.shade(0.54)
            },
            Material.TextField{id:password;
                //floatingLabel:true;
                placeholderText:qsTr("请输入密码...");
                characterLimit: 8;
                objectName: "TextField"
                width:parent.width
                color: Material.Theme.light.shade(0.54)
                onTextChanged:{
                    if(password.text=== AppConfig.currentUserPassword){
                        changeuser.positiveButtonEnabled=true;
                        password.helperText.color="green";
                        password.helperText=qsTr("密码正确");}
                    else{changeuser.positiveButtonEnabled=false;}}
                onHasErrorChanged: {
                    if(password.hasError === true){
                        password.helperText =qsTr( "密码超过最大限制");}}
            },
            Item{
                width:parent.width
                height:Material.Units.dp(16)
            }
        ]
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
        Material.UserData.openDatabase();
        var result=Material.UserData.getResultFromFuncOfTable("AccountTable","","");
        var name,type,password;
        for(var i=0;i<result.rows.length;i++){
            name = result.rows.item(i).name;
            type=result.rows.item(i).type;
            password=result.rows.item(i).password;
            accountmodel.append({"name":name,"type":type,"password":password})
            if(name === accountname.text){
                changeuserFeildtext.selectedIndex = i+1;
                changeuserFeildtext.helperText=type;
                AppConfig.currentUserPassword =password;
            }
        }
        accountmodel.remove(0);
        changeuser.show();
        teachModel.length=0;
        teachModel=Material.UserData.getValueFromFuncOfTable("TeachCondition","","");
        weldConditionModel.length=0;
        weldConditionModel=Material.UserData.getValueFromFuncOfTable("WeldCondition","","");

        //创建错误历史记录
        Material.UserData.createTable("SysErrorHistroy","ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT");
        result=Material.UserData.getResultFromFuncOfTable("SysErrorHistroy","","");
        if(result){
            for(i=0;i<result.rows.length;i++){
                errorHistroy.append({"ID":Number(result.rows.item(i).ID),"C1":Number(result.rows.item(i).C1),"C2":result.rows.item(i).C2,"C3":result.rows.item(i).C3,"C4":result.rows.item(i).C4,"C5":result.rows.item(i).C5})
            }
        }

        //创建9个表格
        // for(i=0;i<9;i++){
        //if(i)
        //删除列表
        //Material.UserData.deleteTable(grooveStyleName[i]+"坡口条件")
        //创建列表
        //Material.UserData.createTable(grooveStyleName[i]+"列表","Teach TEXT,Weld TEXT,Groove TEXT,Limited TEXT,Rules TEXT,CheckError TEXT,WeldLine TEXT,CreatTime TEXT,Creator TEXT,EditTime TEXT,Editor TEXT")
        //清除数据
        //Material.UserData.clearTable(grooveStyleName[i]+"列表","","")
        //初始化列表
        //Material.UserData.insertTable(grooveStyleName[i]+"列表","(?,?,?,?,?,?,?,?,?,?,?)",[grooveStyleName[i]+"示教条件",grooveStyleName[i]+"焊接条件",grooveStyleName[i],grooveStyleName[i]+"限制条件",grooveStyleName[i]+"焊接规范",grooveStyleName[i]+"错误检测",grooveStyleName[i]+"焊接曲线",new Date(),"TKSW",new Date(),"TKSW"])
        //创建坡口条件
        //Material.UserData.createTable(grooveStyleName[i],"ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT")
        // }
        //获取最近的坡口条件 包含名称
        result=Material.UserData.getLastGrooveName(grooveStyleName[currentGroove]+"列表","EditTime")
        if(result){currentGrooveName=result}
    }
}
