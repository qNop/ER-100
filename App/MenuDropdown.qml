import QtQuick 2.0
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.1

Dropdown{
    id:root
    property list<Action>  actions;
    property int rootIndex:0;
    height: columnView.height + Units.dp(16)
    width: Units.dp(168)
    onOpened: forceActiveFocus()
    ColumnLayout {
        id: columnView
        width: parent.width
        anchors.centerIn: parent
        Repeater {
            id:dropRepeater
            model: actions.length
            ListItem.Standard {
                id: listItem
                height:Units.dp(40)
                text:actions[index].name;
                itemLabel.style: "button"
                iconSource: actions[index].iconSource
                enabled: actions[index].enabled
                textColor:Theme.light.textColor
                iconColor: Theme.accentColor
                selected: root.rootIndex===index
                onClicked: {
                    root.close()
                    actions[index].triggered(listItem)
                }
            }
        }
    }
    Keys.onPressed:
    { var i=0;
        if(root.visible){
            switch(event.key){
            case Qt.Key_Down:
                if(rootIndex<(actions.length-1)){
                    //小于最大深度
                    for( i=rootIndex+1;i<actions.length;i++){
                        if(actions[i].enabled){
                             rootIndex=i;
                            break;
                        }
                    }
                }
                event.accpet=true;
                break;
            case Qt.Key_Up:
                if(rootIndex>0){
                    //大于最大深度
                    for(i=rootIndex-1;i>=0;i--){
                        if(actions[i].enabled){
                            rootIndex=i;
                            break;
                        }
                    }
                }
                event.accpet=true;
                break;
            case Qt.Key_Select:
                root.close();
                actions[rootIndex].triggered();
                event.accept=true;
                break;
            case Qt.Key_Escape:
                root.close();
                event.accept=true;break;
            default :
                root.close();
                event.accept=true;;break;
            }
        }
    }//上按下
    onVisibleChanged: {
        //初始化界面 第一条列表信息选中
        rootIndex=0;
    }
}
