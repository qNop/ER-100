import QtQuick 2.4
import WeldSys.WeldControl 1.0
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
    width:parent.width
    Behavior on anchors.leftMargin{NumberAnimation { duration: 200 }}
    property var inforName: ["产品名称","产品代号", "系统版本号","控制器版本号","驱动器版本号","操作盒版本号","公司名称","公司地址","邮编","电话","网址"]
    property var infor:  ["轨道式智能焊接系统","ER-100", "Version 1.1.0  / Version 1.1.0","Version 1.0.0","Version 1.0.0","Version 1.0.0","唐山开元特种焊接设备有限公司","河北省唐山市高新区庆南西道92号","063020","0315-6710298","www.spec-welding.com"]
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
        target: WeldControl
        onUpdateVersion:{
            root.changeInfor(3,obj.control);
            root.changeInfor(4,obj.drvier);
            root.changeInfor(5,obj.hmi);
        }
    }

    Component.onCompleted: {
      //  ERModbus.setmodbusFrame(["R","500","3"]);
        WeldControl.getVersionInfo();
    }
}
