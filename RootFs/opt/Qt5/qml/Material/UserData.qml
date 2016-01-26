/*
 * QML Material - An application framework implementing Material Design.
 * Copyright (C) 2014-2015 Michael Spencer <sonrisesoftware@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, either version 2.1 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.4
import QtQuick.LocalStorage 2.0 as Data
pragma Singleton

/*!
   \qmltype Theme
   \inqmlmodule Material 0.1

   \brief Provides access to standard colors that follow the Material Design specification.

   See \l {http://www.google.com/design/spec/style/color.html#color-ui-color-application} for
   details about choosing a color scheme for your application.
 */
Object {
    id: root

    property var dataBase;

    function getPageFunctionAndValueFromTable(index,mode){
        var result,str;
        // var dataBase = Data.LocalStorage.openDatabaseSync("ERoboWeldSysDataBase","1.0","DataBase", 100000);
        // if(!dataBase) { console.log("dataBase::dataBase ");return -1;}
        switch(index){
        case 0:str="select * from flatweldsinglebevelgroovet where ";break;
        case 1:str="select * from flatweldsinglebevelgroove where ";break;
        case 2:str="select * from flatweldvgroove where ";break;
        case 3:str="select * from flatfillet where ";break;
        case 4:str="select * from horizontalweldsinglebevelgroovet where ";break;
        case 5:str="select * from horizontalweldsinglebevelgroove where ";break;
        case 6:str="select * from verticalweldsinglebevelgroovet where ";break;
        case 7:str="select * from verticalweldsinglebevelgroove where ";break;
        case 8:str="select * from verticalweldvgroove where ";break;
        }
        str+=" mode  ="+"\'"+mode+"\'";
        root.dataBase.transaction( function(tx) {result = tx.executeSql(str); });
        /*遍寻所有数据转换成json格式*/
        var json="[";
        for(var i=0;i<result.rows.length;i++){
            json+="\""+result.rows.item(i).function+"\""+",";
        }
            if(json.substr(json.length-1) === ","){
                json = json.substr(0,json.length -1);
            }
            json+="]"
            console.log(json);
            return json;
        }
        /*写入数据库相关词条的数值*/
        function setValueFromFuncOfTable(index,name,value){
            var result,str;
            //  var dataBase = Data.LocalStorage.openDatabaseSync("ERoboWeldSysDataBase","1.0","DataBase", 100000);
            if(!dataBase) { console.log("UserData::dataBase ");return -1;}
            switch(index){
            case 0:str="update flatweldsinglebevelgroovet set setvalue = ";break;
            case 1:str="update flatweldsinglebevelgroove set setvalue = ";break;
            case 2:str="update flatweldvgroove set setvalue = ";break;
            case 3:str="update flatfillet set setvalue = ";break;
            case 4:str="update horizontalweldsinglebevelgroovet set setvalue = ";break;
            case 5:str="update horizontalweldsinglebevelgroove set setvalue = ";break;
            case 6:str="update verticalweldsinglebevelgroovet set setvalue = ";break;
            case 7:str="update verticalweldsinglebevelgroove set setvalue = ";break;
            case 8:str="update verticalweldvgroove set setvalue = ";break;
            }
            str+="\'"+value+"\'"+" where function = "+"\'"+name+"\'";
            //   console.log(str);
            dataBase.transaction( function(tx) {result = tx.executeSql(str); });
        }
        /*从数据库中获取相关词条的数值*/
        function getValueFromFuncOfTable(index,func,name){
            var result,str;
            //    var dataBase = Data.LocalStorage.openDatabaseSync("ERoboWeldSysDataBase","1.0","DataBase", 100000);
            if(!dataBase) { console.log("dataBase::dataBase ");return -1;}
            switch(index){
            case 0:str="select * from flatweldsinglebevelgroovet where ";break;
            case 1:str="select * from flatweldsinglebevelgroove where ";break;
            case 2:str="select * from flatweldvgroove where ";break;
            case 3:str="select * from flatfillet where ";break;
            case 4:str="select * from horizontalweldsinglebevelgroovet where ";break;
            case 5:str="select * from horizontalweldsinglebevelgroove where ";break;
            case 6:str="select * from verticalweldsinglebevelgroovet where ";break;
            case 7:str="select * from verticalweldsinglebevelgroove where ";break;
            case 8:str="select * from verticalweldvgroove where ";break;
            }
            str+=func+" ="+"\'"+name+"\'";
            //    console.log(str);
            dataBase.transaction( function(tx) {result = tx.executeSql(str); });
            //        console.log(result.rows.item(0).setvalue);
            return result.rows.item(0).setvalue;
        }
        /*
      *打开数据库 输入参数 数据名称 版本 描述 类型
      */
        function openDatabase() {
            //创建链接
            root.dataBase = Data.LocalStorage.openDatabaseSync("ERoboWeldSysDataBase","1.0","DataBase", 100000);
            if(root.dataBase)  {
                console.log("dataBase::Open dataBase Success .");
            }
            else{
                console.log("dataBase::Open dataBase Fail .");
            }
        }
    }
