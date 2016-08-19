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
 *                                 4:删除
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

    property var grooveName: ["flatweldsinglebevelgroovet","flatweldsinglebevelgroove","flatweldvgroove","horizontalweldsinglebevelgroovet","horizontalweldsinglebevelgroove","verticalweldsinglebevelgroovet","verticalweldsinglebevelgroove","verticalweldvgroove","flatfillet"]

    function getPageFunctionAndValueFromTable(index){
        var result,str;
        if(!dataBase) { console.log("dataBase::dataBase ");return -1;}
        switch(index){
        case 0:str="select * from flatweldsinglebevelgroovet";break;
        case 1:str="select * from flatweldsinglebevelgroove";break;
        case 2:str="select * from flatweldvgroove";break;
        case 3:str="select * from horizontalweldsinglebevelgroovet";break;
        case 4:str="select * from horizontalweldsinglebevelgroove";break;
        case 5:str="select * from verticalweldsinglebevelgroovet";break;
        case 6:str="select * from verticalweldsinglebevelgroove";break;
        case 7:str="select * from verticalweldvgroove";break;
        case 8:str="select * from flatfillet";break;
        }
        root.dataBase.transaction( function(tx) {result = tx.executeSql(str); });
        /*遍寻所有数据转换成json格式*/
        var json="[";
        for(var i=0;i<result.rows.length;i++){
            json+="\""+result.rows.item(i)+"\""+",";
        }
        if(json.substr(json.length-1) === ","){
            json = json.substr(0,json.length -1);
        }
        json+="]"
        return json;
    }
    /*写入数据库相关词条的数值*/
    function setValueFromFuncOfTable(tablename,id,value){
        var result,str;
        if(!dataBase) { console.log("UserData::dataBase ");return -1;}
        str="UPDATE "+tablename+" SET value = "+"\'"+value+"\'"+" WHERE id = "+"\'"+id+"\'";
        console.log(str);
        dataBase.transaction( function(tx) {result = tx.executeSql(str); });
    }
    /*写入数据库相关词条的数值*/
    function setValue(tablename,id,value){
        var result,str;
        if(!dataBase) { console.log("UserData::dataBase ");return -1;}
        str="UPDATE "+tablename+" SET Time = "+"\'"+value+"\'"+" WHERE Name = "+"\'"+id+"\'";
        console.log(str);
        dataBase.transaction( function(tx) {result = tx.executeSql(str); });
    }
    /*从数据库中获取相关词条的数值
          * name 数据表格名字，func 定义的名字 setvalue设定数值
         */
    function getValueFromFuncOfTable(tablename,func,name){
        var result,str;
        var value=new Array();
        if(!dataBase) { console.log("dataBase::dataBase ");return -1;}
        str="SELECT * FROM "+tablename;
        if(func!=="")
            str+=" WHERE "+func+" ="+"\'"+name+"\'";
        console.log(str);
        dataBase.transaction( function(tx) {result = tx.executeSql(str); });
        for(var i=0;i<result.rows.length;i++){
            value.push(result.rows.item(i).value)
        }
        console.log(value);
        return value;
    }
    /*从数据库中获取相关词条的数值
          * name 数据表格名字，func 定义的名字
         */
    function getResultFromFuncOfTable(tablename,func,name){
        var result,str;
        if(!dataBase) { console.log("dataBase::dataBase ");return -1;}
        str="SELECT * FROM "+tablename;
        if(func!=="")
            str+= " WHERE "+func+" ="+"\'"+name+"\'";
        console.log(str);
        dataBase.transaction( function(tx) {result = tx.executeSql(str); });
        return result;
    }
    /**
      *从数据库中获取 焊接规范列表
      */
    function getWeldRules(tablename){
        var result,str;
        if(!dataBase) { console.log("dataBase::dataBase ");return -1;}
        str="SELECT * FROM "+tablename;
        dataBase.transaction( function(tx) {result = tx.executeSql(str); });
        var value=new Array();
        /*遍寻所有数据转换成json格式*/
        for(var i=0;i<result.rows.length;i++){
            //result.rows.item返回的就是json object不需要在弄
            value.push(result.rows.item(i));
        }
        return value;
    }
    /**
      *从数据库中获取 焊接规范
      */
    function getWeldRulesListName(tablename){
        var result,str;
        if(!dataBase) { console.log("dataBase::dataBase ");return -1;}
        str="SELECT * FROM "+tablename+" ORDER BY Time DESC";
        dataBase.transaction( function(tx) {result = tx.executeSql(str); });
        var value=new Array();
        for(var i=0;i<result.rows.length;i++){
            value.push(String(result.rows.item(i).Name)+"."+String(result.rows.item(i).Time));
        }
        console.log(value);
        return value;
    }

    /*
    *从数据表中获取最近的头条信息 以时间顺序排列
    */
    function getLastWeldRulesName(tablename){
        var error,result;
        if(!dataBase) { console.log("dataBase::dataBase ");return -1;}
        dataBase.transaction( function(tx) {
            result = tx.executeSql("SELECT * FROM "+tablename+" ORDER BY Time DESC");
        });
        if(result.rows.length){
            return result.rows.item(0).Name;
        }else
            return -1;
    }
    //    /*
    //      *检索list里面是否已经包含当前名称
    //      */
    //    function findWeldRulesName(tablename,func){
    //        var result
    //        if(!dataBase) { console.log("dataBase::dataBase ");return -1;}
    //        dataBase.transaction( function(tx) {
    //            result = tx.executeSql("SELECT * FROM "+tablename+"");
    //        });
    //    }

    /*
      *打开数据库 输入参数 数据名称 版本 描述 类型
      */
//    function openDatabase(databaseName) {
//        //创建链接
//        root.dataBase = Data.LocalStorage.openDatabaseSync("ERoboWeldSysDataBase","1.0","DataBase", 10000000);
//        if(root.dataBase)  {console.log("dataBase::Open dataBase Success .");return 1 }
//        else{ console.log("dataBase::Open dataBase Fail .");return -1;}

