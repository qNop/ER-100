import QtQuick 2.0
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
    objectName: "UserAccount"
    anchors{
        left:parent.left
        right:parent.right
        top:parent.top
        bottom: parent.bottom
        leftMargin:visible?0:Units.dp(250)
    }
    Behavior on anchors.leftMargin{NumberAnimation { duration: 400 ;easing.type:Easing.InQuad }}
    property alias weldTableCurrentRow: tableView.currentRow
    property alias model: tableView.model
    property bool superUser: AppConfig.currentUserType==="超级用户"
    signal userUpdate();
    TableCard{
        id:tableView
        footerText:  "只有超级用户拥有添加、编辑、移除用户的权限。"
        tableRowCount:7
        table.__listView.interactive: status!=="焊接态"
        headerTitle: qsTr("用户列表")
        fileMenu: [
            Action{iconName:"awesome/calendar_plus_o";name:"新建";enabled: false;},
            Action{iconName:"awesome/folder_open_o";name:"打开";enabled: false;},
            Action{iconName:"awesome/save";name:"保存";enabled:superUser
                onTriggered: {
                    //保存用户信息
                    //清除保存数据库
                    UserData.clearTable("AccountTable","","");
                    //删除条目
                    for(var i=0;i<tableView.table.rowCount;i++){
                        UserData.insertTable("AccountTable","?,?,?,?,?,?,?",[
                                                 tableView.model.get(i).ID,
                                                 grooveTableInit.get(i).C1,
                                                 grooveTableInit.get(i).C2,
                                                 grooveTableInit.get(i).C3,
                                                 grooveTableInit.get(i).C4,
                                                 grooveTableInit.get(i).C5,
                                                 grooveTableInit.get(i).C6 ])
                    }
                    message.open("用户信息已保存！");}
            },
            Action{iconName:"awesome/calendar_times_o";name:"删除";enabled: false}
        ]
        editMenu:[
            Action{iconName:"awesome/plus_square_o";onTriggered: add.show();name:"添加";enabled:superUser},
            Action{iconName:"awesome/edit";onTriggered: edit.show();name:"编辑";enabled:superUser
            },
            Action{iconName:"awesome/copy";name:"复制";enabled: false},
            Action{iconName:"awesome/paste"; name:"粘帖";enabled: false;},
            Action{iconName: "awesome/trash_o";  name:"移除";enabled:superUser
                onTriggered: {
                    if(weldTableCurrentRow>=0){
                        tableView.model.remove(weldTableCurrentRow);
                        message.open("已移除。");}
                    else
                        message.open("请选择要移除的行！")
                }
            }]
        inforMenu: [ Action{iconName: "awesome/info";  name:"详细信息" ;enabled: false
                //onTriggered: {info.show();}
            }]
        funcMenu: [
            Action{iconName:"awesome/user";name:"登录用户";
                onTriggered: {  userUpdate()}
            }]
        tableData:[
            Controls.TableViewColumn{role: "C1";title: "工号";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C2";title: "用户名";width:Units.dp(100);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C3";title: "密码";width:Units.dp(100);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;visible: superUser},
            Controls.TableViewColumn{role: "C4";title: "用户组";width:Units.dp(100);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C5";title: "所在班组";width:Units.dp(100);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C6";title: "备注";width:Units.dp(200);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;}]
    }
    Dialog{
        id:add
        title: qsTr("添加用户信息")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        globalMouseAreaEnabled:false
        onAccepted: {
            //只有一个空白行则插入新的行
            tableView.model.append(
                        { "ID":tableView.model.count,
                            "C1":columnRepeater.itemAt(0).text,
                            "C2":columnRepeater.itemAt(1).text,
                            "C3":columnRepeater.itemAt(2).text,
                            "C4":columnRepeater.itemAt(3).text,
                            "C5":columnRepeater.itemAt(4).text,
                            "C6":columnRepeater.itemAt(5).text})}
        dialogContent: [
            Item{
                id:item
                property int  focusIndex;
                width: Units.dp(140)
                height:column.height
                Column{
                    id:column
                    anchors.top:parent.top
                    anchors.left: parent.left
                    anchors.leftMargin: Units.dp(16)
                    anchors.right: parent.right
                    Repeater{
                        id:columnRepeater
                        model:[
                            "工        号：",
                            "用  户  名：",
                            "密        码：",
                            "用  户  组：",
                            "所在班组：",
                            "备        注：" ]
                        delegate:Row{
                            property alias text: textField.text
                            property bool textFeildfocus:false
                            onTextFeildfocusChanged: {
                                if(textFeildfocus){
                                    textField.forceActiveFocus()
                                }
                            }
                            spacing: Units.dp(8)
                            Label{text:modelData;anchors.bottom: parent.bottom}
                            TextField{
                                id:textField
                                horizontalAlignment:TextInput.AlignHCenter
                                width: Units.dp(120)
                                onVisibleChanged: {
                                    if(visible){
                                        text="0";
                                    }
                                }
                                inputMethodHints: Qt.ImhDigitsOnly
                                onActiveFocusChanged: {
                                    if(activeFocus){
                                        item.focusIndex=index;
                                    }
                                }
                            }}
                    }
                }
                Keys.onDownPressed: {
                    if(focusIndex<columnRepeater.count){
                        if(focusIndex!=-1)
                            columnRepeater.itemAt(focusIndex).textFeildfocus=false;
                        focusIndex++;
                        columnRepeater.itemAt(focusIndex).textFeildfocus=true;
                    }
                }
                Keys.onUpPressed: {
                    if(focusIndex>-1){
                        if(focusIndex<columnRepeater.count)
                            columnRepeater.itemAt(focusIndex).textFeildfocus=false;
                        focusIndex--;
                        columnRepeater.itemAt(focusIndex).textFeildfocus=true;
                    }
                }
                onVisibleChanged:  focusIndex=-1;
            }
        ]
    }
    Dialog{
        id:edit
        title: qsTr("编辑用户信息")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        globalMouseAreaEnabled:false
        property string  currentId;
        onAccepted: {
            //只有一个空白行则插入新的行
            tableView.model.set(weldTableCurrentRow,
                                { "ID":currentId,
                                    "C1":editcolumnRepeater.itemAt(0).text,
                                    "C2":editcolumnRepeater.itemAt(1).text,
                                    "C3":editcolumnRepeater.itemAt(2).text,
                                    "C4":editcolumnRepeater.itemAt(3).text,
                                    "C5":editcolumnRepeater.itemAt(4).text,
                                    "C6":editcolumnRepeater.itemAt(5).text}
                                )}
        onOpened: {
            if(weldTableCurrentRow>-1){
                //复制数据到 editData
                var index=weldTableCurrentRow
                currentId=tableView.model.get(index).ID;
                editcolumnRepeater.itemAt(0).text=tableView.model.get(index).C1;
                editcolumnRepeater.itemAt(1).text=tableView.model.get(index).C2;
                editcolumnRepeater.itemAt(2).text=tableView.model.get(index).C3;
                editcolumnRepeater.itemAt(3).text=tableView.model.get(index).C4;
                editcolumnRepeater.itemAt(4).text=tableView.model.get(index).C5;
                editcolumnRepeater.itemAt(5).text=tableView.model.get(index).C6;
            }
            else{
                message.open("请选择要编辑的行！")
                positiveButtonEnabled=false;
            }
        }
        dialogContent: [
            Item{
                id:item1
                property int  focusIndex;
                Keys.onDownPressed: {
                    if(focusIndex<editcolumnRepeater.count){
                        if(focusIndex!=-1)
                            editcolumnRepeater.itemAt(focusIndex).textFeildfocus=false;
                        focusIndex++;
                        editcolumnRepeater.itemAt(focusIndex).textFeildfocus=true;
                    }
                }
                Keys.onUpPressed: {
                    if(focusIndex>-1){
                        if(focusIndex<editcolumnRepeater.count)
                            editcolumnRepeater.itemAt(focusIndex).textFeildfocus=false;
                        focusIndex--;
                        editcolumnRepeater.itemAt(focusIndex).textFeildfocus=true;
                    }
                }
                onVisibleChanged:  focusIndex=-1;
                width: Units.dp(140)
                height:editcolumn.height
                Column{
                    id:editcolumn
                    anchors.top:parent.top
                    anchors.left: parent.left//editimage.right
                    anchors.leftMargin: Units.dp(16)
                    anchors.right: parent.right
                    Repeater{
                        id:editcolumnRepeater
                        model:[
                            "工        号：",
                            "用  户  名：",
                            "密        码：",
                            "用  户  组：",
                            "所在班组：",
                            "备        注：" ]
                        delegate:Row{
                            property alias text: edittextField.text
                            property bool textFeildfocus:false
                            onTextFeildfocusChanged: {
                                if(textFeildfocus){
                                    edittextField.forceActiveFocus()
                                }
                            }
                            spacing: Units.dp(8)
                            Label{text:modelData;anchors.bottom: parent.bottom}
                            TextField{
                                id:edittextField
                                horizontalAlignment:TextInput.AlignHCenter
                                width: Units.dp(120)
                                inputMethodHints: Qt.ImhDigitsOnly
                                onActiveFocusChanged: {
                                    if(activeFocus){
                                        item1.focusIndex=index;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        ]
    }
}
