import QtQuick 2.4
import WeldSys.WeldMath 1.0
import Material 0.1
import QtQuick.Layouts 1.1

Item {
    id:root
    anchors.fill: parent
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "DebugInfor"
    anchors{
        left:parent.left
        top:parent.top
        bottom: parent.bottom
        leftMargin:visible?0:Units.dp(250)
    }
    width:parent.width
    Behavior on anchors.leftMargin{NumberAnimation { duration: 200 }}

    property var infor:["系统状态:","起弧状态:","焊接状态:","收弧状态:","      保留:","      保留:","内侧峰值电流:","外侧峰值电流:","    基值电流:","内侧起始电流:","外侧起始电流:","    起始电流:","中心调整量:","高低调整量:","摆宽调整量:","焊速调整量:","      保留:","      保留:","保留:","保留:"]

      signal changeInfor(int selectedIndex,int value)
    Card{
        anchors{left:parent.left;right:parent.right;top:parent.top;bottom:parent.bottom;margins: Units.dp(12)}
        elevation: 2
        GridLayout{
            anchors{left:parent.left;right:parent.right;top:parent.top;bottom:parent.bottom;margins: Units.dp(12)}
            rows: 6
            flow:GridLayout.TopToBottom
            Repeater{
            model:infor
                    Label{
                        property string num:""
                        text:modelData+num
                        style: "button"
                        Connections{
                            target: root
                            onChangeInfor:{
                                if(index===selectedIndex){
                                    num=String(value);
                                }
                            }
                        }
                    }
                }
            }
    }
    Connections{
        target: WeldMath
        //frame[0] 代表状态 1代读取的寄存器地址 2代表返回的 第一个数据 3代表返回的第二个数据 依次递推
        onEr100_GetControlStatus:{
             console.log("DebugInfor value : "+value);
            for(var i=2;i<value.length;i++){
                    root.changeInfor(i-2,Number(value[i]));
            }
        }
    }
}
