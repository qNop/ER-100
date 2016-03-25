import QtQuick 2.5
import Material 0.1 as Material
import Material.Extras 0.1
import QtQuick.Controls 1.2
import QtQuick.Controls.Private 1.0
import QtQuick.Controls.Styles 1.1

Item{
    objectName: "WeldLine"
    Text {
        id: name
        text: parent.objectName
    }
}
