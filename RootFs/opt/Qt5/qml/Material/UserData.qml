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

    property var grooveStyleName: [ "平焊单边V形坡口T接头",  "平焊单边V形坡口平对接", "平焊V形坡口平对接","横焊单边V形坡口T接头",  "横焊单边V形坡口平对接", "立焊单边V形坡口T接头",  "立焊单边V形坡口平对接", "立焊V形坡口平对接","水平角焊"  ]

    //获取系统时间
    function getSysTime(){
        return new Date().toLocaleString(Qt.locale("ch_ZN"),"yyyy-MM-dd h:mm:ss")
    }
    function getPageFunctionAndValueFromTable(index){
        var result,str;
        if(!dataBase) { if(openDatabase()===-1) return -1;}
        switch(index){
        case 0:str="select * from 平焊单边V形坡口T接头限制条件";break;
        case 1:str="select * from 平焊单边V形坡口平对接限制条件";break;
        case 2:str="select * from 平焊V形坡口平对接限制条件";break;
        case 3:str="select * from 横焊单边V形坡口T接头限制条件";break;
        case 4:str="select * from 横焊单边V形坡口平对接限制条件";break;
        case 5:str="select * from 立焊单边V形坡口T接头限制条件";break;
        case 6:str="select * from 立焊单边V形坡口平对接限制条件";break;
        case 7:str="select * from 立焊V形坡口平对接限制条件";break;
        case 8:str="select * from 水平角焊限制条件";break;
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
        if(!dataBase) { if(openDatabase()===-1);return -1;}
        str="UPDATE "+tablename+" SET value = "+"\'"+value+"\'"+" WHERE id = "+"\'"+id+"\'";
        console.log(str);
        dataBase.transaction( function(tx) {result = tx.executeSql(str); });
    }
    /*写入数据库相关词条的数值*/
    function setValue(tablename,id,value){
        var result,str;
        if(!dataBase) { if(openDatabase()===-1);return -1;}
        if((typeof(tablename)==="string")&&(typeof(funcI)==="string")){
            str="UPDATE "+tablename+" SET Time = "+"\'"+value+"\'"+" WHERE Name = "+"\'"+id+"\'";
            console.log(str);
            dataBase.transaction( function(tx) {result = tx.executeSql(str); });
        }else
            return -1;
    }
    /*写入任何字符串*/
    function setValueWanted(tablename,funcI,id,funcV,value){
        var result,str;
        if(!dataBase) { if(openDatabase()===-1);return -1;}
        console.log(value)
        if((typeof(tablename)==="string")&&(typeof(funcI)==="string")&&(typeof(id)==="string")&&(typeof(funcV)==="string")){
            str="UPDATE "+tablename+" SET "+funcV+ " = "+"\'"+value+"\'"+" WHERE "+funcI+" = "+"\'"+id+"\'";
            dataBase.transaction( function(tx) {result = tx.executeSql(str); });
        }else
            return -1;
    }
    /*从数据库中获取相关词条的数值
          * name 数据表格名字，func 定义的名字 setvalue设定数值
         */
    function getValueFromFuncOfTable(tablename,func,name){
        var result,str;
        var value=new Array();
        if(!dataBase) { if(openDatabase()===-1) return -1;}
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
    function getResultFromFuncOfTable(tablename,column,func,name){
        var result,str;
        if(!dataBase) { if(openDatabase()===-1) return -1;}
        str="SELECT ";
        if(column==="")
            str+="*"
        else
            str+=column;
        str+=" FROM "+tablename;
        if(func!=="")
            str+= " WHERE "+func+" ="+"\'"+name+"\'";
        console.log(str);
        dataBase.transaction( function(tx) {result = tx.executeSql(str); });
        return result;
    }
    function getDataOrderByTime(tablename,func){
        var result,str;
        if(!dataBase) { if(openDatabase()===-1) return -1;}
        str="SELECT * FROM "+tablename+" ORDER BY "+func+" DESC";
        console.log(str)
        if((typeof(tablename)==="string")&&(typeof(func)==="string")){
            dataBase.transaction( function(tx) {result = tx.executeSql(str); });
            var value=new Array(0);
            for(var i=0;i<result.rows.length;i++){
                value.push(result.rows.item(i));
            }
            console.log(value);
            return value;
        }else
            return -1;
    }

    /**
      *从数据库中获取 焊接规范列表
      */
    function getWeldRulesNameOrderByTime(tablename,func){
        var result,str;
        if(!dataBase) { if(openDatabase()===-1) return -1;}
        str="SELECT * FROM "+tablename+" ORDER BY "+func+" DESC";
        console.log(str)
        if((typeof(tablename)==="string")&&(typeof(func)==="string")){
            dataBase.transaction( function(tx) {result = tx.executeSql(str); });
            var value=new Array(0);
            for(var i=0;i<result.rows.length;i++){
                value.push(result.rows.item(i));
            }
            console.log(value);
            return value;
        }else
            return -1;
    }
    /**
      *从数据库中获取 列表
      */
    function getTableJson(tablename){
        var result,str;
        if(!dataBase) { if(openDatabase()===-1) return -1;}
        str="SELECT * FROM "+tablename;
        console.log(str)
        if(typeof(tablename)==="string"){
            dataBase.transaction( function(tx) {result = tx.executeSql(str); });
            var value=new Array();
            /*遍寻所有数据转换成json格式*/
            for(var i=0;i<result.rows.length;i++){
                //result.rows.item返回的就是json object不需要在弄
                value.push(result.rows.item(i));
            }
            console.log(value)
            return value;
        }else
            return -1;
    }
    /*
      *从限制条件表选取 合适的参数
      */
    function getLimitedTableJson(tablename,id){
        var result,str;
        if(!dataBase) { if(openDatabase()===-1) return -1;}
        str="SELECT * FROM "+tablename+ " WHERE C11 "+" = "+"\'"+id+"\'";
        console.log(str)
        if(typeof(tablename)==="string"){
            dataBase.transaction( function(tx) {result = tx.executeSql(str); });
            var value=new Array(0);
            /*遍寻所有数据转换成json格式*/
            for(var i=0;i<result.rows.length;i++){
                //result.rows.item返回的就是json object不需要在弄
                value.push(result.rows.item(i));
            }
            console.log("value"+value)
            return value;
        }else
            return -1;
    }

    /*获取错误倒序排列*/
    function getSysErrorOrderByTime(tablename,func){
        var result,str;
        if(!dataBase) { if(openDatabase()===-1) return -1;}
        str="SELECT * FROM "+tablename+" ORDER BY "+func+" DESC";
        console.log(str)
        if((typeof(tablename)==="string")&&(typeof(func)==="string")){
            dataBase.transaction( function(tx) {result = tx.executeSql(str); });
            var value=new Array();
            for(var i=0;i<result.rows.length;i++){
                value.push(result.rows.item(i));
            }
            console.log(value);
            return value;
        }else
            return -1;
    }

    /**
      *从数据库中获取 焊接规范
      */
    function getListGrooveName(tablename,func){
        var result,str;
        if(!dataBase) { if(openDatabase()===-1) return -1;}
        str="SELECT * FROM "+tablename+" ORDER BY "+func+" DESC";
        console.log(str)
        if((typeof(tablename)==="string")&&(typeof(func)==="string")){
            dataBase.transaction( function(tx) {result = tx.executeSql(str); });
            var value=new Array();
            for(var i=0;i<result.rows.length;i++){
                value.push(String(result.rows.item(i).Groove)+","+String(result.rows.item(i).CreatTime)+","+String(result.rows.item(i).Creator)+","+String(result.rows.item(i).EditTime)+","+String(result.rows.item(i).Editor));
            }
            console.log(value);
            return value;
        }else
            return -1;
    }

    /*
          *根据输入参数 创建数据库 参数库不存在 则返回-1 成功返回1
          */
    function createTable(tablename,format){
        var res;
        if(!root.dataBase){ if(openDatabase()===-1) return -1;}
        if(typeof(tablename)==="string"){
            var str="CREATE TABLE IF NOT EXISTS "+tablename+"("+format+")";
            dataBase.transaction( function(tx) {tx.executeSql(str);
                res=tx.executeSql("select * from "+tablename);
                if(res.rows.length===0) console.log("Create "+tablename+" Table successed !")
                else console.log("Skip Create "+tablename+" !")
            });
        }else
            return -1;
    }
    /*删除数据表数据 当func与value有效时删除func为value所在行数据，否则删除表内所有数据但是表格保留*/
    function clearTable(tablename,func,value){
        if(!root.dataBase){ if(openDatabase()===-1) return -1;}
        if(typeof(tablename)==="string"){
            var str="DELETE FROM "+tablename;
            if((func!=="")&&(value!=="")){
                str+=" WHERE "+func+" = "+"\'"+value+"\'";
            }
            console.log(str)
            dataBase.transaction( function(tx) { tx.executeSql(str);})
        }else
            return -1;
    }
    /*删除整个数据表格*/
    function deleteTable(tablename){
        if(!root.dataBase){ if(openDatabase()===-1) return -1;}
        if(tablename!==""){
            var str="DROP TABLE "+tablename;
            console.log(str);
            dataBase.transaction( function(tx) {tx.executeSql(str);})
        }
    }
    /*
          *插入指定参数到数据库 数据库不存在则返回-1
          操作格式 func (?,?) data 为数组[,]
          */
    function insertTable(tablename,func,data){
        if(!root.dataBase){ if(openDatabase()===-1) return -1;}
        var str="INSERT INTO "+tablename+" VALUES"+func;
        console.log(str+data)
        try{
            dataBase.transaction( function(tx) { tx.executeSql(str,data);});
        }
        catch(e){return e}
    }
    /*
        * 重命名表格
    */
    function renameTable(oldName,newName){
        if(!root.dataBase){ if(openDatabase()===-1) return -1;}
        var str="ALTER TABLE "+oldName+" RENAME TO "+newName;
        console.log(str)
        dataBase.transaction( function(tx) { tx.executeSql(str);});
    }
    /*
        * 表格增加字段
    */
    function alterTable(tableName,columnName){
        if(!root.dataBase){ if(openDatabase()===-1) return -1;}
        var str="ALTER TABLE "+tableName+" ADD COLUMN "+columnName;
        console.log(str)
        dataBase.transaction( function(tx) { tx.executeSql(str);});
    }
    /*
         *打开数据库 输入参数 数据名称 版本 描述 类形
         */
    function openDatabase() {
        var table;
        var error=-1;
        //创建链接
        root.dataBase = Data.LocalStorage.openDatabaseSync("ERoboWeldSysDataBase","1.0","DataBase", 100000);
        if(root.dataBase)  {
            console.log("Open dataBase::dataBase Success .");
            return 1;
        }
        else{
            console.log("Open dataBase::dataBase fail !");
            return -1
        }
    }
    //坡口参数初始值设置
    /**********************************************示教条件*************************************************/
    function openTeachConditionTable(){
        dataBase.transaction( function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS TeachCondition(id INT NOT NULL PRIMARY KEY,value NUMERIC(6,2))');
            var  table = tx.executeSql("select * from TeachCondition");
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
        })
    }
    /*******************************************焊接条件*****************************************************/
    function openWeldConditionTable(){
        dataBase.transaction( function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS WeldCondition(id INT NOT NULL PRIMARY KEY,value NUMERIC(6,2))');
            var   table = tx.executeSql("select * from WeldCondition");
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
        })
    }
    /********************************************错误检测*********************************************/
    function openCheckErrorTable(){
        dataBase.transaction( function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS CheckError(id INT NOT NULL PRIMARY KEY,value NUMERIC(6,2))');
            var table = tx.executeSql("select * from CheckError");
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
        })
    }
    /********************************************帐户表格***************************************************/
    function openAccountTable(){
        dataBase.transaction( function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS accountTable(name TEXT NOT NULL PRIMARY KEY,password TEXT,type TEXT)');
            var table = tx.executeSql("select * from accountTable");
            if(table.rows.length === 0){
                //TKSW
                tx.executeSql('insert into accountTable values(?,?,?)',["TKSW","TKSW","SuperUser"]);
                //ADMIN
                tx.executeSql('insert into accountTable values(?,?,?)',["Nop","Nop","User"]);
            }else{
                console.log("Skip Create accountTable Table .");}
        })
    }

    /***************************************************焊接规范限制**********************************************/
    function createLimited0Table(){
        var table;
        dataBase.transaction( function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS 平焊单边V形坡口T接头限制条件 (ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT,C10 TEXT,C11 TEXT)");
            table = tx.executeSql("SELECT * FROM 平焊单边V形坡口T接头限制条件");
            var str="INSERT INTO 平焊单边V形坡口T接头限制条件 VALUES(?,?,?,?,?,?,?,?,?,?,?,?)"
            if(table.rows.length === 0){
                //气体   脉冲  焊丝种类  直径
                //    8       7       654          3210
                //气体 CO2 脉冲无 焊丝实芯碳钢 直径1.2
                //        0          0                    0             4              ID = 4
                tx.executeSql(str,["陶瓷衬垫","","","","","","","","","","","4"]);
                tx.executeSql(str,["打底层","290/290/290","0/0","5/6","2/2","20","20","1","0","180/450","1","4"]);
                tx.executeSql(str,["第二层","280/280/280","0.1/0.1","4/5","2/2","16","6","0.95","0","180/450","1","4"]);
                tx.executeSql(str,["填充层","280/280/280","0.2/0.2","3.5/5","2/2","18","6","0.95","0","180/450","1","4"]);
                tx.executeSql(str,["盖面层","270/270/270","0.2/0.2","3.5/5","2/2","18","4","1","0","180/450","1","4"]);
                tx.executeSql(str,["立板余高层","","","","","","","","","","","4"]);
                //气体 MAG 脉冲有 焊丝实芯碳钢 直径1.2
                //        1          1                    0             4              ID = 4
                tx.executeSql(str,["陶瓷衬垫","","","","","","","","","","","388"]);
                tx.executeSql(str,["打底层","290/290/290","0/0","5/6","2/2","20","20","1","0","180/450","1","388"]);
                tx.executeSql(str,["第二层","280/280/280","0.1/0.1","4/5","2/2","16","6","0.95","0","180/450","1","388"]);
                tx.executeSql(str,["填充层","280/280/280","0.2/0.2","3.5/5","2/2","18","6","0.95","0","180/450","1","388"]);
                tx.executeSql(str,["盖面层","270/270/270","0.2/0.2","3.5/5","2/2","18","4","1","0","180/450","1","388"]);
                tx.executeSql(str,["立板余高层","","","","","","","","","","","388"]);
            }else{
                console.log("Skip Create 平焊单边V形坡口T接头限制条件 Table .");}
        })
    }
    function createLimited1Table(){
        var table;
        dataBase.transaction( function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS 平焊单边V形坡口平对接限制条件 (ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT,C10 TEXT,C11 TEXT)");
            table = tx.executeSql("SELECT * FROM 平焊单边V形坡口平对接限制条件");
            var str="INSERT INTO 平焊单边V形坡口平对接限制条件 VALUES(?,?,?,?,?,?,?,?,?,?,?,?)"
            if(table.rows.length === 0){
                //气体   脉冲  焊丝种类  直径
                //    8       7       654          3210
                //气体 CO2 脉冲无 焊丝实芯碳钢 直径1.2
                //        0          0                    0             4              ID = 4
                tx.executeSql(str,["陶瓷衬垫","","","","","","","","","","","4"]);
                tx.executeSql(str,["打底层","290/290/290","0/0","5/6","2/2","20","20","1","0","180/450","1","4"]);
                tx.executeSql(str,["第二层","280/280/280","0.1/0.1","4/5","2/2","16","6","0.95","0","180/450","1","4"]);
                tx.executeSql(str,["填充层","280/280/280","0.2/0.2","3.5/5","2/2","18","6","0.95","0","180/450","1","4"]);
                tx.executeSql(str,["盖面层","270/270/270","0.2/0.2","3.5/5","2/2","18","4","1","0","180/450","1","4"]);
                tx.executeSql(str,["立板余高层","","","","","","","","","","","4"]);
                //气体 MAG 脉冲有 焊丝实芯碳钢 直径1.2
                //        1          1                    0             4              ID = 4
                tx.executeSql(str,["陶瓷衬垫","","","","","","","","","","","388"]);
                tx.executeSql(str,["打底层","290/290/290","0/0","5/6","2/2","20","20","1","0","180/450","1","388"]);
                tx.executeSql(str,["第二层","280/280/280","0.1/0.1","4/5","2/2","16","6","0.95","0","180/450","1","388"]);
                tx.executeSql(str,["填充层","280/280/280","0.2/0.2","3.5/5","2/2","18","6","0.95","0","180/450","1","388"]);
                tx.executeSql(str,["盖面层","270/270/270","0.2/0.2","3.5/5","2/2","18","4","1","0","180/450","1","388"]);
                tx.executeSql(str,["立板余高层","","","","","","","","","","","388"]);
            }else{
                console.log("Skip Create 平焊单边V形坡口平对接限制条件 Table .");}
        })
    }
    function createLimited2Table(){
        var table;
        dataBase.transaction( function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS 平焊V形坡口平对接限制条件 (ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT,C10 TEXT,C11 TEXT)");
            table = tx.executeSql("SELECT * FROM 平焊V形坡口平对接限制条件");
            var str="INSERT INTO 平焊V形坡口平对接限制条件 VALUES(?,?,?,?,?,?,?,?,?,?,?,?)"
            if(table.rows.length === 0){
                //气体   脉冲  焊丝种类  直径
                //    8       7       654          3210
                //气体 CO2 脉冲无 焊丝实芯碳钢 直径1.2
                //        0          0                    0             4              ID = 4
                tx.executeSql(str,["陶瓷衬垫","","","","","","","","","","","4"]);
                tx.executeSql(str,["打底层","290/290/290","0/0","5/6","2/2","20","20","1","0","180/450","1","4"]);
                tx.executeSql(str,["第二层","280/280/280","0.1/0.1","4/5","2/2","16","6","0.95","0","180/450","1","4"]);
                tx.executeSql(str,["填充层","280/280/280","0.2/0.2","3.5/5","2/2","18","6","0.95","0","180/450","1","4"]);
                tx.executeSql(str,["盖面层","270/270/270","0.2/0.2","3.5/5","2/2","18","4","1","0","180/450","1","4"]);
                tx.executeSql(str,["立板余高层","","","","","","","","","","","4"]);
                //气体 MAG 脉冲有 焊丝实芯碳钢 直径1.2
                //        1          1                    0             4              ID = 4
                tx.executeSql(str,["陶瓷衬垫","","","","","","","","","","","388"]);
                tx.executeSql(str,["打底层","290/290/290","0/0","5/6","2/2","20","20","1","0","180/450","1","388"]);
                tx.executeSql(str,["第二层","280/280/280","0.1/0.1","4/5","2/2","16","6","0.95","0","180/450","1","388"]);
                tx.executeSql(str,["填充层","280/280/280","0.2/0.2","3.5/5","2/2","18","6","0.95","0","180/450","1","388"]);
                tx.executeSql(str,["盖面层","270/270/270","0.2/0.2","3.5/5","2/2","18","4","1","0","180/450","1","388"]);
                tx.executeSql(str,["立板余高层","","","","","","","","","","","388"]);
            }else{
                console.log("Skip Create 平焊V形坡口平对接限制条件 Table .");}
        })
    }
    function createLimited3Table(){
        var table;
        dataBase.transaction( function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS 横焊单边V形坡口T接头限制条件 (ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT,C10 TEXT,C11 TEXT)");
            table = tx.executeSql("SELECT * FROM 横焊单边V形坡口T接头限制条件");
            var str="INSERT INTO 横焊单边V形坡口T接头限制条件 VALUES(?,?,?,?,?,?,?,?,?,?,?,?)"
            if(table.rows.length === 0){
                //气体   脉冲  焊丝种类  直径
                //    8       7       654          3210
                //气体 CO2 脉冲无 焊丝实芯碳钢 直径1.2
                //        0          0                    0             4              ID = 4
                tx.executeSql(str,["陶瓷衬垫","","","","","","","","","","","4"]);
                tx.executeSql(str,["打底层","300/300/300","0/0","5/6","1/3","7","0","1","0","300/600","1","4"]);
                tx.executeSql(str,["第二层","270/270/270","0/0","4.5/5.2","2/3","5.5","0","1","0","300/600","1","4"]);
                tx.executeSql(str,["填充层","250/260/260","0/0","4/5.2","2/3","5","0","0.95","0","300/600","1","4"]);
                tx.executeSql(str,["盖面层","250/260/260","0/0","4.5/5.1","3/3","4.5","0","1","0","300/600","1","4"]);
                tx.executeSql(str,["立板余高层","","","","","","","","","","","4"]);
                //气体 MAG 脉冲有 焊丝实芯碳钢 直径1.2
                //        1          1                    0             4              ID = 4
                tx.executeSql(str,["陶瓷衬垫","","","","","","","","","","","388"]);
                tx.executeSql(str,["打底层","300/300/300","0/0","5/6","1/3","7","0","1","0","300/600","1","388"]);
                tx.executeSql(str,["第二层","270/270/270","0/0","4.5/5.2","2/3","5.5","0","1","0","300/600","1","388"]);
                tx.executeSql(str,["填充层","250/260/260","0/0","4/5.2","2/3","5","0","0.95","0","300/600","1","388"]);
                tx.executeSql(str,["盖面层","250/260/260","0/0","4.5/5.1","3/3","4.5","0","1","0","300/600","1","388"]);
                tx.executeSql(str,["立板余高层","","","","","","","","","","","388"]);
            }else{
                console.log("Skip Create 横焊单边V形坡口T接头限制条件 Table .");}
        })
    }
    function createLimited4Table(){
        var table;
        dataBase.transaction( function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS 横焊单边V形坡口平对接限制条件 (ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT,C10 TEXT,C11 TEXT)");
            table = tx.executeSql("SELECT * FROM 横焊单边V形坡口平对接限制条件");
            var str="INSERT INTO 横焊单边V形坡口平对接限制条件 VALUES(?,?,?,?,?,?,?,?,?,?,?,?)"
            if(table.rows.length === 0){
                //气体   脉冲  焊丝种类  直径
                //    8       7       654          3210
                //气体 CO2 脉冲无 焊丝实芯碳钢 直径1.2
                //        0          0                    0             4              ID = 4
                tx.executeSql(str,["陶瓷衬垫","","","","","","","","","","","4"]);
                tx.executeSql(str,["打底层","300/300/300","0/0","5/6","1/3","7","0","1","0","300/600","1","4"]);
                tx.executeSql(str,["第二层","270/270/270","0/0","4.5/5.2","2/3","5.5","0","1","0","300/600","1","4"]);
                tx.executeSql(str,["填充层","250/260/260","0/0","4/5.2","2/3","5","0","0.95","0","300/600","1","4"]);
                tx.executeSql(str,["盖面层","250/260/260","0/0","4.5/5.1","3/3","4.5","0","1","0","300/600","1","4"]);
                tx.executeSql(str,["立板余高层","","","","","","","","","","","4"]);
                //气体 MAG 脉冲有 焊丝实芯碳钢 直径1.2
                //        1          1                    0             4              ID = 4
                tx.executeSql(str,["陶瓷衬垫","","","","","","","","","","","388"]);
                tx.executeSql(str,["打底层","300/300/300","0/0","5/6","1/3","7","0","1","0","300/600","1","388"]);
                tx.executeSql(str,["第二层","270/270/270","0/0","4.5/5.2","2/3","5.5","0","1","0","300/600","1","388"]);
                tx.executeSql(str,["填充层","250/260/260","0/0","4/5.2","2/3","5","0","0.95","0","300/600","1","388"]);
                tx.executeSql(str,["盖面层","250/260/260","0/0","4.5/5.1","3/3","4.5","0","1","0","300/600","1","388"]);
                tx.executeSql(str,["立板余高层","","","","","","","","","","","388"]);
            }else{
                console.log("Skip Create 横焊单边V形坡口T接头限制条件 Table .");}
        })
    }
    function createLimited5Table(){
        var table;
        dataBase.transaction( function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS 立焊单边V形坡口T接头限制条件 (ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT,C10 TEXT,C11 TEXT)");
            table = tx.executeSql("SELECT * FROM 立焊单边V形坡口T接头限制条件");
            var str="INSERT INTO 立焊单边V形坡口T接头限制条件 VALUES(?,?,?,?,?,?,?,?,?,?,?,?)"
            if(table.rows.length === 0){
                //气体   脉冲  焊丝种类  直径
                //    8       7       654          3210
                //气体 CO2 脉冲无 焊丝实芯碳钢 直径1.2
                //        0          0                    0             4              ID = 4
                tx.executeSql(str,["陶瓷衬垫","","","","","","","","","","","4"]);
                tx.executeSql(str,["打底层","140/140/140","0.5/0.5","3.5/5","1.2/1.2","20","20","1","0","80/250","1","4"]);
                tx.executeSql(str,["第二层","150/150/150","0.6/0.6","4/5","1.2/1.2","16","2","0.95","0","80/250","1","4"]);
                tx.executeSql(str,["填充层","150/150/150","0.5/0.5","3.5/5","1.2/1.2","16","2","0.95","0","80/250","1","4"]);
                tx.executeSql(str,["盖面层","130/130/130","0.4/0.4","4/5","1.2/1.2","18","2","1","0","80/250","1","4"]);
                tx.executeSql(str,["立板余高层","","","","","","","","","","","4"]);
                //气体 MAG 脉冲有 焊丝实芯碳钢 直径1.2
                //        1          1                    0             4              ID = 4
                tx.executeSql(str,["陶瓷衬垫","","","","","","","","","","","388"]);
                tx.executeSql(str,["打底层","140/140/140","0.5/0.5","3.5/5","1.2/1.2","20","20","1","0","80/250","1","388"]);
                tx.executeSql(str,["第二层","150/150/150","0.6/0.6","4/5","1.2/1.2","16","2","0.95","0","80/250","1","388"]);
                tx.executeSql(str,["填充层","150/150/150","0.5/0.5","3.5/5","1.2/1.2","16","2","0.95","0","80/250","1","388"]);
                tx.executeSql(str,["盖面层","130/130/130","0.4/0.4","4/5","1.2/1.2","18","2","1","0","80/250","1","388"]);
                tx.executeSql(str,["立板余高层","","","","","","","","","","","388"]);
            }else{
                console.log("Skip Create 立焊单边V形坡口T接头限制条件 Table .");}
        })
    }
    function createLimited6Table(){
        var table;
        dataBase.transaction( function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS 立焊单边V形坡口平对接限制条件 (ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT,C10 TEXT,C11 TEXT)");
            table = tx.executeSql("SELECT * FROM 立焊单边V形坡口平对接限制条件");
            var str="INSERT INTO 立焊单边V形坡口平对接限制条件 VALUES(?,?,?,?,?,?,?,?,?,?,?,?)"
            if(table.rows.length === 0){
                //气体   脉冲  焊丝种类  直径
                //    8       7       654          3210
                //气体 CO2 脉冲无 焊丝实芯碳钢 直径1.2
                //        0          0                    0             4              ID = 4
                tx.executeSql(str,["陶瓷衬垫","","","","","","","","","","","4"]);
                tx.executeSql(str,["打底层","140/140/140","0.5/0.5","3.5/5","1.2/1.2","20","20","1","0","80/250","1","4"]);
                tx.executeSql(str,["第二层","150/150/150","0.6/0.6","4/5","1.2/1.2","16","2","0.95","0","80/250","1","4"]);
                tx.executeSql(str,["填充层","150/150/150","0.5/0.5","3.5/5","1.2/1.2","16","2","0.95","0","80/250","1","4"]);
                tx.executeSql(str,["盖面层","130/130/130","0.4/0.4","4/5","1.2/1.2","18","2","1","0","80/250","1","4"]);
                tx.executeSql(str,["立板余高层","","","","","","","","","","","4"]);
                //气体 MAG 脉冲有 焊丝实芯碳钢 直径1.2
                //        1          1                    0             4              ID = 4
                tx.executeSql(str,["陶瓷衬垫","","","","","","","","","","","388"]);
                tx.executeSql(str,["打底层","140/140/140","0.5/0.5","3.5/5","1.2/1.2","20","20","1","0","80/250","1","388"]);
                tx.executeSql(str,["第二层","150/150/150","0.6/0.6","4/5","1.2/1.2","16","2","0.95","0","80/250","1","388"]);
                tx.executeSql(str,["填充层","150/150/150","0.5/0.5","3.5/5","1.2/1.2","16","2","0.95","0","80/250","1","388"]);
                tx.executeSql(str,["盖面层","130/130/130","0.4/0.4","4/5","1.2/1.2","18","2","1","0","80/250","1","388"]);
                tx.executeSql(str,["立板余高层","","","","","","","","","","","388"]);
            }else{
                console.log("Skip Create 立焊单边V形坡口平对接限制条件 Table .");}
        })
    }
    function createLimited7Table(){
        var table;
        dataBase.transaction( function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS 立焊V形坡口平对接限制条件 (ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT,C10 TEXT,C11 TEXT)");
            table = tx.executeSql("SELECT * FROM 立焊V形坡口平对接限制条件");
            var str="INSERT INTO 立焊V形坡口平对接限制条件 VALUES(?,?,?,?,?,?,?,?,?,?,?,?)"
            if(table.rows.length === 0){
                //气体   脉冲  焊丝种类  直径
                //    8       7       654          3210
                //气体 CO2 脉冲无 焊丝实芯碳钢 直径1.2
                //        0          0                    0             4              ID = 4
                tx.executeSql(str,["陶瓷衬垫","","","","","","","","","","","4"]);
                tx.executeSql(str,["打底层","140/140/140","0.5/0.5","3.5/5","1.2/1.2","20","20","1","0","80/250","1","4"]);
                tx.executeSql(str,["第二层","150/150/150","0.6/0.6","4/5","1.2/1.2","16","2","0.95","0","80/250","1","4"]);
                tx.executeSql(str,["填充层","150/150/150","0.5/0.5","3.5/5","1.2/1.2","16","2","0.95","0","80/250","1","4"]);
                tx.executeSql(str,["盖面层","130/130/130","0.4/0.4","4/5","1.2/1.2","18","2","1","0","80/250","1","4"]);
                tx.executeSql(str,["立板余高层","","","","","","","","","","","4"]);
                //气体 MAG 脉冲有 焊丝实芯碳钢 直径1.2
                //        1          1                    0             4              ID = 4
                tx.executeSql(str,["陶瓷衬垫","","","","","","","","","","","388"]);
                tx.executeSql(str,["打底层","140/140/140","0.5/0.5","3.5/5","1.2/1.2","20","20","1","0","80/250","1","388"]);
                tx.executeSql(str,["第二层","150/150/150","0.6/0.6","4/5","1.2/1.2","16","2","0.95","0","80/250","1","388"]);
                tx.executeSql(str,["填充层","150/150/150","0.5/0.5","3.5/5","1.2/1.2","16","2","0.95","0","80/250","1","388"]);
                tx.executeSql(str,["盖面层","130/130/130","0.4/0.4","4/5","1.2/1.2","18","2","1","0","80/250","1","388"]);
                tx.executeSql(str,["立板余高层","","","","","","","","","","","388"]);
            }else{
                console.log("Skip Create 立焊V形坡口平对接限制条件 Table .");}
        })
    }
    function createLimited8Table(){
        var table;
        dataBase.transaction( function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS 水平角焊限制条件 (ID TEXT,C1 TEXT,C2 TEXT,C3 TEXT,C4 TEXT,C5 TEXT,C6 TEXT,C7 TEXT,C8 TEXT,C9 TEXT,C10 TEXT,C11 TEXT)");
            table = tx.executeSql("SELECT * FROM 水平角焊限制条件");
            var str="INSERT INTO 水平角焊限制条件 VALUES(?,?,?,?,?,?,?,?,?,?,?,?)"
            if(table.rows.length === 0){
                //气体   脉冲  焊丝种类  直径
                //    8       7       654          3210
                //气体 CO2 脉冲无 焊丝实芯碳钢 直径1.2
                //        0          0                    0             4              ID = 4
                tx.executeSql(str,["陶瓷衬垫","","","","","","","","","","","4"]);
                tx.executeSql(str,["打底层","300/300/300","0/0","5/6.5","1/1","15","0","1","0","250/500","1","4"]);
                tx.executeSql(str,["第二层","280/280/280","0/0","4.1/5.4","3/3","10","0","0.98","0","250/500","1","4"]);
                tx.executeSql(str,["填充层","270/270/270","0/0","4/5.2","3/3","10","0","0.98","0","250/500","1","4"]);
                tx.executeSql(str,["盖面层","260/260/260","0/0","4.5/5.1","3/3","10","0","0.98","0","250/500","1","4"]);
                tx.executeSql(str,["立板余高层","","","","","","","","","","","4"]);
                //气体 MAG 脉冲有 焊丝实芯碳钢 直径1.2
                //        1          1                    0             4              ID = 4
                tx.executeSql(str,["陶瓷衬垫","","","","","","","","","","","4"]);
                tx.executeSql(str,["打底层","300/300/300","0/0","5/6.5","1/1","15","0","1","0","250/500","1","388"]);
                tx.executeSql(str,["第二层","280/280/280","0/0","4.1/5.4","3/3","10","0","0.98","0","250/500","1","388"]);
                tx.executeSql(str,["填充层","270/270/270","0/0","4/5.2","3/3","10","0","0.98","0","250/500","1","388"]);
                tx.executeSql(str,["盖面层","260/260/260","0/0","4.5/5.1","3/3","10","0","0.98","0","250/500","1","388"]);
                tx.executeSql(str,["立板余高层","","","","","","","","","","","388"]);
            }else{
                console.log("Skip Create 水平角焊限制条件 Table .");}
        })
    }

    function createLimitedTable(){
        createLimited0Table();
        createLimited1Table();
        createLimited2Table();
        createLimited3Table();
        createLimited4Table();
        createLimited5Table();
        createLimited6Table();
        createLimited7Table();
        createLimited8Table();
    }
}
