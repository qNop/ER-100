import QtQuick 2.4
import WeldSys.SysInfor 1.0
import QtCharts 2.0
import Material 0.1 as Material

Item {
    anchors.fill: parent
     /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "SystemInfor"
    property var currentdate:new Date();
    property int count:  0
        Connections{
        target:SysInfor
        onCpuInforChanged:{ currentdate=new Date(); cpu.append(currentdate,Number(infor[1]))
        }
    }
    Connections{
        target: SysInfor
        onCpuTempChanged:{cputemp.append(currentdate,temp);
            var datetime;
            if(count>119){
                datetime= dateTimex.min;
                datetime.setSeconds(datetime.getSeconds()+1);
                dateTimex.min=datetime;
                datetime= dateTimex.max;
                datetime.setSeconds(datetime.getSeconds()+1);
                dateTimex.max=datetime;
                count=118;
                cpu.remove(0);
                memory.remove(0);
                cputemp.remove(0)
            }
            count++;
            console.log(cputemp.count);

        }
    }
    Connections{
        target:SysInfor
        onMemoryInforChanged:{ memory.append(currentdate,Number(infor[1]))
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
