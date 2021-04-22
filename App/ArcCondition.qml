import QtQuick 2.4
import Material 0.1 as Material
import Material.Extras 0.1 as JS
import WeldSys.MySQL 1.0
import WeldSys.WeldMath 1.0
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.1


TestMyConditionView{
    id:root
    objectName:"ArcCondition"
    property int currentGroove
    property var settings
    titleName:"跟踪条件"
    ListModel{
        id:arcConditonModel
        ListElement{name:"焊缝高低跟踪";
            groupOrText:true;value:"0";valueType:"";min:0;max:1;increment:1;description:"打开或关闭焊缝高低跟踪功能。";rowEnable:true;}
        ListElement{name:"    跟踪精度";
            groupOrText:false;value:"0";valueType:"mm";min:0.1;max:1;increment:0.02;description:"设置跟踪精度（mm）。";rowEnable:true;}
        ListElement{name:"    最大调整量";
            groupOrText:false;value:"1";valueType:"mm";min:1;max:20;increment:1;description:"设置跟踪最大调整量（mm）";rowEnable:true;}
        ListElement{name:"焊缝中心跟踪";
            groupOrText:true;value:"0";valueType:"";min:0;max:1;increment:1;description:"打开或关闭焊缝中心跟踪功能。";rowEnable:true;}
        ListElement{name:"    跟踪精度";
            groupOrText:false;value:"0";valueType:"mm";min:0.1;max:1;increment:0.02;description:"设置跟踪精度（mm）。";rowEnable:true;}
        ListElement{name:"    最大调整量";
            groupOrText:false;value:"1";valueType:"mm";min:1;max:20;increment:1;description:"设置跟踪最大调整量（mm）";rowEnable:true;}
        ListElement{name:"焊缝宽度跟踪";
            groupOrText:true;value:"0";valueType:"";min:0;max:1;increment:1;description:"打开或关闭焊缝宽度跟踪功能。";rowEnable:true;}
        ListElement{name:"    跟踪精度";
            groupOrText:false;value:"0";valueType:"mm";min:0.1;max:1;increment:0.02;description:"设置跟踪精度（mm）。";rowEnable:true;}
        ListElement{name:"    最大调整量";
            groupOrText:false;value:"1";valueType:"mm";min:1;max:20;increment:1;description:"设置跟踪最大调整量（mm）";rowEnable:true;}
    }
    model:arcConditonModel
    property list<ListModel> arcConditionModels:[
        ListModel{ListElement{name:"关闭";enable:true}ListElement{name:"打开";enable:true}},
        ListModel{ListElement{name:"";enable:true}},
        ListModel{ListElement{name:"";enable:true}},
        ListModel{ListElement{name:"关闭";enable:true}ListElement{name:"打开";enable:true}},
        ListModel{ListElement{name:"";enable:true}},
        ListModel{ListElement{name:"";enable:true}},
        ListModel{ListElement{name:"关闭";enable:true}ListElement{name:"打开";enable:true}},
        ListModel{ListElement{name:"";enable:true}},
        ListModel{ListElement{name:"";enable:true}}
    ]
    groupModel:arcConditionModels

    onUpdateModel: {
        arcConditonModel.setProperty(selectIndex,"value",value);
        switch(selectIndex){
        case 0:
            arcConditonModel.setProperty(1,"rowEnable",value==="0"?false:true);
            arcConditonModel.setProperty(2,"rowEnable",value==="0"?false:true);
            break;
        case 3:
            arcConditonModel.setProperty(4,"rowEnable",value==="0"?false:true);
            arcConditonModel.setProperty(5,"rowEnable",value==="0"?false:true);
            break;
        case 6:
            arcConditonModel.setProperty(7,"rowEnable",value==="0"?false:true);
            arcConditonModel.setProperty(8,"rowEnable",value==="0"?false:true);
            break;
        }
    }

    onChangeValue: {
        var num=Number(arcConditonModel.get(index).value);
        switch(index){
        case 0:
            WeldMath.setPara("arcAvcEn",num,true,false);
            settings.arcAvcEn=num;
            break;
        case 1:
            settings.arcAvcAdj=num;
            WeldMath.setPara("arcAvcAdj",num*100,true,false);
            break;
        case 2:
            WeldMath.setPara("arcAvcMax",num*100,true,false);
              settings.arcAvcMax=num;
            break;
        case 3:
            WeldMath.setPara("arcSwEn",num,true,false);
              settings.arcSwEn=num;
            break;
        case 4:
             settings.arcSwAdj=num;
            WeldMath.setPara("arcSwAdj",num*100,true,false);
            break;
        case 5:
            WeldMath.setPara("arcSwMax",num*100,true,false);
              settings.arcSwMax=num;
            break;
        case 6:
            WeldMath.setPara("arcSwWEn",num,true,false);
              settings.arcSwWEn=num;
            break;
        case 7:
             settings.arcSwWAdj=num;
            WeldMath.setPara("arcSwWAdj",num*100,true,false);
            break;
        case 8:
             settings.arcSwWMax=num;
            WeldMath.setPara("arcSwWMax",num*100,true,false);

            break;
        }
    }

    Component.onCompleted: {
        selectIndex=0;
        updateModel(settings.arcAvcEn);
        selectIndex=1;
        updateModel(settings.arcAvcAdj);
        selectIndex=2;
        updateModel(settings.arcAvcMax);
        selectIndex=3;
        updateModel(settings.arcSwEn);
        selectIndex=4;
        updateModel(settings.arcSwAdj);
        selectIndex=5;
        updateModel(settings.arcSwMax);
        selectIndex=6;
        updateModel(settings.arcSwWEn);
        selectIndex=7;
        updateModel(settings.arcSwWAdj);
        selectIndex=8;
        updateModel(settings.arcSwWMax);
        for(var i=0;i<9;i++)
            changeValue(i);
    }

}