//    }
    /*
          *根据输入参数 创建数据库 参数库不存在 则返回-1 成功返回1
          */
    function createTable(tablename,format){
        if(!root.dataBase){ console.log("dataBase::dataBase ");return -1;}
        if((tablename!=="")&&(format!=="")){
            var str="CREATE TABLE IF NOT EXISTS "+tablename+"("+format+")";
            dataBase.transaction( function(tx) {tx.executeSql(str);});
        }else
            return -1;
    }
    /*删除数据表数据 当func与value有效时删除func为value所在行数据，否则删除表内所有数据但是表格保留*/
    function clearTable(tablename,func,value){
        if(!root.dataBase){ console.log("dataBase::dataBase ");return -1;}
        if(tablename!==""){
            var str="DELETE FROM "+tablename;
            if((func!=="")&&(value!=="")){
                str+=" WHERE "+func+" = "+"\'"+value+"\'";
            }
            console.log(str)
            dataBase.transaction( function(tx) { tx.executeSql(str);})
        }
    }
    /*删除整个数据表格*/
    function deleteTable(tablename){
        if(!root.dataBase){ console.log("dataBase::dataBase ");return -1;}
        if(tablename!==""){
            var str="DROP TABLE "+tablename;
            dataBase.transaction( function(tx) {tx.executeSql(str);})
        }
    }
    /*
          *插入指定参数到数据库 数据库不存在则返回-1
          操作格式 func (?,?) data 为数组[,]
          */
    function insertTable(tablename,func,data){
        if(!root.dataBase){ console.log("dataBase::dataBase ");return -1;}
        var str="INSERT INTO "+tablename+" VALUES"+func;
        console.log(str)
        dataBase.transaction( function(tx) { tx.executeSql(str,data);});
    }
    function changeTable(tablename,func,data){
        if(!root.dataBase){ console.log("dataBase::dataBase ");return -1;}
        //        for(var i=0;i<9;i++){
        //            var str="UPDATE "+grooveName[i]+" SET "+name+" = "+"\'"+set+"\'"
        //            //+", max = "+"\'"+max+"\'"+", min = "+"\'"+min+"\'"+", step = "+"\'"+step+"\'"+", init = "+"\'"+init+"\'"
        //            str=str+" WHERE function = "+"\'"+func+"\'";
        //            console.log(str)
        //            dataBase.transaction( function(tx) {tx.executeSql(str);});
        //        }
        var str="UPDATE "+tablename+" SET";//+" WHERE function = "+"\'"+func+"\'";
        console.log(str)
        dataBase.transaction( function(tx) { tx.executeSql(str);});
    }
    /*
         *打开数据库 输入参数 数据名称 版本 描述 类型
         */
    function openDatabase() {
        var table;
        var error=-1;
        //创建链接
         root.dataBase = Data.LocalStorage.openDatabaseSync("ERoboWeldSysDataBase","1.0","DataBase", 100000);
        if(root.dataBase)  {
            console.log("DB::Open DB Success .");
        }
        else{
            console.log("DB::Open DB Fail .");
        }
        dataBase.transaction( function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS TeachCondition(id INT NOT NULL PRIMARY KEY,value NUMERIC(6,2))');
            table = tx.executeSql("select * from TeachCondition");
            //坡口参数初始值设置
            /**********************************************示教条件*************************************************/
            if(table.rows.length === 0)
            {
                //示教模式
                tx.executeSql('insert into TeachCondition values(?,?)', [0,0]);
                //始终端检测
                tx.executeSql('insert into TeachCondition values(?,?)',[1,0]);
                //示教第1点位置
                tx.executeSql('insert into TeachCondition values(?,?)',[2,0]);
                //示教1点时焊接长（mm）
                tx.executeSql('insert into TeachCondition values(?,?)',[3,300]);
                //示教点数
                tx.executeSql('insert into TeachCondition values(?,?)', [4,2]);
                //坡口检测点左（mm）
                tx.executeSql('insert into TeachCondition values(?,?)',[5,-10]);
                //坡口检测点右（mm）
                tx.executeSql('insert into TeachCondition values(?,?)', [6,-10]);
                //板厚（mm）
                tx.executeSql('insert into TeachCondition values(?,?)',[7,200]);
                //余高（mm）
                tx.executeSql('insert into TeachCondition values(?,?)', [8,1]);
                //板厚补正（mm）
                tx.executeSql('insert into TeachCondition values(?,?)',[9,0]);
                //角度补正（度）
                tx.executeSql('insert into TeachCondition values(?,?)', [10,0]);
                //间隙补正（mm）
                tx.executeSql('insert into TeachCondition values(?,?)', [11,0]);
            }
            else{
                  console.log("Skip Create TeachCondition Table .");
            }

            /*******************************************焊接条件*****************************************************/
            tx.executeSql('CREATE TABLE IF NOT EXISTS WeldCondition(id INT NOT NULL PRIMARY KEY,value NUMERIC(6,2))');
            table = tx.executeSql("select * from WeldCondition");
            if(table.rows.length === 0){
                //头部摆动
                tx.executeSql('insert into WeldCondition values(?,?)',[0,1]);
                //机器人设置面
                tx.executeSql('insert into WeldCondition values(?,?)',[1,0]);
                //焊接动作（往返/单程）
                tx.executeSql('insert into WeldCondition values(?,?)',[2,0]);
                //电弧跟踪
                tx.executeSql('insert into WeldCondition values(?,?)',[3,0]);
                //溶敷系数
                tx.executeSql('insert into WeldCondition values(?,?)',[4,100]);
                //焊接电流偏置（A）
                tx.executeSql('insert into WeldCondition values(?,?)',[5,0]);
                //焊接电压偏置（V）
                tx.executeSql('insert into WeldCondition values(?,?)',[6,0]);
                //焊丝
                tx.executeSql('insert into WeldCondition values(?,?)',[7,0]);
                //焊丝直径
                tx.executeSql('insert into WeldCondition values(?,?)',[8,0]);
                //焊丝长度（mm）
                tx.executeSql('insert into WeldCondition values(?,?)',[9,0]);
                //焊丝焊缝检测机能
                tx.executeSql('insert into WeldCondition values(?,?)',[10,0]);
                //保护气体
                tx.executeSql('insert into WeldCondition values(?,?)',[11,0]);

                //焊接始终端偏左（mm）
                tx.executeSql('insert into WeldCondition values(?,?)',[12,0]);
                //焊接始终端偏右（mm）
                tx.executeSql('insert into WeldCondition values(?,?)',[13,0]);
                //焊缝背面成型
                tx.executeSql('insert into WeldCondition values(?,?)',[14,0]);
                //连续焊接时间
                tx.executeSql('insert into WeldCondition values(?,?)',[15,0]);
                //连续焊接层数
                tx.executeSql('insert into WeldCondition values(?,?)',[16,0]);
                //层间停止时间（秒）
                tx.executeSql('insert into WeldCondition values(?,?)',[17,0]);
                //最终层前停止时间（秒）
                tx.executeSql('insert into WeldCondition values(?,?)',[18,0]);
                //表面锥度非对应机能
                tx.executeSql('insert into WeldCondition values(?,?)',[19,0]);
                //电弧跟踪控制纠正量（mm）
                tx.executeSql('insert into WeldCondition values(?,?)',[20,0]);

                //X左梯形平移（度）
                tx.executeSql('insert into WeldCondition values(?,?)',[21,0]);
                //X右梯形平移（度）
                tx.executeSql('insert into WeldCondition values(?,?)',[22,0]);
                //Y左梯形平移（度）
                tx.executeSql('insert into WeldCondition values(?,?)',[23,0]);
                //Y右梯形平移（度）
                tx.executeSql('insert into WeldCondition values(?,?)',[24,0]);

                //初层（陶瓷衬垫）-间隔
                tx.executeSql('insert into WeldCondition values(?,?)',[25,0]);
                //初层（钢衬垫）-间隔
                tx.executeSql('insert into WeldCondition values(?,?)',[26,0]);
                //初层以外-间隔
                tx.executeSql('insert into WeldCondition values(?,?)',[27,0]);
                /*
                                 *  A= 30~40       A=45~60
                                 *  T=9~80mm   T=9~50mm
                                 *  B=4~10mm   B=0~2mm
                                 */
            }
            else{
                 console.log("Skip Create WeldCondition Table .");
            }
            /********************************************错误检测*********************************************/
            tx.executeSql('CREATE TABLE IF NOT EXISTS CheckError(id INT NOT NULL PRIMARY KEY,value NUMERIC(6,2))');
            table = tx.executeSql("select * from CheckError");
            if(table.rows.length === 0){
                //板面高
                tx.executeSql('insert into CheckError values(?,?)',[0,5.0]);
                //板面下降量
                tx.executeSql('insert into CheckError values(?,?)',[1,6.0]);
                //坡口检测上高
                tx.executeSql('insert into CheckError values(?,?)',[2,2.0]);
                //坡口检测下高
                tx.executeSql('insert into CheckError values(?,?)',[3,3.0]);
                //底面检测时立板距离
                tx.executeSql('insert into CheckError values(?,?)',[4,5.0]);
                //检测错误板厚左右差--最小
                tx.executeSql('insert into CheckError values(?,?)',[5,2.0]);
                //检测错误板厚左右差--最大
                tx.executeSql('insert into CheckError values(?,?)',[6,7.0]);
                //检测错误板厚容许值--最小
                tx.executeSql('insert into CheckError values(?,?)',[7,0.0]);
                //检测错误板厚容许值--最大
                tx.executeSql('insert into CheckError values(?,?)',[8,0.0]);
                //检测错误板厚差左右差--最小
                tx.executeSql('insert into CheckError values(?,?)',[9,4.0]);
                //检测错误板厚差左右差--最大
                tx.executeSql('insert into CheckError values(?,?)',[10,7.0]);
                //检测错误板厚差容许值--最小
                tx.executeSql('insert into CheckError values(?,?)',[11,0.0]);
                //检测错误板厚差容许值--最大
                tx.executeSql('insert into CheckError values(?,?)',[12,0.0]);
                //检测错误角度左右差--最小
                tx.executeSql('insert into CheckError values(?,?)',[13,5.0]);
                //检测错误角度左右差--最大
                tx.executeSql('insert into CheckError values(?,?)',[14,10.0]);
                //检测错误角度容许值--最小
                tx.executeSql('insert into CheckError values(?,?)',[15,28.0]);
                //检测错误角度容许值--最大
                tx.executeSql('insert into CheckError values(?,?)',[16,65.0]);
                //检测错误间隙左右差--最小
                tx.executeSql('insert into CheckError values(?,?)',[17,6.0]);
                //检测错误间隙左右差--最大
                tx.executeSql('insert into CheckError values(?,?)',[18,12.0]);
                //检测错误间隙容许值--最小
                tx.executeSql('insert into CheckError values(?,?)',[19,4.0]);
                //检测错误间隙容许值--最大
                tx.executeSql('insert into CheckError values(?,?)',[20,10.0]);
            }else{
                 console.log("Skip Create CheckError Table .");
            }

            /********************************************平焊单边V型坡口T接头*********************************************/
            tx.executeSql('CREATE TABLE IF NOT EXISTS FlatWeldSingleBevelGrooveT(id INT NOT NULL PRIMARY KEY,value NUMERIC(6,2))');
            table = tx.executeSql("select * from FlatWeldSingleBevelGrooveT");
            if(table.rows.length === 0){
                /***************************************************焊接规范限制**********************************************/
                //初层陶衬垫电流前侧
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[0,230]);
                //初层陶衬垫电流中间
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[1,230]);
                //初层陶衬垫电流后侧
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[2,230]);
                //初层陶衬垫端部停止时间前（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[3,400]);
                //初层陶衬垫端部停止时间后（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[4,400]);
                //初层陶衬垫堆高MAX
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[5,9.0]);
                //初层陶衬垫接近-前
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[6,2.0]);
                //初层陶衬垫接近-后
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[7,2.0]);
                //初层陶衬垫分开最大摆动宽度
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[8,20.0]);
                //初层陶衬垫摆动宽度间隔
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[9,100.0]);
                //初层陶衬垫分开结束/开始比
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[10,0.85]);
                //初层陶衬垫焊接电压  0代表自动设定
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[11,0]);

                //初层电流前侧
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[12,300]);
                //初层电流中间
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[13,300]);
                //初层电流后侧
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[14,300]);
                //初层端部停止时间前（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[15,500]);
                //初层端部停止时间后（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[16,0]);
                //初层堆高MAX
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[17,7.0]);
                //初层接近-前
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[18,1.0]);
                //初层接近-后
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[19,2.0]);
                //初层分开最大摆动宽度
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[20,20.0]);
                //初层摆动宽度间隔
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[21,100.0]);
                //初层分开结束/开始比
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[22,1.0]);
                //初层焊接电压
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[23,0]);

                //第二层电流前侧
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[24,290]);
                //第二层电流中间
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[25,290]);
                //第二层电流后侧
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[26,290]);
                //第二层端部停止时间前（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[27,100]);
                //第二层端部停止时间后（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[28,100]);
                //第二层堆高MAX
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[29,5.0]);
                //第二层接近-前
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[30,1.0]);
                //第二层接近-后
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[31,2.0]);
                //第二层分开最大摆动宽度
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[32,16.0]);
                //第二层摆动宽度间隔
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[33,5.0]);
                //第二层分开结束/开始比
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[34,0.85]);
                //第二层焊接电压
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[35,0]);

                //中间层电流前侧
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[36,290]);
                //中间层电流中间
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[37,290]);
                //中间层电流后侧
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[38,290]);
                //中间层端部停止时间前（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[39,100]);
                //中间层端部停止时间后（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[40,100]);
                //中间层堆高MAX
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[41,5.0]);
                //中间层接近-前
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[42,1.0]);
                //中间层接近-后
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[43,2.0]);
                //中间层分开最大摆动宽度
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[44,16.0]);
                //中间层摆动宽度间隔
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[45,5.0]);
                //中间层分开结束/开始比
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[46,0.85]);
                //中间层焊接电压
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[47,0]);

                //表面层电流前侧
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[48,280]);
                //表面层电流中间
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[49,280]);
                //表面层电流后侧
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[50,280]);
                //表面层端部停止时间前（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[51,0]);
                //表面层端部停止时间后（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[52,0]);
                //表面层堆高MAX
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[53,4.0]);
                //表面层接近-前
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[54,2.0]);
                //表面层接近-后
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[55,2.0]);
                //表面层分开最大摆动宽度
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[56,11.0]);
                //表面层摆动宽度间隔
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[57,5.0]);
                //表面层分开结束/开始比
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[58,1.0]);
                //表面层焊接电压
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[59,0]);

                //表面层余高层数
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[60,0]);
                //表面层分开方向 0 反方向 1标准
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[61,0]);
                //表面层起弧位置  00代表收弧位置
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[62,0]);
                //开始位置坐标X（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[63,4.0]);
                //开始位置坐标Y（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[64,0.0]);
                //开始位置坐标z（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[65,-3.0]);
                //表面层收弧动作 0 单程 1往返
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[66,0]);
                //表面层返回步骤距离
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[67,5.0]);

                //立板余高层电流前侧
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[68,250]);
                //立板余高层电流中间
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[69,250]);
                //立板余高层电流后侧
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[70,250]);
                //立板余高层端部停止时间前（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[71,0.0]);
                //立板余高层端部停止时间后（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[72,0.0]);
                //立板余高层堆高MAX
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[73,5.0]);
                //立板余高层接近-前
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[74,2.0]);
                //立板余高层接近-后
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[75,15.0]);
                //立板余高层分开最大摆动宽度
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[76,10.0]);
                //立板余高层摆动宽度间隔
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[77,5.0]);
                //立板余高层分开结束/开始比
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[78,1.0]);
                //立板余高层焊接电压
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[79,0]);
                //立板余高层MAX焊接速度
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?)',[80,500.0]);

                /***************************************************焊接规范列表**********************************************/
            }else{
                console.log("Skip Create FlatWeldSingleBevelGrooveT Table .");}
            /********************************************帐户表格***************************************************/
            tx.executeSql('CREATE TABLE IF NOT EXISTS accountTable(name TEXT NOT NULL PRIMARY KEY,password TEXT,type TEXT)');
            table = tx.executeSql("select * from accountTable");
            if(table.rows.length === 0){
                //TKSW
                tx.executeSql('insert into accountTable values(?,?,?)',["TKSW","TKSW","SuperUser"]);
                //ADMIN
                tx.executeSql('insert into accountTable values(?,?,?)',["Nop","Nop","User"]);
            }else{
                console.log("Skip Create accountTable Table .");}
            tx.executeSql('CREATE TABLE IF NOT EXISTS flatweldsinglebevelgroove(id INT NOT NULL PRIMARY KEY,value NUMERIC(6,2))');
            table = tx.executeSql("select * from flatweldsinglebevelgroove");
            if(table.rows.length === 0){
                /***************************************************焊接规范限制**********************************************/
                //初层陶衬垫电流前侧
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[0,230]);
                //初层陶衬垫电流中间
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[1,230]);
                //初层陶衬垫电流后侧
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[2,230]);
                //初层陶衬垫端部停止时间前（ms）
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[3,500]);
                //初层陶衬垫端部停止时间后（ms）
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[4,500]);
                //初层陶衬垫堆高MAX
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[5,8.5]);
                //初层陶衬垫接近-前
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[6,2.0]);
                //初层陶衬垫接近-后
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[7,2.5]);
                //初层陶衬垫分开最大摆动宽度
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[8,20.0]);
                //初层陶衬垫摆动宽度间隔
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[9,100.0]);
                //初层陶衬垫分开结束/开始比
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[10,0.85]);
                //初层陶衬垫焊接电压  0代表自动设定
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[11,28]);


                //初层电流前侧
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[12,300]);
                //初层电流中间
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[13,300]);
                //初层电流后侧
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[14,300]);
                //初层端部停止时间前（ms）
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[15,200]);
                //初层端部停止时间后（ms）
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[16,200]);
                //初层堆高MAX
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[17,7.0]);
                //初层接近-前
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[18,2.0]);
                //初层接近-后
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[19,2.0]);
                //初层分开最大摆动宽度
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[20,20.0]);
                //初层摆动宽度间隔
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[21,100.0]);
                //初层分开结束/开始比
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[22,1.0]);
                //初层焊接电压
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[23,0]);

                //第二层电流前侧
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[24,290]);
                //第二层电流中间
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[25,290]);
                //第二层电流后侧
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[26,290]);
                //第二层端部停止时间前（ms）
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[27,100]);
                //第二层端部停止时间后（ms）
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[28,100]);
                //第二层堆高MAX
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[29,5.0]);
                //第二层接近-前
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[30,1.0]);
                //第二层接近-后
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[31,1.0]);
                //第二层分开最大摆动宽度
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[32,16.0]);
                //第二层摆动宽度间隔
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[33,5.0]);
                //第二层分开结束/开始比
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[34,0.85]);
                //第二层焊接电压
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[35,0]);

                //中间层电流前侧
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[36,290]);
                //中间层电流中间
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[37,290]);
                //中间层电流后侧
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[38,290]);
                //中间层端部停止时间前（ms）
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[39,100]);
                //中间层端部停止时间后（ms）
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[40,100]);
                //中间层堆高MAX
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[41,5.0]);
                //中间层接近-前
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[42,1.0]);
                //中间层接近-后
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[43,1.0]);
                //中间层分开最大摆动宽度
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[44,16.0]);
                //中间层摆动宽度间隔
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[45,5.0]);
                //中间层分开结束/开始比
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[46,0.85]);
                //中间层焊接电压
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[47,0]);

                //表面层电流前侧
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[48,280]);
                //表面层电流中间
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[49,280]);
                //表面层电流后侧
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[50,280]);
                //表面层端部停止时间前（ms）
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[51,100]);
                //表面层端部停止时间后（ms）
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[52,100]);
                //表面层堆高MAX
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[53,4.0]);
                //表面层接近-前
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[54,2.0]);
                //表面层接近-后
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[55,2.0]);
                //表面层分开最大摆动宽度
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[56,16.0]);
                //表面层摆动宽度间隔
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[57,5.0]);
                //表面层分开结束/开始比
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[58,1.0]);
                //表面层焊接电压
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[59,0]);

                //表面层余高层数
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[60,0]);
                //表面层分开方向 0 反方向 1标准
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[61,0]);
                //表面层起弧位置  00代表收弧位置
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[62,0]);
                //开始位置坐标X（mm）
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[63,4.0]);
                //开始位置坐标Y（mm）
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[64,0.0]);
                //开始位置坐标z（mm）
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[65,-3.0]);
                //表面层收弧动作 0 单程 1往返
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[66,0]);
                //表面层返回步骤距离
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[67,5.0]);


                //立板余高层电流前侧
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[68,0]);
                //立板余高层电流中间
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[69,0]);
                //立板余高层电流后侧
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[70,0]);
                //立板余高层端部停止时间前（ms）
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[71,0]);
                //立板余高层端部停止时间后（ms）
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[72,0]);
                //立板余高层堆高MAX
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[73,0]);
                //立板余高层接近-前
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[74,0]);
                //立板余高层接近-后
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[75,0]);
                //立板余高层分开最大摆动宽度
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[76,0]);
                //立板余高层摆动宽度间隔
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[77,0]);
                //立板余高层分开结束/开始比
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[78,0]);
                //立板余高层焊接电压
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[79,0]);
                //立板余高层MAX焊接速度
                tx.executeSql('insert into flatweldsinglebevelgroove values(?,?)',[80,0]);
                /***************************************************焊接规范列表**********************************************/
            }
            else{
                     console.log("Skip Create flatweldsinglebevelgroove Table .");}
            tx.executeSql('CREATE TABLE IF NOT EXISTS flatweldvgroove(id INT NOT NULL PRIMARY KEY,value NUMERIC(6,2))');
            table = tx.executeSql("select * from flatweldvgroove");
            if(table.rows.length === 0){
                /***************************************************焊接规范限制**********************************************/
                //初层陶衬垫电流前侧
                tx.executeSql('insert into flatweldvgroove values(?,?)',[0,230]);
                //初层陶衬垫电流中间
                tx.executeSql('insert into flatweldvgroove values(?,?)',[1,230]);
                //初层陶衬垫电流后侧
                tx.executeSql('insert into flatweldvgroove values(?,?)',[2,230]);
                //初层陶衬垫端部停止时间前（ms）
                tx.executeSql('insert into flatweldvgroove values(?,?)',[3,400]);
                //初层陶衬垫端部停止时间后（ms）
                tx.executeSql('insert into flatweldvgroove values(?,?)',[4,400]);
                //初层陶衬垫堆高MAX
                tx.executeSql('insert into flatweldvgroove values(?,?)',[5,9.0]);
                //初层陶衬垫接近-前
                tx.executeSql('insert into flatweldvgroove values(?,?)',[6,2.0]);
                //初层陶衬垫接近-后
                tx.executeSql('insert into flatweldvgroove values(?,?)',[7,2.0]);
                //初层陶衬垫分开最大摆动宽度
                tx.executeSql('insert into flatweldvgroove values(?,?)',[8,20.0]);
                //初层陶衬垫摆动宽度间隔
                tx.executeSql('insert into flatweldvgroove values(?,?)',[9,100.0]);
                //初层陶衬垫分开结束/开始比
                tx.executeSql('insert into flatweldvgroove values(?,?)',[10,0.85]);
                //初层陶衬垫焊接电压  0代表自动设定
                tx.executeSql('insert into flatweldvgroove values(?,?)',[11,28]);

                //初层电流前侧
                tx.executeSql('insert into flatweldvgroove values(?,?)',[12,300]);
                //初层电流中间
                tx.executeSql('insert into flatweldvgroove values(?,?)',[13,300]);
                //初层电流后侧
                tx.executeSql('insert into flatweldvgroove values(?,?)',[14,300]);
                //初层端部停止时间前（ms）
                tx.executeSql('insert into flatweldvgroove values(?,?)',[15,200]);
                //初层端部停止时间后（ms）
                tx.executeSql('insert into flatweldvgroove values(?,?)',[16,200]);
                //初层堆高MAX
                tx.executeSql('insert into flatweldvgroove values(?,?)',[17,7.0]);
                //初层接近-前
                tx.executeSql('insert into flatweldvgroove values(?,?)',[18,2.0]);
                //初层接近-后
                tx.executeSql('insert into flatweldvgroove values(?,?)',[19,2.0]);
                //初层分开最大摆动宽度
                tx.executeSql('insert into flatweldvgroove values(?,?)',[20,20.0]);
                //初层摆动宽度间隔
                tx.executeSql('insert into flatweldvgroove values(?,?)',[21,100.0]);
                //初层分开结束/开始比
                tx.executeSql('insert into flatweldvgroove values(?,?)',[22,1.0]);
                //初层焊接电压
                tx.executeSql('insert into flatweldvgroove values(?,?)',[23,0]);

                //第二层电流前侧
                tx.executeSql('insert into flatweldvgroove values(?,?)',[24,290]);
                //第二层电流中间
                tx.executeSql('insert into flatweldvgroove values(?,?)',[25,290]);
                //第二层电流后侧
                tx.executeSql('insert into flatweldvgroove values(?,?)',[26,290]);
                //第二层端部停止时间前（ms）
                tx.executeSql('insert into flatweldvgroove values(?,?)',[27,100]);
                //第二层端部停止时间后（ms）
                tx.executeSql('insert into flatweldvgroove values(?,?)',[28,100]);
                //第二层堆高MAX
                tx.executeSql('insert into flatweldvgroove values(?,?)',[29,5.0]);
                //第二层接近-前
                tx.executeSql('insert into flatweldvgroove values(?,?)',[30,1.0]);
                //第二层接近-后
                tx.executeSql('insert into flatweldvgroove values(?,?)',[31,1.0]);
                //第二层分开最大摆动宽度
                tx.executeSql('insert into flatweldvgroove values(?,?)',[32,16.0]);
                //第二层摆动宽度间隔
                tx.executeSql('insert into flatweldvgroove values(?,?)',[33,5.0]);
                //第二层分开结束/开始比
                tx.executeSql('insert into flatweldvgroove values(?,?)',[34,0.85]);
                //第二层焊接电压
                tx.executeSql('insert into flatweldvgroove values(?,?)',[35,0]);

                //中间层电流前侧
                tx.executeSql('insert into flatweldvgroove values(?,?)',[36,290]);
                //中间层电流中间
                tx.executeSql('insert into flatweldvgroove values(?,?)',[37,290]);
                //中间层电流后侧
                tx.executeSql('insert into flatweldvgroove values(?,?)',[38,290]);
                //中间层端部停止时间前（ms）
                tx.executeSql('insert into flatweldvgroove values(?,?)',[39,100]);
                //中间层端部停止时间后（ms）
                tx.executeSql('insert into flatweldvgroove values(?,?)',[40,100]);
                //中间层堆高MAX
                tx.executeSql('insert into flatweldvgroove values(?,?)',[41,4.0]);
                //中间层接近-前
                tx.executeSql('insert into flatweldvgroove values(?,?)',[42,2.0]);
                //中间层接近-后
                tx.executeSql('insert into flatweldvgroove values(?,?)',[43,2.0]);
                //中间层分开最大摆动宽度
                tx.executeSql('insert into flatweldvgroove values(?,?)',[44,14.0]);
                //中间层摆动宽度间隔
                tx.executeSql('insert into flatweldvgroove values(?,?)',[45,5.0]);
                //中间层分开结束/开始比
                tx.executeSql('insert into flatweldvgroove values(?,?)',[46,1.0]);
                //中间层焊接电压
                tx.executeSql('insert into flatweldvgroove values(?,?)',[47,0]);

                //表面层电流前侧
                tx.executeSql('insert into flatweldvgroove values(?,?)',[48,280]);
                //表面层电流中间
                tx.executeSql('insert into flatweldvgroove values(?,?)',[49,280]);
                //表面层电流后侧
                tx.executeSql('insert into flatweldvgroove values(?,?)',[50,280]);
                //表面层端部停止时间前（ms）
                tx.executeSql('insert into flatweldvgroove values(?,?)',[51,100]);
                //表面层端部停止时间后（ms）
                tx.executeSql('insert into flatweldvgroove values(?,?)',[52,100]);
                //表面层堆高MAX
                tx.executeSql('insert into flatweldvgroove values(?,?)',[53,4.0]);
                //表面层接近-前
                tx.executeSql('insert into flatweldvgroove values(?,?)',[54,2.0]);
                //表面层接近-后
                tx.executeSql('insert into flatweldvgroove values(?,?)',[55,2.0]);
                //表面层分开最大摆动宽度
                tx.executeSql('insert into flatweldvgroove values(?,?)',[56,16.0]);
                //表面层摆动宽度间隔
                tx.executeSql('insert into flatweldvgroove values(?,?)',[57,5.0]);
                //表面层分开结束/开始比
                tx.executeSql('insert into flatweldvgroove values(?,?)',[58,1.0]);
                //表面层焊接电压
                tx.executeSql('insert into flatweldvgroove values(?,?)',[59,0]);

                //表面层余高层数
                tx.executeSql('insert into flatweldvgroove values(?,?)',[60,0]);
                //表面层分开方向 0 反方向 1标准
                tx.executeSql('insert into flatweldvgroove values(?,?)',[61,0]);
                //表面层起弧位置  00代表收弧位置
                tx.executeSql('insert into flatweldvgroove values(?,?)',[62,0]);
                //开始位置坐标X（mm）
                tx.executeSql('insert into flatweldvgroove values(?,?)',[63,4.0]);
                //开始位置坐标Y（mm）
                tx.executeSql('insert into flatweldvgroove values(?,?)',[64,0.0]);
                //开始位置坐标z（mm）
                tx.executeSql('insert into flatweldvgroove values(?,?)',[65,-3.0]);
                //表面层收弧动作 0 单程 1往返
                tx.executeSql('insert into flatweldvgroove values(?,?)',[66,0]);
                //表面层返回步骤距离
                tx.executeSql('insert into flatweldvgroove values(?,?)',[67,5.0]);

                //立板余高层电流前侧
                tx.executeSql('insert into flatweldvgroove values(?,?)',[68,0]);
                //立板余高层电流中间
                tx.executeSql('insert into flatweldvgroove values(?,?)',[69,0]);
                //立板余高层电流后侧
                tx.executeSql('insert into flatweldvgroove values(?,?)',[70,0]);
                //立板余高层端部停止时间前（ms）
                tx.executeSql('insert into flatweldvgroove values(?,?)',[71,0]);
                //立板余高层端部停止时间后（ms）
                tx.executeSql('insert into flatweldvgroove values(?,?)',[72,0]);
                //立板余高层堆高MAX
                tx.executeSql('insert into flatweldvgroove values(?,?)',[73,0]);
                //立板余高层接近-前
                tx.executeSql('insert into flatweldvgroove values(?,?)',[74,0]);
                //立板余高层接近-后
                tx.executeSql('insert into flatweldvgroove values(?,?)',[75,0]);
                //立板余高层分开最大摆动宽度
                tx.executeSql('insert into flatweldvgroove values(?,?)',[76,0]);
                //立板余高层摆动宽度间隔
                tx.executeSql('insert into flatweldvgroove values(?,?)',[77,0]);
                //立板余高层分开结束/开始比
                tx.executeSql('insert into flatweldvgroove values(?,?)',[78,0]);
                //立板余高层焊接电压
                tx.executeSql('insert into flatweldvgroove values(?,?)',[79,0]);
                //立板余高层MAX焊接速度
                tx.executeSql('insert into flatweldvgroove values(?,?)',[80,0]);

                /***************************************************焊接规范列表**********************************************/
            }
            else{
                            console.log("Skip Create flatweldvgroove Table .");}
            tx.executeSql('CREATE TABLE IF NOT EXISTS horizontalweldsinglebevelgroovet(id INT NOT NULL PRIMARY KEY,value NUMERIC(6,2))');
            table = tx.executeSql("select * from horizontalweldsinglebevelgroovet");
            if(table.rows.length === 0){
                /***************************************************焊接规范限制**********************************************/
                //初层陶衬垫电流前侧
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[0,0]);
                //初层陶衬垫电流中间
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[1,0]);
                //初层陶衬垫电流后侧
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[2,0]);
                //初层陶衬垫端部停止时间前（ms）
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[3,0]);
                //初层陶衬垫端部停止时间后（ms）
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[4,0]);
                //初层陶衬垫堆高MAX
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[5,0]);
                //初层陶衬垫接近-前
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[6,0]);
                //初层陶衬垫接近-后
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[7,0]);
                //初层陶衬垫分开最大摆动宽度
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[8,0]);
                //初层陶衬垫摆动宽度间隔
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[9,0]);
                //初层陶衬垫分开结束/开始比
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[10,0]);
                //初层陶衬垫焊接电压  0代表自动设定
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[11,0]);

                //初层电流前侧
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[12,300]);
                //初层电流中间
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[13,300]);
                //初层电流后侧
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[14,270]);
                //初层端部停止时间前（ms）
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[15,0]);
                //初层端部停止时间后（ms）
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[16,0]);
                //初层堆高MAX
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[17,8.1]);
                //初层接近-前
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[18,1.5]);
                //初层接近-后
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[19,5.0]);
                //初层分开最大摆动宽度
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[20,20.0]);
                //初层摆动宽度间隔
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[21,100.0]);
                //初层分开结束/开始比
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[22,1.0]);
                //初层焊接电压
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[23,0]);

                //第二层电流前侧
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[24,290]);
                //第二层电流中间
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[25,290]);
                //第二层电流后侧
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[26,290]);
                //第二层端部停止时间前（ms）
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[27,100]);
                //第二层端部停止时间后（ms）
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[28,100]);
                //第二层堆高MAX
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[29,5.0]);
                //第二层接近-前
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[30,1.0]);
                //第二层接近-后
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[31,1.0]);
                //第二层分开最大摆动宽度
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[32,16.0]);
                //第二层摆动宽度间隔
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[33,5.0]);
                //第二层分开结束/开始比
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[34,0.85]);
                //第二层焊接电压
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[35,0]);

                //中间层电流前侧
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[36,290]);
                //中间层电流中间
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[37,290]);
                //中间层电流后侧
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[38,290]);
                //中间层端部停止时间前（ms）
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[39,100]);
                //中间层端部停止时间后（ms）
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[40,100]);
                //中间层堆高MAX
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[41,4.0]);
                //中间层接近-前
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[42,2.0]);
                //中间层接近-后
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[43,2.0]);
                //中间层分开最大摆动宽度
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[44,14.0]);
                //中间层摆动宽度间隔
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[45,5.0]);
                //中间层分开结束/开始比
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[46,1.0]);
                //中间层焊接电压
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[47,0]);

                //表面层电流前侧
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[48,280]);
                //表面层电流中间
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[49,280]);
                //表面层电流后侧
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[50,280]);
                //表面层端部停止时间前（ms）
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[51,100]);
                //表面层端部停止时间后（ms）
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[52,100]);
                //表面层堆高MAX
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[53,4.0]);
                //表面层接近-前
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[54,2.0]);
                //表面层接近-后
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[55,2.0]);
                //表面层分开最大摆动宽度
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[56,16.0]);
                //表面层摆动宽度间隔
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[57,5.0]);
                //表面层分开结束/开始比
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[58,1.0]);
                //表面层焊接电压
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[59,0]);

                //表面层余高层数
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[60,0]);
                //表面层分开方向 0 反方向 1标准
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[61,0]);
                //表面层起弧位置  00代表收弧位置
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[62,0]);
                //开始位置坐标X（mm）
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[63,4.0]);
                //开始位置坐标Y（mm）
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[64,0.0]);
                //开始位置坐标z（mm）
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[65,-3.0]);
                //表面层收弧动作 0 单程 1往返
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[66,0]);
                //表面层返回步骤距离
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[67,5.0]);

                //立板余高层电流前侧
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[68,0]);
                //立板余高层电流中间
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[69,0]);
                //立板余高层电流后侧
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[70,0]);
                //立板余高层端部停止时间前（ms）
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[71,0]);
                //立板余高层端部停止时间后（ms）
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[72,0]);
                //立板余高层堆高MAX
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[73,0]);
                //立板余高层接近-前
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[74,0]);
                //立板余高层接近-后
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[75,0]);
                //立板余高层分开最大摆动宽度
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[76,0]);
                //立板余高层摆动宽度间隔
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[77,0]);
                //立板余高层分开结束/开始比
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[78,0]);
                //立板余高层焊接电压
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[79,0]);
                //立板余高层MAX焊接速度
                tx.executeSql('insert into horizontalweldsinglebevelgroovet values(?,?)',[80,0]);

                /***************************************************焊接规范列表**********************************************/
            }  else{
                console.log("Skip Create horizontalweldsinglebevelgroovet Table .");}
            tx.executeSql('CREATE TABLE IF NOT EXISTS horizontalweldsinglebevelgroove(id INT NOT NULL PRIMARY KEY,value NUMERIC(6,2))');
            table = tx.executeSql("select * from horizontalweldsinglebevelgroove");
            if(table.rows.length === 0){
                /***************************************************焊接规范限制**********************************************/
                //初层陶衬垫电流前侧
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[0,0]);
                //初层陶衬垫电流中间
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[1,0]);
                //初层陶衬垫电流后侧
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[2,0]);
                //初层陶衬垫端部停止时间前（ms）
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[3,0]);
                //初层陶衬垫端部停止时间后（ms）
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[4,0]);
                //初层陶衬垫堆高MAX
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[5,0]);
                //初层陶衬垫接近-前
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[6,0]);
                //初层陶衬垫接近-后
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[7,0]);
                //初层陶衬垫分开最大摆动宽度
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[8,0]);
                //初层陶衬垫摆动宽度间隔
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[9,0]);
                //初层陶衬垫分开结束/开始比
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[10,0]);
                //初层陶衬垫焊接电压  0代表自动设定
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[11,0]);

                //初层电流前侧
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[12,300]);
                //初层电流中间
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[13,300]);
                //初层电流后侧
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[14,270]);
                //初层端部停止时间前（ms）
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[15,0]);
                //初层端部停止时间后（ms）
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[16,0]);
                //初层堆高MAX
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[17,8.1]);
                //初层接近-前
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[18,1.5]);
                //初层接近-后
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[19,5.0]);
                //初层分开最大摆动宽度
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[20,20.0]);
                //初层摆动宽度间隔
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[21,100.0]);
                //初层分开结束/开始比
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[22,1.0]);
                //初层焊接电压
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[23,0]);

                //第二层电流前侧
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[24,290]);
                //第二层电流中间
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[25,290]);
                //第二层电流后侧
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[26,290]);
                //第二层端部停止时间前（ms）
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[27,100]);
                //第二层端部停止时间后（ms）
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[28,100]);
                //第二层堆高MAX
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[29,5.0]);
                //第二层接近-前
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[30,1.0]);
                //第二层接近-后
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[31,1.0]);
                //第二层分开最大摆动宽度
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[32,16.0]);
                //第二层摆动宽度间隔
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[33,5.0]);
                //第二层分开结束/开始比
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[34,0.85]);
                //第二层焊接电压
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[35,0]);

                //中间层电流前侧
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[36,290]);
                //中间层电流中间
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[37,290]);
                //中间层电流后侧
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[38,290]);
                //中间层端部停止时间前（ms）
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[39,100]);
                //中间层端部停止时间后（ms）
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[40,100]);
                //中间层堆高MAX
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[41,4.0]);
                //中间层接近-前
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[42,2.0]);
                //中间层接近-后
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[43,2.0]);
                //中间层分开最大摆动宽度
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[44,14.0]);
                //中间层摆动宽度间隔
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[45,5.0]);
                //中间层分开结束/开始比
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[46,1.0]);
                //中间层焊接电压
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[47,0]);

                //表面层电流前侧
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[48,280]);
                //表面层电流中间
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[49,280]);
                //表面层电流后侧
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[50,280]);
                //表面层端部停止时间前（ms）
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[51,100]);
                //表面层端部停止时间后（ms）
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[52,100]);
                //表面层堆高MAX
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[53,4.0]);
                //表面层接近-前
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[54,2.0]);
                //表面层接近-后
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[55,2.0]);
                //表面层分开最大摆动宽度
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[56,16.0]);
                //表面层摆动宽度间隔
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[57,5.0]);
                //表面层分开结束/开始比
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[58,1.0]);
                //表面层焊接电压
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[59,0]);

                //表面层余高层数
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[60,0]);
                //表面层分开方向 0 反方向 1标准
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[61,0]);
                //表面层起弧位置  00代表收弧位置
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[62,0]);
                //开始位置坐标X（mm）
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[63,4.0]);
                //开始位置坐标Y（mm）
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[64,0.0]);
                //开始位置坐标z（mm）
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[65,-3.0]);
                //表面层收弧动作 0 单程 1往返
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[66,0]);
                //表面层返回步骤距离
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[67,5.0]);

                //立板余高层电流前侧
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[68,0]);
                //立板余高层电流中间
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[69,0]);
                //立板余高层电流后侧
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[70,0]);
                //立板余高层端部停止时间前（ms）
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[71,0]);
                //立板余高层端部停止时间后（ms）
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[72,0]);
                //立板余高层堆高MAX
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[73,0]);
                //立板余高层接近-前
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[74,0]);
                //立板余高层接近-后
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[75,0]);
                //立板余高层分开最大摆动宽度
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[76,0]);
                //立板余高层摆动宽度间隔
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[77,0]);
                //立板余高层分开结束/开始比
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[78,0]);
                //立板余高层焊接电压
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[79,0]);
                //立板余高层MAX焊接速度
                tx.executeSql('insert into horizontalweldsinglebevelgroove values(?,?)',[80,0]);
                /***************************************************焊接规范列表**********************************************/
            } else{
                console.log("Skip Create horizontalweldsinglebevelgroove Table .");}
            tx.executeSql('CREATE TABLE IF NOT EXISTS  verticalWeldSingleBevelGrooveT(id INT NOT NULL PRIMARY KEY,value NUMERIC(6,2))');
            table = tx.executeSql("select * from  verticalWeldSingleBevelGrooveT");
            if(table.rows.length === 0){
                /***************************************************焊接规范限制**********************************************/
                //初层陶衬垫电流前侧
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[0,230]);
                //初层陶衬垫电流中间
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[1,230]);
                //初层陶衬垫电流后侧
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[2,230]);
                //初层陶衬垫端部停止时间前（ms）
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[3,400]);
                //初层陶衬垫端部停止时间后（ms）
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[4,400]);
                //初层陶衬垫堆高MAX
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[5,9.0]);
                //初层陶衬垫接近-前
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[6,2.0]);
                //初层陶衬垫接近-后
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[7,2.0]);
                //初层陶衬垫分开最大摆动宽度
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[8,20.0]);
                //初层陶衬垫摆动宽度间隔
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[9,100.0]);
                //初层陶衬垫分开结束/开始比
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[10,0.85]);
                //初层陶衬垫焊接电压  0代表自动设定
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[11,0]);


                //初层电流前侧
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[12,300]);
                //初层电流中间
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[13,300]);
                //初层电流后侧
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[14,300]);
                //初层端部停止时间前（ms）
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[15,500]);
                //初层端部停止时间后（ms）
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[16,0]);
                //初层堆高MAX
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[17,7.0]);
                //初层接近-前
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[18,1.0]);
                //初层接近-后
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[19,2.0]);
                //初层分开最大摆动宽度
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[20,20.0]);
                //初层摆动宽度间隔
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[21,100.0]);
                //初层分开结束/开始比
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[22,1.0]);
                //初层焊接电压
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[23,0]);

                //第二层电流前侧
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[24,290]);
                //第二层电流中间
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[25,290]);
                //第二层电流后侧
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[26,290]);
                //第二层端部停止时间前（ms）
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[27,100]);
                //第二层端部停止时间后（ms）
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[28,100]);
                //第二层堆高MAX
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[29,5.0]);
                //第二层接近-前
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[30,1.0]);
                //第二层接近-后
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[31,2.0]);
                //第二层分开最大摆动宽度
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[32,16.0]);
                //第二层摆动宽度间隔
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[33,5.0]);
                //第二层分开结束/开始比
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[34,0.85]);
                //第二层焊接电压
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[35,0]);

                //中间层电流前侧
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[36,290]);
                //中间层电流中间
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[37,290]);
                //中间层电流后侧
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[38,290]);
                //中间层端部停止时间前（ms）
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[39,100]);
                //中间层端部停止时间后（ms）
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[40,100]);
                //中间层堆高MAX
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[41,5.0]);
                //中间层接近-前
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[42,1.0]);
                //中间层接近-后
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[43,2.0]);
                //中间层分开最大摆动宽度
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[44,16.0]);
                //中间层摆动宽度间隔
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[45,5.0]);
                //中间层分开结束/开始比
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[46,0.85]);
                //中间层焊接电压
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[47,0]);

                //表面层电流前侧
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[48,280]);
                //表面层电流中间
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[49,280]);
                //表面层电流后侧
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[50,280]);
                //表面层端部停止时间前（ms）
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[51,0]);
                //表面层端部停止时间后（ms）
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[52,0]);
                //表面层堆高MAX
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[53,4.0]);
                //表面层接近-前
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[54,2.0]);
                //表面层接近-后
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[55,2.0]);
                //表面层分开最大摆动宽度
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[56,11.0]);
                //表面层摆动宽度间隔
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[57,5.0]);
                //表面层分开结束/开始比
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[58,1.0]);
                //表面层焊接电压
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[59,0]);

                //表面层余高层数
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[60,0]);
                //表面层分开方向 0 反方向 1标准
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[61,0]);
                //表面层起弧位置  00代表收弧位置
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[62,0]);
                //开始位置坐标X（mm）
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[63,4.0]);
                //开始位置坐标Y（mm）
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[64,0.0]);
                //开始位置坐标z（mm）
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[65,-3.0]);
                //表面层收弧动作 0 单程 1往返
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[66,0]);
                //表面层返回步骤距离
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[67,5.0]);

                //立板余高层电流前侧
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[68,250]);
                //立板余高层电流中间
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[69,250]);
                //立板余高层电流后侧
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[70,250]);
                //立板余高层端部停止时间前（ms）
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[71,0.0]);
                //立板余高层端部停止时间后（ms）
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[72,0.0]);
                //立板余高层堆高MAX
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[73,5.0]);
                //立板余高层接近-前
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[74,2.0]);
                //立板余高层接近-后
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[75,15.0]);
                //立板余高层分开最大摆动宽度
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[76,10.0]);
                //立板余高层摆动宽度间隔
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[77,5.0]);
                //立板余高层分开结束/开始比
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[78,1.0]);
                //立板余高层焊接电压
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[79,0]);
                //立板余高层MAX焊接速度
                tx.executeSql('insert into  verticalWeldSingleBevelGrooveT values(?,?)',[80,500.0]);
            }else{
                console.log("Skip Create verticalWeldSingleBevelGrooveT Table .");}
            tx.executeSql('CREATE TABLE IF NOT EXISTS  verticalweldsinglebevelgroove(id INT NOT NULL PRIMARY KEY,value NUMERIC(6,2))');
            table = tx.executeSql("select * from  verticalweldsinglebevelgroove");
            if(table.rows.length === 0){
                /***************************************************焊接规范限制**********************************************/
                //初层陶衬垫电流前侧
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[0,230]);
                //初层陶衬垫电流中间
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[1,230]);
                //初层陶衬垫电流后侧
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[2,230]);
                //初层陶衬垫端部停止时间前（ms）
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[3,500]);
                //初层陶衬垫端部停止时间后（ms）
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[4,500]);
                //初层陶衬垫堆高MAX
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[5,8.5]);
                //初层陶衬垫接近-前
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[6,2.0]);
                //初层陶衬垫接近-后
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[7,2.5]);
                //初层陶衬垫分开最大摆动宽度
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[8,20.0]);
                //初层陶衬垫摆动宽度间隔
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[9,100.0]);
                //初层陶衬垫分开结束/开始比
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[10,0.85]);
                //初层陶衬垫焊接电压  0代表自动设定
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[11,28]);

                //初层电流前侧
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[12,300]);
                //初层电流中间
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[13,300]);
                //初层电流后侧
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[14,300]);
                //初层端部停止时间前（ms）
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[15,200]);
                //初层端部停止时间后（ms）
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[16,200]);
                //初层堆高MAX
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[17,7.0]);
                //初层接近-前
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[18,2.0]);
                //初层接近-后
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[19,2.0]);
                //初层分开最大摆动宽度
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[20,20.0]);
                //初层摆动宽度间隔
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[21,100.0]);
                //初层分开结束/开始比
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[22,1.0]);
                //初层焊接电压
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[23,0]);

                //第二层电流前侧
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[24,290]);
                //第二层电流中间
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[25,290]);
                //第二层电流后侧
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[26,290]);
                //第二层端部停止时间前（ms）
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[27,100]);
                //第二层端部停止时间后（ms）
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[28,100]);
                //第二层堆高MAX
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[29,5.0]);
                //第二层接近-前
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[30,1.0]);
                //第二层接近-后
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[31,1.0]);
                //第二层分开最大摆动宽度
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[32,16.0]);
                //第二层摆动宽度间隔
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[33,5.0]);
                //第二层分开结束/开始比
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[34,0.85]);
                //第二层焊接电压
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[35,0]);

                //中间层电流前侧
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[36,290]);
                //中间层电流中间
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[37,290]);
                //中间层电流后侧
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[38,290]);
                //中间层端部停止时间前（ms）
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[39,100]);
                //中间层端部停止时间后（ms）
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[40,100]);
                //中间层堆高MAX
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[41,5.0]);
                //中间层接近-前
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[42,1.0]);
                //中间层接近-后
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[43,1.0]);
                //中间层分开最大摆动宽度
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[44,16.0]);
                //中间层摆动宽度间隔
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[45,5.0]);
                //中间层分开结束/开始比
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[46,0.85]);
                //中间层焊接电压
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[47,0]);

                //表面层电流前侧
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[48,280]);
                //表面层电流中间
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[49,280]);
                //表面层电流后侧
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[50,280]);
                //表面层端部停止时间前（ms）
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[51,100]);
                //表面层端部停止时间后（ms）
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[52,100]);
                //表面层堆高MAX
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[53,4.0]);
                //表面层接近-前
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[54,2.0]);
                //表面层接近-后
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[55,2.0]);
                //表面层分开最大摆动宽度
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[56,16.0]);
                //表面层摆动宽度间隔
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[57,5.0]);
                //表面层分开结束/开始比
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[58,1.0]);
                //表面层焊接电压
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[59,0]);

                //表面层余高层数
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[60,0]);
                //表面层分开方向 0 反方向 1标准
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[61,0]);
                //表面层起弧位置  00代表收弧位置
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[62,0]);
                //开始位置坐标X（mm）
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[63,4.0]);
                //开始位置坐标Y（mm）
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[64,0.0]);
                //开始位置坐标z（mm）
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[65,-3.0]);
                //表面层收弧动作 0 单程 1往返
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[66,0]);
                //表面层返回步骤距离
                tx.executeSql('insert into  verticalweldsinglebevelgroove values(?,?)',[67,5.0]);

                //立板余高层电流前侧
                tx.executeSql('insert into verticalweldsinglebevelgroove values(?,?)',[68,0]);
                //立板余高层电流中间
                tx.executeSql('insert into verticalweldsinglebevelgroove values(?,?)',[69,0]);
                //立板余高层电流后侧
                tx.executeSql('insert into verticalweldsinglebevelgroove values(?,?)',[70,0]);
                //立板余高层端部停止时间前（ms）
                tx.executeSql('insert into verticalweldsinglebevelgroove values(?,?)',[71,0]);
                //立板余高层端部停止时间后（ms）
                tx.executeSql('insert into verticalweldsinglebevelgroove values(?,?)',[72,0]);
                //立板余高层堆高MAX
                tx.executeSql('insert into verticalweldsinglebevelgroove values(?,?)',[73,0]);
                //立板余高层接近-前
                tx.executeSql('insert into verticalweldsinglebevelgroove values(?,?)',[74,0]);
                //立板余高层接近-后
                tx.executeSql('insert into verticalweldsinglebevelgroove values(?,?)',[75,0]);
                //立板余高层分开最大摆动宽度
                tx.executeSql('insert into verticalweldsinglebevelgroove values(?,?)',[76,0]);
                //立板余高层摆动宽度间隔
                tx.executeSql('insert into verticalweldsinglebevelgroove values(?,?)',[77,0]);
                //立板余高层分开结束/开始比
                tx.executeSql('insert into verticalweldsinglebevelgroove values(?,?)',[78,0]);
                //立板余高层焊接电压
                tx.executeSql('insert into verticalweldsinglebevelgroove values(?,?)',[79,0]);
                //立板余高层MAX焊接速度
                tx.executeSql('insert into verticalweldsinglebevelgroove values(?,?)',[80,0]);

                /***************************************************焊接规范列表**********************************************/
            }else{
                console.log("Skip Create verticalweldsinglebevelgroove Table .");}
            tx.executeSql('CREATE TABLE IF NOT EXISTS  verticalweldvgroove(id INT NOT NULL PRIMARY KEY,value NUMERIC(6,2))');
            table = tx.executeSql("select * from  verticalweldvgroove");
            if(table.rows.length === 0){
                /***************************************************焊接规范限制**********************************************/
                //初层陶衬垫电流前侧
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[0,230]);
                //初层陶衬垫电流中间
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[1,230]);
                //初层陶衬垫电流后侧
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[2,230]);
                //初层陶衬垫端部停止时间前（ms）
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[3,400]);
                //初层陶衬垫端部停止时间后（ms）
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[4,400]);
                //初层陶衬垫堆高MAX
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[5,9.0]);
                //初层陶衬垫接近-前
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[6,2.0]);
                //初层陶衬垫接近-后
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[7,2.0]);
                //初层陶衬垫分开最大摆动宽度
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[8,20.0]);
                //初层陶衬垫摆动宽度间隔
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[9,100.0]);
                //初层陶衬垫分开结束/开始比
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[10,0.85]);
                //初层陶衬垫焊接电压  0代表自动设定
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[11,28]);

                //初层电流前侧
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[12,300]);
                //初层电流中间
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[13,300]);
                //初层电流后侧
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[14,300]);
                //初层端部停止时间前（ms）
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[15,200]);
                //初层端部停止时间后（ms）
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[16,200]);
                //初层堆高MAX
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[17,7.0]);
                //初层接近-前
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[18,2.0]);
                //初层接近-后
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[19,2.0]);
                //初层分开最大摆动宽度
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[20,20.0]);
                //初层摆动宽度间隔
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[21,100.0]);
                //初层分开结束/开始比
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[22,1.0]);
                //初层焊接电压
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[23,0]);

                //第二层电流前侧
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[24,290]);
                //第二层电流中间
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[25,290]);
                //第二层电流后侧
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[26,290]);
                //第二层端部停止时间前（ms）
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[27,100]);
                //第二层端部停止时间后（ms）
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[28,100]);
                //第二层堆高MAX
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[29,5.0]);
                //第二层接近-前
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[30,1.0]);
                //第二层接近-后
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[31,1.0]);
                //第二层分开最大摆动宽度
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[32,16.0]);
                //第二层摆动宽度间隔
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[33,5.0]);
                //第二层分开结束/开始比
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[34,0.85]);
                //第二层焊接电压
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[35,0]);

                //中间层电流前侧
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[36,290]);
                //中间层电流中间
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[37,290]);
                //中间层电流后侧
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[38,290]);
                //中间层端部停止时间前（ms）
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[39,100]);
                //中间层端部停止时间后（ms）
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[40,100]);
                //中间层堆高MAX
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[41,4.0]);
                //中间层接近-前
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[42,2.0]);
                //中间层接近-后
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[43,2.0]);
                //中间层分开最大摆动宽度
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[44,14.0]);
                //中间层摆动宽度间隔
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[45,5.0]);
                //中间层分开结束/开始比
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[46,1.0]);
                //中间层焊接电压
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[47,0]);

                //表面层电流前侧
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[48,280]);
                //表面层电流中间
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[49,280]);
                //表面层电流后侧
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[50,280]);
                //表面层端部停止时间前（ms）
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[51,100]);
                //表面层端部停止时间后（ms）
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[52,100]);
                //表面层堆高MAX
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[53,4.0]);
                //表面层接近-前
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[54,2.0]);
                //表面层接近-后
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[55,2.0]);
                //表面层分开最大摆动宽度
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[56,16.0]);
                //表面层摆动宽度间隔
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[57,5.0]);
                //表面层分开结束/开始比
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[58,1.0]);
                //表面层焊接电压
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[59,0]);

                //表面层余高层数
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[60,0]);
                //表面层分开方向 0 反方向 1标准
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[61,0]);
                //表面层起弧位置  00代表收弧位置
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[62,0]);
                //开始位置坐标X（mm）
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[63,4.0]);
                //开始位置坐标Y（mm）
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[64,0.0]);
                //开始位置坐标z（mm）
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[65,-3.0]);
                //表面层收弧动作 0 单程 1往返
                tx.executeSql('insert into  verticalweldvgroove values(?,?)',[66,0]);
                //表面层返回步骤距离
                tx.executeSql('insert into verticalweldvgroove values(?,?)',[67,5.0]);

                //立板余高层电流前侧
                tx.executeSql('insert into verticalweldvgroove values(?,?)',[68,0]);
                //立板余高层电流中间
                tx.executeSql('insert into verticalweldvgroove values(?,?)',[69,0]);
                //立板余高层电流后侧
                tx.executeSql('insert into verticalweldvgroove values(?,?)',[70,0]);
                //立板余高层端部停止时间前（ms）
                tx.executeSql('insert into verticalweldvgroove values(?,?)',[71,0]);
                //立板余高层端部停止时间后（ms）
                tx.executeSql('insert into verticalweldvgroove values(?,?)',[72,0]);
                //立板余高层堆高MAX
                tx.executeSql('insert into verticalweldvgroove values(?,?)',[73,0]);
                //立板余高层接近-前
                tx.executeSql('insert into verticalweldvgroove values(?,?)',[74,0]);
                //立板余高层接近-后
                tx.executeSql('insert into verticalweldvgroove values(?,?)',[75,0]);
                //立板余高层分开最大摆动宽度
                tx.executeSql('insert into verticalweldvgroove values(?,?)',[76,0]);
                //立板余高层摆动宽度间隔
                tx.executeSql('insert into verticalweldvgroove values(?,?)',[77,0]);
                //立板余高层分开结束/开始比
                tx.executeSql('insert into verticalweldvgroove values(?,?)',[78,0]);
                //立板余高层焊接电压
                tx.executeSql('insert into verticalweldvgroove values(?,?)',[79,0]);
                //立板余高层MAX焊接速度
                tx.executeSql('insert into verticalweldvgroove values(?,?)',[80,0]);
                /***************************************************焊接规范列表**********************************************/
            }else{
                console.log("Skip Create verticalweldvgroove Table .");}
            tx.executeSql('CREATE TABLE IF NOT EXISTS  flatfillet(id INT NOT NULL PRIMARY KEY,value NUMERIC(6,2))');
            table = tx.executeSql("select * from  flatfillet");
            if(table.rows.length === 0){
                /***************************************************焊接规范限制**********************************************/
                //初层陶衬垫电流前侧
                tx.executeSql('insert into  flatfillet values(?,?)',[0,0]);
                //初层陶衬垫电流中间
                tx.executeSql('insert into  flatfillet values(?,?)',[1,0]);
                //初层陶衬垫电流后侧
                tx.executeSql('insert into  flatfillet values(?,?)',[2,0]);
                //初层陶衬垫端部停止时间前（ms）
                tx.executeSql('insert into  flatfillet values(?,?)',[3,0]);
                //初层陶衬垫端部停止时间后（ms）
                tx.executeSql('insert into  flatfillet values(?,?)',[4,0]);
                //初层陶衬垫堆高MAX
                tx.executeSql('insert into  flatfillet values(?,?)',[5,0]);
                //初层陶衬垫接近-前
                tx.executeSql('insert into  flatfillet values(?,?)',[6,0]);
                //初层陶衬垫接近-后
                tx.executeSql('insert into  flatfillet values(?,?)',[7,0]);
                //初层陶衬垫分开最大摆动宽度
                tx.executeSql('insert into  flatfillet values(?,?)',[8,0]);
                //初层陶衬垫摆动宽度间隔
                tx.executeSql('insert into  flatfillet values(?,?)',[9,0]);
                //初层陶衬垫分开结束/开始比
                tx.executeSql('insert into  flatfillet values(?,?)',[10,0]);
                //初层陶衬垫焊接电压  0代表自动设定
                tx.executeSql('insert into  flatfillet values(?,?)',[11,0]);

                //初层电流前侧
                tx.executeSql('insert into  flatfillet values(?,?)',[12,300]);
                //初层电流中间
                tx.executeSql('insert into  flatfillet values(?,?)',[13,300]);
                //初层电流后侧
                tx.executeSql('insert into  flatfillet values(?,?)',[14,300]);
                //初层端部停止时间前（ms）
                tx.executeSql('insert into  flatfillet values(?,?)',[15,0]);
                //初层端部停止时间后（ms）
                tx.executeSql('insert into  flatfillet values(?,?)',[16,0]);
                //初层堆高MAX
                tx.executeSql('insert into  flatfillet values(?,?)',[17,6.5]);
                //初层接近-前
                tx.executeSql('insert into  flatfillet values(?,?)',[18,23.0]);
                //初层接近-后
                tx.executeSql('insert into  flatfillet values(?,?)',[19,27.0]);
                //初层分开最大摆动宽度
                tx.executeSql('insert into  flatfillet values(?,?)',[20,8.0]);
                //初层摆动宽度间隔
                tx.executeSql('insert into  flatfillet values(?,?)',[21,15.0]);
                //初层分开结束/开始比
                tx.executeSql('insert into  flatfillet values(?,?)',[22,1.0]);
                //初层焊接电压
                tx.executeSql('insert into  flatfillet values(?,?)',[23,0]);

                //第二层电流前侧
                tx.executeSql('insert into  flatfillet values(?,?)',[24,280]);
                //第二层电流中间
                tx.executeSql('insert into  flatfillet values(?,?)',[25,280]);
                //第二层电流后侧
                tx.executeSql('insert into  flatfillet values(?,?)',[26,280]);
                //第二层端部停止时间前（ms）
                tx.executeSql('insert into  flatfillet values(?,?)',[27,0]);
                //第二层端部停止时间后（ms）
                tx.executeSql('insert into  flatfillet values(?,?)',[28,0]);
                //第二层堆高MAX
                tx.executeSql('insert into  flatfillet values(?,?)',[29,5.5]);
                //第二层接近-前
                tx.executeSql('insert into  flatfillet values(?,?)',[30,3.0]);
                //第二层接近-后
                tx.executeSql('insert into  flatfillet values(?,?)',[31,3.0]);
                //第二层分开最大摆动宽度
                tx.executeSql('insert into  flatfillet values(?,?)',[32,7.0]);
                //第二层摆动宽度间隔
                tx.executeSql('insert into  flatfillet values(?,?)',[33,20.0]);
                //第二层分开结束/开始比
                tx.executeSql('insert into  flatfillet values(?,?)',[34,1.0]);
                //第二层焊接电压
                tx.executeSql('insert into  flatfillet values(?,?)',[35,0]);

                //中间层电流前侧
                tx.executeSql('insert into  flatfillet values(?,?)',[36,280]);
                //中间层电流中间
                tx.executeSql('insert into  flatfillet values(?,?)',[37,280]);
                //中间层电流后侧
                tx.executeSql('insert into  flatfillet values(?,?)',[38,280]);
                //中间层端部停止时间前（ms）
                tx.executeSql('insert into  flatfillet values(?,?)',[39,0]);
                //中间层端部停止时间后（ms）
                tx.executeSql('insert into  flatfillet values(?,?)',[40,0]);
                //中间层堆高MAX
                tx.executeSql('insert into  flatfillet values(?,?)',[41,5.0]);
                //中间层接近-前
                tx.executeSql('insert into  flatfillet values(?,?)',[42,3.0]);
                //中间层接近-后
                tx.executeSql('insert into  flatfillet values(?,?)',[43,3.0]);
                //中间层分开最大摆动宽度
                tx.executeSql('insert into  flatfillet values(?,?)',[44,7.3]);
                //中间层摆动宽度间隔
                tx.executeSql('insert into  flatfillet values(?,?)',[45,15.0]);
                //中间层分开结束/开始比
                tx.executeSql('insert into  flatfillet values(?,?)',[46,1.0]);
                //中间层焊接电压
                tx.executeSql('insert into  flatfillet values(?,?)',[47,0]);

                //表面层电流前侧
                tx.executeSql('insert into  flatfillet values(?,?)',[48,250]);
                //表面层电流中间
                tx.executeSql('insert into  flatfillet values(?,?)',[49,250]);
                //表面层电流后侧
                tx.executeSql('insert into  flatfillet values(?,?)',[50,250]);
                //表面层端部停止时间前（ms）
                tx.executeSql('insert into  flatfillet values(?,?)',[51,0]);
                //表面层端部停止时间后（ms）
                tx.executeSql('insert into  flatfillet values(?,?)',[52,0]);
                //表面层堆高MAX
                tx.executeSql('insert into  flatfillet values(?,?)',[53,4.5]);
                //表面层接近-前
                tx.executeSql('insert into  flatfillet values(?,?)',[54,3.0]);
                //表面层接近-后
                tx.executeSql('insert into  flatfillet values(?,?)',[55,3.0]);
                //表面层分开最大摆动宽度
                tx.executeSql('insert into  flatfillet values(?,?)',[56,6.0]);
                //表面层摆动宽度间隔
                tx.executeSql('insert into  flatfillet values(?,?)',[57,15.0]);
                //表面层分开结束/开始比
                tx.executeSql('insert into  flatfillet values(?,?)',[58,1.0]);
                //表面层焊接电压
                tx.executeSql('insert into  flatfillet values(?,?)',[59,0]);

                //表面层余高层数
                tx.executeSql('insert into  flatfillet values(?,?)',[60,0]);
                //表面层分开方向 0 反方向 1标准
                tx.executeSql('insert into  flatfillet values(?,?)',[61,0]);
                //表面层起弧位置  00代表收弧位置
                tx.executeSql('insert into  flatfillet values(?,?)',[62,0]);
                //开始位置坐标X（mm）
                tx.executeSql('insert into  flatfillet values(?,?)',[63,4.0]);
                //开始位置坐标Y（mm）
                tx.executeSql('insert into  flatfillet values(?,?)',[64,0.0]);
                //开始位置坐标z（mm）
                tx.executeSql('insert into  flatfillet values(?,?)',[65,-3.0]);
                //表面层收弧动作 0 单程 1往返
                tx.executeSql('insert into  flatfillet values(?,?)',[66,0]);
                //表面层返回步骤距离
                tx.executeSql('insert into flatfillet values(?,?)',[67,5.0]);

                //立板余高层电流前侧
                tx.executeSql('insert into flatfillet values(?,?)',[68,0]);
                //立板余高层电流中间
                tx.executeSql('insert into flatfillet values(?,?)',[69,0]);
                //立板余高层电流后侧
                tx.executeSql('insert into flatfillet values(?,?)',[70,0]);
                //立板余高层端部停止时间前（ms）
                tx.executeSql('insert into flatfillet values(?,?)',[71,0]);
                //立板余高层端部停止时间后（ms）
                tx.executeSql('insert into flatfillet values(?,?)',[72,0]);
                //立板余高层堆高MAX
                tx.executeSql('insert into flatfillet values(?,?)',[73,0]);
                //立板余高层接近-前
                tx.executeSql('insert into flatfillet values(?,?)',[74,0]);
                //立板余高层接近-后
                tx.executeSql('insert into flatfillet values(?,?)',[75,0]);
                //立板余高层分开最大摆动宽度
                tx.executeSql('insert into flatfillet values(?,?)',[76,0]);
                //立板余高层摆动宽度间隔
                tx.executeSql('insert into flatfillet values(?,?)',[77,0]);
                //立板余高层分开结束/开始比
                tx.executeSql('insert into flatfillet values(?,?)',[78,0]);
                //立板余高层焊接电压
                tx.executeSql('insert into flatfillet values(?,?)',[79,0]);
                //立板余高层MAX焊接速度
                tx.executeSql('insert into flatfillet values(?,?)',[80,0]);
                /***************************************************焊接规范列表**********************************************/
            }else{
                console.log("Skip Create flatfillet Table .");}
        });
    }
}
