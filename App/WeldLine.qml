
import QtQuick 2.5
import Material 0.1
import Material.Extras 0.1
import QtCharts 2.1
import WeldSys.ERModbus 1.0
import WeldSys.AppConfig 1.0

FocusScope{
    id:root
    objectName: "WeldLine"
    anchors{
        left:parent.left
        right:parent.right
        top:parent.top
        bottom: parent.bottom
        leftMargin:visible?0:Units.dp(250)
    }

    //当前层数
    property int floorNum:0
    //当前道数
    property int weldNum:0

    Behavior on anchors.leftMargin{NumberAnimation { duration: 400 ;easing.type:Easing.InQuad }}

    property string status:"空闲态"

    property var lineTime:new Date()

    property var lineModel;

    property bool lineActive;

    property int chartScrollPoint;

    property var groovestyles: [
        qsTr( "平焊单边V型坡口T接头"), qsTr( "平焊单边V型坡口平对接"),  qsTr("平焊V型坡口平对接"),
        qsTr("横焊单边V型坡口T接头"), qsTr( "横焊单边V型坡口平对接"),
        qsTr("立焊单边V型坡口T接头"),  qsTr("立焊单边V型坡口平对接"), qsTr("立焊V型坡口平对接"),
        qsTr("水平角焊")  ]

    onLineActiveChanged: {
        var time=new Date();
        setCurrent.append(time,Number(lineModel[2]));
        setVoltage.append(time,Number(lineModel[3]/10));
        current.append(time,Number(lineModel[4]));
        voltage.append(time,Number(lineModel[5])/10);
        if(time>dateTimex.max){
            time= dateTimex.min;
            time.setSeconds(time.getSeconds()+1);
            dateTimex.min=time;
            time= dateTimex.max;
            time.setSeconds(time.getSeconds()+1);
            dateTimex.max=time;
            console.log(setCurrent.count);
        }
    }
    onLineTimeChanged: {
        var time=lineTime;
        current.clear();
        voltage.clear();
        setVoltage.clear();
        setCurrent.clear();
        dateTimex.min=lineTime;
        time.setMinutes(time.getMinutes()+1);
        dateTimex.max=time;
    }
    ListModel{
        id:pointBuf
        ListElement{SETC:"";SETV:"";FEEDC:"";FEEDV:"";TIME:""}
    }
    Component.onDestruction: {
        current.clear();
        voltage.clear();
        setVoltage.clear();
        setCurrent.clear();
    }
    Component.onCompleted: {
        //        var res= UserData.getResultFromFuncOfTable(groovestyles[AppConfig.currentGroove]+"焊接数据")
        //        if(res.rows.length>0){
        //            res.rows.item(0).Time
        //            setCurrent.append()
        //        }
    }
    Timer{interval: 10000;repeat: false;running: true;onTriggered: {//weldLineTime.running=true;
          var time=new Date();
            dateTimex.min=time;
            time.setMinutes(time.getMinutes()+1);
            dateTimex.max=time;
        }}
    Timer{id:weldLineTime;interval: 200;repeat: true;running: false;onTriggered: {
            var time=new Date();
            setCurrent.append(time,100+Math.random(1)*50);
            setVoltage.append(time,20+Math.random(1)*5);
            current.append(time,300+Math.random(1)*50);
            voltage.append(time,40+Math.random(1)*5);
        } }
    Keys.onLeftPressed: {
        chart.scrollRight(1);
    }
    Keys.onRightPressed: {
        chart.scrollLeft(1);
    }
    Keys.onDownPressed: {
        chart.scrollUp(1);
    }
    Keys.onUpPressed: {
        chart.scrollDown(1);
    }
    Keys.onSelectPressed: {
        var lineTime=new Date();
        var time;
        currentAxisy.max=500;
        currentAxisy.min=0;
        voltageAxisy.max=50;
        voltageAxisy.min=0;

        current.clear();
        voltage.clear();
        setVoltage.clear();
        setCurrent.clear();

        dateTimex.min=lineTime;
        time.setMinutes(time.getMinutes()+1);
        dateTimex.max=time;

        weldLineTime.restart();
    }
    Keys.onEscapePressed: {
        if(chart.isZoomed()){
            chart.zoomReset();
        }
        weldLineTime.stop();
    }
    Keys.onPressed: {
        var disp;
        switch(event.key){
        case Qt.Key_Plus:
            chart.zoom(1.1);
            break;
        case Qt.Key_Minus:
            chart.zoom(0.9);
            break;
        }
    }
    property list<Action> actions:[
        Action{iconName:"awesome/folder_open_o";onTriggered: {}
            name:"打开";hoverAnimation:true;summary: "F1"},
        Action{iconName:"awesome/save";onTriggered: {}
            name:"保存";hoverAnimation:true;summary: "F2"},
        Action{iconName:"awesome/file_text_o";
            onTriggered: {}
            name:"新建"
            hoverAnimation:true;summary: "F3"
        },Action{iconName:"awesome/calendar_times_o";
            onTriggered: {
            }
            name:"删除"
            hoverAnimation:true;summary: "F4"
        },
        Action{iconName:"awesome/sticky_note_o";
            onTriggered: {

            }
            name:"信息"
            hoverAnimation:true;summary: "F5"
        },
        Action{iconName:"awesome/stack_overflow";
            onTriggered: {
                //                if(dropDowm.showing)
                //                    dropDowm.close();
                //                else{
                //                    dropDowm.open(tableview.__listView.currentItem,-5,0);
                //                }
            }
            name:"更多"
            hoverAnimation:true;summary: "F6"
        }
    ]
    Card{
        id:table
        anchors{
            fill: parent
            margins: Units.dp(12)
        }
        elevation: 2;
        radius: 2;
        Item{
            id:title
            anchors.top:parent.top
            anchors.left: parent.left
            width: parent.width
            height:Units.dp(64);
            Label{
                anchors.left: parent.left
                anchors.leftMargin: Units.dp(24)
                anchors.verticalCenter: parent.verticalCenter
                text:"第"+floorNum+"层"+"第"+weldNum+"道"+"实时焊接波形"
                style:"subheading"
                color: Theme.light.shade(0.87)
            }
            Row{
                anchors.right: parent.right
                anchors.rightMargin: Units.dp(24)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Units.dp(12);
                Repeater{
                    model:actions.length
                    delegate:View{
                        width: row.width
                        enabled: actions[index].enabled
                        opacity: enabled ? 1 : 0.6
                        Ink{id:ink
                            anchors.fill: parent
                            onClicked: actions[index].triggered();
                            enabled: actions[index].enabled
                        }
                        Tooltip{
                            text:actions[index].summary
                            mouseArea: ink
                        }
                        Row{
                            id:row
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Units.dp(4);
                            Icon{
                                source:actions[index].iconSource
                                color: Theme.accentColor
                                size: Units.dp(27)
                            }
                            Label{
                                style: "button"
                                text:actions[index].name;
                            }
                        }
                    }
                }
            }
        }
        ChartView{
            id:chart
            anchors{
                left:parent.left
                leftMargin: Units.dp(5)
                right:parent.right
                rightMargin: Units.dp(5)
                top:title.bottom
                bottom: parent.bottom
            }
            property int pixelSize: 14
            property int weight: Font.Normal;
            margins{
                left:0
                right:0
                top:0
                bottom:0
            }
            legend{
                alignment: Qt.AlignTop||Qt.AlignLeft
                font.pixelSize: chart.pixelSize
                font.weight:chart.weight
                height: Units.dp(24);
                //   visible: false
            }
            DateTimeAxis{
                id:dateTimex
                format: "h:mm:ss"
                titleText: "时间(s)"
                labelsFont.pixelSize: chart.pixelSize
                titleFont.pixelSize: chart.pixelSize
                titleFont.weight:chart.weight
                labelsFont.weight:chart.weight
                tickCount: 6;
                onMaxChanged: { console.log("dateTimex.max "+dateTimex.max)}
            }
            ValueAxis{
                id:currentAxisy
                max:500
                min:0
                titleText: "电流(A)"
                labelsFont.pixelSize: chart.pixelSize
                titleFont.pixelSize: chart.pixelSize
                titleFont.weight:chart.weight
                labelsFont.weight:chart.weight

            }
            ValueAxis{
                id:voltageAxisy
                max:50
                min:0
                titleText: "电压(V)"
                labelsFont.pixelSize: chart.pixelSize
                titleFont.pixelSize: chart.pixelSize
                titleFont.weight:chart.weight
                labelsFont.weight:chart.weight
            }
            LineSeries{
                id:setVoltage
                name:"预置电压"
                axisX:dateTimex
                axisY:voltageAxisy
                color: Palette.colors["lightGreen"]["600"]
                width:2
            }
            LineSeries{
                id:setCurrent
                name:"预置电流"
                axisX:dateTimex
                axisYRight:currentAxisy
                color: Palette.colors["pink"]["A400"]
                width:2
                //添加点
                onPointAdded: {
                    console.log("point is "+chart.mapToPosition(setCurrent.at(count-1),setCurrent));
                    console.log("rect is "+chart.plotArea);
                    while(setCurrent.at(count-1).x>dateTimex.max){
                        chart.scrollRight(1);
                    }
                }
//                onCountChanged: {
//                    if(count==3){
//                         chartScrollPoint=chart.mapToPosition(setCurrent.at(count-2),setCurrent).x-chart.mapToPosition(setCurrent.at(count-1),setCurrent).x;
//                    }
//                }
            }
            LineSeries{
                id:voltage
                name:"焊接电压"
                axisX:dateTimex
                axisY:voltageAxisy
                color: Palette.colors["green"]["500"]
                width:2
            }
            LineSeries{
                id:current
                name:"焊接电流"
                axisX:dateTimex
                axisYRight:currentAxisy
                color: Palette.colors["red"]["A700"]
                width:2
            }
        }
    }
}
