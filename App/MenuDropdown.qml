import QtQuick 2.0
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Layouts 1.1

Dropdown{
    id:root
    objectName: "Dropdown"
    property list<Action>  actions;
    property int rootIndex:0;
    property int place
    property Item columnViewItem;
    width: Units.dp(168)
    function loadView(){
         columnViewItem=componetView.createObject(internalView,{});
         height=columnViewItem.height+ Units.dp(16)
    }
    onVisibleChanged: {
        //找到第一个使能的index
        if(visible){
            rootIndex=0;
            for(var i=0;i<actions.length;i++){
                if(actions[i].enabled){
                    rootIndex=i;
                    break;
                }
            }
            //获取焦点
            root.forceActiveFocus();
        }
    }
    onShowingChanged: {
        if((!showing)&&(columnViewItem!==null)){
            columnViewItem.destroy(100);
        }
    }

   Component{
        id:componetView
        ColumnLayout {
            objectName: "test"
            id: columnView
            width: parent.width
            anchors.top:parent.top
            anchors.topMargin: Units.dp(8)
            Repeater {
                id:dropRepeater
                model: actions.length
                ListItem.Standard {
                    id: listItem
                    height:Units.dp(40)
                    text:actions[index].name;
                    visible: actions[index].visible;
                    itemLabel.style: "button"
                    iconSource: actions[index].iconSource
                    enabled: actions[index].enabled
                    textColor:selected?Theme.accentColor:Theme.light.textColor
                    iconColor: selected?Theme.accentColor:Theme.light.iconColor
                    selected: root.rootIndex===index
                    onClicked: {
                        root.close()
                        actions[index].triggered(listItem)
                    }
                }
            }
        }
    }
    Keys.onPressed: { var i=0;
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
                        if((rootIndex<actions.length)&&(actions[i].enabled)){
                            rootIndex=i;
                            break;
                        }
                    }
                }
                event.accpet=true;
                break;
            case Qt.Key_Return:
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
}
