import QtQuick 2.4
import Material 0.1
import Material.Extras 0.1
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0
import WeldSys.WeldMath 1.0
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.2 as Controls

Item {
    id:root
    anchors.fill: parent
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "WeldAnalyse"
    anchors{
        left:parent.left
        right:parent.right
        top:parent.top
        bottom: parent.bottom
        leftMargin:visible?0:Units.dp(250)
    }
    Behavior on anchors.leftMargin{NumberAnimation { duration: 400 ;easing.type:Easing.InQuad }}
    property bool actionEnable:false
    property var groovestyles: [
        qsTr( "平焊单边V型坡口T接头"), qsTr( "平焊单边V型坡口平对接"),  qsTr("平焊V型坡口平对接"),
        qsTr("横焊单边V型坡口T接头"), qsTr( "横焊单边V型坡口平对接"),
        qsTr("立焊单边V型坡口T接头"),  qsTr("立焊单边V型坡口平对接"), qsTr("立焊V型坡口平对接"),
        qsTr("水平角焊")  ]
    property Item message
    property var editData:["","","","","","","","","","","","","","",""]
    property string status:"空闲态"
    property alias weldTableCurrentRow: tableView.currentRow
    property var weldDataModel

    //上次焊接规范名称
    property alias weldRulesName: tableView.headerTitle
    property bool weldTableEx:AppConfig.currentUserType=="SuperUser"?true:false
    //焊缝长度
    property int weldLength: 0

    //当前页面关闭 则 关闭当前页面内 对话框


    TableCard{
        id:tableView
        footerText:"系统当前处于"+status.replace("态","状态。")
        tableRowCount:7
        table.__listView.interactive: status!=="焊接"
        fileMenu: [
            Action{iconName:"awesome/calendar_plus_o";name:"新建"; enabled: false},
            Action{iconName:"awesome/folder_open_o";name:"打开"; enabled: false},
            Action{iconName:"awesome/save";name:"保存";
                onTriggered: {
                    if((typeof(weldRulesName)==="string")&&(weldRulesName!=="")){
                        //清除保存数据库
                        UserData.clearTable(weldRulesName+"过程分析","","");
                        for(var i=0;i<tableView.table.rowCount;i++){
                            //插入新的数据
                            UserData.insertTable(weldRulesName+"过程分析","(?,?,?,?,?,?,?)",[
                                                     tableView.model.get(i).ID,
                                                     tableView.model.get(i).C1,
                                                     tableView.model.get(i).C2,
                                                     tableView.model.get(i).C3,
                                                     tableView.model.get(i).C4,
                                                     tableView.model.get(i).C5,
                                                     tableView.model.get(i).C6,
                                                     tableView.model.get(i).C7])
                        }
                        message.open("过程分析数据已保存。");}
                    else{
                        message.open("过程分析名称格式不符，未保存！")
                    }
                }},
            Action{iconName:"awesome/calendar_times_o";name:"删除";enabled: false}
        ]
        editMenu:[
            Action{iconName:"awesome/plus_square_o";name:"添加";enabled:false},
            Action{iconName:"awesome/edit";name:"编辑";enabled: false},
            Action{iconName:"awesome/copy";name:"复制";enabled:false},
            Action{iconName:"awesome/paste"; name:"粘帖";enabled:false},
            Action{iconName: "awesome/trash_o";  name:"移除" ;enabled:false}]
        inforMenu: [Action{iconName: "awesome/info";  name:"详细信息";enabled: false}]
        funcMenu: [Action{iconName:"awesome/send_o";name:"生成图表";enabled: false}]
        tableData:[
            Controls.TableViewColumn{role: "C1";title:"   焊接\n层道数";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C2";title: "开始时间\n       s";width:Units.dp(120);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C3";title: "结束时间\n       s";width:Units.dp(120);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C4";title: "焊接时间\n       s";width:Units.dp(120);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C5";title: "   焊接\n热输入量";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C6";title: "焊丝消耗\n       Kg";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C7";title: "气体消耗\n       Kg";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter; }
        ]
    }
}


