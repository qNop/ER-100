import QtQuick 2.0
import Material 0.1
import Material.Extras 0.1
import WeldSys.ERModbus 1.0
import WeldSys.WeldMath 1.0
import WeldSys.MySQL 1.0
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.2 as Controls

TableCard {
    id:root
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "UserAccount"

    property bool superUser

   // signal userUpdate();

//    ListModel{id:pasteModel;ListElement{ID:"";C1:"";C2:"";C3:"";C4:"";C5:"";C6:""}}

    footerText:  "只有超级用户拥有添加、编辑、移除用户的权限。"
    tableRowCount:7
    table.__listView.interactive: status!=="焊接态"
    headerTitle: "用户列表"
    function save(){
            //清除保存数据库
            MySQL.clearTable("AccountTable","","");
            for(var i=0;i<model.count;i++){
                //插入新的数据
                MySQL.insertTable("AccountTable",model.get(i));
            }
            message.open("用户信息已保存！");

    }
   /* fileMenu: [
        Action{iconName:"awesome/calendar_plus_o";name:"新建";enabled: false;},
        Action{iconName:"awesome/folder_open_o";name:"打开";enabled: false;},
        Action{iconName:"awesome/save";name:"保存";enabled:superUser
            onTriggered: {
                message.open("正在保存用户信息！");
                //保存用户信息
                MySQL.clearTable("AccountTable","","");
                //删除条目
                for(var i=0;i<model.count;i++){
                    MySQL.insertTable("AccountTable",model.get(i));
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
               if((currentRow>=0)&&(table.rowCount)){
                   selectIndex(currentRow-1)
                   model.remove(currentRow);
                  //  selectIndex(currentRow-1);
                    message.open("已移除。");}
                else
                    message.open("请选择要移除的行！")
            }
        }]
    inforMenu: [ Action{iconName: "awesome/info";  name:"详细信息" ;enabled:false
            //onTriggered: {info.show();}
        }]
    funcMenu: [
        Action{iconName:"awesome/user";name:"登录用户";
            onTriggered: {  userUpdate()}
        }]*/
    tableData:[
        Controls.TableViewColumn{role: "C1";title: "工号";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C2";title: "用户名";width:Units.dp(100);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C3";title: "密码";width:Units.dp(100);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;visible: superUser},
        Controls.TableViewColumn{role: "C4";title: "用户组";width:Units.dp(100);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C5";title: "所在班组";width:Units.dp(100);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C6";title: "备注";width:Units.dp(200);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;}]
/*
    MyTextFieldDialog{
        id:dialog
         message: root.message
        title: addOrEdit?qsTr("编辑用户信息"):qsTr("添加用户信息")
        property bool addOrEdit: true
        isTextInput: true
        function openWith(flag){
            addOrEdit=flag;
            open();
        }
        ListModel{
            id:textModel
            ListElement{name:"工        号：";value:"";show:true;min:1;max:1000;isNum:true;step:1}
            ListElement{name:"用  户  名：";value:"";show:true;min:10;max:300;isNum:false;step:1}
            ListElement{name:"密        码：";value:"";show:true;min:10;max:300;isNum:false;step:1}
            ListElement{name:"用  户  组：";value:"";show:true;min:10;max:300;isNum:false;step:1}
            ListElement{name:"所在班组：";value:"";show:true;min:10;max:300;isNum:false;step:1}
            ListElement{name:"备        注：";value:"";show:true;min:10;max:300;isNum:false;step:1}
        }
        repeaterModel:textModel
        onOpened: {
            if((currentRow>-1)||(!addOrEdit)){
                //复制数据到 editData
                var index=currentRow
                textModel.setProperty(0,"value",addOrEdit?model.get(index).C1:"0");
                textModel.setProperty(1,"value",addOrEdit?model.get(index).C2:"0");
                textModel.setProperty(2,"value",addOrEdit?model.get(index).C3:"0");
                textModel.setProperty(3,"value",addOrEdit?model.get(index).C4:"0");
                textModel.setProperty(4,"value",addOrEdit?model.get(index).C5:"0");
                textModel.setProperty(5,"value",addOrEdit?model.get(index).C6:"0");
               updateText()
            }
            else{
                message.open("请选择要编辑的行！")
            }
        }
        onAccepted: {
            var js={"ID":String(table.rowCount+1),"C1":getText(0),"C2":getText(1),"C3":getText(2),"C4":getText(3),"C5":getText(4),"C6":getText(5)};
            if(addOrEdit)
                model.set(currentRow,js)
            else
                model.append(js)
        }
    }*/
}
