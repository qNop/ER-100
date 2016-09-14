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
    objectName: "RoboInfor"
    TableCard{
        id:groove
        tableRowCount: 2
      actions:[
                Action{iconName:"awesome/folder_open_o";name:"打开";hoverAnimation:true;summary: "F1"
                },
                Action{iconName:"awesome/save"; name:"保存";hoverAnimation:true;summary: "F2";  },
                Action{iconName:"awesome/calendar_plus_o";
                    name:"新建"
                    hoverAnimation:true;summary: "F3"
                },
                Action{iconName:"awesome/calendar_times_o";
                    name:"删除"
                    hoverAnimation:true;summary: "F4"
                },
                Action{iconName:"awesome/sticky_note_o";
                    name:"信息"
                    hoverAnimation:true;summary: "F5"
                },
                Action{iconName:"awesome/stack_overflow";
                    name:"更多"
                    hoverAnimation:true;summary: "F6"
                }
            ]
        tableData: [
            Controls.TableViewColumn{  role:"C1"; title: "板厚 δ\n (mm)";width:Units.dp(105);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{  role:"C2"; title: "板厚差 e\n   (mm)";width:Units.dp(105);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{  role:"C3"; title: "间隙 b\n (mm)";width:Units.dp(105);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{  role:"C4"; title: "角度 β1\n  (deg)";width:Units.dp(105);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{  role:"C5"; title: "角度 β2\n  (deg)";width:Units.dp(105);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{  role:"C6"; title: "余高 h\n (mm)";width:Units.dp(105);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter}]
        }
    TableCard{
        anchors.top: groove.bottom
        tableRowCount: 2
        tableData: [
            Controls.TableViewColumn{role: "C1";title:"   焊接\n层道数";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C2";title: "电流\n  A";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C3";title: "电压\n  V";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C4";title: " 摆幅\n  mm";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C5";title: "  摆频\n次/min";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C6";title: "焊接速度\n cm/min";width:Units.dp(80);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C7";title: "焊接线\n X mm";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C8";title: "焊接线\n Y mm";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C9";title: "内停留\n     s";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter; },
            Controls.TableViewColumn{role: "C10";title: "外停留\n     s";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter;},
            Controls.TableViewColumn{role: "C11";title: "预约\n停止";width:Units.dp(70);movable:false;resizable:false;horizontalAlignment:Text.AlignHCenter},
            Controls.TableViewColumn{role: "C12";title: "层面积";width:Units.dp(70);movable:false;resizable:false;},
            Controls.TableViewColumn{role: "C13";title: "道面积";width:Units.dp(70);movable:false;resizable:false;},
            Controls.TableViewColumn{role: "C14";title: "起弧x";width:Units.dp(70);movable:false;resizable:false;},
            Controls.TableViewColumn{role: "C15";title: "起弧y";width:Units.dp(70);movable:false;resizable:false;},
            Controls.TableViewColumn{role: "C16";title: "起弧z";width:Units.dp(70);movable:false;resizable:false;}]
        }
}
