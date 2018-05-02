import QtQuick 2.4
import Material.ListItems 0.1 as ListItem
import Material.Extras 0.1
import Material 0.1
import QtQuick.Controls 1.3 as Controls
/*

*/
ListView{
    id:root
    objectName: "MyListview"

    property alias group: exclusiveGroup

    Controls.ExclusiveGroup { id: exclusiveGroup;}

    delegate:Item{
        height:Units.dp(48)
        anchors{
            left:parent.left
            right:parent.right
        }
        Label{
            anchors{
                left:parent.left
                leftMargin: Units.dp(48)
                verticalCenter: parent.verticalCenter
            }
            elide: Text.ElideRight
            style: "subheading"
            text:name
        }
        Row{
            anchors.verticalCenter: parent.verticalCenter
            Repeater{
                id:weldDirRepeater
                model:actionModel
                delegate:RadioButton{
                    text:modelData
                    exclusiveGroup: root.exclusiveGroup
                    //onClicked:{//与掉低位将index插入进来
                       // currentGroove=(currentGroove&0xfffffffc)|index;}
                    canToggle: false
                    //低两位中存在与index相当的数即checked
                  //  checked:(currentGroove&0x03)===index?true:false
                }
            }
        }
    }
}

