import QtQuick 2.0
import Material 0.1 as Material
import Material.Extras 0.1
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0
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
    property string  weldRulesName
    //
    property bool superUser
    //示教模式
    property int teachModel: 0
    //示教点数
    property int teachPoint: 0
    //第一点位置
    property bool firstPointLeftOrRight:false

    property bool readSet:false

    property bool conWrite: true

    property int errorCount: 0
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
    //
    signal changeWeldLength(double value);
    //生成焊接规范
    signal changeWeldRules();
    //自动保存生成的焊接规范
    signal saveData();
    //Settings
    MySettings{id:appSettings}
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
                snackBar.open("截屏成功！")
            }else
                snackBar.open("截屏失败！")
        }
    }
    //该页面下1000ms问一次检测参数是否有效
    Timer{ repeat: true;interval:300;
        running:readTime
        onTriggered: {
            if(sysStatus!=="未登录态"){ //登陆以后才支持
                if((readSet)&&(sysStatus==="坡口检测态"))
                    ERModbus.setmodbusFrame(["R","150","10"])
                else if((readSet)&&((sysStatus==="焊接端部暂停态")||(sysStatus==="焊接中间暂停态")))
                    ERModbus.setmodbusFrame(["R","200","1"]);
                else if((readSet)&&(sysStatus==="空闲态")){
                    if(conWrite)
                        ERModbus.setmodbusFrame(["R","99","6"]) //读取设置规范
                }
                else
                    ERModbus.setmodbusFrame(["R","0","5"]); //读取系统状态
                readSet=!readSet;
            }
            ERModbus.setmodbusFrame(["R","25","1"]); //一直读取 系统钥匙开关
        }
    }
    onChangeUserFlagChanged: {
        if((!changeUserFlag)&&(!changeuser.showing)){
            sysStatus="未登录态"
            changeuser.show();
        }
    }

    //计算坡口数据平均值 flag 为1则取均值 否则 取 当前行的值
    function getGrooveAverage(flag){
        var i,j,temp;
        var array=new Array(0);
        //有多少有效示教点数
        var count=app.teachPoint;
        var res;
        if(count>0){
            if(flag){
                for(i=0;i<5;i++){
                    temp=0;
                    for(j=0;j<count;j++){
                        res=grooveTable.get(j);
                        //平对接的时候
                        temp+=Number(i===0?appSettings.connectStyle===1?String(Math.max(Number(res.C1),Number(res.C1)-Number(res.C2))):res.C1
                                     :i===1?res.C2:i===2?res.C3:i===3?res.C4:res.C5);
                    }
                    temp/=j;
                    array.push(String(temp))
                }
                array.push(grooveTable.get(j-1).C6)
                array.push(grooveTable.get(j-1).C7)
            }else{
                res=grooveTable.get(grooveTableIndex);
                array.push(appSettings.connectStyle===1?String(Math.max(Number(res.C1),Number(res.C1)-Number(res.C2))):res.C1)
                array.push(res.C2)
                array.push(res.C3)
                array.push(res.C4)
                array.push(res.C5)
                array.push(res.C6)
                array.push(res.C7)
            }
            if(count>0){
                temp=Number(grooveTable.get(0).C8)
                //找出最远端
                if((count==1)||(!flag)){//只有一点
                    temp=app.weldLength;
                }else{//多点
                    for(j=1;j<count;j++){
                        if(temp<Math.abs(Number(grooveTable.get(j).C8)))
                            temp=Math.abs(Number(grooveTable.get(j).C8));
                    }
                    temp=Math.round(temp);
                    changeWeldLength(temp);
                }
                array.push(String(temp))
            }
            return array;
        }else
            return -1;
    }
    function sendWeldData(){
        if((weldTable.count)&&((weldTableIndex>-1)&&(weldTableIndex<weldTable.count))){
            var index=weldTableIndex;
            var res=weldTable.get(index);
            var floor=res.C1.split("/");
            var z1=Number(res.C16);
            var z2=Number(res.C19);
            if(firstPointLeftOrRight){
                z1=-Math.round(z1);
                z2=-Math.round(z2);
            }
            ERModbus.setmodbusFrame(["W","201","20",
                                     (Number(floor[0])*100+Number(floor[1])).toString(),
                                     res.C2,
                                     res.C3*10,
                                     res.C4*10,
                                     res.C5*10,
                                     res.C6*10,
                                     res.C7*10,
                                     res.C8*10,
                                     res.C9*10,
                                     res.C10*10,
                                     res.C11,
                                     res.C12*10,//层面积
                                     res.C13*10,//单道面积
                                     res.C14*10,//起弧位置偏移
                                     res.C15*10,//起弧
                                     z1.toString(),//起弧
                                     weldTable.count,//总共焊道号
                                     res.C17*10,//起弧位置偏移
                                     res.C18*10,//起弧
                                     z2.toString()//起弧
                                    ]);
        }else
            return -1;
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
            case Qt.Key_F5:
                myErrorDialog.toggle()
                event.accpet=true;
                break;
            case Qt.Key_F6:
                moto.toggle()
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
                    message: snackBar
                    visible: page.selectedTab===0&&page0SelectedIndex===1
                    enabled: sysStatus!=="坡口检测态"
                    onChangeTeachPoint: app.teachPoint=num;
                    onChangeTeachModel: app.teachModel=model;
                    onChangeWeldLength:{ app.weldLength=num; }//console.log(objectName+" weldLength "+num.toString())}
                    onChangeFirstPointLeftOrRight:app.firstPointLeftOrRight=num;
                    onWriteEnableChanged: {//console.log(objectName+"writeEnablechanged "+writeEnable.toString())
                        app.conWrite=!writeEnable;
                    }
                    Connections{
                        target:app
                        onChangeTeachSet:{//此处有bug
                            if(!teachConditionPage.writeEnable){
                                for(var i=2;i<6;i++){
                                    if(Number(value[i])!==teachConditionPage.condition[i-1]){//始终端改变
                                        page.selectedTab=0;
                                        page0SelectedIndex=1;
                                        lastFocusedItem=teachConditionPage;//聚焦lastFocusedItem
                                        lastFocusedItem.forceActiveFocus();
                                        teachConditionPage.selectedIndex=i-1;//切换选中栏
                                        MySQL.setValue(teachConditionPage.objectName,"id",String(i-1),"value",String(value[i]));
                                        if(i<=teachConditionPage.listValueName.length){
                                            //只改变显示不下发数据不存储
                                            teachConditionPage.changeGroupCurrent(Number(value[i]),true);
                                        }else{
                                            teachConditionPage.changeText(Number(value[i]),true);
                                        }
                                        //改变
                                        switch(i){
                                        case 2: break; //始终端检测
                                        case 3: firstPointLeftOrRight=Number(value[3]);break; //第一点位置
                                        case 4:teachPoint=Number(value[4]);break; //console.log(objectName+"teachPoint"+teachPoint.toString());break; //示教点数
                                        case 5:weldLength=Number(value[5]); break; //焊接长度
                                        }
                                    }
                                }
                            }
                        }
                        onChangeWeldLength:{//改变焊接长度
                            teachConditionPage.selectedIndex=4;
                            teachConditionPage.changeText(value,false);
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
                            if(Number(value[0])!==weldConditionPage.condition[1]){//头部摇动
                                page.selectedTab=0;
                                page0SelectedIndex=2;
                                lastFocusedItem=weldConditionPage;//聚焦lastFocusedItem
                                lastFocusedItem.forceActiveFocus();
                                weldConditionPage.selectedIndex=1;
                                //只改变显示不下发数据不存储
                                weldConditionPage.changeGroupCurrent(Number(value[0]),false);
                                //存储数据
                                MySQL.setValue(teachConditionPage.objectName,"id",1,"value",String(value[0]));
                                snackBar.open(weldConditionPage.listName[1]+"切换为"+weldConditionPage.listValueName[1][Number(value[0])]+"。")
                            }
                        }
                    }
                    Connections{
                        target: grooveConditionPage
                        onChangeV:{
                            if(index==0){//!v
                                weldConditionPage.changeEnable(3,1,true);
                            }else{//V
                                weldConditionPage.changeEnable(3,1,false);
                                weldConditionPage.selectedIndex=3;
                                //改变显示同时下发数据
                                weldConditionPage.changeGroupCurrent(0,false);
                            }
                        }
                    }
                }
                GrooveCheck{
                    id:grooveCheckPage
                    visible: page.selectedTab===0&&page0SelectedIndex===3
                    status: app.sysStatus;message:snackBar
                    model:grooveTable
                    settings: appSettings
                    //状态为坡口检测态时不能更改 数据表
                    onStatusChanged: table.enabled=app.sysStatus!=="坡口检测态"?true:false
                    onCurrentRowChanged: app.grooveTableIndex=currentRow
                    currentGroove: app.currentGroove
                    //生成焊接规范
                    onGetWeldRules:{
                        //先切换界面
                        page.selectedTab=1;
                        app.page1SelectedIndex=0;
                        //生成规范前先更新限制条件
                        limitedConditionPage.setLimited();
                        //计算坡口条件
                        var temp1 =getGrooveAverage(app.sysStatus==="坡口检测完成态"?true:false);
                        //计算焊接规范
                        WeldMath.setGrooveRules(temp1===-1?snackBar.open("坡口参数数据不存在！"):temp1);
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
                        onChangeWeldRules:{
                            grooveCheckPage.getWeldRules();
                        }
                        onCurrentGrooveChanged:{
                            grooveCheckPage.grooveNameList=app.grooveStyleName[app.currentGroove]+"坡口条件列表";
                            grooveCheckPage.getLastGrooveName();
                        }
                        onSaveData:{
                            grooveCheckPage.save();
                        }
                    }
                }
                LimitedCondition{
                    id:limitedConditionPage
                    swingWidthOrWeldWidth: appSettings.weldStyle===1||appSettings.weldStyle===3?false:true
                    visible: page.selectedTab===0&&(page0SelectedIndex===4)&&(app.superUser)
                    currentUserName: appSettings.currentUserName
                    message: snackBar
                    Connections{
                        target: weldConditionPage
                        onChangeNum:{limitedConditionPage.limitedString=value;
                            limitedConditionPage.limitedRulesNameList= app.grooveStyleName[app.currentGroove]+"限制条件列表"+limitedConditionPage.limitedString;
                            limitedConditionPage.getLastRulesName();
                        }
                    }
                    Connections{
                        target: app
                        onCurrentGrooveChanged:{
                            if(limitedConditionPage.limitedString!==""){
                                //更新焊接规范列表
                                limitedConditionPage.limitedRulesNameList= app.grooveStyleName[app.currentGroove]+"限制条件列表"+limitedConditionPage.limitedString;
                                //更新焊接规范
                                limitedConditionPage.getLastRulesName();
                            }
                        }
                    }
                }
                GrooveCondition{
                    id:grooveConditionPage
                    settings: appSettings
                    visible: page.selectedTab===0&&page0SelectedIndex===0
                    message: snackBar
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
                    message:snackBar
                    weldTableEx: app.superUser
                    currentUserName: appSettings.currentUserName
                    onChangeWeldData: app.sendWeldData();
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
                        onChangeWeldIndex:{//改变索引
                            if(index<weldTable.count){
                                weldDataPage.currentRow=index;
                                weldDataPage.selectIndex(index);
                            }else
                                snackBar.open("索引条目超过模型最大值！");
                        }
                        onCurrentGrooveChanged:{
                            //更新焊接规范列表
                            weldDataPage.weldRulesNameList=app.grooveStyleName[app.currentGroove]+"焊接规范列表";
                            //更新焊接规范
                            weldDataPage.getLastweldRulesName();
                        }
                        onSaveData:{
                            weldDataPage.save();
                        }
                    }
                    Component.onCompleted: { //加载的时候 加载数据表格
                        //更新焊接规范列表
                        weldDataPage.weldRulesNameList=app.grooveStyleName[app.currentGroove]+"焊接规范列表";
                        //
                        weldDataPage.updateEx=sysStatus==="空闲态";
                        //更新焊接规范
                        weldDataPage.getLastweldRulesName();
                        //
                        weldDataPage.updateEx=true;
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
                }
                SysErrorHistroy{
                    id:sysErrorHistroyPage
                    model:errorHistroy
                    visible: page.selectedTab===2&&page2SelectedIndex===1
                    status:sysStatus
                    footerText: "总计: "+String(errorHistroy.count)+" 条历史记录。"
                    onRemoveall:{
                        errorCount=0;//清空
                        errorHistroy.clear();
                        //清楚数据表格
                        snackBar.open("错误历史记录已被清空！");
                    }
                    onRemove:{
                        if(currentRow!==-1){
                            var index=currentRow;

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
        if(sysStatus==="空闲态"){
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
        }else if(sysStatus==="坡口检测态"){
            //高压接触传感
            snackBar.open("坡口检测中，高压输出，请注意安全！")
            //切换指示灯
            AppConfig.setleds("start");
            //切换界面
            page.selectedTab=0;
            //切小页面
            app.page0SelectedIndex=3;
            //不选中任何一行
            changeGrooveTableIndex(-1);
            //全自动则清除
            if((teachModel===0)&&(appSettings.weldStyle!==3)){
                //清除坡口数据
                grooveTable.clear();
            }else {//半自动 手动 检测数据表是否有效
                if(grooveTable.count===0){
                    //写入错误
                    errorCode|=0x20000000;
                    ERModbus.setmodbusFrame(["W","1","2",String(errorCode&0x0000ffff),String((errorCode&0xffff0000)>>16)]);
                }else{//根据示教点数 复制第一个数据表格内容创建 示教点数个 坡口参数
                    if(grooveTable.count>1)//删除多余点保留第一点
                        grooveTable.remove(1,grooveTable.count-1);
                    grooveTable.setProperty(0,"ID","1");
                    for(var i=1;i<app.teachPoint;i++){
                        grooveTable.append(grooveTable.get(0))
                        grooveTable.setProperty(i,"ID",String(i+1));
                    }
                }
            }
        }else if(sysStatus==="坡口检测完成态"){
            //获取坡口长度
            ERModbus.setmodbusFrame(["R","104","1"])
            //检测完成
            snackBar.open("坡口检测完成！正在计算相关焊接规范。")
            //切换指示灯为准备好
            AppConfig.setleds("ready");
            page.selectedTab=1;
            app.page1SelectedIndex=0;
            changeWeldIndex(-1);
            weldTableIndex=-1;
        }else if(sysStatus==="焊接态"){
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
        }else if(sysStatus==="焊接端部暂停态"){
            //焊接暂停
            AppConfig.setleds("ready");
            //系统焊接中
            snackBar.open(weldFix?"焊接系统修补焊接端部暂停。":"焊接系统焊接端部暂停。")
            //切换到 表格
            app.page1SelectedIndex=0;
            //切换到 焊接分析页面
            page.selectedTab=1;
        }else if(sysStatus==="停止态"){
            //修复修补焊接时 数据下发不正常的问题
            weldFix=false;
            //系统停止
            AppConfig.setleds("stop");
            //焊接系统停止
            snackBar.open("焊接系统停止。")
            //将状态切换成0
            ERModbus.setmodbusFrame(["W","0","1","0"]);
        }else if(sysStatus==="焊接中间暂停态"){
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
            var temp;
            if(frame[0]!=="Success"){
                MathError=1;
                MathError<<=25;
                errorCode=MathError;
            }else{
                //查询系统状态
                if(frame[1]==="0"){
                    if((sysStatus==="坡口检测态")&&(grooveTableIndex<(app.teachPoint-1))){ //如果当前检测的坡口数据与实际的不符合时则不更新坡口状态
                        if(frame[2]==="6"){
                            sysStatus=sysStatusList[6];
                        }
                    }else
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
                }else if((frame[1]==="150")&&(sysStatus==="坡口检测态")){
                    //console.log(frame);
                    //间隔跳示教点允许删除示教点操作尚未加入
                    if(frame[2]!=="0"){
                        var num=Number(frame[2])-1;
                        //如果当前选择行和 上传数据行不一至则更新数据
                        if((num!==app.grooveTableIndex)&&(num>app.grooveTableIndex)){
                            if(teachModel===0){
                                if(appSettings.weldStyle!==3){
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

                                }else{//角焊需要设置脚长1 脚长2
                                    grooveTable.setProperty(num,"ID",frame[2])
                                    grooveTable.setProperty(num,"C3",(Number(frame[5])/10).toString()) //根部
                                    grooveTable.setProperty(num,"C4",(Number(frame[6])/10).toString()) //角1
                                    grooveTable.setProperty(num,"C5",(Number(frame[7])/10).toString()) //角2
                                }
                            }else if(teachModel===1){
                                grooveTable.setProperty(num,"ID",frame[2])
                                if((appSettings.fixHeight)&&(appSettings.weldStyle!=3)){//水平角焊时不替换脚长1
                                    grooveTable.setProperty(num,"C1",(Number(frame[3])/10).toString())
                                }
                                if(appSettings.fixGap){
                                    grooveTable.setProperty(num,"C3",(Number(frame[5])/10).toString())
                                }
                                if(appSettings.fixAngel){
                                    grooveTable.setProperty(num,"C4",(Number(frame[6])/10).toString())
                                    grooveTable.setProperty(num,"C5",(Number(frame[7])/10).toString())
                                }
                                if((appSettings.connectStyle!==0)&&(appSettings.weldStyle!==3)) {//只有在非T接头和水平角焊时不替换
                                    grooveTable.setProperty(num,"C2",String(Number(frame[4])/10))
                                }
                            }
                            else{
                                grooveTable.setProperty(num,"C3",(Number(frame[5])/10).toString())
                            }
                            //只有在T接头非水平角焊时更改脚长
                            if((appSettings.connectStyle===0)&&(appSettings.weldStyle!==3)){
                                var tempNum=Number(grooveTable.get(num).C2);
                                if((isNaN(tempNum))||(tempNum===0))//如果是非数或为0 则替换 成0.3倍板厚
                                    grooveTable.setProperty(num,"C2",String(Math.round(Number(frame[3])*0.3)/10))
                            }
                            //对掉一下xz坐标 对比Z行走轴坐标转换 刘斌那边行走轴 往左走为负 往右走为正 即只需要调换往左走的坐标变为 正
                            var temp1=(Number(frame[8])|(Number(frame[9])<<16))/10;
                            grooveTable.setProperty(num,"C8",String(app.firstPointLeftOrRight?-temp1:temp1))
                            grooveTable.setProperty(num,"C7",String(Number(frame[10])/10))
                            grooveTable.setProperty(num,"C6",String(Number(frame[11])/10))
                            changeGrooveTableIndex(num);
                        }
                    }
                }else if((frame[1]==="104")&&(sysStatus=="坡口检测完成态")){
                    //如果坡口参数里面有数据 则进行计算数据
                    if(grooveTable.count!==0){
                        changeWeldRules();//生成焊接规范
                    }
                }else if((frame[1]==="10")&&(sysStatus==="焊接态")){
                    //记录焊接时间（焊接长度）
                }else  if((frame[1]==="200")&&((sysStatus==="焊接端部暂停态")||(sysStatus==="焊接中间暂停态"))){
                    if((frame[2]!==weldTableIndex.toString())&&(!weldFix)){
                        if(frame[2]!=="200"){
                            //当前焊道号与实际焊道号不符 更换当前焊道
                            if(weldTable.count>=Number(frame[2])){
                                //Index
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
                            sendWeldData();
                        }else{
                            //焊接表格内无数据
                            errorCode|=0x80000000;
                            ERModbus.setmodbusFrame(["W","1","2",String(errorCode&0x0000ffff),String((errorCode&0xffff0000)>>16)]);
                        }
                        return;
                    }else if ((weldFix)&&(frame[2]!=="200")){
                        weldFix=false;
                    }
                }else if(frame[1]==="510"){
                    if(!readTime){
                        //读取系统时间
                        ERModbus.setmodbusFrame(["R","510","6"])
                    }else{
                        //console.log(frame);
                        AppConfig.setdateTime(frame.slice(2,8));
                    }
                    readTime=true;
                }else if(frame[1]==="99"){//读取设置
                    changeTeachSet(frame.slice(2,8))
                }else if(frame[1]==="1022"){
                    moto.currentTravelPoint=String((Number(frame[2])|(Number(frame[3])<<16))/10);
                    moto.currentSwingPoint=String(Number(frame[4])/10);
                    moto.currentAvcPoint=String(Number(frame[5])/10);
                    moto.currentRockPoint=String(Number(frame[7])/10)+"度 "+String(Number(frame[6])/10);
                }else if(frame[1]==="25"){
                    if(Number(frame[2])===0){
                        changeUserFlag=false; //钥匙开关被带走
                    }else
                        changeUserFlag=true;
                }
            }
        }
    }
    // 链接 weldmath
    Connections{
        target: WeldMath
        onWeldRulesChanged:{
            //确保数组数值正确
            if(status==="Successed"){
                weldTable.set(Number(value.ID)-1,value)
            }else if(status==="Clear"){
                weldTableIndex=-1;
                changeWeldIndex(-1);
                weldTable.clear();
            }else if(status==="Finish"){
                snackBar.open("焊接规范已生成！")
                //选中焊接规范表格的第一行数据
                if(weldTable.count){
                    //先改变 Table 然后在改变App
                    changeWeldIndex(0);
                    //下发第一条规范
                    weldTableIndex=weldTable.count;
                }else{
                    errorCode|=0x40000000;
                    ERModbus.setmodbusFrame(["W","1","2",String(errorCode&0x0000ffff),String((errorCode&0xffff0000)>>16)]);
                }
                // 切换状态为端部暂停
                if(sysStatus==="坡口检测完成态"){
                    //保存数据
                    saveData();
                    //下发端部暂停态
                    ERModbus.setmodbusFrame(["W","0","1","5"]);
                }
            }else{
                //输出错误
                snackBar.open(status)
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
                                                                                        sysStatus==="焊接态"?"user/MAG":
                                                                                                           sysStatus==="坡口检测完成态"?"awesome/step_forward":
                                                                                                                                  sysStatus==="停止态"?"awesome/stop": "awesome/pause"
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
                    if((inputPanel.visible)&&(InputContext.inputItem.hasOwnProperty("inputMethodHints"))){
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
    function errorMath(Start,Length,MathError,MathXor){
        //获取时间
        var errorTime=MyMath.getSysTime();
        for(var i=Start;i<Length;i++){
            //如果变化存在
            if(MathXor&0x0001){
                errorCount++;//记录条目增加
                //错误存在
                if(MathError&0x0001){
                    //如果无错误存在则 移除无错误
                    if(initialListModel.count){
                        if(initialListModel.get(0).ID===0)
                            initialListModel.remove(0,1);}
                    initialListModel.insert(0,{"ID":Number(i+1),"C1":errorName[i],"C2":errorTime })
                    if(errorCount>50){//超过50条则自动删除最后一条且自动移动ID号码
                        for(var k=0;k<50;k++){
                            errorHistroy.setProperty(k,"ID",String(Number(errorHistroy.get(k).ID)-1))//所有序号递减
                        }
                        errorHistroy.remove(49,errorHistroy.count-49);
                        errorCount=50;
                    }
                    errorHistroy.insert(0,{"ID":String(errorCount>50?50:errorCount),"C1":String(i+1),"C2":"发生","C4":errorName[i],"C3":appSettings.currentUserName,"C5": errorTime})
                }else{
                    for(var j=0;j<initialListModel.count;j++){
                        //如果列表里面有则移除 解除错误
                        if((i+1)===(initialListModel.get(j).ID)){
                            initialListModel.remove(j,1);
                            if(errorCount>50){//超过50条则自动删除最后一条且自动移动ID号码
                                for(k=0;k<50;k++){
                                    errorHistroy.setProperty(k,"ID",String(Number(errorHistroy.get(k).ID)-1))//所有序号递减
                                }
                                errorHistroy.remove(49,errorHistroy.count-49);//移除多余的项
                                errorCount=50;//变更总表
                            }
                            //向数据库中插入
                            errorHistroy.insert(0,{"ID":String(errorCount>50?50:errorCount),"C1":String(i+1),"C2":"解除","C4":errorName[i],"C3":appSettings.currentUserName,"C5": errorTime})
                            if(errorTable.__listView.currentIndex>=initialListModel.count){
                                errorTable.__listView.currentIndex=j;
                                errorTable.selection.select(j);
                            }
                        }
                    }
                }
                //插入数据表格
            }
            MathXor>>=1;
            MathError>>=1;
        }
        return true;
    }
    onErrorCodeChanged: {
        moto.errorCode=errorCode;
        if( errorMath(0,32,errorCode,errorCode^oldErrorCode)){
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
        }
        oldErrorCode=errorCode;
    }
    onErrorCode1Changed: {
        if(errorMath(32,64,errorCode1,errorCode1^oldErrorCode1)){
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
        }
        oldErrorCode1=errorCode1;
    }
    Material.Dialog{
        id:myErrorDialog
        objectName: "myErrorDialog"
        title: "系统错误"
        property alias errorModel:errorTable.model
        positiveButtonText: qsTr("确认");
        onAccepted: {
            if(errorCode&0x60000000){//两种错误一起清 顺带把errorCode 也清掉
                errorCode&=0x9fffffff;
                ERModbus.setmodbusFrame(["W","1","2",String(errorCode&0x0000ffff),String((errorCode&0xffff0000)>>16)]);
            }else if(errorCode&0x20000000){//坡口数据表中无数据
                errorCode&=0xdfffffff;
                ERModbus.setmodbusFrame(["W","1","2",String(errorCode&0x0000ffff),String((errorCode&0xffff0000)>>16)]);
            }else if(errorCode&0x40000000){//错误生成焊接规范错误
                errorCode&=0xbfffffff;
                ERModbus.setmodbusFrame(["W","1","2",String(errorCode&0x0000ffff),String((errorCode&0xffff0000)>>16)]);
            }else if(errorCode&0x80000000){//错误焊接规范表格内无数据
                errorCode&=0x7fffffff;
                ERModbus.setmodbusFrame(["W","1","2",String(errorCode&0x0000ffff),String((errorCode&0xffff0000)>>16)]);
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

    MotoDialog{id:moto;settings: appSettings;errorCode: app.errorCode
        Timer{ interval:400;running:visible;repeat: true;
            onTriggered:{
                ERModbus.setmodbusFrame(["R","1022","6"]);  //获取各电机当前位置
            }
        }
    }
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
            //console.log(dateTimeDialog);
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
            //prefer24Hour:true
        }
        onOpened: {
            timePicker.reset();
        }
        onAccepted: {
            var current=new Date().toLocaleDateString(Qt.locale(app.local),"yy/M/d/");
            current=current+timePicker.getCurrentTime().toLocaleTimeString(Qt.locale(app.local),"h/m/s");
            timeDialog=current.split("/")
            //console.log(timeDialog)
            ERModbus.setmodbusFrame(["W","510","6"].concat(timeDialog));
            AppConfig.setdateTime(timeDialog);
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
        title:!changeUserFlag?qsTr("用户登录(请插入钥匙并打开)"):qsTr("用户登录");
        negativeButtonText:qsTr("取消");positiveButtonText:qsTr("确定");
        positiveButtonEnabled:false;
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
                    changeUserFlag=true;
                    //发送主控登录标志
                    ERModbus.setmodbusFrame(["W","25","1","2"])
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
                if(changeUserFlag){//如果插入钥匙
                    app.sysStatus="空闲态";
                    //发送主控登录标志
                    ERModbus.setmodbusFrame(["W","25","1","2"])
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
            if(changeUserFlag){
                password.placeholderText="请输入密码..."
                password.helperText=""
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
                        readOnly: !changeUserFlag //钥匙插入后可以输入密码
                        onReadOnlyChanged: {
                            if(readOnly) {
                                password.placeholderText=qsTr("禁止登录！");
                            }else
                                password.placeholderText=qsTr("请输入密码...")
                        }
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
    }/*
    //初始化所有数据
    function initAllTable(){
        grooveTable.clear()//删除坡口参数
        weldTable.clear()//删除焊接数据表格
        var res,j;
        snackBar.open("系统初始化进度0%！请耐心等待~");
        var tableName=["坡口条件列表","焊接规范列表","限制条件列表_药芯碳钢_脉冲无_CO2_12","限制条件列表_实芯碳钢_脉冲无_CO2_12","限制条件列表_实芯碳钢_脉冲无_MAG_12","限制条件列表_实芯碳钢_脉冲有_MAG_12"]
        for(var i=0;i<9;i++){
            for(var k=0;k<tableName.length;k++){
                res= Material.UserData.getTableJson(grooveStyleName[i]+tableName[k]);
                if(res!==-1){
                    for(j=0;j<res.length;j++){
                        if(j===0){//默认表格只是清除
                            Material.UserData.clearTable(res[0].Name,"","");
                        }else{//删除列表
                            Material.UserData.deleteTable(res[j].Name)
                        }
                    }
                }
                Material.UserData.clearTable(grooveStyleName[i]+tableName[k],"","");//清除列表
                Material.UserData.insertTable(grooveStyleName[i]+tableName[k],"(?,?,?,?,?)",[res[0].Name,res[0].CreatTime,"TKSW",res[0].EditTime,"TKSW"])//插入新的列表
            }
            snackBar.open("系统初始化进度"+String((i+1)*10)+"%！请耐心等待~");
        }
    }*/
    Connections{
        target: MySQL
        onMySqlChanged:{
            if(tableName==="AccountTable"){
                for(var i=0;i<jsonObject.length;i++){
                    if(i<accountmodel.count)
                        accountmodel.set(i,jsonObject[i]);
                    else
                        accountmodel.append(jsonObject[i]);
                }
            }
        }
        onMySqlStatusChanged:{
            if(!status)
                snackBar.open("操作"+tableName+"失败！")
        }
    }
    Component.onCompleted: {
        theme.accentColor=appSettings.accentColor
        theme.primaryColor=appSettings.primaryColor
        theme.backgroundColor=appSettings.backgroundColor
        theme.tabHighlightColor=appSettings.accentColor
        AppConfig.setleds("all");
        ERModbus.setmodbusFrame(["R","510","6"]);
        ERModbus.setmodbusFrame(["W","98","1","0"]);
        ERModbus.setmodbusFrame(["W","127","1","0"]);
        MySQL.getJsonTable("AccountTable")
        sysStatus="未登录态";//系统处于未登陆状态
        changeuser.show();
    }
}
