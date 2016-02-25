
import QtQuick 2.0
import Material 0.1
import Material.Extras 0.1
import "awesomechart.js" as Paint

Rectangle {
    color: Theme.backgroundColor
    anchors.fill: parent
    Canvas{
        id:canvas
        height:parent.height
        width:parent.width
        onPaint: {
            var mychart = new Paint.AwesomeChart(canvas);
            mychart.title = "世界粗钢产量 - 2013";
            mychart.chartType = 'pie';
            mychart.data = [1532, 3251, 3460, 1180, 6543];
            mychart.labels = ["美国", "唐山", "河北", "迁安", "中国"];
            mychart.draw();
        }
    }
}
