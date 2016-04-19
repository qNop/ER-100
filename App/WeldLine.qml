
import QtQuick 2.5
import Material 0.1
import Material.Extras 0.1
import QtCharts 2.1

FocusScope{
    objectName: "WeldLine"
    anchors{
        left:parent.left
        right:parent.right
        top:parent.top
        bottom: parent.bottom
        leftMargin:visible?0:Units.dp(250)
    }
    Behavior on anchors.leftMargin{NumberAnimation { duration: 400 ;easing.type:Easing.InQuad }}
    property list<Action> actions:[
        Action{iconName:"awesome/folder_open_o"},
        Action{iconName:"awesome/save"},
        Action{iconName:"awesome/copy"; },
        Action{iconName:"awesome/paste";},
        Action{iconName:"awesome/edit";}
    ]
    Keys.onDownPressed: {
        switch(chart.theme){
        case ChartView.ChartThemeBlueCerulean :
            chart.theme=ChartView.ChartThemeBlueIcy;break;
        case ChartView.ChartThemeBlueIcy:
            chart.theme=ChartView.ChartThemeBlueNcs;break;
        case ChartView.ChartThemeBlueNcs:
            chart.theme=ChartView.ChartThemeBrownSand;break;
        case ChartView.ChartThemeBrownSand:
            chart.theme=ChartView.ChartThemeDark;break;
        case ChartView.ChartThemeDark:
            chart.theme=ChartView.ChartThemeHighContrast;break;
        case ChartView.ChartThemeHighContrast:
            chart.theme=ChartView.ChartThemeLight;break;
        case ChartView.ChartThemeLight:
            chart.theme=ChartView.ChartThemeQt;break;
        case ChartView.ChartThemeQt:
            chart.theme=ChartView.ChartThemeBlueCerulean;break;
        }
    }

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
            anchors.top:parent.top//tableview.bottom
            anchors.left: parent.left
            width: parent.width
            height:Units.dp(64);
            Label{
                anchors.left: parent.left
                anchors.leftMargin: Units.dp(24)
                anchors.verticalCenter: parent.verticalCenter
                text:"焊接实时波形显示"
                style:"title"
                color: Theme.light.shade(0.87)
            }
            Row{
                anchors.right: parent.right
                anchors.rightMargin: Units.dp(24)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Units.dp(24);
                Repeater{
                    model:actions.length
                    delegate: IconButton{
                        action: actions[index]
                        color: Theme.light.iconColor
                        size: Units.dp(27)
                        visible: action.visible
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
            margins{
                left:0
                right:0
                top:0
                bottom:0
            }
            legend{
               alignment: Qt.AlignTop
                font.pixelSize: chart.pixelSize
           }
            DateTimeAxis{
                id:dateTimex
                format: "h:mm"
                titleText: "时间"
                min:new Date()
                max:{var datetime=min;datetime.setMinutes(datetime.getMinutes()+1);  return datetime;   }
                labelsFont.pixelSize: Device.type==Device.desktop?15:chart.pixelSize
                titleFont.pixelSize: chart.pixelSize
            }
            ValueAxis{
                id:currentAxisy
                max:500
                min:0
                titleText: "电流(A)"
            }
            ValueAxis{
                id:voltageAxisy
                max:50
                min:0
                titleText: "电压(V)"
            }
            LineSeries{
                id:voltage
                name:"焊接电压"
                axisX:dateTimex
                axisY:voltageAxisy
            }
            LineSeries{
                id:current
                name:"焊接电流"
                axisX:dateTimex
                axisYRight:currentAxisy
            }
        }
    }
}
