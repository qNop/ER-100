import QtQuick 2.4
import WeldSys.SysInfor 1.0
import QtCharts 2.0
import Material 0.1 as Material

Item {
    anchors.fill: parent
     /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "SystemInfor"
    property int count: 0
    Connections{
        target:SysInfor
        onCpuInforChanged:{ cpu.append(new Date(),Number(infor[1]))}
    }
    Connections{
        target:SysInfor
        onMemoryInforChanged:{ memory.append(new Date(),Number(infor[1]))
            count++;
            var datetime;
            if(count>60){
                datetime= dateTimex.min;
                datetime.setSeconds(datetime.getSeconds()+1);
                dateTimex.min=datetime;
                datetime= dateTimex.max;
                datetime.setSeconds(datetime.getSeconds()+1);
                dateTimex.max=datetime;
                count=60;
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
        LineSeries{
            id:cpu
            name:"cpu"
            axisX:dateTimex
            axisY:valueAxisy
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
