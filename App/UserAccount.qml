import QtQuick 2.0
import Material 0.1
import Material.Extras 0.1
import WeldSys.ERModbus 1.0
import WeldSys.WeldMath 1.0
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.2 as Controls

TableCard {
    id:root
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "UserAccount"

    property bool superUser

    property Item message;
    signal userUpdate();

    ListModel{id:pasteModel;ListElement{ID:"";C1:"";C2:"";C3:"";C4:"";C5:"";C6:""}}

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
                for(var i=0;i<table.rowCount;i++){
                    UserData.insertTable("AccountTable","(?,?,?,?,?,?,?)",[
                                             model.get(i).ID,
                                             model.get(i).C1,
                                             model.get(i).C2,
                                             model.get(i).C3,
                                             model.get(i).C4,
                                             model.get(i).C5,
                                             model.get(i).C6 ])
                }
                message.open("用户信息已保存！");}
        },
        Action{iconName:"awesome/calendar_times_o";name:"删除";enabled: false}
    ]
    editMenu:[
        Action{iconName:"awesome/plus_square_o";onTriggered:dialog.openWith(false);name:"添加";enabled:superUser},
        Action{iconName:"awesome/edit";onTriggered: dialog.openWith(true);name:"编辑";enabled:superUser
        },
        Action{iconName:"awesome/copy";name:"复制";enabled: false},
        Action{iconName:"awesome/paste"; name:"粘帖";enabled: false;},
        Action{iconName: "awesome/trash_o";  name:"移除";enabled:superUser
            onTriggered: {
                if(currentRow>=0){
                    model.remove(currentRow);
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

    MyTextFieldDialog{
        id:dialog
        title: addOrEdit?qsTr("编辑用户信息"):qsTr("添加用户信息")
        property bool addOrEdit: true
        isTextInput: true
        function openWith(flag){
            addOrEdit=flag;
            open();
        }
        repeaterModel: [
            "工        号：",
            "用  户  名：",
            "密        码：",
            "用  户  组：",
            "所在班组：",
            "备        注：" ]
        onOpened: {
            if((currentRow>-1)||(!addOrEdit)){
                //复制数据到 editData
                var index=currentRow
                pasteModel.setProperty(0,"ID",addOrEdit?model.get(index).ID:String(model.count+1));
                openText(0,addOrEdit?model.get(index).C1:"");
                openText(1,addOrEdit?model.get(index).C2:"");
                openText(2,addOrEdit?model.get(index).C3:"");
                openText(3,addOrEdit?model.get(index).C4:"");
                openText(4,addOrEdit?model.get(index).C5:"");
                openText(5,addOrEdit?model.get(index).C6:"");
            }
            else{
                message.open("请选择要编辑的行！")
            }
        }
        onChangeText: {
            switch(index){
            case 0:pasteModel.setProperty(0,"C1",text);break;
            case 1:pasteModel.setProperty(0,"C2",text);break;
            case 2:pasteModel.setProperty(0,"C3",text);break;
            case 3:pasteModel.setProperty(0,"C4",text);break;
            case 4:pasteModel.setProperty(0,"C5",text);break;
            case 5:pasteModel.setProperty(0,"C6",text);break;
            }
        }
        onAccepted: {
            if(addOrEdit)
                model.set(currentRow,pasteModel.get(0))
            else
                model.append(pasteModel.get(0))
        }
    }
}
