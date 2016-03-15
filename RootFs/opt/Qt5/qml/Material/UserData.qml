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
/*
 * 作者：陈世豪
 * 部门：开发科
 * 项目名称：便携式MAG焊接机器人系统
 * 时间：2015年7月31日
 * 描述：该文件能够实现QML对SQL数据库操作：
 *                                	1:创建初始化
 *                                	2:读取
 *                                	3:写入
 * 注意事项：存储路径~/.local/share/localstorage/QML/OfflineStorage/Databases/
 * 命令： CREATE TABLE IF NOT EXISTS 创建如过不存在
 *        INSERT INTO  tartget // 想追加记录的表或视图的名称
 *                            【IN externaldatabase】 //外部数据库名称
 *                                                   VALUES
 *        SELECT 【DISTINCT】 //指定要选择的列或者行及其限定 *代表通配符
 *                            FROM table_source //FORM语句 指定表或者视图
 *                                               【WHERE search_condition】WHERE语句//指定查询条件
 *        DELETE  FROM table_names //删除条目
 *                【WHERE】
 *        UPDATE  table_names //更新表中记录
 *                            SET Fild = expression ..  //设定 fild需要更新的字段 expression要更新的新值表达式
 *                                                                【WHERE】
*/

Object {
    id: root

    property var dataBase;

    function getPageFunctionAndValueFromTable(index,mode){
        var result,str;
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
        str+= " mode  ="+"\'"+mode+"\'";
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
        function setValueFromFuncOfTable(tablename,func,value){
            var result,str;
            if(!dataBase) { console.log("UserData::dataBase ");return -1;}
            str="UPDATE "+tablename+" SET setvalue = "+"\'"+value+"\'"+" where function = "+"\'"+func+"\'";
            console.log(str);
            dataBase.transaction( function(tx) {result = tx.executeSql(str); });
        }
        /*从数据库中获取相关词条的数值
          * name 数据表格名字，func 定义的名字 setvalue设定数值
         */
        function getValueFromFuncOfTable(tablename,func,name){
            var result,str;
            if(!dataBase) { console.log("dataBase::dataBase ");return -1;}
            str="SELECT * FROM "+tablename+" WHERE "+func+" ="+"\'"+name+"\'";
            console.log(str);
            dataBase.transaction( function(tx) {result = tx.executeSql(str); });
            console.log(result.rows.item(0).setvalue);
            return result.rows.item(0).setvalue;
        }
        /*
      *打开数据库 输入参数 数据名称 版本 描述 类型
      */
        function openDatabase() {
            //创建链接
            root.dataBase = Data.LocalStorage.openDatabaseSync("ERoboWeldSysDataBase","1.0","DataBase", 100000);
            if(root.dataBase)  {console.log("dataBase::Open dataBase Success .");return 1 }
            else{ console.log("dataBase::Open dataBase Fail .");return -1;}
        }
        /*
          *根据输入参数 创建数据库 参数库不存在 则返回-1 成功返回1
          */
        function createTable(tablename){
            if(!root.dataBase){ console.log("dataBase::dataBase ");return -1;}
            var str="CREATE TABLE IF NOT EXISTS "+tablename+"(function TEXT,\
                                                                setvalue TEXT,max TEXT,min TEXT,step TEXT,init TEXT,description TEXT)"
            dataBase.transaction( function(tx) {tx.executeSql(str); });
        }
        /*
          *插入指定参数到数据库 数据库不存在则返回-1
          */
        function insertTable(tablename,fuc,set,max,min,step,init,description){
            if(!root.dataBase){ console.log("dataBase::dataBase ");return -1;}
            var str="INSERT INTO "+tablename+" VALUES(?,?,?,?,?,?,?)"
            dataBase.transaction( function(tx) {tx.executeSql(str,[fuc,set,max,min,step,init,description]);});
        }
    }

