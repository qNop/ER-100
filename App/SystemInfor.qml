import QtQuick 2.4
//import WeldSys.SysInfor 1.0
import QtCharts 2.0
import Material 0.1 as Material

Item {
    anchors.fill: parent
     /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "SystemInfor"
    property var currentdate:new Date();
    //Component.onCompleted: {SysInfor.systemInformation; timerRun=true}
    property bool timerRun: false
//    Timer{ interval: 1000 ;running:true ;repeat:true
//        onTriggered: {
//            //刷新坐标轴
//            currentdate= dateTimex.min;
//            currentdate.setSeconds(currentdate.getSeconds()+1);
//            dateTimex.min=currentdate;
//            currentdate= dateTimex.max;
//            currentdate.setSeconds(currentdate.getSeconds()+1);
//            dateTimex.max=currentdate;
//            console.log(cpu)
//        }
//    }
    Connections{
        target:SysInfor
        onSystemInformationChanged:{
            currentdate=new Date();
            console.log(infor)
            cpu.append(currentdate,Number(infor[0]));
            memory.append(currentdate,Number(infor[1]));
            cputemp.append(currentdate,Material.Device.type==Material.Device.desktop?Number(infor[2])/1000:Number(infor[2]));
            console.log(Qt.formatDateTime(cpu.at(0).x, "h:mm"));
//            if(currentdate>dateTimex.max){
//                currentdate= dateTimex.min;
//                currentdate.setSeconds(currentdate.getSeconds()+1);
//                dateTimex.min=currentdate;
//                currentdate= dateTimex.max;
//                currentdate.setSeconds(currentdate.getSeconds()+1);
//                dateTimex.max=currentdate;
//                var count=cpu.count;
//                console.log(count);
//                if(cpu.count>59){
//                    cpu.removePoints(0,count-60);
//                    memory.removePoints(0,count-60);
//                    cputemp.removePoints(0,count-60);
//                }
//            }
        }
    }
    ChartView{
        id:chartView
        anchors.fill: parent
        title: "System Information"
        property int pixelSize: 14
        property int weight: Font.Normal;
//        margins{
//            left:0
//            right:0
//            top:0
//            bottom:0
//        }
//        legend{
//            alignment: Qt.AlignTop||Qt.AlignLeft
//            font.pixelSize: chartView.pixelSize
//            font.weight:chartView.weight
//            height: Material.Units.dp(24);
//            //   visible: false
//        }
        //只有 曲线有 动画其他没有
        animationOptions: ChartView.SeriesAnimations
        property bool openGl: Material.Device.type==Material.Device.desktop?false:true
        DateTimeAxis{
            id:dateTimex
            format: "h:mm"
            titleText: "时间"
            min:new Date()
            max:{var datetime=min;datetime.setMinutes(datetime.getMinutes()+1);  return datetime;   }
            labelsFont.pixelSize: chartView.pixelSize
            titleFont.pixelSize: chartView.pixelSize
            titleFont.weight:chartView.weight
            labelsFont.weight:chartView.weight
            tickCount: 6;
        }
        ValueAxis{
            id:valueAxisy
            max:100
            min:0
            titleText: "使用率%"
            labelsFont.pixelSize: chartView.pixelSize
            titleFont.pixelSize: chartView.pixelSize
            titleFont.weight:chartView.weight
            labelsFont.weight:chartView.weight
        }
        ValueAxis{
            id:tempAxisy
            max:100
            min:0
            titleText: "温度"
            labelsFont.pixelSize: chartView.pixelSize
            titleFont.pixelSize: chartView.pixelSize
            titleFont.weight:chartView.weight
            labelsFont.weight:chartView.weight
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
