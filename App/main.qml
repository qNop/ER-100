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
import QtQuick.Window 2.2

/*应用程序窗口 */
Material.ApplicationWindow{
    id: app;title: "app";
    objectName: "App"
    visible: false
    /*主题默认颜色*/
    theme.tabHighlightColor: theme.accentColor
    //不需要解释
    property var grooveStyleName: [ "平焊单边V形坡口T接头",  "平焊单边V形坡口平对接", "平焊V形坡口平对接","横焊单边V形坡口T接头",  "横焊单边V形坡口平对接", "立焊单边V形坡口T接头",  "立焊单边V形坡口平对接", "立焊V形坡口平对接","水平角焊"]
    property var preset:["GrooveCondition","TeachCondition","WeldCondition","GrooveCheck","LimitedConditon"]
    property var presetName: ["坡口条件","示教条件","焊接条件","坡口参数","限制条件"]
    property var presetIcon: ["awesome/road","action/android","user/MAG","awesome/road","awesome/sliders"]
    property var analyse: ["WeldData"]//,"WeldAnalyse"]
    property var analyseName:["焊接参数"]//,"过程分析"]
    property var analyseIcon: ["awesome/tasks"]//,"awesome/pie_chart"]
    property var infor: ["UserAccount","SysErrorHistroy","SystemInfor"]
    property var inforName:["用户管理","历史错误","关于系统"]
    property var inforIcon: ["social/group","awesome/list_alt","awesome/desktop"]
    property var sections: [preset,analyse, infor]
    property var sectionsName:[presetName,analyseName,inforName]
    property var sectionsIcon:[presetIcon,analyseIcon,inforIcon]
    property var sectionTitles: ["预置条件", "焊接分析", "系统信息"]
    property var tabiconname: ["action/settings_input_composite","awesome/tasks","awesome/windows"]
    property var errorName:["主控制器异常","CAN通讯异常","急停报警","摇动电机过热过流","摇动电机右限位","摇动电机左限位","摇动电机原点搜索","摇动电机堵转", "摆动电机过热过流","摆动电机内限位",
        "摆动电机外限位","摆动电机原点搜索","摆动电机堵转", "上下电机过热过流","上下电机下限位","上下电机上限位","上下电机原点搜索","上下电机堵转", "行走电机过热过流","行走电机右限位",
        "行走电机左限位","行走电机原点搜索","行走电机堵转","驱动器急停报警","手持盒通讯异常","示教器通讯异常","焊接电源通讯异常","焊接电源粘丝异常","焊接电源其他异常","坡口参数表格内无数据",
        "生成焊接规范异常","未定义异常",
        "未定义异常","未定义异常","未定义异常","未定义异常","未定义异常","未定义异常","未定义异常","未定义异常", "未定义异常","未定义异常",
        "未定义异常","未定义异常","未定义异常", "未定义异常","未定义异常","未定义异常","未定义异常","未定义异常", "未定义异常","未定义异常",
        "未定义异常","未定义异常","未定义异常","未定义异常","未定义异常","未定义异常","未定义异常","未定义异常","未定义异常","未定义异常",
        "未定义异常","未定义异常"]
    property int  page0SelectedIndex:0
    property int  page1SelectedIndex:0
    property int  page2SelectedIndex:0
    /*当前本地化语言*/
    property string local: "zh_CN"
    /*当前坡口形状*/
    property int currentGroove:0
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
    /*app加载完毕*/
    property bool completed:false
    /*当前用户名*/
    // property string currentUser: appSettings.currentUserName

    property string  weldRulesName

    property bool superUser
    //示教模式
    property int teachModel: 0
    //示教点数
    property int teachPoint: 0

    property bool readSet:false
    /*account*/
    ListModel{id:accountmodel;}
    //错误列表
    ListModel{id:initialListModel;ListElement{ID:0;C1:"无";C2:"0:00"}}
    //焊接规范表格
    ListModel{id:weldTable;}
    //错误历史信息 ID：条数 C1 错误代码 C2 错误状态 C3 错误信息 C4: 操作用户 C5 错误发生/解除时刻
    ListModel{id:errorHistroy}
    //坡口参数规范
    ListModel{id:grooveTable}
    //信号
    signal changeWeldIndex(int index)
    //信号
    signal changeGrooveTableIndex(int index)
    //signal
    signal changeTeachSet(var value);
    //Settings
    MySettings{id:appSettings}
    /*更新时间定时器*/
    Timer{
        interval:1000;running:true;repeat: true;
        onTriggered:{
            var dateTime= new Date().toLocaleString(Qt.locale(app.local),"MMMdd ddd-h:mm")
            var timeD =dateTime.split("-");
            date.name=timeD[0];
            time.name=timeD[1];
        }
    }
    Timer{id:camera
        interval:10000;running: false;repeat: false
        onTriggered: {
            if(AppConfig.screenShot(app)){
                snackBar.open("截屏成功！")
            }else
                snackBar.open("截屏失败！")
        }
    }
    //该页面下1000ms问一次检测参数是否有效
    Timer{ repeat: true;interval:sysStatus==="空闲态"?200:500;
        running:readTime
        onTriggered: {
            if(sysStatus==="坡口检测态")
                ERModbus.setmodbusFrame(["R","150","10"])
            else if((sysStatus==="焊接端部暂停态")||(sysStatus==="焊接中间暂停态"))
                ERModbus.setmodbusFrame(["R","200","1"]);
            //            else if(sysStatus==="焊接态"){
            //                //  ERModbus.setmodbusFrame(["R","10","4"])
            //            }
            else if(sysStatus==="未登录态"){
            } else
                if((readSet)&&(sysStatus==="空闲态"))
                    ERModbus.setmodbusFrame(["R","99","6"]) //读取设置规范
                else
                    ERModbus.setmodbusFrame(["R","0","5"]); //读取系统状态
            readSet=!readSet;
        }
    }
    //计算坡口数据平均值
    function getGrooveAverage(){
        var i,j,temp;
        var array=new Array(0);
        //有多少有效示教点数
        var count=grooveTable.count;
        if(count>0){
            for(i=0;i<5;i++){
                temp=0;
                for(j=0;j<count;j++){
                    temp+=Number(i===0?grooveTable.get(j).C1:i===1?grooveTable.get(j).C2:i===2?grooveTable.get(j).C3:i===3?grooveTable.get(j).C4:grooveTable.get(j).C5);
                }
                temp/=j;
                array.push(String(temp))
            }
            array.push(grooveTable.get(j-1).C6)
            array.push(grooveTable.get(j-1).C7)
            array.push(grooveTable.get(j-1).C8)
            console.log("grooveTable data is "+array)
            return array;
        }else
            return -1;
    }
    onCurrentGrooveChanged: {
        console.log(objectName+" currentGroove "+currentGroove)
        var res=Material.UserData.getLastGrooveName(grooveStyleName[currentGroove]+"列表","EditTime")
        //更新焊接规范名称
        if((typeof(res)==="string")&&(res!=="")){
            currentGrooveName=res;
            //名称存在且格式正确  那么 重新更新 表名称参数 找出最新的表
            res =Material.UserData.getWeldRulesNameOrderByTime(currentGrooveName+"次列表","EditTime")
            if((res!==-1)&&(typeof(res)==="object")){
                //清除焊接规范表格
                weldTable.clear();
                weldRulesName=res[0].Rules;
                //获取新的焊接规范表
                res=Material.UserData.getTableJson(weldRulesName)
                if((res!==-1)&&(typeof(res)==="object")){
                    for(var i=0;i<res.length;i++){
                        weldTable.append(res[i]);
                    }
                }else{
                    snackBar.open("获取焊接规范表格错误！")
                }
            }else
                snackBar.open("获取焊接规范名称错误！")

        }else{
            snackBar.open("获取坡口名称错误！")
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
                onTriggered:{page.selectedTab=0;app.page0SelectedIndex=0;}
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
            Material.Action {iconName: "action/language";name: qsTr("语言");
                onTriggered: languagePicker.show();
            },
            /*截屏*/
            Material.Action {iconName:"awesome/camera";name: qsTr("截屏");visible: superUser
                onTriggered: {snackBar.open("截屏操作将在10秒钟后启动！");camera.start()}
            },
            //            /*mount网络*/
            //            Material.Action {iconName:loadInterNet?"hardware/phonelink": "hardware/phonelink_off";name: qsTr("网络");
            //                onTriggered: {loadInterNet=!loadInterNet;AppConfig.setloadNet(loadInterNet);}
            //            },
            /*系统电源*/
            Material.Action {iconName: "awesome/power_off";name: qsTr("关机")
                onTriggered: {app.modbusBusy=false;app.sysInforFlag=false;Qt.quit();}
            }
        ]
        backAction: navigationDrawer.action
        actionBar.tabBar{leftKeyline: 0;isLargeDevice: false;fullWidth:false}
        Keys.onDigit1Pressed: {if(!event.isAutoRepeat)navigationDrawer.toggle();}
        Keys.onDigit2Pressed: {if((page.selectedTab!==0)&&preConditionTab.enabled)page.selectedTab=0;}
        Keys.onDigit3Pressed: {if((page.selectedTab!==1)&&weldAnalyseTab.enabled)page.selectedTab=1;}
        Keys.onDigit4Pressed: {if((page.selectedTab!==2)&&(systemInforTab.enabled))page.selectedTab=2;}
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
            settings: appSettings
            onClosed: openFinish=false;
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
                //最后加载
                GrooveCondition{
                    id:grooveConditionPage
                    settings: appSettings
                    visible: page.selectedTab===0&&page0SelectedIndex===0
                    message: snackBar
                    onCurrentGrooveChanged:{
                        app.currentGroove=currentGroove;
                    }
                }
                TeachCondition{
                    id:teachConditionPage
                    message: snackBar
                    visible: page.selectedTab===0&&page0SelectedIndex===1
                    enabled: sysStatus!=="坡口检测态"
                    onChangeTeachPoint: app.teachPoint=num;
                    onChangeTeachModel: app.teachModel=model;
                    Connections{
                        target:app
                        onChangeTeachSet:{
                            var str="";
                            for(var i=2;i<6;i++)
                                if(Number(value[i])!==teachConditionPage.condition[i-1]){//始终端改变
                                    page.selectedTab=0;
                                    page0SelectedIndex=1;
                                    lastFocusedItem=teachConditionPage;//聚焦lastFocusedItem
                                    lastFocusedItem.forceActiveFocus();
                                    teachConditionPage.selectedIndex=i-1;//切换选中栏
                                    Material.UserData.setValueFromFuncOfTable(teachConditionPage.objectName,i-1,Number(value[i]))//存储数据
                                    if(i<teachConditionPage.listValueName.length){
                                        //只改变显示不下发数据不存储
                                        teachConditionPage.changeGroupCurrent(Number(value[i]),true);
                                        str= teachConditionPage.listName[i-1]+"切换为"+teachConditionPage.listValueName[i-1][Number(value[i])]+"。"
                                    }else{
                                        teachConditionPage.changeText(Number(value[i]),true);
                                        str=teachConditionPage.listName[i-1]+"切换为"+value[i]+teachConditionPage.valueType[i-teachConditionPage.listValueName.length]
                                    }
                                    snackBar.open(str)
                                }
                        }
                    }
                }
                WeldCondition{
                    id:weldConditionPage
                    visible: page.selectedTab===0&&page0SelectedIndex===2
                    message:snackBar
                    superUser:app.superUser
                    Connections{
                        target:app
                        onChangeTeachSet:{
                            if(Number(value[0])!==weldConditionPage.condition[1]){//始终端改变
                                page.selectedTab=0;
                                page0SelectedIndex=2;
                                lastFocusedItem=weldConditionPage;//聚焦lastFocusedItem
                                lastFocusedItem.forceActiveFocus();
                                weldConditionPage.selectedIndex=1;
                                //只改变显示不下发数据不存储
                                weldConditionPage.changeGroupCurrent(Number(value[0]),true);
                                //存储数据
                                Material.UserData.setValueFromFuncOfTable(teachConditionPage.objectName,1,Number(value[0]))
                                snackBar.open(weldConditionPage.listName[1]+"切换为"+weldConditionPage.listValueName[1][Number(value[0])]+"。")
                            }
                        }
                    }
                }
                GrooveCheck{
                    id:grooveCheckPage
                    visible: page.selectedTab===0&&page0SelectedIndex===3
                    status: app.sysStatus
                    message:snackBar
                    model:grooveTable
                    settings: appSettings
                    //状态为坡口检测态时不能更改 数据表
                    onStatusChanged: table.enabled=app.sysStatus!=="坡口检测态"?true:false
                    currentGrooveName:app.currentGrooveName
                    grooveName: app.grooveStyleName[currentGroove]
                    currentGroove: app.currentGroove
                    //改变坡口名称
                    onChangedCurrentGroove: {
                        app.currentGrooveName=name;
                    }
                    //通过信号的方式交互Model数据而不影响到数据的绑定问题。
                    onUpdateModel: {
                        console.log(objectName+str+data.ID+data.C1+data.C2+data.C3+data.C4)
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
                    Connections{
                        target: teachConditionPage
                        onChangeTeachModel:{
                            grooveCheckPage.teachModel=model;
                        }
                    }
                    Connections{
                        target:app
                        onChangeGrooveTableIndex:{
                            if(index<grooveTable.count){
                                grooveTableIndex=index;
                                grooveCheckPage.currentRow=index;
                                grooveCheckPage.selectIndex(index);
                            }else
                                snackBar.open("索引条目超过模型最大值！");
                        }
                    }
                }
                LimitedCondition{
                    id:limitedConditionPage
                    settings: appSettings
                    visible: page.selectedTab===0&&(page0SelectedIndex===4)&&(app.superUser)
                    limitedRulesName: app.weldRulesName.replace("焊接规范","限制条件")
                    message: snackBar
                    Connections{
                        target: weldConditionPage
                        onChangeNum:{limitedConditionPage.num=value;}
                    }
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
                    id:weldDataPage
                    visible:page.selectedTab===1&& page1SelectedIndex===0;
                    status: app.sysStatus
                    message:snackBar
                    weldTableEx: app.superUser
                    currentGrooveName: app.currentGrooveName
                    weldRulesName: app.weldRulesName
                    currentUserName: appSettings.currentUserName
                    onUpdateWeldRulesName: {
                        app.weldRulesName=str;
                        weldTable.clear()
                        var res=Material.UserData.getTableJson(str)
                        if(res!==-1){
                            for(var i=0;i<res.length;i++){
                                if(res[i].ID!==null)
                                    weldTable.append(res[i]);
                            }
                            currentRow=0;
                            selectIndex(0);
                        }
                    }
                    onCurrentRowChanged: {
                        app.weldTableIndex=currentRow;
                    }
                    model: weldTable
                    //外部更改模型数据 避免绑定过程中解除绑定的操作存在而影响数据与模型内容不一致
                    onUpdateModel: {
                        switch(str){
                        case "Set":weldTable.set(currentRow,data);
                            selectIndex(currentRow);
                            break;
                        case "Append":weldTable.append(data);
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
                    //链接app的changeWeldIndex信号实现外部对数据模型索引的变更,优化绑定造成的影响
                    Connections{
                        target: app
                        onChangeWeldIndex:{
                            if(index<weldTable.count){
                                console.log("weldDataPage.currentRow"+index)
                                weldDataPage.currentRow=index;
                                weldDataPage.selectIndex(index);
                            }else
                                snackBar.open("索引条目超过模型最大值！");
                        }
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
                    model:accountmodel
                    superUser: app.superUser
                    onUserUpdate: changeuser.show()
                    message: snackBar
                    Component.onCompleted: console.log(objectName+"Completed")
                }
                SysErrorHistroy{
                    id:sysErrorHistroyPage
                    model:errorHistroy
                    visible: page.selectedTab===2&&page2SelectedIndex===1
                    status:sysStatus
                    onRemoveall:{
                        errorHistroy.clear();
                        //清楚数据表格
                        Material.UserData.clearTable("SysErrorHistroy","","");
                        snackBar.open("错误历史记录已被清空！");
                    }
                    onRemove:{
                        if(currentRow!==-1){
                            var index=currentRow;
                            Material.UserData.clearTable("SysErrorHistroy","ID",errorHistroy.get(index).ID);
                            errorHistroy.remove(index);
                            snackBar.open("本条错误已移除！");
                        }else
                            snackBar.open("请选择要移除的信息条目！");
                    }
                }
                SystemInfor{
                    id:systemInforPage
                    visible: page.selectedTab===2&&page2SelectedIndex===2}
            }
        }
    }
    onSysStatusChanged: {
        if(sysStatus=="空闲态"){
            //高压接触传感
            snackBar.open("焊接系统空闲！")
            //空闲态
            AppConfig.setleds("ready");
            if(!myErrorDialog.showing){
                //切换页面
                page.selectedTab=0;
                //
                app.page0SelectedIndex=0;
            }
        }else if(sysStatus=="坡口检测态"){
            //高压接触传感
            snackBar.open("坡口检测中，高压输出，请注意安全！")
            //切换指示灯
            AppConfig.setleds("start");
            //切换界面
            page.selectedTab=0;
            //切小页面
            app.page0SelectedIndex=3;
            //全自动则清除
            if(teachModel===0)
                //清除坡口数据
                grooveTable.clear();
            else {//半自动 手动 检测数据表是否有效
                if(grooveTable.count===0){
                    //写入错误
                    errorCode|=0x20000000;
                    ERModbus.setmodbusFrame(["W","1","2",String(errorCode&0x0000ffff),String((errorCode&0xffff0000)>>16)]);
                }else{//根据示教点数 复制第一个数据表格内容创建 示教点数个 坡口参数
                    if(grooveTable.count!==1)
                        for(var i=1;i<grooveTable.count;i++)
                            grooveTable.remove(i);
                    for(i=1;i<app.teachPoint;i++){
                        grooveTable.append(grooveTable.get(0))
                        grooveTable.setProperty(i,"ID",String(i+1));
                    }
                    changeGrooveTableIndex(-1);
                }
            }
        }else if(sysStatus=="坡口检测完成态"){
            //检测完成
            snackBar.open("坡口检测完成！正在计算相关焊接规范。")
            //切换指示灯为准备好
            AppConfig.setleds("ready");
            //获取坡口长度
            ERModbus.setmodbusFrame(["R","104","1"])
            page.selectedTab=1;
            app.page1SelectedIndex=0;
            weldTable.clear();
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
                MathError=1;
                MathError<<=25;
                errorCode=MathError;
            }else{
                //查询系统状态
                if(frame[1]==="0"){
                    //获取系统状态
                    sysStatus=sysStatusList[Number(frame[2])];
                    //获取系统错误警报
                    MathError=Number(frame[6]);
                    MathError<<=16;
                    MathError|=Number(frame[5]);
                    errorCode1=MathError;
                    MathError=Number(frame[4]);
                    MathError<<=16;
                    MathError|=Number(frame[3]);
                    errorCode=MathError;
                }
                else if((frame[1]==="150")&&(sysStatus==="坡口检测态")){
                    //间隔跳示教点允许删除示教点操作尚未加入
                    if(frame[2]!=="0"){
                        var num=Number(frame[2])-1;
                        //如果当前选择行和 上传数据行不一至则更新数据
                        if((num!==app.grooveTableIndex)&&(num>app.grooveTableIndex)){
                            if(teachModel===0)
                                grooveTable.append({
                                                       "ID":frame[2],
                                                       "C1":(Number(frame[3])/10).toString(),
                                                       "C2":(Number(frame[4])/10).toString(),
                                                       "C3":(Number(frame[5])/10).toString(),
                                                       "C4":(Number(frame[6])/10).toString(),
                                                       "C5":(Number(frame[7])/10).toString(),
                                                       "C6":String((Number(frame[8])|(Number(frame[9])<<16))/10),
                                                       "C7":String(Number(frame[10])/10),
                                                       "C8":String(Number(frame[11])/10)})
                            else if(teachModel===1){
                                grooveTable.setProperty(num,"ID",frame[2])
                                if(appSettings.fixHeight){
                                    grooveTable.setProperty(num,"C1",(Number(frame[3])/10).toString())
                                }
                                if(appSettings.fixGap){
                                    grooveTable.setProperty(num,"C3",(Number(frame[5])/10).toString())
                                }
                                if(appSettings.fixAngel){
                                    grooveTable.setProperty(num,"C4",(Number(frame[6])/10).toString())
                                    grooveTable.setProperty(num,"C5",(Number(frame[7])/10).toString())
                                }
                                grooveTable.setProperty(num,"C6",String((Number(frame[8])|(Number(frame[9])<<16))/10))
                                grooveTable.setProperty(num,"C7",String(Number(frame[10])/10))
                                grooveTable.setProperty(num,"C8",String(Number(frame[11])/10))
                            }
                            else{
                                grooveTable.setProperty(num,"C3",(Number(frame[5])/10).toString())
                                grooveTable.setProperty(num,"C6",String((Number(frame[8])|(Number(frame[9])<<16))/10))
                                grooveTable.setProperty(num,"C7",String(Number(frame[10])/10))
                                grooveTable.setProperty(num,"C8",String(Number(frame[11])/10))
                            }
                            changeGrooveTableIndex(num);
                        }
                    }
                    ERModbus.setmodbusFrame(["R","0","5"]);
                }
                else if((frame[1]==="104")&&(sysStatus=="坡口检测完成态")){
                    //如果坡口参数里面有数据 则进行计算数据
                    if(grooveTable.count!==0){
                        var temp =getGrooveAverage();
                        WeldMath.setGrooveRules(temp===-1?snackBar.open("坡口参数数据不存在！"):temp);
                    }
                    ERModbus.setmodbusFrame(["R","0","5"]);
                }else if((frame[1]==="10")&&(sysStatus==="焊接态")){
                    //记录焊接时间（焊接长度）
                    //发送握手信号
                    //ERModbus.setmodbusFrame(["R","0","5"]);
                }else  if((frame[1]==="200")&&((sysStatus==="焊接端部暂停态")||(sysStatus==="焊接中间暂停态"))){
                    if((frame[2]!==weldTableIndex.toString())&&(!weldFix)){
                        if(frame[2]!=="99"){
                            //当前焊道号与实际焊道号不符 更换当前焊道
                            if(weldTable.count>0){
                                changeWeldIndex(Number(frame[2]));
                                weldTableIndex=Number(frame[2]);
                            }
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
                                                     weldTable.get(weldTableIndex).C11==="永久"?"0":weldTable.get(weldTableIndex).C11,
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
                    }else if ((weldFix)&&(frame[2]!=="99")){
                        weldFix=false;
                    }
                    ERModbus.setmodbusFrame(["R","0","5"]);
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
                }else if(frame[1]==="99"){//读取设置
                    changeTeachSet(frame.slice(2,8))
                }
            }
        }
    }
    // 链接 weldmath
    Connections{
        target: WeldMath
        onWeldRulesChanged:{
            console.log(value);
            //确保数组数值正确
            if((typeof(value)==="object")&&(value.length===18)&&(value[0]==="Successed")){
                weldTable.append({"ID":value[1], "C1":value[2],"C2":value[3],"C3":value[4],"C4":value[5],"C5":value[6],
                                     "C6":value[7],"C7":value[8],"C8":value[9],"C9":value[10],"C10":value[11],"C11":value[12],"C12":value[13],
                                     "C13":value[14],"C14":value[15],"C15":value[16],"C16":value[17]})
            }else if(value[0]==="Clear"){
                weldTable.clear();
            }else if(value[0]==="Finish"){
                // 切换状态为端部暂停
                if(sysStatus==="坡口检测完成态"){
                    //下发端部暂停态
                    ERModbus.setmodbusFrame(["W","0","1","5"]);
                }
                //选中焊接规范表格的第一行数据
                if(weldTable.count){
                    page.selectedTab=1;
                    app.page1SelectedIndex=0;
                    changeWeldIndex(0);
                    //1目的是为了能够正常下发第一条规范。
                    weldTableIndex=1;
                }else{
                    // showMathError("计算错误！");
                    errorCode|=0x40000000;
                    ERModbus.setmodbusFrame(["W","1","2",String(errorCode&0x0000ffff),String((errorCode&0xffff0000)>>16)]);
                }
            }else{
                //输出错误
                //showMathError(value[0]);
                snackBar.open(value[0])
                //写入错误
                errorCode|=0x40000000;
                ERModbus.setmodbusFrame(["W","1","2",String(errorCode&0x0000ffff),String((errorCode&0xffff0000)>>16)]);
            }
        }
    }
    Material.OverlayLayer{
        objectName: "ActionButtonOverlayer"
        z:snackBar.opened?4:0
        Material.ActionButton{
            id:robot
            iconName: "action/android"
            anchors.right: snackBar.left
            anchors.rightMargin: Material.Units.dp(24)
            anchors.verticalCenter: snackBar.verticalCenter
            isMiniSize: true
            onPressedChanged: {
                if(pressed){
                    moto.open();
                }
            }
        }
        /*危险报警action*/
        Material.ActionButton{
            id:error
            property int count: 0
            iconName: errorCode?"alert/warning":sysStatus==="空闲态"?"awesome/play":
                                                                   sysStatus==="坡口检测态"?"awesome/flash":
                                                                                        sysStatus==="焊接态"?"user/MAG":"awesome/pause"
            anchors.right: robot.visible? robot.left:snackBar.left
            anchors.rightMargin: Material.Units.dp(16)
            anchors.verticalCenter: snackBar.verticalCenter
            isMiniSize: true
            onPressedChanged: {
                ///防止出现 屏幕开机 click 焦点错误
                count++;
                if(pressed&&count>3){
                    count=4;
                    myErrorDialog.open();
                }
            }
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
                topMargin:app.height-page.height-snackBar.height/2
                horizontalCenter:undefined
                Behavior on leftMargin {
                    NumberAnimation { duration: 300 }
                }
            }
            property string status: "open"
            fullWidth:false
            duration:3000;
        }
    }
    Material.OverlayLayer{
        z:5
        objectName: "InputPanelOverLayer"
        InputPanel{
            id:input
            objectName: "InputPanel"
            visible: Qt.inputMethod.visible
            y: Qt.inputMethod.visible ? parent.height - input.height:parent.height
            Behavior on y{
                NumberAnimation { duration: 200 }
            }
        }
    }
    function errorMath(Start,Length,MathError,MathXor){
        //获取时间
        var errorTime=Material.UserData.getSysTime();
        for(var i=Start;i<Length;i++){
            //如果变化存在
            if(MathXor&0x0001){
                //错误存在
                if(MathError&0x0001){
                    //如果无错误存在则 移除无错误
                    if(initialListModel.count){
                        if(initialListModel.get(0).ID===0)
                            initialListModel.remove(0,1);}
                    initialListModel.insert(0,{"ID":Number(i+1),"C1":errorName[i],"C2":errorTime })
                    console.log("C1",errorName[i])
                    errorHistroy.insert(0,{"ID":String(errorHistroy.count+1),"C1":String(i+1),"C2":"发生","C4":errorName[i],"C3":appSettings.currentUserName,"C5": errorTime})
                }else{
                    for(var j=0;j<initialListModel.count;j++){
                        //如果列表里面有则移除 解除错误
                        if((i+1)===(initialListModel.get(j).ID)){
                            initialListModel.remove(j,1);
                            //向数据库中插入
                            errorHistroy.insert(0,{"ID":String(errorHistroy.count+1),"C1":String(i+1),"C2":"解除","C4":errorName[i],"C3":appSettings.currentUserName,"C5": errorTime})
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
    }

    onErrorCodeChanged: {
        moto.errorCode=errorCode;
        errorMath(0,32,errorCode,errorCode^oldErrorCode);
        if((errorCode)&&(!myErrorDialog.showing))
            myErrorDialog.show();
        if((errorCode===0)&&(errorCode1===0))
        {
            initialListModel.clear()
            initialListModel.append({"ID":0,"C1":"无","C2":"0:00"})
            errorTable.__listView.currentIndex=0;
            errorTable.selection.select(0);
            if(myErrorDialog.showing)
                myErrorDialog.close()
        }
        oldErrorCode=errorCode;
    }
    onErrorCode1Changed: {
        errorMath(32,64,errorCode1,errorCode1^oldErrorCode1);
        if((errorCode1)&&(!myErrorDialog.showing))
            myErrorDialog.show();
        if((errorCode===0)&&(errorCode1===0))
        {
            initialListModel.clear()
            initialListModel.append({"ID":0,"C1":"无","C2":"0:00"})
            errorTable.__listView.currentIndex=0;
            errorTable.selection.select(0);
            if(myErrorDialog.showing)
                myErrorDialog.close()
        }
        oldErrorCode1=errorCode1;
    }
    Material.Dialog{
        id:myErrorDialog
        objectName: "myErrorDialog"
        title: "系统错误"
        property alias errorModel:errorTable.model
        positiveButtonText: (errorCode&0x20000000||errorCode&0x40000000)?qsTr("确认"):qsTr("错误历史信息");
        onAccepted: {
            if(errorCode&0x20000000){//坡口数据表中无数据
                errorCode&=0xdfffffff;
                ERModbus.setmodbusFrame(["W","1","2",String(errorCode&0x0000ffff),String((errorCode&0xffff0000)>>16)]);
            }else if(errorCode&0x40000000){//错误生成焊接规范错误
                errorCode&=0xbfffffff;
                ERModbus.setmodbusFrame(["W","1","2",String(errorCode&0x0000ffff),String((errorCode&0xffff0000)>>16)]);
            }else{
                page.selectedTab=2;
                page2SelectedIndex=1;
            }
        }
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

    MotoDialog{id:moto;settings: appSettings}
    /*日历*/
    Material.Dialog {
        id:datePickerDialog;
        property var dateTimeDialog:new Array(0);
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
        property var timeDialog:new Array(0);
        hasActions: true; contentMargins: 0;
        negativeButtonText:qsTr("取消");positiveButtonText: qsTr("完成");
        Material.TimePicker {
            //存在bug 24小时制时 输出数据多减12
            id:timePicker
            prefer24Hour:true
        }
        onOpened: {
            timePicker.reset();
        }
        onAccepted: {
            var current=new Date().toLocaleDateString(Qt.locale(app.local),"yy/M/d/");
            current= current+timePicker.getCurrentTime().toLocaleTimeString(Qt.locale(app.local),"h/m/s");
            timeDialog=current.split("/")
            console.log(timeDialog)
            ERModbus.setmodbusFrame(["W","510","6"].concat(timeDialog));
            AppConfig.setdateTime(timeDialog);
        }
    }//计算错误报告
    //显示math错误函数
    function showMathError(text){
        mathError.text=text;
        mathError.open();
    }
    Material.Dialog{
        id:mathError
        title: qsTr("生成焊接规范异常");negativeButtonText:qsTr("取消");positiveButtonText: qsTr("确认");
        negativeButton.visible: false;
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
        property int upCount: 0
        function getIndex(name){
            for(var i=0;i<accountmodel.count;i++){
                if(accountmodel.get(i).C2===name)
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
                if(upCount>50){
                    upCount=0;
                    app.sysStatus="空闲态";
                    appSettings.currentUserPassword = "TKSW"
                    appSettings.currentUserName = "TKSW";
                    appSettings.currentUserType = "超级用户";
                    app.superUser=appSettings.currentUserType==="超级用户"?true:false;
                    //发送主控登录标志
                    ERModbus.setmodbusFrame(["W","25","1","3"])
                    close();
                    rejected();
                }
            }
        }
        onAccepted: {
            if(changeuser.positiveButtonEnabled){
                appSettings.currentUserPassword = changeuser.password
                appSettings.currentUserName = changeuser.user;
                appSettings.currentUserType = changeuser.type;
                app.superUser=appSettings.currentUserType==="超级用户"?true:false;
                if(app.sysStatus==="未登录态"){
                    app.sysStatus="空闲态";
                    //发送主控登录标志
                    ERModbus.setmodbusFrame(["W","25","1","3"])
                }
            }
        }
        onRejected: {
            changeuserFeildtext.selectedIndex=getIndex(appSettings.currentUserName);
            changeuser.type=appSettings.currentUserType;
        }
        onOpened: {
            app.visible=true
            if(accountmodel.count>0){
                changeuser.user=appSettings.currentUserName;
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
                        model:accountmodel
                        width:Material.Units.dp(120)
                        onItemSelected:  {
                            password.enabled=true;
                            var data=accountmodel.get(index);
                            changeuser.user=data.C2
                            changeuser.password = data.C3;
                            changeuser.type = data.C4;
                            password.text="";}}
                }
                ListItem.Subtitled{
                    margins: 1
                    text:qsTr("密    码:");
                    height: Material.Units.dp(56)
                    interactive:false
                    secondaryItem: Material.TextField{id:password;
                        placeholderText:qsTr("请输入密码...");
                        characterLimit: 8;
                        width:Material.Units.dp(120)
                        onTextChanged:{
                            if(password.text=== changeuser.password){
                                changeuser.positiveButtonEnabled=true;
                                password.helperText=qsTr("密码正确");}
                            else{
                                password.helperText=qsTr("请输入密码...");
                                changeuser.positiveButtonEnabled=false;}}
                        onHasErrorChanged: {
                            if(password.hasError === true){
                                password.helperText =qsTr( "密码超过最大限制");}
                            else
                                password.helperText=""
                        }
                    }
                }
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
                model: ["汉语","英语"];
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
        theme.accentColor=appSettings.accentColor
        theme.primaryColor=appSettings.primaryColor
        theme.backgroundColor=appSettings.backgroundColor
        theme.tabHighlightColor=appSettings.accentColor
        AppConfig.setleds("all");
        ERModbus.setmodbusFrame(["R","510","6"]);
        /*打开数据库*/
        var res = Material.UserData.getTableJson("AccountTable");
        var i;
        if(res!==-1){
            for( i=0;i<res.length;i++){
                if(i<accountmodel.count)
                    accountmodel.set(i,res[i]);
                else
                    accountmodel.append(res[i]);
            }
        }
        changeuser.show();
        //创建错误历史记录
        Material.UserData.createTable("SysErrorHistroy","ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT");
        res=Material.UserData.getTableJson("SysErrorHistroy","","")
        if(res!==-1){
            for(i=res.length-1;i>=0;i--){
                errorHistroy.append(res[i])
                if(res.length-i>50){
                    break;
                }
            }
        }
        var time=Material.UserData.getSysTime();
        //创建9个表格
        //  for(i=0;i<9;i++){
        //删除列表
        //Material.UserData.deleteTable(grooveStyleName[i]+"列表")
        //创建列表
        //Material.UserData.createTable(grooveStyleName[i]+"列表","Teach TEXT,Weld TEXT,Groove TEXT,Data TEXT,CheckError TEXT,CreatTime TEXT,Creator TEXT,EditTime TEXT,Editor TEXT")
        //清除数据
        //Material.UserData.clearTable(grooveStyleName[i]+"列表","","")
        //重命名列表
        //Material.UserData.renameTable(grooveStyleName[i]+"列表",grooveStyleName[i].replace("型","形")+"列表")
        //初始化列表
        //Material.UserData.insertTable(grooveStyleName[i]+"列表","(?,?,?,?,?,?,?,?,?)",[grooveStyleName[i]+"示教条件",grooveStyleName[i]+"焊接条件",grooveStyleName[i],grooveStyleName[i]+"次列表",grooveStyleName[i]+"错误检测",time,"TKSW",time,"TKSW"])
        //创建坡口条件
        //Material.UserData.createTable(grooveStyleName[i],"ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT")
        //重命名坡口条件
        //Material.UserData.renameTable(grooveStyleName[i],grooveStyleName[i].replace("型","形"))
        //删除坡口限制条件
        // Material.UserData.createTable(grooveStyleName[i]+"限制条件","ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT,C10 TEXT")
        // Material.UserData.deleteTable(grooveStyleName[8]+"限制条件")
        //创建坡口限制条件
        //  Material.UserData.createTable(grooveStyleName[i]+"限制条件","ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT,C10 TEXT")
        //重命名限制条件
        // Material.UserData.renameTable(grooveStyleName[i]+"限制条件",grooveStyleName[i].replace("型","形")+"限制条件")
        // Material.UserData.alterTable(grooveStyleName[i].replace("型","形")+"限制条件","C10 TEXT")
        //删除次列表
        // Material.UserData.deleteTable(grooveStyleName[i]+"次列表")
        //创建次列表
        // Material.UserData.createTable(grooveStyleName[i]+"次列表","Rules TEXT,Limited TEXT,Analyse TEXT,Line TEXT,CreatTime TEXT,Creator TEXT,EditTime TEXT,Editor TEXT")
        //清除次列表
        //Material.UserData.clearTable(grooveStyleName[i]+"次列表","","")
        //初始化次列表
        //Material.UserData.insertTable(grooveStyleName[i]+"次列表","(?,?,?,?,?,?,?,?)",[grooveStyleName[i]+"焊接规范",grooveStyleName[i]+"限制条件",grooveStyleName[i]+"过程分析",grooveStyleName[i]+"焊接曲线",time,"TKSW",time,"TKSW"])
        //重命名次列表
        //  Material.UserData.renameTable(grooveStyleName[i]+"次列表",grooveStyleName[i].replace("型","形")+"次列表")
        //创建过程分析列表
        //  Material.UserData.createTable(grooveStyleName[i]+"过程分析","ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT")
        //重命名次列表
        // Material.UserData.renameTable(grooveStyleName[i]+"过程分析",grooveStyleName[i].replace("型","形")+"过程分析")
        //重命名焊接规范列表
        //  Material.UserData.renameTable(grooveStyleName[i].replace("形","型")+"焊接规范",grooveStyleName[i]+"焊接规范")
        //   }
        //删除用户管理列表
        //   Material.UserData.deleteTable("accountTable");
        //创建限制条件
        Material.UserData.createLimitedTable();
        //创建用户管理列表
        //  Material.UserData.createTable("accountTable","ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT")
        //获取最近的坡口条件 包含名称
        res=Material.UserData.getLastGrooveName(grooveStyleName[currentGroove]+"列表","EditTime")
        if(res!==-1){currentGrooveName=res}
    }
}
