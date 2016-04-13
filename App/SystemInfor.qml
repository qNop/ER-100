import QtQuick 2.4
import WeldSys.SysInfor 1.0
import QtCharts 2.0
import Material 0.1 as Material

Item {
    anchors.fill: parent
     /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "SystemInfor"
    property var currentdate:new Date();
    Component.onCompleted: SysInfor.systemInformation;
    Connections{
        target:SysInfor
        onSystemInformationChanged:{
            currentdate=new Date();
            console.log(infor)
            cpu.append(currentdate,Number(infor[0]));
            memory.append(currentdate,Number(infor[1]));
            cputemp.append(currentdate,Number(infor[2]));
            if(currentdate>dateTimex.max){
                currentdate= dateTimex.min;
                currentdate.setSeconds(currentdate.getSeconds()+1);
                dateTimex.min=currentdate;
                currentdate= dateTimex.max;
                currentdate.setSeconds(currentdate.getSeconds()+1);
                dateTimex.max=currentdate;
                if(cpu.count>60){
                    cpu.remove(0);
                    memory.remove(0);
                    cputemp.remove(0);
                }
            }
        }
    }
    ChartView{
        id:chartView
        anchors.fill: parent
        anchors.margins:Material.Units.dp(8)
        title: "System Information"
        legend.alignment: Qt.AlignTop
        //只有 曲线有 动画其他没有
        animationOptions: ChartView.SeriesAnimations
        property bool openGl: true
        DateTimeAxis{
            id:dateTimex
            format: "h:mm:ss"
            titleText: "时间"
            min:new Date()
            max:{var datetime=min;datetime.setMinutes(datetime.getMinutes()+1);  return datetime;   }
        }
        ValueAxis{
            id:valueAxisy
            max:100
            min:0
            titleText: "使用率%"
        }
        ValueAxis{
            id:tempAxisy
            max:100
            min:0
            titleText: "温度"
        }
        LineSeries{
            id:cpu
            name:"cpu"
            axisX:dateTimex
            axisYRight:tempAxisy
            useOpenGL:chartView.openGl
        }
        LineSeries{
            id:cputemp
            name:"temp"
            axisX:dateTimex
            axisY:tempAxisy
            useOpenGL:chartView.openGl
        }
        LineSeries{
            id:memory;
            name:"memory"
            axisX:dateTimex
            axisY:valueAxisy
            useOpenGL:chartView.openGl
        }
    }
}
