import QtQuick 2.4
import WeldSys.WeldMath 1.0
import Material 0.1
import QtQuick.Layouts 1.1

Item {
    id:root
    anchors.fill: parent
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "SystemInfor"
    anchors{
        left:parent.left
        top:parent.top
        bottom: parent.bottom
        leftMargin:visible?0:Units.dp(250)
    }
    property  string  test:""
    width:parent.width
    Behavior on anchors.leftMargin{NumberAnimation { duration: 200 }}
    property string name
    //处理版本
    // 15-12 硬件改动 11-7 软件改动 6-0 bug修复
    function doInfor(str){
        var code,sysI,sysC,sysBug
            code=Number(str);
            sysI=code&0xf000;
            sysI=sysI>>12;
            sysC=code&0x0f80;
             sysC=sysC>>7;
            sysBug=code&0x007f;
            str="Version "+String(sysI)+"."+String(sysC)+"."+String(sysBug);
            return str;
    }
    //系统程序版本、数据版本、操作盒版本、公司名称、公司地址、邮编、电话、网址。
    property var inforName: ["产品名称","产品代号",
        "系统版本号","控制器版本号","驱动器版本号","操作盒版本号","公司名称","公司地址","邮编","电话","网址"]
    property var infor:  ["轨道式智能焊接系统","ER-100", "Version 1.0.4 / Version 1.0.3","Version 1.0.0","Version 1.0.0","Version 1.0.0","唐山开元自动焊接装备有限公司","河北省唐山市高新区庆南西道92号","063020","0315-6710298","www.autoweld.com.cn"]
    signal changeInfor(int selectedIndex,string str)
    Card{
        anchors{left:parent.left;right:parent.right;top:parent.top;bottom:parent.bottom;margins: Units.dp(12)}
        elevation: 2
        Image{
            id:logo
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top:parent.top
            anchors.topMargin: height-10
            source: "../Pic/logo.png"
            height: 40
            width: 5.7*height
            mipmap: true
        }
        Image{
            id:logo2
            anchors.bottom:parent.bottom
            anchors.bottomMargin: 24
            anchors.left: parent.left
            anchors.leftMargin: 18
            source: "../Pic/erweima.png"
            height: 100
            width: 100
            mipmap: true
        }
        ColumnLayout{
            anchors.right: parent.horizontalCenter
            anchors.rightMargin: 36
            anchors.top:logo.bottom
            anchors.topMargin: logo.height/2
            Repeater{
                model:inforName
                Label{
                    Layout.alignment: Qt.AlignRight
                    text:modelData
                    style: "button"
                }
            }
        }
        ColumnLayout{
            anchors.left: parent.horizontalCenter
            anchors.leftMargin: -12
            anchors.top:logo.bottom
            anchors.topMargin: logo.height/2
            Repeater{
                model:infor
                Label{
                    Connections{
                        target: root
                        onChangeInfor:{
                            if(index===selectedIndex){
                                text=str;
                            }
                        }
                    }
                    text:modelData
                    style: "button"
                }
            }
        }
    }
    Connections{
        target: WeldMath
        //frame[0] 代表状态 1代读取的寄存器地址 2代表返回的 第一个数据 3代表返回的第二个数据 依次递推
        onEr100_Version:{
            changeInfor(3,doInfor(code1));
            changeInfor(4,doInfor(code2));
            changeInfor(5,doInfor(code3));
        }
    }
    Component.onCompleted: {
        WeldMath.readVersion();
    }
}
