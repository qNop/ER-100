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

    tableData:[
        Controls.TableViewColumn{role: "C1";title: "工号";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C2";title: "用户名";width:Units.dp(100);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
        Controls.TableViewColumn{role: "C3";title: "密码";width:Units.dp(100);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;visible: superUser},
        Controls.TableViewColumn{role: "C4";title: "用户组";width:Units.dp(100);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C5";title: "所在班组";width:Units.dp(100);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
        Controls.TableViewColumn{role: "C6";title: "备注";width:Units.dp(200);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;}]

}
