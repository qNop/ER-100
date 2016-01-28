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
            mychart.title = "Product Sales - 2010";
            mychart.chartType = 'pareto';
            mychart.data = [1532, 3251, 3460, 1180, 6543];
            mychart.labels = ["Desktops", "Laptops", "Netbooks", "Tablets", "Smartphones"];
            mychart.draw();
        }
    }
}

