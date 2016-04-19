import QtQuick 2.4
import Material 0.1
import Material.ListItems 0.1 as ListItem
import QtQuick.Controls 1.2 as Controls
import QtQuick.Window 2.2
import WeldSys.AppConfig 1.0
import WeldSys.ERModbus 1.0

FocusScope{
    id:root
    /*名称必须要有方便 nav打开后寻找焦点*/
    objectName: "GrooveCheck"
    anchors{
        left:parent.left
        right:parent.right
        top:parent.top
        bottom: parent.bottom
        leftMargin:visible?0:Units.dp(250)
    }
    Behavior on anchors.leftMargin{NumberAnimation { duration: 400 }}
    /*坡口列表*/
    property var groovestyles: [
        qsTr( "平焊单边V型坡口T接头"), qsTr( "平焊单边V型坡口平对接"),  qsTr("平焊V型坡口平对接"),
        qsTr("横焊单边V型坡口T接头"), qsTr( "横焊单边V型坡口平对接"),
        qsTr("立焊单边V型坡口T接头"),  qsTr("立焊单边V型坡口平对接"), qsTr("立焊V型坡口平对接"),
        qsTr("水平角焊") ]
    property var grooveStyleEnglish: [];
    property var editData:["","","","","",""]

    property alias grooveStyleModel: grooveTableview.model
    property string status:"0"
    property string grooveLength:"0"
    property list<Action> actions:[
        Action{iconName:"awesome/folder_open_o";onTriggered: open.show()},
        Action{iconName:"awesome/save";onTriggered: save.show()},
        Action{iconName:"awesome/copy";
            enabled:grooveTableview.__listView.currentIndex!==-1?true:false
            onTriggered: copy.show();
        },
        Action{iconName:"awesome/paste";
            enabled:grooveTableview.__listView.currentIndex!==-1?true:false
            onTriggered: paste.show();
        },
        Action{iconName:"awesome/edit";
            enabled:grooveTableview.__listView.currentIndex!==-1?true:false
            onTriggered: edit.show();
        },
        Action{iconName: "awesome/trash_o";
            enabled:grooveTableview.__listView.currentIndex!==-1?true:false
            onTriggered: delet.show();
        }
    ]
    Keys.onPressed: {
        switch(event.key){
        case Qt.Key_F1:
            open.show();
            event.accepted=true;
            break;
        case Qt.Key_F2:
            save.show();
            event.accepted=true;
            break;
        case Qt.Key_F3:
            copy.show();
            event.accepted=true;
            break;
        case Qt.Key_F4:
            paste.show();
            event.accepted=true;
            break;
        case Qt.Key_F5:
            edit.show();
            event.accepted=true;
            break;
        case Qt.Key_F6:
            delet.show();
            event.accepted=true;
            break;
        }
    }

    Card{
        anchors{left:parent.left;right:parent.right;bottom: parent.bottom;top:parent.top;margins: Units.dp(12)}
        elevation: 2
        Item{
            id:groovepresettitle
            anchors.top:parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height:Units.dp(64);
            Label{
                id:groovepresetlabel
                anchors.left: parent.left
                anchors.leftMargin: Units.dp(24)
                anchors.verticalCenter: parent.verticalCenter
                text:groovestyles[AppConfig.currentGroove]+"坡口参数"
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
        Controls.TableView{
            id:grooveTableview
            //不是隔行插入色彩
            alternatingRowColors:false
            anchors{
                left:parent.left
                leftMargin: Units.dp(5)
                right:parent.right
                rightMargin: Units.dp(5)
                top:groovepresettitle.bottom
                bottom:footer.top //parent.bottom//
            }
            //显示表头
            headerVisible:true
            __listView.add:Transition{
                NumberAnimation { properties: "x"; from:grooveTableview.width-100;duration: 500 }
            }
            __listView.removeDisplaced:Transition{
                NumberAnimation { properties: "y";duration: 500 }
            }
            //Tableview样式
            style:MyTableViewStyle{}
            //选择模式 单选
            selectionMode:Controls.SelectionMode.SingleSelection
            Controls.ExclusiveGroup{  id:checkboxgroup }
            ThinDivider{anchors.bottom:grooveTableview.bottom;color:Palette.colors["grey"]["500"]}
            onRowCountChanged: {
                for(var i=0;i<rowCount;i++)
                    model.set(i,{"ID":(i+1).toString()})
            }
            Controls.TableViewColumn{
                role:"ID"
                title: "No."
                width: Units.dp(120);
                //不可移动
                movable:false
                resizable:false
                delegate: Item{
                    anchors.fill: parent
                    CheckBox{
                        id:checkbox
                        anchors.left: parent.left
                        anchors.leftMargin: Units.dp(16)
                        anchors.verticalCenter: parent.verticalCenter
                        checked: styleData.selected
                        exclusiveGroup:checkboxgroup
                        visible:label.text!==""?true:false
                    }
                    Label{
                        id:label
                        anchors.left: checkbox.right
                        anchors.leftMargin:  Units.dp(24)
                        anchors.verticalCenter: parent.verticalCenter
                        text:styleData.value
                        style:"body1"
                        color: Theme.light.shade(0.87)
                    }
                }
            }
            Controls.TableViewColumn{  role:"C1"; title: "板厚 δ\n (mm)";width:Units.dp(100);movable:false;resizable:false}
            Controls.TableViewColumn{  role:"C2"; title: "板厚差 e\n   (mm)";width:Units.dp(100);movable:false;resizable:false}
            Controls.TableViewColumn{  role:"C3"; title: "间隙 b\n (mm)";width:Units.dp(100);movable:false;resizable:false}
            Controls.TableViewColumn{  role:"C4"; title: "角度 β1\n  (deg)";width:Units.dp(100);movable:false;resizable:false}
            Controls.TableViewColumn{  role:"C5"; title: "角度 β2\n  (deg)";width:Units.dp(100);movable:false;resizable:false}
            Controls.TableViewColumn{  role:"C6"; title: "余高 h\n (mm)";width:Units.dp(100);movable:false;resizable:false}
            Keys.onPressed: {
                var diff = event.key ===Qt.Key_Right ? 50 : event.key === Qt.Key_Left ? -50 :  0
                if(diff !==0){
                    grooveTableview.__horizontalScrollBar.value +=diff;
                    event.accept=true;
                }
            }
        }
        Item{
            id:footer
            height: Units.dp(47)
            anchors{
                left:parent.left
                right:parent.right
                bottom: parent.bottom
            }
            Row{
                anchors{
                    left:parent.left
                    leftMargin: Units.dp(24)
                    verticalCenter: parent.verticalCenter
                }
                spacing: Units.dp(16)
                ProgressCircle{
                    id:progress
                    color: Theme.accentColor
                    visible:root.status==="1"
                }
                Label{
                    id:status
                    text:root.status==="1"?"坡口参数检测中":root.status>"2"?"坡口参数检测完成,坡口长度为"+grooveLength:"坡口检测空闲"
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Label{
                id:footerLabel
                anchors.right: parent.right
                anchors.rightMargin: Units.dp(24)
                anchors.verticalCenter: parent.verticalCenter
                text:"总计："+grooveTableview.rowCount+" 点"
            }
        }
    }
    Dialog{
        id:save
        title: qsTr("坡口参数保存")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        dialogContent:Row{
            spacing: Units.dp(16)
            Icon {
                name: "awesome/file_text_o"
            }
            TextField{
                id:filename

                placeholderText: groovepresetlabel.text
            }
        }
        onAccepted: {
            //保存文件
            UserData.createTable(filename.text,"(ID INT NOT NULL PRIMARY KEY,C1 INT,C2 INT,C3 INT,C4 INT,C5 INT,C6 INT)");
            for(var i=0;i<grooveTableview.model.count;i++){
                UserData.insertTable(filename.text,"(?,?,?,?,?,?,?)",[
                                         Number(grooveTableview.model.get(i).ID),
                                         Number(grooveTableview.model.get(i).C1),
                                         Number(grooveTableview.model.get(i).C2),
                                         Number(grooveTableview.model.get(i).C3),
                                         Number(grooveTableview.model.get(i).C4),
                                         Number(grooveTableview.model.get(i).C5),
                                         Number(grooveTableview.model.get(i).C6)])
            }
        }
    }
    Dialog{
        id:open
        title:qsTr("打开坡口参数")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
    }
    Dialog{
        id:edit
        title: qsTr("编辑坡口参数")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        onAccepted: {
            if(grooveTableview.rowCount>0)
                grooveTableview.model.set(grooveTableview.currentRow,
                                          {"C1":editData[0],"C2":editData[1],
                                              "C3":editData[2],"C4":editData[3],
                                              "C5":editData[4],"C6":editData[5]})
            else{
                grooveTableview.model.insert(0, {"C1":editData[0],"C2":editData[1],
                                                 "C3":editData[2],"C4":editData[3],
                                                 "C5":editData[4],"C6":editData[5]});
            }
        }
        dialogContent: [
            Item{
                width: Units.dp(540)
                height:column.height
                Image{
                    id:image
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    source: "../Pic/坡口参数图.png"
                    sourceSize.width: Units.dp(350)
                }
                Column{
                    id:column
                    anchors.top:parent.top
                    anchors.left: image.right
                    anchors.leftMargin: Units.dp(16)
                    anchors.right: parent.right
                    Repeater{
                        id:columnRepeater
                        model:["板    厚δ(mm)","板厚差e(mm)","余    高h(mm)","角  度β1(deg)","角  度β2(deg)","间    隙b(mm)"]
                        delegate:Row{
                            spacing: Units.dp(8)
                            Label{text:modelData;anchors.bottom: parent.bottom}
                            TextField{text:index===0?grooveTableview.rowCount>0?grooveTableview.model.get(grooveTableview.currentRow).C1:"0":
                                index===1?grooveTableview.rowCount>0?grooveTableview.model.get(grooveTableview.currentRow).C2:"0":
                                index===2?grooveTableview.rowCount>0?grooveTableview.model.get(grooveTableview.currentRow).C3:"0":
                                index===3?grooveTableview.rowCount>0?grooveTableview.model.get(grooveTableview.currentRow).C4:"0":
                                index===4?grooveTableview.rowCount>0?grooveTableview.model.get(grooveTableview.currentRow).C5:"0":
                                grooveTableview.currentRow>=0?grooveTableview.model.get(grooveTableview.currentRow).C6:"0";
                                horizontalAlignment:TextInput.AlignHCenter
                                width: Units.dp(60)
                                inputMethodHints: Qt.ImhDigitsOnly
                                onTextChanged: {
                                    if(edit.showing)
                                        editData[index]=text;
                                }
                            }}
                    }
                }
            }
        ]
    }
    Dialog{
        id:copy
        title: qsTr("复制坡口参数")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        onAccepted: {
            for(var i=0;i<6;i++){
                switch(i){
                case 0:editData[0]=grooveTableview.model.get(grooveTableview.currentRow).C1; break;
                case 1:editData[1]=grooveTableview.model.get(grooveTableview.currentRow).C2; break;
                case 2:editData[2]=grooveTableview.model.get(grooveTableview.currentRow).C3; break;
                case 3:editData[3]=grooveTableview.model.get(grooveTableview.currentRow).C4; break;
                case 4:editData[4]=grooveTableview.model.get(grooveTableview.currentRow).C5; break;
                case 5:editData[5]=grooveTableview.model.get(grooveTableview.currentRow).C6; break;
                }
            }
        }
    }
    Dialog{
        id:paste
        title: qsTr("粘帖坡口参数")
        text:qsTr("粘帖到当前位置")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        onAccepted: {
            grooveTableview.model.insert(grooveTableview.currentRow,
                                         {"ID":(grooveTableview.currentRow+1).toString(),"C1":editData[0],"C2":editData[1],
                                             "C3":editData[2],"C4":editData[3],
                                             "C5":editData[4],"C6":editData[5]})
            grooveTableview.selection.clear();
            grooveTableview.selection.select((grooveTableview.currentRow+1)<grooveTableview.rowCount?grooveTableview.currentRow+1:grooveTableview.currentRow)
        }
    }
    Dialog{
        id:delet
        title: qsTr("删除坡口参数")
        negativeButtonText:qsTr("取消")
        positiveButtonText:qsTr("确定")
        text:qsTr("确认删除操作？\n删除后不可恢复")
        onAccepted: {
            grooveTableview.model.remove(grooveTableview.currentRow);
            grooveTableview.selection.select((grooveTableview.currentRow+1)<grooveTableview.rowCount?grooveTableview.currentRow:grooveTableview.currentRow-1)
        }
    }

}

