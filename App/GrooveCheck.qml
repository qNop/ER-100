import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.2 as Controls
import QtQuick.Window 2.2
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0
import WeldSys.WeldMath 1.0
import QtQuick.Layouts 1.1
/*
  * tableview 选中当前行时必需 要更改__listview.currentrow 然后在选择要选择的行单纯的只选择 选中的行无效
  * 能不使用 ProgressCircle 不要使用 太耗费cpu 能够达到30% 使用率
*/
FocusScope{
    id:root
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "GrooveCheck"
    anchors{
        left:parent.left
        right:parent.right
        top:parent.top
        bottom: parent.bottom
        leftMargin:visible?0:Units.dp(250)
    }
    property Item message
    Behavior on anchors.leftMargin{NumberAnimation { duration: 400 }}
    /*坡口列表*/
    property var groovestyles: [
        qsTr( "平焊单边V型坡口T接头"), qsTr( "平焊单边V型坡口平对接"),  qsTr("平焊V型坡口平对接"),
        qsTr("横焊单边V型坡口T接头"), qsTr( "横焊单边V型坡口平对接"),
        qsTr("立焊单边V型坡口T接头"),  qsTr("立焊单边V型坡口平对接"), qsTr("立焊V型坡口平对接"),
        qsTr("水平角焊") ]
    property var grooveStyleEnglish: [];
    property var editData:["","","","","","",""]
    property bool actionEnable:false
    property string status:"空闲态"
    property string grooveLength:"0"
    property alias grooveModel: tableview.model
    property alias selectedIndex:tableview.currentRow
    property list<Action> actions:[
        Action{iconName:"awesome/folder_open_o";onTriggered: open.show();name:"打开";hoverAnimation:true;summary: "F1"},
        Action{iconName:"awesome/save";onTriggered: save.show();name:"保存";hoverAnimation:true;summary: "F2"},
        Action{iconName:"awesome/file_text_o";
            onTriggered: add.show();
            name:"新建"
            hoverAnimation:true;summary: "F3"
        },Action{iconName:"awesome/calendar_times_o";
            onTriggered: {
            }
            name:"删除"
            hoverAnimation:true;summary: "F4"
        },
        Action{iconName:"awesome/sticky_note_o";
            onTriggered: {

            }
            name:"信息"
            hoverAnimation:true;summary: "F5"
        },
        Action{iconName:"awesome/stack_overflow";
            onTriggered: {
                if(dropDown.showing)
                    dropDown.close();
                else{
                    dropDown.open(tableview.__listView.currentItem,-5,0);
                }
            }
            name:"更多"
            hoverAnimation:true;summary: "F6"
        }
    ]
    property list<Action> dropDownActions:[
        Action{iconName:"awesome/edit";onTriggered: edit.show();name:"编辑";
        },
        Action{iconName:"awesome/paste";name:"复制";enabled:root.actionEnable
            onTriggered: {
                for(var i=0;i<7;i++){
                    switch(i){
                    case 0:editData[0]=tableview.model.get(selectedIndex).ID; break;
                    case 1:editData[1]=tableview.model.get(selectedIndex).C1; break;
                    case 2:editData[2]=tableview.model.get(selectedIndex).C2; break;
                    case 3:editData[3]=tableview.model.get(selectedIndex).C3; break;
                    case 4:editData[4]=tableview.model.get(selectedIndex).C4; break;
                    case 5:editData[5]=tableview.model.get(selectedIndex).C5; break;
                    case 6:editData[6]=tableview.model.get(selectedIndex).C6; break;
                    }
                }
                message.open("已复制。");
            }},
        Action{iconName:"awesome/copy"; name:"粘帖";enabled:root.actionEnable
            onTriggered: {
                tableview.model.insert(selectedIndex,
                                       {   "ID":editData[0],
                                           "C1":editData[1],"C2":editData[2],
                                           "C3":editData[3],"C4":editData[4],
                                           "C5":editData[5],"C6":editData[6]})
                tableview.__listView.currentIndex=selectedIndex;
                tableview.selection.__selectOne(selectedIndex);
                message.open("已粘帖。");
            }
        },
        Action{iconName: "awesome/trash_o";  name:"删除" ;enabled:root.actionEnable
            onTriggered: {
                if(tableview.rowCount===1)
                    tableview.model.set(0,{"ID":"","C1":"","C2":"","C3":"","C4":"","C5":"","C6":""})
                else
                    tableview.model.remove(selectedIndex);
                message.open("已删除。");
            }
        },
        Action{iconName:"awesome/send_o";
            onTriggered:{
                WeldMath.setGrooveRules([
                                            tableview.model.get(0).C1,
                                            tableview.model.get(0).C2,
                                            tableview.model.get(0).C3,
                                            tableview.model.get(0).C4,
                                            tableview.model.get(0).C5]);
                message.open("生成焊接规范。");
            }
            hoverAnimation:true;
            enabled: true//root.actionEnable
            name:"生成规范"
        }
    ]
    Keys.onPressed: {
        switch(event.key){
        case Qt.Key_F1:
            //  open.show();
            event.accepted=true;
            break;
        case Qt.Key_F2:
            // save.show();
            event.accepted=true;
            break;
        case Qt.Key_F3:
            //  add.show();
            event.accepted=true;
            break;
        case Qt.Key_F4:
            event.accepted=true;
            break;
        case Qt.Key_Down:
            tableview.__listView.incrementCurrentIndex();
            event.accept=true;
            break;
        case Qt.Key_Up:
            tableview.__listView.decrementCurrentIndex();
            event.accept=true;
            break;
        }
    }
    //当前页面关闭 则 关闭当前页面内 对话框
    onVisibleChanged: {
        if(visible==false){
            if(edit.showing) edit.close();
            if(open.showing) open.close();
            if(save.showing) save.close();
            if(add.showing) add.close();
        }
    }
    onSelectedIndexChanged: {
        if(selectedIndex<tableview.rowCount){
            console.log(selectedIndex);
            tableview.__listView.currentIndex=selectedIndex;
            tableview.selection.__selectOne(selectedIndex);
        }
    }
    Card{
        anchors{left:parent.left;right:parent.right;bottom: parent.bottom;top:parent.top;margins: Units.dp(12)}
        elevation: 2
        Item{
            id:groovepresettitle
            anchors.top:parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height:Units.dp(64);
            Label{
                id:groovepresetlabel
                anchors.left: parent.left
                anchors.leftMargin: Units.dp(24)
                anchors.verticalCenter: parent.verticalCenter
                text:groovestyles[AppConfig.currentGroove]+"坡口参数"
                style:"subheading"
                color: Theme.light.shade(0.87)
                wrapMode: Text.WordWrap
                width: Units.dp(300)
            }
            Row{       
                anchors.right: parent.right
                anchors.rightMargin: Units.dp(24)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Units.dp(12);
                Repeater{
                    id:test
                    model:actions.length
                    delegate:View{
                        width: row.width
                        enabled: actions[index].enabled
                        opacity: enabled ? 1 : 0.6
                        radius: Units.dp(6)
                        Ink{id:ink
                            anchors.fill: parent
                            onClicked: actions[index].triggered();
                            enabled: actions[index].enabled

                        }
                        Tooltip{
                            text:actions[index].summary
                            mouseArea: ink
                        }
                        Row{
                            id:row
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Units.dp(4);
                            Icon{
                                source:actions[index].iconSource
                                color: Theme.accentColor
                                size: Units.dp(27)
                            }
                            Label{
                                style: "button"
                                text:actions[index].name;
                            }
                        }
                    }
                }
            }
        }
        Controls.TableView{
            id:tableview
            //不是隔行插入色彩
            alternatingRowColors:false
            anchors{
                left:parent.left
                leftMargin: Units.dp(5)
                right:parent.right
                rightMargin: Units.dp(5)
                top:groovepresettitle.bottom
                bottom:footer.top
            }
            //显示表头
            headerVisible:true
            __listView.add:Transition{
                NumberAnimation { properties: "x"; from:tableview.width-100;duration: 500 }
            }
            __listView.removeDisplaced:Transition{
                NumberAnimation { properties: "y";duration: 500 }
            }
            //Tableview样式
            style:TableStyle{}
            //选择模式 单选
            selectionMode:Controls.SelectionMode.SingleSelection
            Controls.ExclusiveGroup{  id:checkboxgroup }
            ThinDivider{anchors.bottom:tableview.bottom;color:Palette.colors["grey"]["500"]}
            Controls.TableViewColumn{role:"ID";title: "No.";width: Units.dp(120);movable:false;resizable:false
                delegate: Item{
                    anchors.fill: parent
                    CheckBox{
                        id:checkbox;anchors.left: parent.left;anchors.leftMargin: Units.dp(16);
                        anchors.verticalCenter: parent.verticalCenter;
                        checked: styleData.selected;
                        exclusiveGroup:checkboxgroup;
                        visible:label.text!==""?true:false;
                    }
                    Label{
                        id:label
                        anchors.left: checkbox.right
                        anchors.leftMargin:  Units.dp(32)
                        anchors.verticalCenter: parent.verticalCenter
                        text:styleData.value
                        style:"body1"
                        color: Theme.light.shade(0.87)
                    }
                }
            }
            Controls.TableViewColumn{  role:"C1"; title: "板厚 δ\n (mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter}
            Controls.TableViewColumn{  role:"C2"; title: "板厚差 e\n   (mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter}
            Controls.TableViewColumn{  role:"C3"; title: "间隙 b\n (mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter}
            Controls.TableViewColumn{  role:"C4"; title: "角度 β1\n  (deg)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter}
            Controls.TableViewColumn{  role:"C5"; title: "角度 β2\n  (deg)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter}
            Controls.TableViewColumn{  role:"C6"; title: "中心线 \n X(mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter}
            Controls.TableViewColumn{  role:"C7"; title: "中心线 \n Y(mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter}
            Controls.TableViewColumn{  role:"C8"; title: "中心线 \n Z(mm)";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter}
            Keys.onPressed: {
                var diff = event.key ===Qt.Key_Right ? 50 : event.key === Qt.Key_Left ? -50 :  0
                if(diff !==0){
                    tableview.__horizontalScrollBar.value +=diff;
                    event.accept=true;
                }
            }
            Component.onCompleted: {
                selectedIndex=0;
                tableview.selection.__selectOne(selectedIndex);
            }
        }
        Item{
            id:footer
            height: Units.dp(47)
            anchors{
                left:parent.left
                right:parent.right
                bottom: parent.bottom
            }
            Row{
                anchors{
                    left:parent.left
                    leftMargin: Units.dp(24)
                    verticalCenter: parent.verticalCenter
                }
                spacing: Units.dp(16)
                Label{
                    id:status
                    text:root.status==="坡口检测态"?"坡口检测中，高压输出！注意安全！":""
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Label{
                id:footerLabel
                anchors.right: parent.right
                anchors.rightMargin: Units.dp(24)
                anchors.verticalCenter: parent.verticalCenter
                text:"总计："+ tableview.rowCount  +" 点"
            }
        }
    }
    MenuDropdown{
        id:dropDown
        //actions: dropDownActions
    }
    Dialog{
        id:save
        title: qsTr("坡口参数保存")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        globalMouseAreaEnabled:false
        dialogContent:Row{
            spacing: Units.dp(16)
            Icon {
                name: "awesome/file_text_o"
            }
            TextField{
                id:filename
                placeholderText: groovepresetlabel.text
            }
        }
        onAccepted: {
            //保存文件
            //            UserData.createTable(filename.text,"(ID INT NOT NULL PRIMARY KEY,C1 INT,C2 INT,C3 INT,C4 INT,C5 INT,C6 INT)");
            //            for(var i=0;i<tableview.rowCount;i++){
            //                UserData.insertTable(filename.text,"(?,?,?,?,?,?,?)",[
            //                                         Number(tableview.model.get(i).ID),
            //                                         Number(tableview.model.get(i).C1),
            //                                         Number(tableview.model.get(i).C2),
            //                                         Number(tableview.model.get(i).C3),
            //                                         Number(tableview.model.get(i).C4),
            //                                         Number(tableview.model.get(i).C5),
            //                                         Number(tableview.model.get(i).C6)])
            //            }
        }
    }
    Dialog{
        id:open
        title:qsTr("打开坡口参数")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
    }
    Dialog{
        id:add
        title: qsTr("新建坡口")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        dialogContent:Row{
            spacing: Units.dp(16)
            Icon {
                name: "awesome/file_text_o"
            }
            TextField{
                placeholderText: "请输入坡口名称。。"
            }
        }
        onAccepted: {
            console.log("model changed")
            console.log(initlist.count);
            tableview.model=initlist;
        }
    }

    Dialog{
        id:edit
        title: qsTr("编辑坡口参数")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        globalMouseAreaEnabled:false
        onAccepted: {
            //只有一个空白行则插入新的行
            tableview.model.set(selectedIndex,
                                {   "ID":columnRepeater.itemAt(0).text,
                                    "C1":columnRepeater.itemAt(1).text,
                                    "C2":columnRepeater.itemAt(2).text,
                                    "C3":columnRepeater.itemAt(3).text,
                                    "C4":columnRepeater.itemAt(4).text,
                                    "C5":columnRepeater.itemAt(5).text,
                                    "C6":columnRepeater.itemAt(6).text})}
        onOpened: {
            //复制数据到 editData
            for(var i=0;i<7;i++){
                switch(i){
                case 0:columnRepeater.itemAt(i).text=tableview.model.get(selectedIndex).ID; break;
                case 1:columnRepeater.itemAt(i).text=tableview.model.get(selectedIndex).C1; break;
                case 2:columnRepeater.itemAt(i).text=tableview.model.get(selectedIndex).C2; break;
                case 3:columnRepeater.itemAt(i).text=tableview.model.get(selectedIndex).C3; break;
                case 4:columnRepeater.itemAt(i).text=tableview.model.get(selectedIndex).C4; break;
                case 5:columnRepeater.itemAt(i).text=tableview.model.get(selectedIndex).C5; break;
                case 6:columnRepeater.itemAt(i).text=tableview.model.get(selectedIndex).C6; break;
                }
            }
        }
        dialogContent: [
            Item{
                width: Units.dp(540)
                height:column.height
                Image{
                    id:image
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    source: "../Pic/坡口参数图.png"
                    sourceSize.width: Units.dp(350)
                }
                Column{
                    id:column
                    anchors.top:parent.top
                    anchors.left: image.right
                    anchors.leftMargin: Units.dp(16)
                    anchors.right: parent.right
                    Repeater{
                        id:columnRepeater
                        model:["           No.       ", "板    厚δ(mm)","板厚差e(mm)","间    隙b(mm)","角  度β1(deg)","角  度β2(deg)","余    高h(mm)"]
                        delegate:Row{
                            property alias text: textField.text
                            spacing: Units.dp(8)
                            Label{text:modelData;anchors.bottom: parent.bottom}
                            TextField{
                                id:textField
                                horizontalAlignment:TextInput.AlignHCenter
                                width: Units.dp(60)
                                inputMethodHints: Qt.ImhDigitsOnly
                            }}
                    }
                }
            }
        ]
    }

}

