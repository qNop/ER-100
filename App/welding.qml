import QtQuick 2.0
import Material 0.1
import Material.Extras 0.1
import "awesomechart.js" as Paint



Rectangle {

    color: Theme.backgroundColor
    anchors.leftMargin: title.visible ? 0 :100
    Behavior on anchors.leftMargin {
        NumberAnimation { duration: 200 }
    }
    Column{
        id:column
        TextField{
            placeholderText: "input"
            inputMethodHints:Qt.ImhDigitsOnly
        }
        Label{
            anchors.leftMargin: 24
            text:Qt.inputMethod.visible?"inputPanel is visible":"inputPanel is not visible"
        }
    }
    Card{
        anchors.top:column.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        backgroundColor: Theme.accentColor
        Canvas{
            id:canvas
            anchors.fill: parent
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
}

