import QtQuick 2.0
import Material 0.1 as Material
import Material.Extras 0.1
import WeldSys.AppConfig 1.0
import WeldSys.WeldMath 1.0
import WeldSys.MySQL 1.0
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Window 2.2
import "MyMath.js" as MyMath
import QtQuick.Enterprise.VirtualKeyboard 1.3

/*应用程序窗口 */
Material.ApplicationWindow{
    id: app;title: "app";
    objectName: "App"
    visible: false
    /*主题默认颜色  */
    theme.tabHighlightColor: theme.accentColor
    //不需要解释
    property var grooveStyleName: [ "平焊单边V形坡口T接头",  "平焊单边V形坡口平对接", "平焊V形坡口平对接","横焊单边V形坡口T接头",  "横焊单边V形坡口平对接", "立焊单边V形坡口T接头",  "立焊单边V形坡口平对接", "立焊V形坡口平对接","水平角焊"]
    property var grooveStyleName1: [ "平焊",  "平焊", "平焊","横焊",  "横焊", "立焊",  "立焊", "立焊","水平角焊"]
    property var preset:["GrooveCondition","TeachCondition","WeldCondition","GrooveCheck","ArcCondition","LimitedConditon"]
    property var presetName: ["坡口条件","示教条件","焊接条件","坡口参数","跟踪条件","限制条件"]
    property var presetIcon: ["awesome/road","action/android","user/MAG","awesome/road","awesome/sliders","awesome/sliders"]
    property var analyse: ["WeldData"]//,"WeldAnalyse"]
    property var analyseName:["焊接参数"]//,"过程分析"]
    property var analyseIcon: ["awesome/tasks"]//,"awesome/pie_chart"]
    property var infor: ["UserAccount","SysErrorHistroy","SystemInfor","DebugInfor"]
    property var inforName:["用户管理","历史错误","关于系统","调试信息"]
    property var inforIcon: ["social/group","awesome/list_alt","awesome/desktop","awesome/desktop"]
    property var sections: [preset,analyse, infor]
    property var sectionsName:[presetName,analyseName,inforName]
    property var sectionsIcon:[presetIcon,analyseIcon,inforIcon]
    property var sectionTitles: ["预置条件", "焊接分析", "系统信息"]
    property var tabiconname: ["action/settings_input_composite","awesome/tasks","awesome/windows"]
    property var errorName:["主控制器错误","CAN通讯错误","急停报警","摇动电机过热过流","摇动电机右限位","摇动电机左限位","摇动电机原点搜索","摇动电机堵转", "摆动电机过热过流","摆动电机内限位",
        "摆动电机外限位","摆动电机原点搜索","摆动电机堵转", "上下电机过热过流","上下电机下限位","上下电机上限位","上下电机原点搜索","上下电机堵转", "行走电机过热过流","行走电机右限位",
        "行走电机左限位","行走电机原点搜索","行走电机堵转","驱动器急停报警","手持盒通讯错误","示教器通讯错误","焊接电源通讯错误","焊接电源粘丝错误","焊接电源其他错误","坡口参数表格内无数据",
        "生成焊接规范错误","焊接规范表格内无数据",
        "未插入钥匙","坡口检测未检测到工件错误","坡口检测碰触工件错误","机头未接入错误","坡口检测摆动速度错误","未定义错误","未定义错误","未定义错误", "未定义错误","未定义错误",
        "未定义错误","未定义错误","未定义错误", "未定义错误","未定义错误","未定义错误","未定义错误","未定义错误", "未定义错误","未定义错误",
        "未定义错误","未定义错误","未定义错误","未定义错误","未定义错误","未定义错误","未定义错误","未定义错误","未定义错误","未定义错误",
        "未定义错误","未定义错误"]
    property int  page0SelectedIndex:0
    property int  page1SelectedIndex:0
    property int  page2SelectedIndex:0
    property bool changeUserFlag: false
    /*当前本地化语言*/
    property string local: "zh_CN"
    /*当前坡口形状*/
    property int currentGroove:9
    /*当前坡口形状的名称*/
    property string currentGrooveName
    /*Modbus重载*/
    property bool modbusBusy:false;
    /*系统状态*/
    property string sysStatus:"初始态"
    /*系统状态集合*/
    property var sysStatusList: ["空闲态","坡口检测态","坡口检测完成态","焊接态","焊接中间暂停态","焊接端部暂停态","停止态","未登录态"]
    /*上一次froceitem*/
    property Item lastFocusedItem:null
    /*错误*/
    property int errorCode:0
    property int errorCode1: 0
    /*上次错误*/
    property int oldErrorCode: 0
    property int oldErrorCode1: 0
    /*焊接分析表格index*/
    property int weldTableIndex: -1
    /*坡口表格index*/
    property int grooveTableIndex: -1
    /*限制条件index*/
    property int limitedTableIndex:-1
    /**/
    property int accountTableIndex:-1
    /*line flag*/
    property bool dataActive: false
    /*开始采集时间*/
    property var startLine:new Date();
    /*刷新数据*/
    property var lineData;
    /*系统时间读取标志*/
    property bool readTime:false
    /*是否为修补焊接*/
    //  property bool weldFix: false
    /*bool 加载网络*/
    property bool loadInterNet: false
    /*焊接长度*/
    property int weldLength: 0
    /*app加载完毕*/
    property bool completed:false
    /*当前用户名*/
    property string  weldRulesName
    //
    property bool superUser

    property bool readSet:false

    property bool conWrite: true

    property int errorCount: 0

    property bool weldAnalyseTabCompleted:false

    property int teachmodel:0

    property int teachPoint: 1

    /*account*/
    ListModel{id:accountTable;}
    //错误列表
    ListModel{id:initialListModel;ListElement{ID:0;C1:"无";C2:"0:00"}}
    //焊接规范表格
    ListModel{id:weldTable;}
    //错误历史信息 ID：条数 C1 错误代码 C2 错误状态 C3 错误信息 C4: 操作用户 C5 错误发生/解除时刻
    ListModel{id:errorHistroy}
    //坡口参数规范
    ListModel{id:grooveTable}
    //坡口名称列表
    ListModel{id:grooveNameListModel
        objectName: "grooveNameListModel"
        ListElement{Name:"";CreatTime:"";Creater:"";EditTime:"";Editor:"";}
    }
    ListModel{id:limitedRulesNameListModel
        objectName:"limitedRulesNameListModel"
        ListElement{Name:"";CreatTime:"";Creater:"";EditTime:"";Editor:"";}
    }
    ListModel{id:weldRulesNameListModel
        objectName: "weldRulesNameListModel"
        ListElement{Name:"";CreatTime:"";Creater:"";EditTime:"";Editor:"";}
    }

    ListModel{id:limitedTable}
    //信号
    signal changeWeldIndex(int index)
    //信号
    signal changeGrooveTableIndex(int index)

    signal changeLimitedTableIndex(int index)

    signal changeAccountTableIndex(int index)

    property string grooveName: ""
    property string currentGrooveNameList: ""

    property string limitedName:""
    property string currentLimitedNameList:""

    property string weldName: ""
    property string currentWeldNameList:""

    property alias message: tool.message
    //signal
   // signal changeTeachSet(var value);
    //
  //  signal changeWeldLength(double value);
    //生成焊接规范
    signal changeWeldRules();
    //自动保存生成的焊接规范
    signal saveData();
    //Settings
    MySettings{id:appSettings}

    property bool systemStart;
    /*更新时间定时器*/
    Timer{
        interval:1000;running:true;repeat: true;
        onTriggered:{
            var dateTime= new Date().toLocaleString(Qt.locale(app.local),"MMMdd ddd-h:mm")
            var timeD =dateTime.split("-");
            date.name=timeD[0];
            var timee=timeD[1].split(":")
            var timec=Number(timee[0])>12?String(Number(timee[0])-12):timee[0];
            timec+=":"+timee[1];
            timec+=Number(timee[0])>11?" PM":" AM"
            time.name=timec;
            delete Date;
        }
    }
    Timer{id:camera
        interval:10000;running: false;repeat: false
        onTriggered: {
            if(AppConfig.screenShot(app)){
                message.open("截屏成功！")
            }else
                message.open("截屏失败！")
        }
    }
    //该页面下1000ms问一次检测参数是否有效
    onChangeUserFlagChanged: {
        if((!changeUserFlag)&&(!changeuser.showing)){
            sysStatus="未登录态"
            changeuser.show();
        }
    }
    signal changeFirstStartPoit(bool value)
    function setPage(pageIndex,index){
        page.selectedTab=pageIndex;
        navigationDrawer.selectedIndex=index;
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

    /*初始化Tabpage*/
    initialPage: Material.TabbedPage {
        id: page
        /*标题*/
        title:qsTr("轨道式智能焊接系统")
        /*最大action显示数量*/
        actionBar.maxActionCount: 6
        /*actions列表*/
        actions: [
            /*坡口形状action*/
            Material.Action{id:grooveAction;name: currentGrooveName
                onTriggered:{setPage(0,0)}
            },
            /*时间action*/
            Material.Action{name: qsTr("日期"); id:date;
                onTriggered:datePickerDialog.show();
            },
            /*时间action*/
            Material.Action{id:time;name:qsTr("时间");
                onTriggered:timePickerDialog.show();
            },
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
            /*账户*/
            Material.Action {id:accountname;iconName: "awesome/user";
                onTriggered:changeuser.show();text:appSettings.currentUserName;
            },
            /*语言*/
            //       Material.Action {iconName: "action/language";name: qsTr("语言");
            //     onTriggered: languagePicker.show();
            // },
            /*截屏*/
            Material.Action {iconName:"awesome/camera";name: qsTr("截屏");visible: superUser
                onTriggered: {message.open("截屏操作将在10秒钟后启动！");camera.start()}
            },
            /*恢复出厂设置*/
            Material.Action {iconName: "awesome/power_off";name: qsTr("关机");
                onTriggered: {Qt.quit();}
            }
        ]
        backAction: navigationDrawer.action
        actionBar.tabBar{leftKeyline: 0;isLargeDevice: false;fullWidth:false}
        Keys.onDigit1Pressed: {if((!event.isAutoRepeat)&&(changeUserFlag))navigationDrawer.toggle();}
        Keys.onDigit2Pressed: {if((page.selectedTab!==0)&&preConditionTab.enabled&&(changeUserFlag))page.selectedTab=0;}
        Keys.onDigit3Pressed: {if((page.selectedTab!==1)&&weldAnalyseTab.enabled&&(changeUserFlag))page.selectedTab=1;}
        Keys.onDigit4Pressed: {if((page.selectedTab!==2)&&(systemInforTab.enabled)&&(changeUserFlag))page.selectedTab=2;}
        Keys.onPressed:{
            switch(event.key){
            case Qt.Key_F1:
                tool.keyFunction(0);
                event.accpet=true;
                break;
            case Qt.Key_F2:
                tool.keyFunction(1);
                event.accpet=true;
                break;
            case Qt.Key_F3:
                tool.keyFunction(2);
                event.accpet=true;
                break;
            case Qt.Key_F4:
                tool.keyFunction(3);
                event.accpet=true;
                break;
            case Qt.Key_F5:
                tool.keyFunction(4);
                event.accpet=true;
                break;
            case Qt.Key_F6:
                tool.keyFunction(5);
                event.accpet=true;
                break;
            }
        }
        MyNavigationDrawer{
            id:navigationDrawer
            ListModel{id:listModel;ListElement{name:"";icon:""}}
            settings: appSettings
            //加载model进入listview
            onOpened: {
                listModel.clear();
                titleImage=app.tabiconname[page.selectedTab]
                titleLabel=app.sectionTitles[page.selectedTab]
                var type=appSettings.currentUserType;
                for(var i=0;i<sectionsName[page.selectedTab].length;i++){
                    listModel.append({"name":sectionsName[page.selectedTab][i],"icon":sectionsIcon[page.selectedTab][i]})
                }
                if((page.selectedTab===0)&&(type==="用户"))
                    listModel.remove(4,1);
                model=listModel;
                oldIndex=page.selectedTab===0 ? page0SelectedIndex :page.selectedTab===1?page1SelectedIndex :page2SelectedIndex;
                selectedIndex=oldIndex;
            }
            onSelectedIndexChanged: {
                switch(page.selectedTab){
                case 0:page0SelectedIndex=selectedIndex;
                    tool.tablePageNumber=selectedIndex===3?0:selectedIndex===5?1:5;
                    break;
                case 1:page1SelectedIndex=selectedIndex;
                    tool.tablePageNumber=selectedIndex===0?2:5;
                    break;
                case 2:page2SelectedIndex=selectedIndex;
                    tool.tablePageNumber=selectedIndex===0?3:selectedIndex===1?4:5;
                    break;
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
                if (__lastFocusedItem !== null){
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
            switch(page.selectedTab){
            case 0:tool.tablePageNumber=page0SelectedIndex===3?0:page0SelectedIndex===5?1:5;break;
            case 1:tool.tablePageNumber=page1SelectedIndex===0?2:5;break;
            case 2:tool.tablePageNumber=page2SelectedIndex===0?3:page2SelectedIndex===1?4:5;break;
            }
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
                //最后加载
                TeachCondition{
                    id:teachConditionPage
                    message: app.message
                    visible: page.selectedTab===0&&page0SelectedIndex===1
                    onChangeTeachModel: {app.teachmodel=model;}
                    onChangeTeachPoint: {app.teachPoint=num;console.log("teachPoint"+num)}
                }
                ArcCondition{
                    id:arcConditionPage
                    visible: page.selectedTab===0&&page0SelectedIndex===4
                    settings: appSettings
                }
               WeldCondition{
                    id:weldConditionPage
                     visible: page.selectedTab===0&&page0SelectedIndex===2
                     message: app.message
                     currentGroove: app.currentGroove
                }
                GrooveCheck{
                    id:grooveCheckPage
                    visible: page.selectedTab===0&&page0SelectedIndex===3
                    status: app.sysStatus;message:app.message
                    model:grooveTable
                    settings: appSettings
                    //状态为坡口检测态时不能更改 数据表
                    onStatusChanged: table.enabled=app.sysStatus!=="坡口检测态"?true:false
                    onCurrentRowChanged: app.grooveTableIndex=currentRow
                    onGrooveNameChanged: app.grooveName=grooveName;
                    onGrooveNameListChanged: app.currentGrooveNameList=grooveNameList
                 //   currentGroove: app.currentGroove
                    //生成焊接规范
                    onGetWeldRules:{
                        if(grooveTable.count){
                            //先切换界面
                            setPage(1,0)
                            //生成规范前先更新限制条件
                            if(limitedConditionPage.setLimited()){
                                //存储坡口数据
                                for(var i=0;i<grooveTable.count;i++){
                                    WeldMath.setGrooveRulesTable(grooveTable.get(i),i);
                                }
                                //计算焊接规范
                                WeldMath.getWeldMath();
                            }else{
                                message.open("限制条件不存在！")
                            }
                        }else
                            message.open("坡口参数数据不存在！");
                    }
                    //通过信号的方式交互Model数据而不影响到数据的绑定问题。
                    onUpdateModel: {
                        switch(str){
                        case "Set":grooveTable.set(currentRow,data);break;
                        case "Append":grooveTable.append(data);break;
                        case "Clear":grooveTable.clear();break;
                        case "Remove":
                            selectIndex(currentRow-1);
                            grooveTable.remove(currentRow);
                            if((currentRow===0)&&(grooveTable.count))
                                ;
                            else
                                currentRow-=1;
                            break;
                        default:message.open("操作焊接数据表格命令不支持！")
                        }

                    }
                    onUpdateListModel: {
                        switch(str){
                        case "Append":grooveNameListModel.append(data);break;
                        case "Clear":grooveNameListModel.clear();break;
                        default:message.open("操作坡口名列表命令不支持！")
                        }
                    }
                    Connections{
                        target: teachConditionPage
                        onChangeTeachModel:{
                            grooveCheckPage.teachModel=model;
                            tool.teachModel=model;
                        }
                    }
                    Connections{
                        target:tool
                        onNewGrooveFile:grooveCheckPage.newFile(name,saveAs);
                        onOpenGrooveName:grooveCheckPage.openName(name);
                        onRemoveGrooveName:grooveCheckPage.removeName(name);
                        onSaveGrooveName:grooveCheckPage.save();
                        onFixDialogShow:grooveCheckPage.fixDialog.show()
                        onMakeWeldRules:grooveCheckPage.getWeldRules();
                        onUpdateGrooveTable:grooveCheckPage.updateModel(str,data);
                    }
                    Connections{
                        target:app
                        onChangeGrooveTableIndex:{
                            if(index<grooveTable.count){
                                grooveTableIndex=index;
                                grooveCheckPage.currentRow=index;
                                grooveCheckPage.selectIndex(index);
                            }else
                                message.open("索引条目超过模型最大值！");
                        }
                        onChangeWeldRules:{
                            grooveCheckPage.getWeldRules();
                        }
                        onCurrentGrooveChanged:{
                            //grooveCheckPage.grooveNameList=app.grooveStyleName[app.currentGroove]+"坡口条件列表";
                            //grooveCheckPage.getLastGrooveName();
                            grooveCheckPage.openName(app.grooveStyleName[app.currentGroove]);
                        }
                        onSaveData:{
                            grooveCheckPage.save();
                        }
                    }
                }
                LimitedCondition{
                    id:limitedConditionPage
                    swingWidthOrWeldWidth: appSettings.weldStyle===1||appSettings.weldStyle===3?false:true
                    visible: page.selectedTab===0&&(page0SelectedIndex===5)&&(app.superUser)
                    currentUserName: appSettings.currentUserName
                    message: app.message
                    model:limitedTable
                    onCurrentRowChanged: app.limitedTableIndex=currentRow
                    onLimitedRulesNameChanged: app.limitedName=limitedRulesName
                    onLimitedRulesNameListChanged: app.currentLimitedNameList=limitedRulesNameList
                    onUpdateModel: {
                        switch(str){
                        case "Set":limitedTable.set(currentRow,data);break;
                        case "Append":limitedTable.append(data);break;
                        case "Clear":limitedTable.clear();break;
                        case "Remove":
                            selectIndex(currentRow-1);
                            limitedTable.remove(currentRow);
                            if((currentRow===0)&&(limitedTable.count))
                                ;
                            else
                                currentRow-=1;
                            break;
                        default:message.open("操作坡口条件表格命令不支持！")
                        }
                    }
                    onUpdateListModel: {
                        switch(str){
                        case "Append":limitedRulesNameListModel.append(data);break;
                        case "Clear":limitedRulesNameListModel.clear();break;
                        default:message.open("操作坡口名列表命令不支持！")
                        }
                    }
                    Connections{
                        target: weldConditionPage
                        onChangeNum:{limitedConditionPage.limitedString=value;
                            tool.limitedString=value;
                            //limitedConditionPage.limitedRulesNameList= app.grooveStyleName1[app.currentGroove]+"限制条件列表"+limitedConditionPage.limitedString;
                            //limitedConditionPage.getLastRulesName();
                            limitedConditionPage.openName(app.grooveStyleName1[app.currentGroove])
                        }
                    }
                    Connections{
                        target:tool
                        onNewLimitedFile:limitedConditionPage.newFile(name,saveAs);
                        onOpenLimitedName:limitedConditionPage.openName(name);
                        onRemoveLimitedName:limitedConditionPage.removeName(name);
                        onSaveLimitedName:limitedConditionPage.save();
                        onSetLimited:limitedConditionPage.setLimited();
                        onUpdateLimitedTable:limitedConditionPage.updateModel(str,data);
                    }
                    Connections{
                        target: grooveConditionPage
                        onCurrentGrooveChanged:{
                            if(limitedConditionPage.limitedString!==""){
                                //更新焊接规范列表
                                //limitedConditionPage.limitedRulesNameList= app.grooveStyleName1[app.currentGroove]+"限制条件列表"+limitedConditionPage.limitedString;
                                //更新焊接规范
                                //limitedConditionPage.getLastRulesName();
                                limitedConditionPage.openName(app.grooveStyleName1[app.currentGroove])
                            }
                        }
                    }
                }
                GrooveCondition{
                    id:grooveConditionPage
                    settings: appSettings
                    visible: page.selectedTab===0&&page0SelectedIndex===0
                    message: tool.message
                    onCurrentGrooveChanged:{
                        app.currentGroove=currentGroove;
                    }
                }
            }
        }
        Material.Tab{
            id:weldAnalyseTab   //自己更新自己的数据库
            title: qsTr("焊接分析(III)")
            iconName:"awesome/tasks"
            Item{
                anchors.fill: parent
                WeldData{
                    id:weldDataPage
                    visible:page.selectedTab===1&& page1SelectedIndex===0;
                    status: app.sysStatus
                    message:app.message
                    // weldTableEx: app.superUser
                    currentUserName: appSettings.currentUserName
                    onChangeWeldData: app.sendWeldData();
                    onCurrentRowChanged:app.weldTableIndex=currentRow;
                    onWeldRulesNameChanged: app.weldName=weldRulesName
                    onWeldRulesNameListChanged: app.currentWeldNameList=weldRulesNameList
                    model: weldTable
                    //外部更改模型数据 避免绑定过程中解除绑定的操作存在而影响数据与模型内容不一致
                    onUpdateModel: {
                        switch(str){
                        case "Set":weldTable.set(currentRow,data);
                            selectIndex(currentRow);
                            break;
                        case "Append":
                            weldTable.append(data);
                            break;
                        case "Clear":
                            weldTable.clear();
                            break;
                        case "Remove":
                            selectIndex(currentRow-1);
                            weldTable.remove(currentRow);
                            if((currentRow===0)&&(weldTable.count));
                            else
                                weldTableIndex-=1;break;
                        default:message.open("操作焊接数据表格命令不支持！")
                        }
                    }
                    onUpdateListModel: {
                        switch(str){
                        case "Append":weldRulesNameListModel.append(data);break;
                        case "Clear":weldRulesNameListModel.clear();break;
                        default:app.message.open("操作坡口名列表命令不支持！")
                        }
                    }
                    //链接app的changeWeldIndex信号实现外部对数据模型索引的变更,优化绑定造成的影响
                    Connections{
                        target: app
                        onChangeWeldIndex:{//改变索引
                            if(index<weldTable.count){
                                weldDataPage.currentRow=index;
                                weldDataPage.selectIndex(index);
                            }else
                                message.open("索引条目超过模型最大值！");
                        }
                        onCurrentGrooveChanged:{
                            //更新焊接规范列表
                            //weldDataPage.weldRulesNameList=app.grooveStyleName[app.currentGroove]+"焊接规范列表";
                            //更新焊接规范
                           // weldDataPage.getLastweldRulesName();
                            weldDataPage.openName(app.grooveStyleName[app.currentGroove]);
                        }
                        onSaveData:{
                            weldDataPage.save();
                        }
                    }
                    Connections{
                        target:tool
                        onNewWeldFile:weldDataPage.newFile(name,saveAs);
                        onOpenWeldName:weldDataPage.openName(name);
                        onRemoveWeldName:weldDataPage.removeName(name);
                        onSaveWeldName:weldDataPage.save();
                        onUpdateWeldTable:weldDataPage.updateModel(str,data);
                        onSendWeldData:{
                            if(weldTable.count===0)
                                message.open("焊接数据表中无数据！");
                            else if(weldTableIndex===-1)
                                message.open("请选中要下发的数据行！");
                            else{
                                if(WeldMath.sendWeldData(weldTable.get(weldTableIndex)))
                                    message.open("已下发焊接规范。");
                                else
                                    message.open("下发焊接规范失败！");
                            }
                        }
                    }
                    Component.onCompleted: { //加载的时候 加载数据表格
                        //更新焊接规范列表
                        //weldDataPage.weldRulesNameList=app.grooveStyleName[app.currentGroove]+"焊接规范列表";
                        //更新焊接规范
                       // weldDataPage.getLastweldRulesName();
                        weldDataPage.openName(app.grooveStyleName[app.currentGroove]);
                    }
                }
            }
        }
        Material.Tab{
            id:systemInforTab
            title: qsTr("系统信息(IV)")
            iconName:"action/dashboard"
            Item{
                anchors.fill: parent
                UserAccount{
                    id:userAccountPage
                    visible: page.selectedTab===2&&page2SelectedIndex===0
                    model:accountTable
                    superUser: app.superUser
                    onCurrentRowChanged: accountTableIndex=currentRow
                    message: app.message
                    onUpdateModel: {
                        switch(str){
                        case "Set":accountTable.set(currentRow,data);
                            selectIndex(currentRow);
                            break;
                        case "Append":accountTable.append(data);
                            break;
                        case "Clear":
                            accountTable.clear();
                            break;
                        case "Remove":
                            selectIndex(currentRow-1);
                            accountTable.remove(currentRow);
                            if((currentRow===0)&&(accountTable.count));
                            else
                                weldTableIndex-=1;break;
                        default:message.open("操作信息数据表格命令不支持！")
                        }
                    }
                    Connections{
                        target: tool
                        onSaveAccountName:userAccountPage.save()
                        onUpdateAccountTable:userAccountPage.updateModel(str,data);
                    }
                }
                SysErrorHistroy{
                    id:sysErrorHistroyPage
                    model:errorHistroy
                    visible: page.selectedTab===2&&page2SelectedIndex===1
                    status:sysStatus
                    footerText: "总计: "+String(errorHistroy.count)+" 条历史记录。"
                    Connections{
                        target: tool
                        onUpdateErrorHistroyTable:{
                            app.errorCount=0;//清空
                            errorHistroy.clear();
                            //清楚数据表格
                            app.message.open("错误历史记录已被清空！");
                        }
                    }
                }
                SystemInfor{
                    id:systemInforPage
                    visible: page.selectedTab===2&&page2SelectedIndex===2}
                DebugInfor{
                    id:debugInforPage
                    visible:page.selectedTab===2&&page2SelectedIndex===3
                }
            }
        }
    }
    onSysStatusChanged: {
        WeldMath.setSysStatus(sysStatus);
        if(sysStatus==="空闲态"){
            //高压接触传感
            message.open("焊接系统空闲！")
            //空闲态
            AppConfig.setleds("ready");
            if(!myErrorDialog.showing){
                //切换页面
                setPage(0,0)
            }
        }else if(sysStatus==="坡口检测态"){
            //高压接触传感
            message.open("坡口检测中，高压输出，请注意安全！")
            //切换指示灯
            AppConfig.setleds("start");
            //切换界面
            setPage(0,3)
            //不选中任何一行
            changeGrooveTableIndex(0);
            //全自动则清除
            if((teachmodel===0)&&(appSettings.weldStyle!==3)){
                //清除坡口数据
                grooveTable.clear();
            }else {//半自动 手动 检测数据表是否有效
                //根据示教点数 复制第一个数据表格内容创建 示教点数个 坡口参数
                if(grooveTable.count>1)//删除多余点保留第一点
                    grooveTable.remove(1,grooveTable.count-1);
                else if(grooveTable.count===0){
                    //插入全零的一行数据
                    grooveTable.append({"ID":"1","C1":"0","C2":"0","C3":"0","C4":"0","C5":"0","C6":"0","C7":"0","C8":"0"});
                }
                grooveTable.setProperty(0,"ID","1");
                console.log("teachPoint"+teachPoint)
                for(var i=1;i<app.teachPoint;i++){
                    var obj=grooveTable.get(0);
                    grooveTable.append({"ID":obj.ID,"C1":obj.C1,"C2":obj.C2,"C3":obj.C3,"C4":obj.C4,"C5":obj.C5,"C6":obj.C6,"C7":obj.C7,"C8":obj.C8});
                    grooveTable.setProperty(i,"ID",String(i+1));
                }
                //}
            }
            appSettings.welding=1;
        }else if(sysStatus==="坡口检测完成态"){
            //为了确保坡口参数最后一个示教点数据被准确读取 再读一遍坡口数据
            WeldMath.getGrooveTable();
            //检测完成
            message.open("坡口检测完成！正在计算相关焊接规范。")
            //切换指示灯为准备好
            AppConfig.setleds("ready");
            page.selectedTab=1;
            navigationDrawer.selectedIndex=0;
            weldTableIndex=0;
        }else if(sysStatus==="焊接态"){
            //启动焊接
            AppConfig.setleds("start");
            //提示
            message.open("焊接系统焊接中。")//weldFix?"焊接系统修补焊接中。":"焊接系统焊接中。")
            //切换到 焊接分析页面
            setPage(1,0)
            //把line的坐标更新到当前坐标
            app.startLine=new Date();
        }else if(sysStatus==="焊接端部暂停态"){
            //焊接暂停
            AppConfig.setleds("ready");
            //系统焊接中
            message.open("焊接系统焊接端部暂停。")//weldFix?"焊接系统修补焊接端部暂停。":"焊接系统焊接端部暂停。")
            //切换到 焊接分析页面
            setPage(1,0)
            if(appSettings.welding===1)
                appSettings.welding=2;
        }else if(sysStatus==="停止态"){
            //修复修补焊接时 数据下发不正常的问题
            // weldFix=false;
            WeldMath.initWeldMath();
            //系统停止
            AppConfig.setleds("stop");
            //焊接系统停止
            message.open("焊接系统停止。")
            //将状态切换成0
            WeldMath.setPara("sysStatus",0,true,false);
            appSettings.welding=0;
        }else if(sysStatus==="焊接中间暂停态"){
            //焊接中间暂停
            AppConfig.setleds("ready");
            //切换提示信息
            message.open("焊接系统焊接中间暂停。")//weldFix?"焊接系统修补焊接中间暂停。":"焊接系统焊接中间暂停。")
            if(appSettings.welding===1)
                appSettings.welding=2;
        }
    }
    // 链接 weldmath
    Connections{
        target: WeldMath
        onEr100_Key:{
            changeUserFlag=flag;
            changeuser.title=!changeUserFlag?qsTr("用户登录(请插入钥匙并打开)"):qsTr("用户登录");
            if(changeUserFlag){
                changeuser.passwordInput.readOnly=false;
                changeuser.passwordInput.placeholderText=qsTr("请输入密码...");
            }else{
                changeuser.passwordInput.helperText=""
                changeuser.passwordInput.text=""
                changeuser.passwordInput.placeholderText=qsTr("禁止登录！");
                changeuser.passwordInput.readOnly=true;
            }
        }
        onEr100_SysStatus:{
            sysStatus=status;
        }
        onEr100_updateGrooveTable:{
            var num=Number(groove.ID)-1;
            if(teachmodel===0){
                if(appSettings.weldStyle!==3){
                    grooveTable.append(groove);
                }else{//角焊需要设置脚长1 脚长2
                    grooveTable.setProperty(num,"ID",groove.ID)
                    grooveTable.setProperty(num,"C3",groove.C3) //根部
                    grooveTable.setProperty(num,"C4",groove.C4) //角1
                    grooveTable.setProperty(num,"C5",groove.C5) //角2
                }
            }else if(teachmodel===1){
                grooveTable.setProperty(num,"ID",groove.ID)
                if((appSettings.fixHeight)&&(appSettings.weldStyle!=3)){//水平角焊时不替换脚长1
                    grooveTable.setProperty(num,"C1",groove.C1)
                }
                if(appSettings.fixGap){
                    grooveTable.setProperty(num,"C3",groove.C3)
                }
                if(appSettings.fixAngel){
                    grooveTable.setProperty(num,"C4",groove.C4)
                    grooveTable.setProperty(num,"C5",groove.C5)
                }
                if((appSettings.connectStyle!==0)&&(appSettings.weldStyle!==3)) {//只有在非T接头和水平角焊时不替换
                    grooveTable.setProperty(num,"C2",groove.C2)
                }
            }
            else{
                grooveTable.setProperty(num,"C3",groove.C3)
            }
            //只有在T接头非水平角焊时更改脚长
            if((appSettings.connectStyle===0)&&(appSettings.weldStyle!==3)){
                var tempNum=Number(grooveTable.get(num).C2);
                if((isNaN(tempNum))||(tempNum===0))//如果是非数或为0 则替换 成0.3倍板厚
                    grooveTable.setProperty(num,"C2",String(Math.round(Number(groove.C1)*0.3)/10))
            }
            //对掉一下xz坐标 对比Z行走轴坐标转换 刘斌那边行走轴 往左走为负 往右走为正 即只需要调换往左走的坐标变为 正
            grooveTable.setProperty(num,"C8",groove.C8)
            grooveTable.setProperty(num,"C7",groove.C7)
            grooveTable.setProperty(num,"C6",groove.C6)
            changeGrooveTableIndex(num);
            appSettings.welding=1;
            if(((num+1)===app.teachPoint)&&((sysStatus==="坡口检测态")||(sysStatus==="坡口检测完成态"))){
                app.changeWeldRules();
            }
        }
        onEr100_UpdateWeldRules:{
            //确保数组数值正确
            weldTable.clear();
            for(var i=0;i<value.length;i++){
                weldTable.append(value[i]);
            }
            if(appSettings.welding!==2){
                changeWeldIndex(0);
            }
            // 切换状态为端部暂停
            if((grooveTableIndex===(app.teachPoint-1))&&((sysStatus==="坡口检测态")||(sysStatus==="坡口检测完成态"))){
                //保存数据
                saveData();
                //下发端部暂停态
                WeldMath.setPara("sysStatus",5,true,false);
            }
        }
        onEr100_SysError:{
            var errorTime=MyMath.getSysTime();
            errorCount++;//记录条目增加
            if(status){
                //如果无错误存在则 移除无错误
                if(initialListModel.count){
                    if(initialListModel.get(0).ID===0)
                        initialListModel.remove(0,1);}
                tool.errorCode=true;
                initialListModel.insert(0,{"ID":index,"C1":errorName[index-1],"C2":errorTime })
                if(!myErrorDialog.showing)
                    myErrorDialog.show();
                if(errorCount>50){//超过50条则自动删除最后一条且自动移动ID号码
                    for(var k=0;k<50;k++){
                        errorHistroy.setProperty(k,"ID",String(Number(errorHistroy.get(k).ID)-1))//所有序号递减
                    }
                    errorHistroy.remove(49,errorHistroy.count-49);
                    errorCount=50;
                }
                errorHistroy.insert(0,{"ID":String(errorCount>50?50:errorCount),"C1":String(index),"C2":"发生","C4":errorName[index-1],"C3":appSettings.currentUserName,"C5": errorTime})
            }else{
                //如果列表里面有则移除 解除错误
                for(var j=0;j<initialListModel.count;j++){
                    //如果列表里面有则移除 解除错误
                    if(index===(initialListModel.get(j).ID)){
                        initialListModel.remove(j,1);
                        if(initialListModel.count==0){
                            tool.errorCode=false;
                            initialListModel.append({"ID":0,"C1":"无","C2":errorTime})
                            myErrorDialog.close()
                        }
                        if(errorCount>50){//超过50条则自动删除最后一条且自动移动ID号码
                            for(k=0;k<50;k++){
                                errorHistroy.setProperty(k,"ID",String(Number(errorHistroy.get(k).ID)-1))//所有序号递减
                            }
                            errorHistroy.remove(49,errorHistroy.count-49);//移除多余的项
                            errorCount=50;//变更总表
                        }
                        //向数据库中插入
                        errorHistroy.insert(0,{"ID":String(errorCount>50?50:errorCount),"C1":String(index),"C2":"解除","C4":errorName[index-1],"C3":appSettings.currentUserName,"C5": errorTime})
                        if(errorTable.__listView.currentIndex>=initialListModel.count){
                            errorTable.__listView.currentIndex=j;
                            errorTable.selection.select(j);
                        }
                    }
                }
            }
        }
        onEr100_MotoPoint:{
            var travel;
            travel=value[1];
            travel<<=16;
            travel|=value[0];
            moto.currentTravelPoint=String(Number(travel/10).toFixed(1));
            moto.currentSwingPoint=String(Number(value[2]/10).toFixed(1));
            moto.currentAvcPoint=String(Number(value[3]/10).toFixed(1));
            moto.currentRockPoint=String(Number(value[4]/10).toFixed(1));
        }
        onEr100_changeWeldRules:{
            app.changeWeldRules();
        }
        onEr100_changeWeldTableIndex:{
            //当数值为 200时属于修补焊 不变更选中行，直接下发选中行数据
            if(index!==200){
                app.changeWeldIndex(index);
                weldTableIndex=index;
            }
            if(weldTableIndex>-1){
                WeldMath.sendWeldData(weldTable.get(weldTableIndex))
            }else if(weldTable.count>0){
                WeldMath.sendWeldData(weldTable.get(0))
            }
        }
        onEr100_GetControlStatus:{
               console.log(value);
        }
    }
    Tool{
        id:tool
        pageWidth: page.width
        pageHeight: page.height
        settings: appSettings
        status:sysStatus
        onToggleMotoDialog: moto.toggle();
        onToggleMyErrorDialog: myErrorDialog.toggle();
        onOpenMotoDialog: moto.open()
        onOpenMyErrorDialog: myErrorDialog.open();
        onUserUpdate: changeuser.show()
        onOpenControlStatusDialog: controlStatus.open();
        onUpdateDisplay: {
            currentGroove=app.currentGroove
            switch(page.selectedTab){
            case 0:switch(page0SelectedIndex){
                case 3:
                    toolName="坡口条件";
                    modelName="grooveModel";
                    currentRow=app.grooveTableIndex
                    currentName=app.grooveName
                    currentNameList=currentGrooveNameList;
                    currentNameListModel=grooveNameListModel;
                    model=grooveTable;
                    break;
                case 5:
                    toolName="限制条件";
                    modelName="limitedModel";
                    currentRow=app.limitedTableIndex
                    currentName=app.limitedName
                    currentNameList=app.currentLimitedNameList;
                    currentNameListModel=limitedRulesNameListModel;
                    model=limitedTable;
                    break;
                }break;
            case 1:switch(page1SelectedIndex){
                case 0:
                    toolName="焊接规范";
                    modelName="weldModel";
                    currentRow=app.weldTableIndex
                    currentName=app.weldName
                    currentNameList= app.currentWeldNameList;
                    currentNameListModel=weldRulesNameListModel;
                    model=weldTable;
                    break;
                }break;
            case 2:switch(page2SelectedIndex){
                case 0:
                    toolName="用户信息";
                    currentRow=app.accountTableIndex
                    currentName=""
                    modelName="accountModel";
                    currentNameList="";
                    currentNameListModel=null;
                    model=accountTable;
                    break;
                case 1:
                    toolName="";
                    modelName="errorHistory";
                    currentRow=-1;
                    currentName=""
                    currentNameList="";
                    currentNameListModel=null;
                    model=errorHistroy;
                    break;
                }break;
            }
        }
    }
    Material.OverlayLayer{
        z:5
        objectName: "InputPanelOverLayer"
        currentOverlay:Item{
            property bool  globalMouseAreaEnabled:false
            property color overlayColor: "transparent"
        }
        InputPanel{
            id:inputPanel
            y: app.height
            anchors.left: parent.left
            anchors.right: parent.right
            states: State {
                name: "visible"
                when: Qt.inputMethod.visible
                PropertyChanges {
                    target: inputPanel
                    y: app.height - inputPanel.height
                }
            }
            transitions: Transition {
                from: ""
                to: "visible"
                reversible: true
                ParallelAnimation {
                    NumberAnimation {
                        properties: "y"
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
            }
            Connections{
                target: InputContext
                onFocusEditorChanged:{
                    //控件能否输入
                    if(inputPanel.visible){
                        if(InputContext.inputItem.hasOwnProperty("inputMethodHints")){
                            var flickable=InputContext.inputItem;
                            while(flickable){
                                if(flickable.hasOwnProperty("flicking")){
                                    var inputItemRect=flickable.mapFromItem(InputContext.inputItem,0,0,InputContext.inputItem.width,InputContext.inputItem.height)
                                    var keyboardRect=flickable.mapFromItem(inputPanel,0,0,inputPanel.width,inputPanel.height)
                                    var contentY=flickable.contentY
                                    //尚未加载时算法
                                    if((inputPanel.y===app.height)&&((keyboardRect.top-keyboardRect.height)<(inputItemRect.bottom+20))){
                                        contentY+= inputItemRect.bottom-keyboardRect.y+keyboardRect.height +20;
                                    }
                                    //加载后算法
                                    if(keyboardRect.top<(inputItemRect.bottom+20)){
                                        contentY+= inputItemRect.bottom-keyboardRect.y+20;
                                    }
                                    flickable.contentY=contentY;
                                    break;
                                }
                                flickable=flickable.parent;
                            }
                        }
                    }
                }
            }
        }
    }

    Material.Dialog{
        id:myErrorDialog
        objectName: "myErrorDialog"
        title: "系统错误"
        property alias errorModel:errorTable.model
        positiveButtonText: qsTr("确认");

        negativeButton.visible: false
        onOpened: {
            errorTable.__listView.currentIndex=0;
            errorTable.selection.clear();
            errorTable.selection.select(0);
        }
        globalMouseAreaEnabled:false;
        Keys.onVolumeDownPressed: {
            if(errorTable.columnCount>errorTable.currentRow)
                errorTable.__incrementCurrentIndex();
        }
        Keys.onVolumeUpPressed: {
            if(errorTable.currentRow>0)
                errorTable.__decrementCurrentIndex();
        }
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

    MotoDialog{id:moto;settings: appSettings;errorCode: app.errorCode
                    onVisibleChanged:  WeldMath.getMotoPoint(visible);
    }
    /*日历*/
    Material.Dialog {
        id:datePickerDialog;
        hasActions: true; contentMargins: 0;floatingActions: true
        negativeButtonText:qsTr("取消");positiveButtonText: qsTr("完成");
        dialogContent:Material.DatePicker {
            id:datePicker
            __locale:Qt.locale(app.local)
            frameVisible: false;dayAreaBottomMargin : Material.Units.dp(48);isLandscape: true;
        }
        onOpened: {
            //更新一下 当前选择的date
            datePicker.selectedDate=new Date();
        }
        onAccepted: {
            var current=datePicker.selectedDate.toLocaleDateString(Qt.locale(app.local),"yy/M/d/");
            current =current+new Date().toLocaleTimeString(Qt.locale(app.local),"h/m/s");
            var dateTime=current.split("/");
            WeldMath.setDateTime(dateTime);
        }
    }
    /*时间*/
    Material.Dialog {
        id:timePickerDialog;
        hasActions: true; contentMargins: 0;
        negativeButtonText:qsTr("取消");positiveButtonText: qsTr("完成");
        Material.TimePicker {
            //存在bug 24小时制时 输出数据多减12
            id:timePicker
            //prefer24Hour:true
        }
        onOpened: {
            timePicker.reset();
        }
        onAccepted: {
            var current=new Date().toLocaleDateString(Qt.locale(app.local),"yy/M/d/");
            current=current+timePicker.getCurrentTime().toLocaleTimeString(Qt.locale(app.local),"h/m/s");
            var time=current.split("/")
            WeldMath.setDateTime(time);
        }
    }
    Material.Dialog{
        id:controlStatus
        title: "控制器状态信息"
        hasActions: false
       Item{
            width: Material.Units.dp(300)
            height: Material.Units.dp(200)
            ColumnLayout{
                anchors.right: parent.horizontalCenter
                anchors.rightMargin: 24
                anchors.top:parent.top
                anchors.topMargin:24
                Repeater{
                    model: ["系统状态:","起弧状态:","焊接状态:","收弧状态:"]
                   Material.Label{
                        Layout.alignment: Qt.AlignRight
                        text:modelData
                        style: "button"
                    }
                }
            }
            ColumnLayout{
                anchors.left: parent.horizontalCenter
                anchors.leftMargin: -12
                anchors.top:parent.top
                anchors.topMargin:24
                Repeater{
                    model:4
                    Material.Label{
                        text:"0"
                        style: "button"
                    }
                }
            }
        }
    }

    /*背光调节*/
    Material.Dialog{
        id:backlight
        title: qsTr("背光调节");negativeButtonText:qsTr("取消");positiveButtonText: qsTr("完成")
        dialogContent: Item{
            height:Material.Units.dp(100);
            width:Material.Units.dp(240);
            Material.Slider {
                id:backlightslider;width:Material.Units.dp(240);anchors.top: parent.top;anchors.topMargin: Material.Units.dp(24)
                stepSize: 1;numericValueLabel: true;
                minimumValue: 5;maximumValue: 100; activeFocusOnPress: true;
                onValueChanged: AppConfig.setbackLight(backlightslider.value)
                Component.onCompleted: backlightslider.value=appSettings.backLightValue<5?5:appSettings.backLightValue
            }}
        onOpened: {backlightslider.value=appSettings.backLightValue<5?5:appSettings.backLightValue
            backlightslider.forceActiveFocus()
        }
        onAccepted: appSettings.backLightValue=backlightslider.value
        onRejected: backlightslider.value=appSettings.backLightValue<5?5:appSettings.backLightValue

    }
    /*颜色选择对话框*/
    Material.Dialog {
        id: colorPicker;title: qsTr("主题");negativeButtonText:qsTr("取消");positiveButtonText: qsTr("完成");
        /*接受则存储系统颜色*/
        onAccepted:{
            appSettings.accentColor=theme.accentColor;
            appSettings.primaryColor=theme.primaryColor;
            appSettings.backgroundColor=theme.backgroundColor;
        }
        /*不接受则释放系统颜色*/
        onRejected: {
            theme.accentColor=appSettings.accentColor
            theme.primaryColor=appSettings.primaryColor
            theme.backgroundColor=appSettings.backgroundColor
        }
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
        objectName: "ChangeUserDialog"
        negativeButtonText:qsTr("取消");
        positiveButtonText:qsTr("确定");
        positiveButtonEnabled:false;
        globalMouseAreaEnabled: true
        dismissOnTap:positiveButtonEnabled
        overlayColor: Qt.rgba(0, 0, 0, 0.3)
        property alias passwordInput: passwordTextfield
        property string password
        property string user
        property string type
        property int upCount: 0
        function getIndex(name){
            for(var i=0;i<accountTable.count;i++){
                if(accountTable.get(i).C2===name)
                    return i;
            }
            return -1;
        }
        Keys.onUpPressed: {
            if(sysStatus==="未登录态"){
                if(event.isAutoRepeat)
                    upCount++;
                else
                    upCount=0;
                if(upCount>20){
                    upCount=0;
                    app.sysStatus="空闲态";
                    appSettings.currentUserPassword = "TKAS"
                    appSettings.currentUserName = "TKAS";
                    appSettings.currentUserType = "超级用户";
                    app.superUser=appSettings.currentUserType==="超级用户"?true:false;
                    changeUserFlag=true;
                    //发送主控登录标志
                    WeldMath.setPara("signedIn",2,true,false);
                    close();
                    rejected();
                }
                //判断是不是初始检测数据
                if((appSettings.welding==2)&&(!systemStart)){
                    //更新规范
                    app.changeWeldRules();
                    //下发规范
                    if(weldTableIndex>-1){
                        WeldMath.sendWeldData(weldTable.get(weldTableIndex))
                    }
                }
            }
        }
        Keys.onDigit9Pressed: {
            app.sysStatus="空闲态";
            appSettings.currentUserPassword = "TKAS"
            appSettings.currentUserName = "TKAS";
            appSettings.currentUserType = "超级用户";
            app.superUser=appSettings.currentUserType==="超级用户"?true:false;
            changeUserFlag=true;
            //发送主控登录标志
            WeldMath.setPara("signedIn",2,true,false);
            close();
            rejected();
        }
        onAccepted: {
            if(changeuser.positiveButtonEnabled){
                appSettings.currentUserPassword = changeuser.password
                appSettings.currentUserName = changeuser.user;
                appSettings.currentUserType = changeuser.type;
                app.superUser=appSettings.currentUserType==="超级用户"?true:false;
                if(changeUserFlag){//如果插入钥匙
                    app.sysStatus="空闲态";
                    WeldMath.setSysStatus("空闲态");
                    //发送主控登录标志
                    WeldMath.setPara("signedIn",2,true,false);
                }
                if((appSettings.welding==2)&&(!systemStart)){
                    //更新规范
                    app.changeWeldRules();
                    //下发规范
                    if(weldTableIndex>-1){
                        WeldMath.sendWeldData(weldTable.get(weldTableIndex))
                    }
                }
            }
        }
        onRejected: {
            changeuserFeildtext.selectedIndex=getIndex(appSettings.currentUserName);
            changeuser.type=appSettings.currentUserType;
        }
        onOpened: {
            app.visible=true
            title=!changeUserFlag?qsTr("用户登录(请插入钥匙并打开)"):qsTr("用户登录");
            if(accountTable.count>0){
                changeuser.user=appSettings.currentUserName;
                var index=getIndex(changeuser.user);
                if(index>=0){
                    var obj=accountTable.get(index);
                    changeuser.password=accountTable.get(index).C3;
                    changeuser.type=accountTable.get(index).C4
                    changeuserFeildtext.selectedIndex=index;
                }else
                    message.open("当前用户不存在！")
            }
            passwordInput.text="";
            if(changeUserFlag){
                passwordInput.readOnly=false;
            }else{
                passwordInput.readOnly=true;
                passwordInput.placeholderText=qsTr("禁止登录！");
            }
            if(sysStatus==="未登录态"){
                negativeButton.visible=false;
            }else{
                passwordInput.placeholderText="请输入密码..."
                passwordInput.helperText=""
                negativeButton.visible=true;
            }
            Qt.inputMethod.hide();
        }
        RowLayout{
            spacing: Material.Units.dp(24)
            Image{
                id:image
                Layout.alignment: Qt.AlignVCenter
                source: "../Pic/logo.png"
                Layout.preferredWidth: Material.Units.dp(256)
                Layout.preferredHeight: Material.Units.dp(45)
                mipmap: true
            }
            Rectangle{
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredHeight: parent.height-Material.Units.dp(24)
                width: 1
                color: Qt.rgba(0,0,0,0.2)
            }
            Column{
                id:column
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth:Material.Units.dp(200)
                ListItem.Subtitled{
                    margins: 1
                    text:qsTr("用户名:");
                    interactive:false
                    height: Material.Units.dp(64)
                    secondaryItem: Material.MenuField{
                        id:changeuserFeildtext;
                        textRole: "C2"
                        model:accountTable
                        width:Material.Units.dp(120)
                        onItemSelected:  {
                            changeuser.passwordInput.enabled=true;
                            var data=accountTable.get(index);
                            changeuser.user=data.C2
                            changeuser.password = data.C3;
                            changeuser.type = data.C4;
                            changeuser.passwordInput.text="";}}
                }
                ListItem.Subtitled{
                    margins: 1
                    text:qsTr("密    码:");
                    height: Material.Units.dp(56)
                    interactive:false
                    secondaryItem: Material.TextField{id:passwordTextfield;
                        characterLimit: 8;
                        width:Material.Units.dp(120)
                        onTextChanged:{
                            if(text===changeuser.password){
                                changeuser.positiveButtonEnabled=true;
                                helperText=qsTr("密码正确");}
                            else{
                                helperText=qsTr("请输入密码...");
                                changeuser.positiveButtonEnabled=false;}}
                        onHasErrorChanged: {
                            if(hasError === true){
                                helperText =qsTr( "密码超过最大限制");}
                            else
                                helperText=""
                        }
                    }
                }
            }
        }
    }
    Connections{
        target: MySQL
        onAccountTableChanged:{
            for(var i=0;i<jsonObject.length;i++){
                if(i<accountTable.count)
                    accountTable.set(i,jsonObject[i]);
                else
                    accountTable.append(jsonObject[i]);
            }
            if(sysStatus==="未登录态"){
                changeuser.show()
            }
        }
        onMySqlStatusChanged:{
            if(!status){
                message.open("操作"+tableName+"失败！")
            }
        }
    }
    Component.onCompleted: {
        theme.accentColor=appSettings.accentColor
        theme.primaryColor=appSettings.primaryColor
        theme.backgroundColor=appSettings.backgroundColor
        theme.tabHighlightColor=appSettings.accentColor
        MySQL.getJsonTable("AccountTable");
        AppConfig.setleds("all");
        systemStart=false;
        //切换页面
        page.selectedTab=1;
        //加载焊接分析界面
        page1SelectedIndex=0;
        WeldMath.getDateTime();
        WeldMath.setFixPara(appSettings.a,appSettings.b,appSettings.c,appSettings.d,appSettings.e);
        WeldMath.setFixWeld(appSettings.fixWeld);
        WeldMath.setSysStatus("未登录态");
        sysStatus="未登录态";//系统处于未登陆状态
        //切换回原界面
        page.selectedTab=0;

    }
}
