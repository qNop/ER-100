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

    property var grooveStyleName: [ "平焊单边V型坡口T接头",  "平焊单边V型坡口平对接", "平焊V型坡口平对接","横焊单边V型坡口T接头",  "横焊单边V型坡口平对接", "立焊单边V型坡口T接头",  "立焊单边V型坡口平对接", "立焊V型坡口平对接","水平角焊"  ]

    //获取系统时间
    function getSysTime(){
            return new Date().toLocaleString(Qt.locale("ch_ZN"),"yyyy-MM-dd h:mm:ss")
    }
    function getPageFunctionAndValueFromTable(index){
        var result,str;
        if(!dataBase) { console.log("Open dataBase::dataBase fail !");return -1;}
        switch(index){
        case 0:str="select * from 平焊单边V型坡口T接头限制条件";break;
        case 1:str="select * from 平焊单边V型坡口平对接限制条件";break;
        case 2:str="select * from 平焊V型坡口平对接限制条件";break;
        case 3:str="select * from 横焊单边V型坡口T接头限制条件";break;
        case 4:str="select * from 横焊单边V型坡口平对接限制条件";break;
        case 5:str="select * from 立焊单边V型坡口T接头限制条件";break;
        case 6:str="select * from 立焊单边V型坡口平对接限制条件";break;
        case 7:str="select * from 立焊V型坡口平对接限制条件";break;
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
        if(!dataBase) { console.log("UserData::dataBase ");return -1;}
        str="UPDATE "+tablename+" SET value = "+"\'"+value+"\'"+" WHERE id = "+"\'"+id+"\'";
        console.log(str);
        dataBase.transaction( function(tx) {result = tx.executeSql(str); });
    }
    /*写入数据库相关词条的数值*/
    function setValue(tablename,id,value){
        var result,str;
        if(!dataBase) { console.log("UserData::dataBase ");return -1;}
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
        if(!dataBase) { console.log("UserData::dataBase ");return -1;}
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
        if(!dataBase) { console.log("Open dataBase::dataBase fail !");return -1;}
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
        if(!dataBase) { console.log("Open dataBase::dataBase fail !");return -1;}
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
        if(!dataBase) { console.log("Open dataBase::dataBase fail !");return -1;}
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
      *从数据库中获取 列表
      */
    function getTableJson(tablename){
        var result,str;
        if(!dataBase) { console.log("Open dataBase::dataBase fail !");return -1;}
        str="SELECT * FROM "+tablename;
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
    /**
      *从数据库中获取 焊接规范
      */
    function getListGrooveName(tablename,func){
        var result,str;
        if(!dataBase) { console.log("Open dataBase::dataBase fail !");return -1;}
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
    *从数据表中获取最近的头条信息 以时间顺序排列
    */
    function getLastGrooveName(tablename,func){
        var error,result;
        if(!dataBase) { console.log("Open dataBase::dataBase fail !");return -1;}
        if((typeof(tablename)==="string")&&(typeof(func)==="string")){
            dataBase.transaction( function(tx) {
                result = tx.executeSql("SELECT * FROM "+tablename+" ORDER BY "+func+" DESC");
            });
            if(result.rows.length){
                return result.rows.item(0).Groove;
            }else
                return -1;
        }else
            return -1;
    }
    /*
          *根据输入参数 创建数据库 参数库不存在 则返回-1 成功返回1
          */
    function createTable(tablename,format){
        var res;
        if(!root.dataBase){ console.log("Open dataBase::dataBase fail !");return -1;}
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
        if(!root.dataBase){ console.log("Open dataBase::dataBase fail !");return -1;}
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
        if(!root.dataBase){ console.log("Open dataBase::dataBase fail !");return -1;}
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
        if(!root.dataBase){ console.log("Open dataBase::dataBase fail !");return -1;}
        var str="INSERT INTO "+tablename+" VALUES"+func;
        console.log(str)
        dataBase.transaction( function(tx) { tx.executeSql(str,data);});
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
    function createLimited0Table(tableName){
        if(typeof(tableName)==="string"){
            var str="CREATE TABLE IF NOT EXISTS ";
            str+=tableName;
            str+="(id INT NOT NULL PRIMARY KEY,value TEXT)"
            var table;
            dataBase.transaction( function(tx) {
                tx.executeSql(str);
                table = tx.executeSql("select * from "+tableName);
                str="insert into "
                str+=tableName;
                str+=" values(?,?)"
                if(table.rows.length === 0){
                    //初层陶衬垫电流前侧
                    tx.executeSql(str,[0,"230"]);
                    //初层陶衬垫电流中间
                    tx.executeSql(str,[1,"230"]);
                    //初层陶衬垫电流后侧
                    tx.executeSql(str,[2,"230"]);
                    //初层陶衬垫端部停止时间前（ms）
                    tx.executeSql(str,[3,"400"]);
                    //初层陶衬垫端部停止时间后（ms）
                    tx.executeSql(str,[4,"400"]);
                    //初层陶衬垫堆高MAX
                    tx.executeSql(str,[5,"9.0"]);
                    //初层陶衬垫接近-前
                    tx.executeSql(str,[6,"2.0"]);
                    //初层陶衬垫接近-后
                    tx.executeSql(str,[7,"2.0"]);
                    //初层陶衬垫分开最大摆动宽度
                    tx.executeSql(str,[8,"20.0"]);
                    //初层陶衬垫摆动宽度间隔
                    tx.executeSql(str,[9,"100.0"]);
                    //初层陶衬垫分开结束/开始比
                    tx.executeSql(str,[10,"0.85"]);
                    //初层陶衬垫焊接电压  0代表自动设定
                    tx.executeSql(str,[11,"0"]);

                    //初层电流前侧
                    tx.executeSql(str,[12,"300"]);
                    //初层电流中间
                    tx.executeSql(str,[13,"300"]);
                    //初层电流后侧
                    tx.executeSql(str,[14,"300"]);
                    //初层端部停止时间前（ms）
                    tx.executeSql(str,[15,"500"]);
                    //初层端部停止时间后（ms）
                    tx.executeSql(str,[16,"0"]);
                    //初层堆高MAX
                    tx.executeSql(str,[17,"7.0"]);
                    //初层接近-前
                    tx.executeSql(str,[18,"1.0"]);
                    //初层接近-后
                    tx.executeSql(str,[19,"2.0"]);
                    //初层分开最大摆动宽度
                    tx.executeSql(str,[20,"20.0"]);
                    //初层摆动宽度间隔
                    tx.executeSql(str,[21,"100.0"]);
                    //初层分开结束/开始比
                    tx.executeSql(str,[22,"1.0"]);
                    //初层焊接电压
                    tx.executeSql(str,[23,"0"]);

                    //第二层电流前侧
                    tx.executeSql(str,[24,"290"]);
                    //第二层电流中间
                    tx.executeSql(str,[25,"290"]);
                    //第二层电流后侧
                    tx.executeSql(str,[26,"290"]);
                    //第二层端部停止时间前（ms）
                    tx.executeSql(str,[27,"100"]);
                    //第二层端部停止时间后（ms）
                    tx.executeSql(str,[28,"100"]);
                    //第二层堆高MAX
                    tx.executeSql(str,[29,"5.0"]);
                    //第二层接近-前
                    tx.executeSql(str,[30,"1.0"]);
                    //第二层接近-后
                    tx.executeSql(str,[31,"2.0"]);
                    //第二层分开最大摆动宽度
                    tx.executeSql(str,[32,"16.0"]);
                    //第二层摆动宽度间隔
                    tx.executeSql(str,[33,"5.0"]);
                    //第二层分开结束/开始比
                    tx.executeSql(str,[34,"0.85"]);
                    //第二层焊接电压
                    tx.executeSql(str,[35,"0"]);

                    //中间层电流前侧
                    tx.executeSql(str,[36,"290"]);
                    //中间层电流中间
                    tx.executeSql(str,[37,"290"]);
                    //中间层电流后侧
                    tx.executeSql(str,[38,"290"]);
                    //中间层端部停止时间前（ms）
                    tx.executeSql(str,[39,"100"]);
                    //中间层端部停止时间后（ms）
                    tx.executeSql(str,[40,"100"]);
                    //中间层堆高MAX
                    tx.executeSql(str,[41,"5.0"]);
                    //中间层接近-前
                    tx.executeSql(str,[42,"1.0"]);
                    //中间层接近-后
                    tx.executeSql(str,[43,"2.0"]);
                    //中间层分开最大摆动宽度
                    tx.executeSql(str,[44,"16.0"]);
                    //中间层摆动宽度间隔
                    tx.executeSql(str,[45,"5.0"]);
                    //中间层分开结束/开始比
                    tx.executeSql(str,[46,"0.85"]);
                    //中间层焊接电压
                    tx.executeSql(str,[47,"0"]);

                    //表面层电流前侧
                    tx.executeSql(str,[48,"280"]);
                    //表面层电流中间
                    tx.executeSql(str,[49,"280"]);
                    //表面层电流后侧
                    tx.executeSql(str,[50,"280"]);
                    //表面层端部停止时间前（ms）
                    tx.executeSql(str,[51,"0"]);
                    //表面层端部停止时间后（ms）
                    tx.executeSql(str,[52,"0"]);
                    //表面层堆高MAX
                    tx.executeSql(str,[53,"4.0"]);
                    //表面层接近-前
                    tx.executeSql(str,[54,"2.0"]);
                    //表面层接近-后
                    tx.executeSql(str,[55,"2.0"]);
                    //表面层分开最大摆动宽度
                    tx.executeSql(str,[56,"11.0"]);
                    //表面层摆动宽度间隔
                    tx.executeSql(str,[57,"5.0"]);
                    //表面层分开结束/开始比
                    tx.executeSql(str,[58,"1.0"]);
                    //表面层焊接电压
                    tx.executeSql(str,[59,"0"]);

                    //表面层余高层数
                    tx.executeSql(str,[60,"0"]);
                    //表面层分开方向 0 反方向 1标准
                    tx.executeSql(str,[61,"0"]);
                    //表面层起弧位置  00代表收弧位置
                    tx.executeSql(str,[62,"0"]);
                    //开始位置坐标X（mm）
                    tx.executeSql(str,[63,"4.0"]);
                    //开始位置坐标Y（mm）
                    tx.executeSql(str,[64,"0.0"]);
                    //开始位置坐标z（mm）
                    tx.executeSql(str,[65,"-3.0"]);
                    //表面层收弧动作 0 单程 1往返
                    tx.executeSql(str,[66,"0"]);
                    //表面层返回步骤距离
                    tx.executeSql(str,[67,"5.0"]);

                    //立板余高层电流前侧
                    tx.executeSql(str,[68,"250"]);
                    //立板余高层电流中间
                    tx.executeSql(str,[69,"250"]);
                    //立板余高层电流后侧
                    tx.executeSql(str,[70,"250"]);
                    //立板余高层端部停止时间前（ms）
                    tx.executeSql(str,[71,"0.0"]);
                    //立板余高层端部停止时间后（ms）
                    tx.executeSql(str,[72,"0.0"]);
                    //立板余高层堆高MAX
                    tx.executeSql(str,[73,"5.0"]);
                    //立板余高层接近-前
                    tx.executeSql(str,[74,"2.0"]);
                    //立板余高层接近-后
                    tx.executeSql(str,[75,"15.0"]);
                    //立板余高层分开最大摆动宽度
                    tx.executeSql(str,[76,"10.0"]);
                    //立板余高层摆动宽度间隔
                    tx.executeSql(str,[77,"5.0"]);
                    //立板余高层分开结束/开始比
                    tx.executeSql(str,[78,"1.0"]);
                    //立板余高层焊接电压
                    tx.executeSql(str,[79,"0"]);
                    //立板余高层MAX焊接速度
                    tx.executeSql(str,[80,"500.0"]);

                    /***************************************************焊接规范列表**********************************************/
                }else{
                    console.log("Skip Create "+tableName+" Table .");}
            })}
        else
            return -1;
    }
    function createLimited1Table(tableName){
        if(typeof(tableName)==="string"){
            var str="CREATE TABLE IF NOT EXISTS ";
            str+=tableName;
            str+="(id INT NOT NULL PRIMARY KEY,value TEXT)"
            var table;
            dataBase.transaction( function(tx) {
                tx.executeSql(str);
                table = tx.executeSql("select * from "+tableName);
                str="insert into "
                str+=tableName;
                str+=" values(?,?)"
                if(table.rows.length === 0){
                    //初层陶衬垫电流前侧
                    tx.executeSql(str,[0,"230"]);
                    //初层陶衬垫电流中间
                    tx.executeSql(str,[1,"230"]);
                    //初层陶衬垫电流后侧
                    tx.executeSql(str,[2,"230"]);
                    //初层陶衬垫端部停止时间前（ms）
                    tx.executeSql(str,[3,"500"]);
                    //初层陶衬垫端部停止时间后（ms）
                    tx.executeSql(str,[4,"500"]);
                    //初层陶衬垫堆高MAX
                    tx.executeSql(str,[5,"8.5"]);
                    //初层陶衬垫接近-前
                    tx.executeSql(str,[6,"2.0"]);
                    //初层陶衬垫接近-后
                    tx.executeSql(str,[7,"2.5"]);
                    //初层陶衬垫分开最大摆动宽度
                    tx.executeSql(str,[8,"20.0"]);
                    //初层陶衬垫摆动宽度间隔
                    tx.executeSql(str,[9,"100.0"]);
                    //初层陶衬垫分开结束/开始比
                    tx.executeSql(str,[10,"0.85"]);
                    //初层陶衬垫焊接电压  0代表自动设定
                    tx.executeSql(str,[11,"28"]);


                    //初层电流前侧
                    tx.executeSql(str,[12,"300"]);
                    //初层电流中间
                    tx.executeSql(str,[13,"300"]);
                    //初层电流后侧
                    tx.executeSql(str,[14,"300"]);
                    //初层端部停止时间前（ms）
                    tx.executeSql(str,[15,"200"]);
                    //初层端部停止时间后（ms）
                    tx.executeSql(str,[16,"200"]);
                    //初层堆高MAX
                    tx.executeSql(str,[17,"7.0"]);
                    //初层接近-前
                    tx.executeSql(str,[18,"2.0"]);
                    //初层接近-后
                    tx.executeSql(str,[19,"2.0"]);
                    //初层分开最大摆动宽度
                    tx.executeSql(str,[20,"20.0"]);
                    //初层摆动宽度间隔
                    tx.executeSql(str,[21,"100.0"]);
                    //初层分开结束/开始比
                    tx.executeSql(str,[22,"1.0"]);
                    //初层焊接电压
                    tx.executeSql(str,[23,"0"]);

                    //第二层电流前侧
                    tx.executeSql(str,[24,"290"]);
                    //第二层电流中间
                    tx.executeSql(str,[25,"290"]);
                    //第二层电流后侧
                    tx.executeSql(str,[26,"290"]);
                    //第二层端部停止时间前（ms）
                    tx.executeSql(str,[27,"100"]);
                    //第二层端部停止时间后（ms）
                    tx.executeSql(str,[28,"100"]);
                    //第二层堆高MAX
                    tx.executeSql(str,[29,"5.0"]);
                    //第二层接近-前
                    tx.executeSql(str,[30,"1.0"]);
                    //第二层接近-后
                    tx.executeSql(str,[31,"1.0"]);
                    //第二层分开最大摆动宽度
                    tx.executeSql(str,[32,"16.0"]);
                    //第二层摆动宽度间隔
                    tx.executeSql(str,[33,"5.0"]);
                    //第二层分开结束/开始比
                    tx.executeSql(str,[34,"0.85"]);
                    //第二层焊接电压
                    tx.executeSql(str,[35,"0"]);

                    //中间层电流前侧
                    tx.executeSql(str,[36,"290"]);
                    //中间层电流中间
                    tx.executeSql(str,[37,"290"]);
                    //中间层电流后侧
                    tx.executeSql(str,[38,"290"]);
                    //中间层端部停止时间前（ms）
                    tx.executeSql(str,[39,"100"]);
                    //中间层端部停止时间后（ms）
                    tx.executeSql(str,[40,"100"]);
                    //中间层堆高MAX
                    tx.executeSql(str,[41,"5.0"]);
                    //中间层接近-前
                    tx.executeSql(str,[42,"1.0"]);
                    //中间层接近-后
                    tx.executeSql(str,[43,"1.0"]);
                    //中间层分开最大摆动宽度
                    tx.executeSql(str,[44,"16.0"]);
                    //中间层摆动宽度间隔
                    tx.executeSql(str,[45,"5.0"]);
                    //中间层分开结束/开始比
                    tx.executeSql(str,[46,"0.85"]);
                    //中间层焊接电压
                    tx.executeSql(str,[47,"0"]);

                    //表面层电流前侧
                    tx.executeSql(str,[48,"280"]);
                    //表面层电流中间
                    tx.executeSql(str,[49,"280"]);
                    //表面层电流后侧
                    tx.executeSql(str,[50,"280"]);
                    //表面层端部停止时间前（ms）
                    tx.executeSql(str,[51,"100"]);
                    //表面层端部停止时间后（ms）
                    tx.executeSql(str,[52,"100"]);
                    //表面层堆高MAX
                    tx.executeSql(str,[53,"4.0"]);
                    //表面层接近-前
                    tx.executeSql(str,[54,"2.0"]);
                    //表面层接近-后
                    tx.executeSql(str,[55,"2.0"]);
                    //表面层分开最大摆动宽度
                    tx.executeSql(str,[56,"16.0"]);
                    //表面层摆动宽度间隔
                    tx.executeSql(str,[57,"5.0"]);
                    //表面层分开结束/开始比
                    tx.executeSql(str,[58,"1.0"]);
                    //表面层焊接电压
                    tx.executeSql(str,[59,"0"]);

                    //表面层余高层数
                    tx.executeSql(str,[60,"0"]);
                    //表面层分开方向 0 反方向 1标准
                    tx.executeSql(str,[61,"0"]);
                    //表面层起弧位置  00代表收弧位置
                    tx.executeSql(str,[62,"0"]);
                    //开始位置坐标X（mm）
                    tx.executeSql(str,[63,"4.0"]);
                    //开始位置坐标Y（mm）
                    tx.executeSql(str,[64,"0.0"]);
                    //开始位置坐标z（mm）
                    tx.executeSql(str,[65,"-3.0"]);
                    //表面层收弧动作 0 单程 1往返
                    tx.executeSql(str,[66,"0"]);
                    //表面层返回步骤距离
                    tx.executeSql(str,[67,"5.0"]);


                    //立板余高层电流前侧
                    tx.executeSql(str,[68,"0"]);
                    //立板余高层电流中间
                    tx.executeSql(str,[69,"0"]);
                    //立板余高层电流后侧
                    tx.executeSql(str,[70,"0"]);
                    //立板余高层端部停止时间前（ms）
                    tx.executeSql(str,[71,"0"]);
                    //立板余高层端部停止时间后（ms）
                    tx.executeSql(str,[72,"0"]);
                    //立板余高层堆高MAX
                    tx.executeSql(str,[73,"0"]);
                    //立板余高层接近-前
                    tx.executeSql(str,[74,"0"]);
                    //立板余高层接近-后
                    tx.executeSql(str,[75,"0"]);
                    //立板余高层分开最大摆动宽度
                    tx.executeSql(str,[76,"0"]);
                    //立板余高层摆动宽度间隔
                    tx.executeSql(str,[77,"0"]);
                    //立板余高层分开结束/开始比
                    tx.executeSql(str,[78,"0"]);
                    //立板余高层焊接电压
                    tx.executeSql(str,[79,"0"]);
                    //立板余高层MAX焊接速度
                    tx.executeSql(str,[80,"0"]);
                    /***************************************************焊接规范列表**********************************************/
                }
                else{
                    console.log("Skip Create "+tableName+" Table .");}
            })
        }else
            return -1;
    }

    function createLimited2Table(tableName){
        if(typeof(tableName)==="string"){
            var str="CREATE TABLE IF NOT EXISTS ";
            str+=tableName;
            str+="(id INT NOT NULL PRIMARY KEY,value TEXT)"
            var table;
            dataBase.transaction( function(tx) {
                tx.executeSql(str);
                table = tx.executeSql("select * from "+tableName);
                str="insert into "
                str+=tableName;
                str+=" values(?,?)"
                if(table.rows.length === 0){
                    /***************************************************焊接规范限制**********************************************/
                    //初层陶衬垫电流前侧
                    tx.executeSql(str,[0,"230"]);
                    //初层陶衬垫电流中间
                    tx.executeSql(str,[1,"230"]);
                    //初层陶衬垫电流后侧
                    tx.executeSql(str,[2,"230"]);
                    //初层陶衬垫端部停止时间前（ms）
                    tx.executeSql(str,[3,"400"]);
                    //初层陶衬垫端部停止时间后（ms）
                    tx.executeSql(str,[4,"400"]);
                    //初层陶衬垫堆高MAX
                    tx.executeSql(str,[5,"9.0"]);
                    //初层陶衬垫接近-前
                    tx.executeSql(str,[6,"2.0"]);
                    //初层陶衬垫接近-后
                    tx.executeSql(str,[7,"2.0"]);
                    //初层陶衬垫分开最大摆动宽度
                    tx.executeSql(str,[8,"20.0"]);
                    //初层陶衬垫摆动宽度间隔
                    tx.executeSql(str,[9,"100.0"]);
                    //初层陶衬垫分开结束/开始比
                    tx.executeSql(str,[10,"0.85"]);
                    //初层陶衬垫焊接电压  0代表自动设定
                    tx.executeSql(str,[11,"28"]);

                    //初层电流前侧
                    tx.executeSql(str,[12,"300"]);
                    //初层电流中间
                    tx.executeSql(str,[13,"300"]);
                    //初层电流后侧
                    tx.executeSql(str,[14,"300"]);
                    //初层端部停止时间前（ms）
                    tx.executeSql(str,[15,"200"]);
                    //初层端部停止时间后（ms）
                    tx.executeSql(str,[16,"200"]);
                    //初层堆高MAX
                    tx.executeSql(str,[17,"7.0"]);
                    //初层接近-前
                    tx.executeSql(str,[18,"2.0"]);
                    //初层接近-后
                    tx.executeSql(str,[19,"2.0"]);
                    //初层分开最大摆动宽度
                    tx.executeSql(str,[20,"20.0"]);
                    //初层摆动宽度间隔
                    tx.executeSql(str,[21,"100.0"]);
                    //初层分开结束/开始比
                    tx.executeSql(str,[22,"1.0"]);
                    //初层焊接电压
                    tx.executeSql(str,[23,"0"]);

                    //第二层电流前侧
                    tx.executeSql(str,[24,"290"]);
                    //第二层电流中间
                    tx.executeSql(str,[25,"290"]);
                    //第二层电流后侧
                    tx.executeSql(str,[26,"290"]);
                    //第二层端部停止时间前（ms）
                    tx.executeSql(str,[27,"100"]);
                    //第二层端部停止时间后（ms）
                    tx.executeSql(str,[28,"100"]);
                    //第二层堆高MAX
                    tx.executeSql(str,[29,"5.0"]);
                    //第二层接近-前
                    tx.executeSql(str,[30,"1.0"]);
                    //第二层接近-后
                    tx.executeSql(str,[31,"1.0"]);
                    //第二层分开最大摆动宽度
                    tx.executeSql(str,[32,"16.0"]);
                    //第二层摆动宽度间隔
                    tx.executeSql(str,[33,"5.0"]);
                    //第二层分开结束/开始比
                    tx.executeSql(str,[34,"0.85"]);
                    //第二层焊接电压
                    tx.executeSql(str,[35,"0"]);

                    //中间层电流前侧
                    tx.executeSql(str,[36,"290"]);
                    //中间层电流中间
                    tx.executeSql(str,[37,"290"]);
                    //中间层电流后侧
                    tx.executeSql(str,[38,"290"]);
                    //中间层端部停止时间前（ms）
                    tx.executeSql(str,[39,"100"]);
                    //中间层端部停止时间后（ms）
                    tx.executeSql(str,[40,"100"]);
                    //中间层堆高MAX
                    tx.executeSql(str,[41,"4.0"]);
                    //中间层接近-前
                    tx.executeSql(str,[42,"2.0"]);
                    //中间层接近-后
                    tx.executeSql(str,[43,"2.0"]);
                    //中间层分开最大摆动宽度
                    tx.executeSql(str,[44,"14.0"]);
                    //中间层摆动宽度间隔
                    tx.executeSql(str,[45,"5.0"]);
                    //中间层分开结束/开始比
                    tx.executeSql(str,[46,"1.0"]);
                    //中间层焊接电压
                    tx.executeSql(str,[47,"0"]);

                    //表面层电流前侧
                    tx.executeSql(str,[48,"280"]);
                    //表面层电流中间
                    tx.executeSql(str,[49,"280"]);
                    //表面层电流后侧
                    tx.executeSql(str,[50,"280"]);
                    //表面层端部停止时间前（ms）
                    tx.executeSql(str,[51,"100"]);
                    //表面层端部停止时间后（ms）
                    tx.executeSql(str,[52,"100"]);
                    //表面层堆高MAX
                    tx.executeSql(str,[53,"4.0"]);
                    //表面层接近-前
                    tx.executeSql(str,[54,"2.0"]);
                    //表面层接近-后
                    tx.executeSql(str,[55,"2.0"]);
                    //表面层分开最大摆动宽度
                    tx.executeSql(str,[56,"16.0"]);
                    //表面层摆动宽度间隔
                    tx.executeSql(str,[57,"5.0"]);
                    //表面层分开结束/开始比
                    tx.executeSql(str,[58,"1.0"]);
                    //表面层焊接电压
                    tx.executeSql(str,[59,"0"]);

                    //表面层余高层数
                    tx.executeSql(str,[60,"0"]);
                    //表面层分开方向 0 反方向 1标准
                    tx.executeSql(str,[61,"0"]);
                    //表面层起弧位置  00代表收弧位置
                    tx.executeSql(str,[62,"0"]);
                    //开始位置坐标X（mm）
                    tx.executeSql(str,[63,"4.0"]);
                    //开始位置坐标Y（mm）
                    tx.executeSql(str,[64,"0.0"]);
                    //开始位置坐标z（mm）
                    tx.executeSql(str,[65,"-3.0"]);
                    //表面层收弧动作 0 单程 1往返
                    tx.executeSql(str,[66,"0"]);
                    //表面层返回步骤距离
                    tx.executeSql(str,[67,"5.0"]);

                    //立板余高层电流前侧
                    tx.executeSql(str,[68,"0"]);
                    //立板余高层电流中间
                    tx.executeSql(str,[69,"0"]);
                    //立板余高层电流后侧
                    tx.executeSql(str,[70,"0"]);
                    //立板余高层端部停止时间前（ms）
                    tx.executeSql(str,[71,"0"]);
                    //立板余高层端部停止时间后（ms）
                    tx.executeSql(str,[72,"0"]);
                    //立板余高层堆高MAX
                    tx.executeSql(str,[73,"0"]);
                    //立板余高层接近-前
                    tx.executeSql(str,[74,"0"]);
                    //立板余高层接近-后
                    tx.executeSql(str,[75,"0"]);
                    //立板余高层分开最大摆动宽度
                    tx.executeSql(str,[76,"0"]);
                    //立板余高层摆动宽度间隔
                    tx.executeSql(str,[77,"0"]);
                    //立板余高层分开结束/开始比
                    tx.executeSql(str,[78,"0"]);
                    //立板余高层焊接电压
                    tx.executeSql(str,[79,"0"]);
                    //立板余高层MAX焊接速度
                    tx.executeSql(str,[80,"0"]);

                    /***************************************************焊接规范列表**********************************************/
                }
                else{
                    console.log("Skip Create "+tableName+" Table .");}
            })
        }else
            return -1;
    }
    function createLimited3Table(tableName){
        if(typeof(tableName)==="string"){
            var str="CREATE TABLE IF NOT EXISTS ";
            str+=tableName;
            str+="(id INT NOT NULL PRIMARY KEY,value TEXT)"
            var table;
            dataBase.transaction( function(tx) {
                tx.executeSql(str);
                table = tx.executeSql("select * from "+tableName);
                str="insert into "
                str+=tableName;
                str+=" values(?,?)"
                if(table.rows.length === 0){
                    /***************************************************焊接规范限制**********************************************/
                    //初层陶衬垫电流前侧
                    tx.executeSql(str,[0,"0"]);
                    //初层陶衬垫电流中间
                    tx.executeSql(str,[1,"0"]);
                    //初层陶衬垫电流后侧
                    tx.executeSql(str,[2,"0"]);
                    //初层陶衬垫端部停止时间前（ms）
                    tx.executeSql(str,[3,"0"]);
                    //初层陶衬垫端部停止时间后（ms）
                    tx.executeSql(str,[4,"0"]);
                    //初层陶衬垫堆高MAX
                    tx.executeSql(str,[5,"0"]);
                    //初层陶衬垫接近-前
                    tx.executeSql(str,[6,"0"]);
                    //初层陶衬垫接近-后
                    tx.executeSql(str,[7,"0"]);
                    //初层陶衬垫分开最大摆动宽度
                    tx.executeSql(str,[8,"0"]);
                    //初层陶衬垫摆动宽度间隔
                    tx.executeSql(str,[9,"0"]);
                    //初层陶衬垫分开结束/开始比
                    tx.executeSql(str,[10,"0"]);
                    //初层陶衬垫焊接电压  0代表自动设定
                    tx.executeSql(str,[11,"0"]);

                    //初层电流前侧
                    tx.executeSql(str,[12,"300"]);
                    //初层电流中间
                    tx.executeSql(str,[13,"300"]);
                    //初层电流后侧
                    tx.executeSql(str,[14,"270"]);
                    //初层端部停止时间前（ms）
                    tx.executeSql(str,[15,"0"]);
                    //初层端部停止时间后（ms）
                    tx.executeSql(str,[16,"0"]);
                    //初层堆高MAX
                    tx.executeSql(str,[17,"8.1"]);
                    //初层接近-前
                    tx.executeSql(str,[18,"1.5"]);
                    //初层接近-后
                    tx.executeSql(str,[19,"5.0"]);
                    //初层分开最大摆动宽度
                    tx.executeSql(str,[20,"20.0"]);
                    //初层摆动宽度间隔
                    tx.executeSql(str,[21,"100.0"]);
                    //初层分开结束/开始比
                    tx.executeSql(str,[22,"1.0"]);
                    //初层焊接电压
                    tx.executeSql(str,[23,"0"]);

                    //第二层电流前侧
                    tx.executeSql(str,[24,"290"]);
                    //第二层电流中间
                    tx.executeSql(str,[25,"290"]);
                    //第二层电流后侧
                    tx.executeSql(str,[26,"290"]);
                    //第二层端部停止时间前（ms）
                    tx.executeSql(str,[27,"100"]);
                    //第二层端部停止时间后（ms）
                    tx.executeSql(str,[28,"100"]);
                    //第二层堆高MAX
                    tx.executeSql(str,[29,"5.0"]);
                    //第二层接近-前
                    tx.executeSql(str,[30,"1.0"]);
                    //第二层接近-后
                    tx.executeSql(str,[31,"1.0"]);
                    //第二层分开最大摆动宽度
                    tx.executeSql(str,[32,"16.0"]);
                    //第二层摆动宽度间隔
                    tx.executeSql(str,[33,"5.0"]);
                    //第二层分开结束/开始比
                    tx.executeSql(str,[34,"0.85"]);
                    //第二层焊接电压
                    tx.executeSql(str,[35,"0"]);

                    //中间层电流前侧
                    tx.executeSql(str,[36,"290"]);
                    //中间层电流中间
                    tx.executeSql(str,[37,"290"]);
                    //中间层电流后侧
                    tx.executeSql(str,[38,"290"]);
                    //中间层端部停止时间前（ms）
                    tx.executeSql(str,[39,"100"]);
                    //中间层端部停止时间后（ms）
                    tx.executeSql(str,[40,"100"]);
                    //中间层堆高MAX
                    tx.executeSql(str,[41,"4.0"]);
                    //中间层接近-前
                    tx.executeSql(str,[42,"2.0"]);
                    //中间层接近-后
                    tx.executeSql(str,[43,"2.0"]);
                    //中间层分开最大摆动宽度
                    tx.executeSql(str,[44,"14.0"]);
                    //中间层摆动宽度间隔
                    tx.executeSql(str,[45,"5.0"]);
                    //中间层分开结束/开始比
                    tx.executeSql(str,[46,"1.0"]);
                    //中间层焊接电压
                    tx.executeSql(str,[47,"0"]);

                    //表面层电流前侧
                    tx.executeSql(str,[48,"280"]);
                    //表面层电流中间
                    tx.executeSql(str,[49,"280"]);
                    //表面层电流后侧
                    tx.executeSql(str,[50,"280"]);
                    //表面层端部停止时间前（ms）
                    tx.executeSql(str,[51,"100"]);
                    //表面层端部停止时间后（ms）
                    tx.executeSql(str,[52,"100"]);
                    //表面层堆高MAX
                    tx.executeSql(str,[53,"4.0"]);
                    //表面层接近-前
                    tx.executeSql(str,[54,"2.0"]);
                    //表面层接近-后
                    tx.executeSql(str,[55,"2.0"]);
                    //表面层分开最大摆动宽度
                    tx.executeSql(str,[56,"16.0"]);
                    //表面层摆动宽度间隔
                    tx.executeSql(str,[57,"5.0"]);
                    //表面层分开结束/开始比
                    tx.executeSql(str,[58,"1.0"]);
                    //表面层焊接电压
                    tx.executeSql(str,[59,"0"]);

                    //表面层余高层数
                    tx.executeSql(str,[60,"0"]);
                    //表面层分开方向 0 反方向 1标准
                    tx.executeSql(str,[61,"0"]);
                    //表面层起弧位置  00代表收弧位置
                    tx.executeSql(str,[62,"0"]);
                    //开始位置坐标X（mm）
                    tx.executeSql(str,[63,"4.0"]);
                    //开始位置坐标Y（mm）
                    tx.executeSql(str,[64,"0.0"]);
                    //开始位置坐标z（mm）
                    tx.executeSql(str,[65,"-3.0"]);
                    //表面层收弧动作 0 单程 1往返
                    tx.executeSql(str,[66,"0"]);
                    //表面层返回步骤距离
                    tx.executeSql(str,[67,"5.0"]);

                    //立板余高层电流前侧
                    tx.executeSql(str,[68,"0"]);
                    //立板余高层电流中间
                    tx.executeSql(str,[69,"0"]);
                    //立板余高层电流后侧
                    tx.executeSql(str,[70,"0"]);
                    //立板余高层端部停止时间前（ms）
                    tx.executeSql(str,[71,"0"]);
                    //立板余高层端部停止时间后（ms）
                    tx.executeSql(str,[72,"0"]);
                    //立板余高层堆高MAX
                    tx.executeSql(str,[73,"0"]);
                    //立板余高层接近-前
                    tx.executeSql(str,[74,"0"]);
                    //立板余高层接近-后
                    tx.executeSql(str,[75,"0"]);
                    //立板余高层分开最大摆动宽度
                    tx.executeSql(str,[76,"0"]);
                    //立板余高层摆动宽度间隔
                    tx.executeSql(str,[77,"0"]);
                    //立板余高层分开结束/开始比
                    tx.executeSql(str,[78,"0"]);
                    //立板余高层焊接电压
                    tx.executeSql(str,[79,"0"]);
                    //立板余高层MAX焊接速度
                    tx.executeSql(str,[80,"0"]);

                }  else{
                    console.log("Skip Create "+tableName+" Table .");}
            })}
        else
            return -1;
    }
    function createLimited4Table(tableName){
        if(typeof(tableName)==="string"){
            var str="CREATE TABLE IF NOT EXISTS ";
            str+=tableName;
            str+="(id INT NOT NULL PRIMARY KEY,value TEXT)"
            var table;
            dataBase.transaction( function(tx) {
                tx.executeSql(str);
                table = tx.executeSql("select * from "+tableName);
                str="insert into "
                str+=tableName;
                str+=" values(?,?)"
                if(table.rows.length === 0){
                    /***************************************************焊接规范限制**********************************************/
                    //初层陶衬垫电流前侧
                    tx.executeSql(str,[0,"0"]);
                    //初层陶衬垫电流中间
                    tx.executeSql(str,[1,"0"]);
                    //初层陶衬垫电流后侧
                    tx.executeSql(str,[2,"0"]);
                    //初层陶衬垫端部停止时间前（ms）
                    tx.executeSql(str,[3,"0"]);
                    //初层陶衬垫端部停止时间后（ms）
                    tx.executeSql(str,[4,"0"]);
                    //初层陶衬垫堆高MAX
                    tx.executeSql(str,[5,"0"]);
                    //初层陶衬垫接近-前
                    tx.executeSql(str,[6,"0"]);
                    //初层陶衬垫接近-后
                    tx.executeSql(str,[7,"0"]);
                    //初层陶衬垫分开最大摆动宽度
                    tx.executeSql(str,[8,"0"]);
                    //初层陶衬垫摆动宽度间隔
                    tx.executeSql(str,[9,"0"]);
                    //初层陶衬垫分开结束/开始比
                    tx.executeSql(str,[10,"0"]);
                    //初层陶衬垫焊接电压  0代表自动设定
                    tx.executeSql(str,[11,"0"]);

                    //初层电流前侧
                    tx.executeSql(str,[12,"300"]);
                    //初层电流中间
                    tx.executeSql(str,[13,"300"]);
                    //初层电流后侧
                    tx.executeSql(str,[14,"270"]);
                    //初层端部停止时间前（ms）
                    tx.executeSql(str,[15,"0"]);
                    //初层端部停止时间后（ms）
                    tx.executeSql(str,[16,"0"]);
                    //初层堆高MAX
                    tx.executeSql(str,[17,"8.1"]);
                    //初层接近-前
                    tx.executeSql(str,[18,"1.5"]);
                    //初层接近-后
                    tx.executeSql(str,[19,"5.0"]);
                    //初层分开最大摆动宽度
                    tx.executeSql(str,[20,"20.0"]);
                    //初层摆动宽度间隔
                    tx.executeSql(str,[21,"100.0"]);
                    //初层分开结束/开始比
                    tx.executeSql(str,[22,"1.0"]);
                    //初层焊接电压
                    tx.executeSql(str,[23,"0"]);

                    //第二层电流前侧
                    tx.executeSql(str,[24,"290"]);
                    //第二层电流中间
                    tx.executeSql(str,[25,"290"]);
                    //第二层电流后侧
                    tx.executeSql(str,[26,"290"]);
                    //第二层端部停止时间前（ms）
                    tx.executeSql(str,[27,"100"]);
                    //第二层端部停止时间后（ms）
                    tx.executeSql(str,[28,"100"]);
                    //第二层堆高MAX
                    tx.executeSql(str,[29,"5.0"]);
                    //第二层接近-前
                    tx.executeSql(str,[30,"1.0"]);
                    //第二层接近-后
                    tx.executeSql(str,[31,"1.0"]);
                    //第二层分开最大摆动宽度
                    tx.executeSql(str,[32,"16.0"]);
                    //第二层摆动宽度间隔
                    tx.executeSql(str,[33,"5.0"]);
                    //第二层分开结束/开始比
                    tx.executeSql(str,[34,"0.85"]);
                    //第二层焊接电压
                    tx.executeSql(str,[35,"0"]);

                    //中间层电流前侧
                    tx.executeSql(str,[36,"290"]);
                    //中间层电流中间
                    tx.executeSql(str,[37,"290"]);
                    //中间层电流后侧
                    tx.executeSql(str,[38,"290"]);
                    //中间层端部停止时间前（ms）
                    tx.executeSql(str,[39,"100"]);
                    //中间层端部停止时间后（ms）
                    tx.executeSql(str,[40,"100"]);
                    //中间层堆高MAX
                    tx.executeSql(str,[41,"4.0"]);
                    //中间层接近-前
                    tx.executeSql(str,[42,"2.0"]);
                    //中间层接近-后
                    tx.executeSql(str,[43,"2.0"]);
                    //中间层分开最大摆动宽度
                    tx.executeSql(str,[44,"14.0"]);
                    //中间层摆动宽度间隔
                    tx.executeSql(str,[45,"5.0"]);
                    //中间层分开结束/开始比
                    tx.executeSql(str,[46,"1.0"]);
                    //中间层焊接电压
                    tx.executeSql(str,[47,"0"]);

                    //表面层电流前侧
                    tx.executeSql(str,[48,"280"]);
                    //表面层电流中间
                    tx.executeSql(str,[49,"280"]);
                    //表面层电流后侧
                    tx.executeSql(str,[50,"280"]);
                    //表面层端部停止时间前（ms）
                    tx.executeSql(str,[51,"100"]);
                    //表面层端部停止时间后（ms）
                    tx.executeSql(str,[52,"100"]);
                    //表面层堆高MAX
                    tx.executeSql(str,[53,"4.0"]);
                    //表面层接近-前
                    tx.executeSql(str,[54,"2.0"]);
                    //表面层接近-后
                    tx.executeSql(str,[55,"2.0"]);
                    //表面层分开最大摆动宽度
                    tx.executeSql(str,[56,"16.0"]);
                    //表面层摆动宽度间隔
                    tx.executeSql(str,[57,"5.0"]);
                    //表面层分开结束/开始比
                    tx.executeSql(str,[58,"1.0"]);
                    //表面层焊接电压
                    tx.executeSql(str,[59,"0"]);

                    //表面层余高层数
                    tx.executeSql(str,[60,"0"]);
                    //表面层分开方向 0 反方向 1标准
                    tx.executeSql(str,[61,"0"]);
                    //表面层起弧位置  00代表收弧位置
                    tx.executeSql(str,[62,"0"]);
                    //开始位置坐标X（mm）
                    tx.executeSql(str,[63,"4.0"]);
                    //开始位置坐标Y（mm）
                    tx.executeSql(str,[64,"0.0"]);
                    //开始位置坐标z（mm）
                    tx.executeSql(str,[65,"-3.0"]);
                    //表面层收弧动作 0 单程 1往返
                    tx.executeSql(str,[66,"0"]);
                    //表面层返回步骤距离
                    tx.executeSql(str,[67,"5.0"]);

                    //立板余高层电流前侧
                    tx.executeSql(str,[68,"0"]);
                    //立板余高层电流中间
                    tx.executeSql(str,[69,"0"]);
                    //立板余高层电流后侧
                    tx.executeSql(str,[70,"0"]);
                    //立板余高层端部停止时间前（ms）
                    tx.executeSql(str,[71,"0"]);
                    //立板余高层端部停止时间后（ms）
                    tx.executeSql(str,[72,"0"]);
                    //立板余高层堆高MAX
                    tx.executeSql(str,[73,"0"]);
                    //立板余高层接近-前
                    tx.executeSql(str,[74,"0"]);
                    //立板余高层接近-后
                    tx.executeSql(str,[75,"0"]);
                    //立板余高层分开最大摆动宽度
                    tx.executeSql(str,[76,"0"]);
                    //立板余高层摆动宽度间隔
                    tx.executeSql(str,[77,"0"]);
                    //立板余高层分开结束/开始比
                    tx.executeSql(str,[78,"0"]);
                    //立板余高层焊接电压
                    tx.executeSql(str,[79,"0"]);
                    //立板余高层MAX焊接速度
                    tx.executeSql(str,[80,"0"]);
                    /***************************************************焊接规范列表**********************************************/
                } else{
                    console.log("Skip Create "+tableName+" Table .");}
            })}
        else
            return -1;
    }
    function createLimited5Table(tableName){
        if(typeof(tableName)==="string"){
            var str="CREATE TABLE IF NOT EXISTS ";
            str+=tableName;
            str+="(id INT NOT NULL PRIMARY KEY,value TEXT)"
            var table;
            dataBase.transaction( function(tx) {
                tx.executeSql(str);
                table = tx.executeSql("select * from "+tableName);
                str="insert into "
                str+=tableName;
                str+=" values(?,?)"
                if(table.rows.length === 0){
                    //初层陶衬垫电流前侧
                    tx.executeSql(str,[0,"230"]);
                    //初层陶衬垫电流中间
                    tx.executeSql(str,[1,"230"]);
                    //初层陶衬垫电流后侧
                    tx.executeSql(str,[2,"230"]);
                    //初层陶衬垫端部停止时间前（ms）
                    tx.executeSql(str,[3,"400"]);
                    //初层陶衬垫端部停止时间后（ms）
                    tx.executeSql(str,[4,"400"]);
                    //初层陶衬垫堆高MAX
                    tx.executeSql(str,[5,"9.0"]);
                    //初层陶衬垫接近-前
                    tx.executeSql(str,[6,"2.0"]);
                    //初层陶衬垫接近-后
                    tx.executeSql(str,[7,"2.0"]);
                    //初层陶衬垫分开最大摆动宽度
                    tx.executeSql(str,[8,"20.0"]);
                    //初层陶衬垫摆动宽度间隔
                    tx.executeSql(str,[9,"100.0"]);
                    //初层陶衬垫分开结束/开始比
                    tx.executeSql(str,[10,"0.85"]);
                    //初层陶衬垫焊接电压  0代表自动设定
                    tx.executeSql(str,[11,"0"]);


                    //初层电流前侧
                    tx.executeSql(str,[12,"300"]);
                    //初层电流中间
                    tx.executeSql(str,[13,"300"]);
                    //初层电流后侧
                    tx.executeSql(str,[14,"300"]);
                    //初层端部停止时间前（ms）
                    tx.executeSql(str,[15,"500"]);
                    //初层端部停止时间后（ms）
                    tx.executeSql(str,[16,"0"]);
                    //初层堆高MAX
                    tx.executeSql(str,[17,"7.0"]);
                    //初层接近-前
                    tx.executeSql(str,[18,"1.0"]);
                    //初层接近-后
                    tx.executeSql(str,[19,"2.0"]);
                    //初层分开最大摆动宽度
                    tx.executeSql(str,[20,"20.0"]);
                    //初层摆动宽度间隔
                    tx.executeSql(str,[21,"100.0"]);
                    //初层分开结束/开始比
                    tx.executeSql(str,[22,"1.0"]);
                    //初层焊接电压
                    tx.executeSql(str,[23,"0"]);

                    //第二层电流前侧
                    tx.executeSql(str,[24,"290"]);
                    //第二层电流中间
                    tx.executeSql(str,[25,"290"]);
                    //第二层电流后侧
                    tx.executeSql(str,[26,"290"]);
                    //第二层端部停止时间前（ms）
                    tx.executeSql(str,[27,"100"]);
                    //第二层端部停止时间后（ms）
                    tx.executeSql(str,[28,"100"]);
                    //第二层堆高MAX
                    tx.executeSql(str,[29,"5.0"]);
                    //第二层接近-前
                    tx.executeSql(str,[30,"1.0"]);
                    //第二层接近-后
                    tx.executeSql(str,[31,"2.0"]);
                    //第二层分开最大摆动宽度
                    tx.executeSql(str,[32,"16.0"]);
                    //第二层摆动宽度间隔
                    tx.executeSql(str,[33,"5.0"]);
                    //第二层分开结束/开始比
                    tx.executeSql(str,[34,"0.85"]);
                    //第二层焊接电压
                    tx.executeSql(str,[35,"0"]);

                    //中间层电流前侧
                    tx.executeSql(str,[36,"290"]);
                    //中间层电流中间
                    tx.executeSql(str,[37,"290"]);
                    //中间层电流后侧
                    tx.executeSql(str,[38,"290"]);
                    //中间层端部停止时间前（ms）
                    tx.executeSql(str,[39,"100"]);
                    //中间层端部停止时间后（ms）
                    tx.executeSql(str,[40,"100"]);
                    //中间层堆高MAX
                    tx.executeSql(str,[41,"5.0"]);
                    //中间层接近-前
                    tx.executeSql(str,[42,"1.0"]);
                    //中间层接近-后
                    tx.executeSql(str,[43,"2.0"]);
                    //中间层分开最大摆动宽度
                    tx.executeSql(str,[44,"16.0"]);
                    //中间层摆动宽度间隔
                    tx.executeSql(str,[45,"5.0"]);
                    //中间层分开结束/开始比
                    tx.executeSql(str,[46,"0.85"]);
                    //中间层焊接电压
                    tx.executeSql(str,[47,"0"]);

                    //表面层电流前侧
                    tx.executeSql(str,[48,"280"]);
                    //表面层电流中间
                    tx.executeSql(str,[49,"280"]);
                    //表面层电流后侧
                    tx.executeSql(str,[50,"280"]);
                    //表面层端部停止时间前（ms）
                    tx.executeSql(str,[51,"0"]);
                    //表面层端部停止时间后（ms）
                    tx.executeSql(str,[52,"0"]);
                    //表面层堆高MAX
                    tx.executeSql(str,[53,"4.0"]);
                    //表面层接近-前
                    tx.executeSql(str,[54,"2.0"]);
                    //表面层接近-后
                    tx.executeSql(str,[55,"2.0"]);
                    //表面层分开最大摆动宽度
                    tx.executeSql(str,[56,"11.0"]);
                    //表面层摆动宽度间隔
                    tx.executeSql(str,[57,"5.0"]);
                    //表面层分开结束/开始比
                    tx.executeSql(str,[58,"1.0"]);
                    //表面层焊接电压
                    tx.executeSql(str,[59,"0"]);

                    //表面层余高层数
                    tx.executeSql(str,[60,"0"]);
                    //表面层分开方向 0 反方向 1标准
                    tx.executeSql(str,[61,"0"]);
                    //表面层起弧位置  00代表收弧位置
                    tx.executeSql(str,[62,"0"]);
                    //开始位置坐标X（mm）
                    tx.executeSql(str,[63,"4.0"]);
                    //开始位置坐标Y（mm）
                    tx.executeSql(str,[64,"0.0"]);
                    //开始位置坐标z（mm）
                    tx.executeSql(str,[65,"-3.0"]);
                    //表面层收弧动作 0 单程 1往返
                    tx.executeSql(str,[66,"0"]);
                    //表面层返回步骤距离
                    tx.executeSql(str,[67,"5.0"]);

                    //立板余高层电流前侧
                    tx.executeSql(str,[68,"250"]);
                    //立板余高层电流中间
                    tx.executeSql(str,[69,"250"]);
                    //立板余高层电流后侧
                    tx.executeSql(str,[70,"250"]);
                    //立板余高层端部停止时间前（ms）
                    tx.executeSql(str,[71,"0.0"]);
                    //立板余高层端部停止时间后（ms）
                    tx.executeSql(str,[72,"0.0"]);
                    //立板余高层堆高MAX
                    tx.executeSql(str,[73,"5.0"]);
                    //立板余高层接近-前
                    tx.executeSql(str,[74,"2.0"]);
                    //立板余高层接近-后
                    tx.executeSql(str,[75,"15.0"]);
                    //立板余高层分开最大摆动宽度
                    tx.executeSql(str,[76,"10.0"]);
                    //立板余高层摆动宽度间隔
                    tx.executeSql(str,[77,"5.0"]);
                    //立板余高层分开结束/开始比
                    tx.executeSql(str,[78,"1.0"]);
                    //立板余高层焊接电压
                    tx.executeSql(str,[79,"0"]);
                    //立板余高层MAX焊接速度
                    tx.executeSql(str,[80,"500.0"]);
                }else{
                    console.log("Skip Create "+tableName+" Table .");}
            })}
        else
            return -1;
    }
    function createLimited6Table(tableName){
        if(typeof(tableName)==="string"){
            var str="CREATE TABLE IF NOT EXISTS ";
            str+=tableName;
            str+="(id INT NOT NULL PRIMARY KEY,value TEXT)"
            var table;
            dataBase.transaction( function(tx) {
                tx.executeSql(str);
                table = tx.executeSql("select * from "+tableName);
                str="insert into "
                str+=tableName;
                str+=" values(?,?)"
                if(table.rows.length === 0){
                    //初层陶衬垫电流前侧
                    tx.executeSql(str,[0,"230"]);
                    //初层陶衬垫电流中间
                    tx.executeSql(str,[1,"230"]);
                    //初层陶衬垫电流后侧
                    tx.executeSql(str,[2,"230"]);
                    //初层陶衬垫端部停止时间前（ms）
                    tx.executeSql(str,[3,"500"]);
                    //初层陶衬垫端部停止时间后（ms）
                    tx.executeSql(str,[4,"500"]);
                    //初层陶衬垫堆高MAX
                    tx.executeSql(str,[5,"8.5"]);
                    //初层陶衬垫接近-前
                    tx.executeSql(str,[6,"2.0"]);
                    //初层陶衬垫接近-后
                    tx.executeSql(str,[7,"2.5"]);
                    //初层陶衬垫分开最大摆动宽度
                    tx.executeSql(str,[8,"20.0"]);
                    //初层陶衬垫摆动宽度间隔
                    tx.executeSql(str,[9,"100.0"]);
                    //初层陶衬垫分开结束/开始比
                    tx.executeSql(str,[10,"0.85"]);
                    //初层陶衬垫焊接电压  0代表自动设定
                    tx.executeSql(str,[11,"28"]);

                    //初层电流前侧
                    tx.executeSql(str,[12,"300"]);
                    //初层电流中间
                    tx.executeSql(str,[13,"300"]);
                    //初层电流后侧
                    tx.executeSql(str,[14,"300"]);
                    //初层端部停止时间前（ms）
                    tx.executeSql(str,[15,"200"]);
                    //初层端部停止时间后（ms）
                    tx.executeSql(str,[16,"200"]);
                    //初层堆高MAX
                    tx.executeSql(str,[17,"7.0"]);
                    //初层接近-前
                    tx.executeSql(str,[18,"2.0"]);
                    //初层接近-后
                    tx.executeSql(str,[19,"2.0"]);
                    //初层分开最大摆动宽度
                    tx.executeSql(str,[20,"20.0"]);
                    //初层摆动宽度间隔
                    tx.executeSql(str,[21,"100.0"]);
                    //初层分开结束/开始比
                    tx.executeSql(str,[22,"1.0"]);
                    //初层焊接电压
                    tx.executeSql(str,[23,"0"]);

                    //第二层电流前侧
                    tx.executeSql(str,[24,"290"]);
                    //第二层电流中间
                    tx.executeSql(str,[25,"290"]);
                    //第二层电流后侧
                    tx.executeSql(str,[26,"290"]);
                    //第二层端部停止时间前（ms）
                    tx.executeSql(str,[27,"100"]);
                    //第二层端部停止时间后（ms）
                    tx.executeSql(str,[28,"100"]);
                    //第二层堆高MAX
                    tx.executeSql(str,[29,"5.0"]);
                    //第二层接近-前
                    tx.executeSql(str,[30,"1.0"]);
                    //第二层接近-后
                    tx.executeSql(str,[31,"1.0"]);
                    //第二层分开最大摆动宽度
                    tx.executeSql(str,[32,"16.0"]);
                    //第二层摆动宽度间隔
                    tx.executeSql(str,[33,"5.0"]);
                    //第二层分开结束/开始比
                    tx.executeSql(str,[34,"0.85"]);
                    //第二层焊接电压
                    tx.executeSql(str,[35,"0"]);

                    //中间层电流前侧
                    tx.executeSql(str,[36,"290"]);
                    //中间层电流中间
                    tx.executeSql(str,[37,"290"]);
                    //中间层电流后侧
                    tx.executeSql(str,[38,"290"]);
                    //中间层端部停止时间前（ms）
                    tx.executeSql(str,[39,"100"]);
                    //中间层端部停止时间后（ms）
                    tx.executeSql(str,[40,"100"]);
                    //中间层堆高MAX
                    tx.executeSql(str,[41,"5.0"]);
                    //中间层接近-前
                    tx.executeSql(str,[42,"1.0"]);
                    //中间层接近-后
                    tx.executeSql(str,[43,"1.0"]);
                    //中间层分开最大摆动宽度
                    tx.executeSql(str,[44,"16.0"]);
                    //中间层摆动宽度间隔
                    tx.executeSql(str,[45,"5.0"]);
                    //中间层分开结束/开始比
                    tx.executeSql(str,[46,"0.85"]);
                    //中间层焊接电压
                    tx.executeSql(str,[47,"0"]);

                    //表面层电流前侧
                    tx.executeSql(str,[48,"280"]);
                    //表面层电流中间
                    tx.executeSql(str,[49,"280"]);
                    //表面层电流后侧
                    tx.executeSql(str,[50,"280"]);
                    //表面层端部停止时间前（ms）
                    tx.executeSql(str,[51,"100"]);
                    //表面层端部停止时间后（ms）
                    tx.executeSql(str,[52,"100"]);
                    //表面层堆高MAX
                    tx.executeSql(str,[53,"4.0"]);
                    //表面层接近-前
                    tx.executeSql(str,[54,"2.0"]);
                    //表面层接近-后
                    tx.executeSql(str,[55,"2.0"]);
                    //表面层分开最大摆动宽度
                    tx.executeSql(str,[56,"16.0"]);
                    //表面层摆动宽度间隔
                    tx.executeSql(str,[57,"5.0"]);
                    //表面层分开结束/开始比
                    tx.executeSql(str,[58,"1.0"]);
                    //表面层焊接电压
                    tx.executeSql(str,[59,"0"]);

                    //表面层余高层数
                    tx.executeSql(str,[60,"0"]);
                    //表面层分开方向 0 反方向 1标准
                    tx.executeSql(str,[61,"0"]);
                    //表面层起弧位置  00代表收弧位置
                    tx.executeSql(str,[62,"0"]);
                    //开始位置坐标X（mm）
                    tx.executeSql(str,[63,"4.0"]);
                    //开始位置坐标Y（mm）
                    tx.executeSql(str,[64,"0.0"]);
                    //开始位置坐标z（mm）
                    tx.executeSql(str,[65,"-3.0"]);
                    //表面层收弧动作 0 单程 1往返
                    tx.executeSql(str,[66,"0"]);
                    //表面层返回步骤距离
                    tx.executeSql(str,[67,"5.0"]);

                    //立板余高层电流前侧
                    tx.executeSql(str,[68,"0"]);
                    //立板余高层电流中间
                    tx.executeSql(str,[69,"0"]);
                    //立板余高层电流后侧
                    tx.executeSql(str,[70,"0"]);
                    //立板余高层端部停止时间前（ms）
                    tx.executeSql(str,[71,"0"]);
                    //立板余高层端部停止时间后（ms）
                    tx.executeSql(str,[72,"0"]);
                    //立板余高层堆高MAX
                    tx.executeSql(str,[73,"0"]);
                    //立板余高层接近-前
                    tx.executeSql(str,[74,"0"]);
                    //立板余高层接近-后
                    tx.executeSql(str,[75,"0"]);
                    //立板余高层分开最大摆动宽度
                    tx.executeSql(str,[76,"0"]);
                    //立板余高层摆动宽度间隔
                    tx.executeSql(str,[77,"0"]);
                    //立板余高层分开结束/开始比
                    tx.executeSql(str,[78,"0"]);
                    //立板余高层焊接电压
                    tx.executeSql(str,[79,"0"]);
                    //立板余高层MAX焊接速度
                    tx.executeSql(str,[80,"0"]);

                }else{
                    console.log("Skip Create "+tableName+" Table .");}
            })}
        else
            return -1;
    }
    function createLimited7Table(tableName){
        if(typeof(tableName)==="string"){
            var str="CREATE TABLE IF NOT EXISTS ";
            str+=tableName;
            str+="(id INT NOT NULL PRIMARY KEY,value TEXT)"
            var table;
            dataBase.transaction( function(tx) {
                tx.executeSql(str);
                table = tx.executeSql("select * from "+tableName);
                str="insert into "
                str+=tableName;
                str+=" values(?,?)"
                if(table.rows.length === 0){
                    //初层陶衬垫电流前侧
                    tx.executeSql(str,[0,"230"]);
                    //初层陶衬垫电流中间
                    tx.executeSql(str,[1,"230"]);
                    //初层陶衬垫电流后侧
                    tx.executeSql(str,[2,"230"]);
                    //初层陶衬垫端部停止时间前（ms）
                    tx.executeSql(str,[3,"400"]);
                    //初层陶衬垫端部停止时间后（ms）
                    tx.executeSql(str,[4,"400"]);
                    //初层陶衬垫堆高MAX
                    tx.executeSql(str,[5,"9.0"]);
                    //初层陶衬垫接近-前
                    tx.executeSql(str,[6,"2.0"]);
                    //初层陶衬垫接近-后
                    tx.executeSql(str,[7,"2.0"]);
                    //初层陶衬垫分开最大摆动宽度
                    tx.executeSql(str,[8,"20.0"]);
                    //初层陶衬垫摆动宽度间隔
                    tx.executeSql(str,[9,"100.0"]);
                    //初层陶衬垫分开结束/开始比
                    tx.executeSql(str,[10,"0.85"]);
                    //初层陶衬垫焊接电压  0代表自动设定
                    tx.executeSql(str,[11,"28"]);

                    //初层电流前侧
                    tx.executeSql(str,[12,"300"]);
                    //初层电流中间
                    tx.executeSql(str,[13,"300"]);
                    //初层电流后侧
                    tx.executeSql(str,[14,"300"]);
                    //初层端部停止时间前（ms）
                    tx.executeSql(str,[15,"200"]);
                    //初层端部停止时间后（ms）
                    tx.executeSql(str,[16,"200"]);
                    //初层堆高MAX
                    tx.executeSql(str,[17,"7.0"]);
                    //初层接近-前
                    tx.executeSql(str,[18,"2.0"]);
                    //初层接近-后
                    tx.executeSql(str,[19,"2.0"]);
                    //初层分开最大摆动宽度
                    tx.executeSql(str,[20,"20.0"]);
                    //初层摆动宽度间隔
                    tx.executeSql(str,[21,"100.0"]);
                    //初层分开结束/开始比
                    tx.executeSql(str,[22,"1.0"]);
                    //初层焊接电压
                    tx.executeSql(str,[23,"0"]);

                    //第二层电流前侧
                    tx.executeSql(str,[24,"290"]);
                    //第二层电流中间
                    tx.executeSql(str,[25,"290"]);
                    //第二层电流后侧
                    tx.executeSql(str,[26,"290"]);
                    //第二层端部停止时间前（ms）
                    tx.executeSql(str,[27,"100"]);
                    //第二层端部停止时间后（ms）
                    tx.executeSql(str,[28,"100"]);
                    //第二层堆高MAX
                    tx.executeSql(str,[29,"5.0"]);
                    //第二层接近-前
                    tx.executeSql(str,[30,"1.0"]);
                    //第二层接近-后
                    tx.executeSql(str,[31,"1.0"]);
                    //第二层分开最大摆动宽度
                    tx.executeSql(str,[32,"16.0"]);
                    //第二层摆动宽度间隔
                    tx.executeSql(str,[33,"5.0"]);
                    //第二层分开结束/开始比
                    tx.executeSql(str,[34,"0.85"]);
                    //第二层焊接电压
                    tx.executeSql(str,[35,"0"]);

                    //中间层电流前侧
                    tx.executeSql(str,[36,"290"]);
                    //中间层电流中间
                    tx.executeSql(str,[37,"290"]);
                    //中间层电流后侧
                    tx.executeSql(str,[38,"290"]);
                    //中间层端部停止时间前（ms）
                    tx.executeSql(str,[39,"100"]);
                    //中间层端部停止时间后（ms）
                    tx.executeSql(str,[40,"100"]);
                    //中间层堆高MAX
                    tx.executeSql(str,[41,"4.0"]);
                    //中间层接近-前
                    tx.executeSql(str,[42,"2.0"]);
                    //中间层接近-后
                    tx.executeSql(str,[43,"2.0"]);
                    //中间层分开最大摆动宽度
                    tx.executeSql(str,[44,"14.0"]);
                    //中间层摆动宽度间隔
                    tx.executeSql(str,[45,"5.0"]);
                    //中间层分开结束/开始比
                    tx.executeSql(str,[46,"1.0"]);
                    //中间层焊接电压
                    tx.executeSql(str,[47,"0"]);

                    //表面层电流前侧
                    tx.executeSql(str,[48,"280"]);
                    //表面层电流中间
                    tx.executeSql(str,[49,"280"]);
                    //表面层电流后侧
                    tx.executeSql(str,[50,"280"]);
                    //表面层端部停止时间前（ms）
                    tx.executeSql(str,[51,"100"]);
                    //表面层端部停止时间后（ms）
                    tx.executeSql(str,[52,"100"]);
                    //表面层堆高MAX
                    tx.executeSql(str,[53,"4.0"]);
                    //表面层接近-前
                    tx.executeSql(str,[54,"2.0"]);
                    //表面层接近-后
                    tx.executeSql(str,[55,"2.0"]);
                    //表面层分开最大摆动宽度
                    tx.executeSql(str,[56,"16.0"]);
                    //表面层摆动宽度间隔
                    tx.executeSql(str,[57,"5.0"]);
                    //表面层分开结束/开始比
                    tx.executeSql(str,[58,"1.0"]);
                    //表面层焊接电压
                    tx.executeSql(str,[59,"0"]);

                    //表面层余高层数
                    tx.executeSql(str,[60,"0"]);
                    //表面层分开方向 0 反方向 1标准
                    tx.executeSql(str,[61,"0"]);
                    //表面层起弧位置  00代表收弧位置
                    tx.executeSql(str,[62,"0"]);
                    //开始位置坐标X（mm）
                    tx.executeSql(str,[63,"4.0"]);
                    //开始位置坐标Y（mm）
                    tx.executeSql(str,[64,"0.0"]);
                    //开始位置坐标z（mm）
                    tx.executeSql(str,[65,"-3.0"]);
                    //表面层收弧动作 0 单程 1往返
                    tx.executeSql(str,[66,"0"]);
                    //表面层返回步骤距离
                    tx.executeSql('insert into 立焊V型坡口平对接限制条件 values(?,?)',[67,"5.0"]);

                    //立板余高层电流前侧
                    tx.executeSql('insert into 立焊V型坡口平对接限制条件 values(?,?)',[68,"0"]);
                    //立板余高层电流中间
                    tx.executeSql('insert into 立焊V型坡口平对接限制条件 values(?,?)',[69,"0"]);
                    //立板余高层电流后侧
                    tx.executeSql('insert into 立焊V型坡口平对接限制条件 values(?,?)',[70,"0"]);
                    //立板余高层端部停止时间前（ms）
                    tx.executeSql('insert into 立焊V型坡口平对接限制条件 values(?,?)',[71,"0"]);
                    //立板余高层端部停止时间后（ms）
                    tx.executeSql('insert into 立焊V型坡口平对接限制条件 values(?,?)',[72,"0"]);
                    //立板余高层堆高MAX
                    tx.executeSql('insert into 立焊V型坡口平对接限制条件 values(?,?)',[73,"0"]);
                    //立板余高层接近-前
                    tx.executeSql('insert into 立焊V型坡口平对接限制条件 values(?,?)',[74,"0"]);
                    //立板余高层接近-后
                    tx.executeSql('insert into 立焊V型坡口平对接限制条件 values(?,?)',[75,"0"]);
                    //立板余高层分开最大摆动宽度
                    tx.executeSql('insert into 立焊V型坡口平对接限制条件 values(?,?)',[76,"0"]);
                    //立板余高层摆动宽度间隔
                    tx.executeSql('insert into 立焊V型坡口平对接限制条件 values(?,?)',[77,"0"]);
                    //立板余高层分开结束/开始比
                    tx.executeSql('insert into 立焊V型坡口平对接限制条件 values(?,?)',[78,"0"]);
                    //立板余高层焊接电压
                    tx.executeSql('insert into 立焊V型坡口平对接限制条件 values(?,?)',[79,"0"]);
                    //立板余高层MAX焊接速度
                    tx.executeSql('insert into 立焊V型坡口平对接限制条件 values(?,?)',[80,"0"]);

                }else{
                    console.log("Skip Create "+tableName+" Table .");}
            })}
        else
            return -1;
    }
    function createLimited8Table(tableName){
        if(typeof(tableName)==="string"){
            var str="CREATE TABLE IF NOT EXISTS ";
            str+=tableName;
            str+="(id INT NOT NULL PRIMARY KEY,value TEXT)"
            var table;
            dataBase.transaction( function(tx) {
                tx.executeSql(str);
                table = tx.executeSql("select * from "+tableName);
                str="insert into "
                str+=tableName;
                str+=" values(?,?)"
                if(table.rows.length === 0){
                    /***************************************************焊接规范限制**********************************************/
                    //初层陶衬垫电流前侧
                    tx.executeSql(str,[0,"0"]);
                    //初层陶衬垫电流中间
                    tx.executeSql(str,[1,"0"]);
                    //初层陶衬垫电流后侧
                    tx.executeSql(str,[2,"0"]);
                    //初层陶衬垫端部停止时间前（ms）
                    tx.executeSql(str,[3,"0"]);
                    //初层陶衬垫端部停止时间后（ms）
                    tx.executeSql(str,[4,"0"]);
                    //初层陶衬垫堆高MAX
                    tx.executeSql(str,[5,"0"]);
                    //初层陶衬垫接近-前
                    tx.executeSql(str,[6,"0"]);
                    //初层陶衬垫接近-后
                    tx.executeSql(str,[7,"0"]);
                    //初层陶衬垫分开最大摆动宽度
                    tx.executeSql(str,[8,"0"]);
                    //初层陶衬垫摆动宽度间隔
                    tx.executeSql(str,[9,"0"]);
                    //初层陶衬垫分开结束/开始比
                    tx.executeSql(str,[10,"0"]);
                    //初层陶衬垫焊接电压  0代表自动设定
                    tx.executeSql(str,[11,"0"]);

                    //初层电流前侧
                    tx.executeSql(str,[12,"300"]);
                    //初层电流中间
                    tx.executeSql(str,[13,"300"]);
                    //初层电流后侧
                    tx.executeSql(str,[14,"300"]);
                    //初层端部停止时间前（ms）
                    tx.executeSql(str,[15,"0"]);
                    //初层端部停止时间后（ms）
                    tx.executeSql(str,[16,"0"]);
                    //初层堆高MAX
                    tx.executeSql(str,[17,"6.5"]);
                    //初层接近-前
                    tx.executeSql(str,[18,"23.0"]);
                    //初层接近-后
                    tx.executeSql(str,[19,"27.0"]);
                    //初层分开最大摆动宽度
                    tx.executeSql(str,[20,"8.0"]);
                    //初层摆动宽度间隔
                    tx.executeSql(str,[21,"15.0"]);
                    //初层分开结束/开始比
                    tx.executeSql(str,[22,"1.0"]);
                    //初层焊接电压
                    tx.executeSql(str,[23,"0"]);

                    //第二层电流前侧
                    tx.executeSql(str,[24,"280"]);
                    //第二层电流中间
                    tx.executeSql(str,[25,"280"]);
                    //第二层电流后侧
                    tx.executeSql(str,[26,"280"]);
                    //第二层端部停止时间前（ms）
                    tx.executeSql(str,[27,"0"]);
                    //第二层端部停止时间后（ms）
                    tx.executeSql(str,[28,"0"]);
                    //第二层堆高MAX
                    tx.executeSql(str,[29,"5.5"]);
                    //第二层接近-前
                    tx.executeSql(str,[30,"3.0"]);
                    //第二层接近-后
                    tx.executeSql(str,[31,"3.0"]);
                    //第二层分开最大摆动宽度
                    tx.executeSql(str,[32,"7.0"]);
                    //第二层摆动宽度间隔
                    tx.executeSql(str,[33,"20.0"]);
                    //第二层分开结束/开始比
                    tx.executeSql(str,[34,"1.0"]);
                    //第二层焊接电压
                    tx.executeSql(str,[35,"0"]);

                    //中间层电流前侧
                    tx.executeSql(str,[36,"280"]);
                    //中间层电流中间
                    tx.executeSql(str,[37,"280"]);
                    //中间层电流后侧
                    tx.executeSql(str,[38,"280"]);
                    //中间层端部停止时间前（ms）
                    tx.executeSql(str,[39,"0"]);
                    //中间层端部停止时间后（ms）
                    tx.executeSql(str,[40,"0"]);
                    //中间层堆高MAX
                    tx.executeSql(str,[41,"5.0"]);
                    //中间层接近-前
                    tx.executeSql(str,[42,"3.0"]);
                    //中间层接近-后
                    tx.executeSql(str,[43,"3.0"]);
                    //中间层分开最大摆动宽度
                    tx.executeSql(str,[44,"7.3"]);
                    //中间层摆动宽度间隔
                    tx.executeSql(str,[45,"15.0"]);
                    //中间层分开结束/开始比
                    tx.executeSql(str,[46,"1.0"]);
                    //中间层焊接电压
                    tx.executeSql(str,[47,"0"]);

                    //表面层电流前侧
                    tx.executeSql(str,[48,"250"]);
                    //表面层电流中间
                    tx.executeSql(str,[49,"250"]);
                    //表面层电流后侧
                    tx.executeSql(str,[50,"250"]);
                    //表面层端部停止时间前（ms）
                    tx.executeSql(str,[51,"0"]);
                    //表面层端部停止时间后（ms）
                    tx.executeSql(str,[52,"0"]);
                    //表面层堆高MAX
                    tx.executeSql(str,[53,"4.5"]);
                    //表面层接近-前
                    tx.executeSql(str,[54,"3.0"]);
                    //表面层接近-后
                    tx.executeSql(str,[55,"3.0"]);
                    //表面层分开最大摆动宽度
                    tx.executeSql(str,[56,"6.0"]);
                    //表面层摆动宽度间隔
                    tx.executeSql(str,[57,"15.0"]);
                    //表面层分开结束/开始比
                    tx.executeSql(str,[58,"1.0"]);
                    //表面层焊接电压
                    tx.executeSql(str,[59,"0"]);

                    //表面层余高层数
                    tx.executeSql(str,[60,"0"]);
                    //表面层分开方向 0 反方向 1标准
                    tx.executeSql(str,[61,"0"]);
                    //表面层起弧位置  00代表收弧位置
                    tx.executeSql(str,[62,"0"]);
                    //开始位置坐标X（mm）
                    tx.executeSql(str,[63,"4.0"]);
                    //开始位置坐标Y（mm）
                    tx.executeSql(str,[64,"0.0"]);
                    //开始位置坐标z（mm）
                    tx.executeSql(str,[65,"-3.0"]);
                    //表面层收弧动作 0 单程 1往返
                    tx.executeSql(str,[66,"0"]);
                    //表面层返回步骤距离
                    tx.executeSql('insert into 水平角焊限制条件 values(?,?)',[67,"5.0"]);

                    //立板余高层电流前侧
                    tx.executeSql('insert into 水平角焊限制条件 values(?,?)',[68,"0"]);
                    //立板余高层电流中间
                    tx.executeSql('insert into 水平角焊限制条件 values(?,?)',[69,"0"]);
                    //立板余高层电流后侧
                    tx.executeSql('insert into 水平角焊限制条件 values(?,?)',[70,"0"]);
                    //立板余高层端部停止时间前（ms）
                    tx.executeSql('insert into 水平角焊限制条件 values(?,?)',[71,"0"]);
                    //立板余高层端部停止时间后（ms）
                    tx.executeSql('insert into 水平角焊限制条件 values(?,?)',[72,"0"]);
                    //立板余高层堆高MAX
                    tx.executeSql('insert into 水平角焊限制条件 values(?,?)',[73,"0"]);
                    //立板余高层接近-前
                    tx.executeSql('insert into 水平角焊限制条件 values(?,?)',[74,"0"]);
                    //立板余高层接近-后
                    tx.executeSql('insert into 水平角焊限制条件 values(?,?)',[75,"0"]);
                    //立板余高层分开最大摆动宽度
                    tx.executeSql('insert into 水平角焊限制条件 values(?,?)',[76,"0"]);
                    //立板余高层摆动宽度间隔
                    tx.executeSql('insert into 水平角焊限制条件 values(?,?)',[77,"0"]);
                    //立板余高层分开结束/开始比
                    tx.executeSql('insert into 水平角焊限制条件 values(?,?)',[78,"0"]);
                    //立板余高层焊接电压
                    tx.executeSql('insert into 水平角焊限制条件 values(?,?)',[79,"0"]);
                    //立板余高层MAX焊接速度
                    tx.executeSql('insert into 水平角焊限制条件 values(?,?)',[80,"0"]);

                }else{
                    console.log("Skip Create "+tableName+" Table .");}
            })}
        else
            return -1;
    }
    function createLimitedTable(grooveName,tableName){
        if(typeof(grooveName)==="string"){
            switch(grooveName){
            case grooveStyleName[0]:createLimited0Table(tableName);break;
            case grooveStyleName[1]:createLimited1Table(tableName);break;
            case grooveStyleName[2]:createLimited2Table(tableName);break;
            case grooveStyleName[3]:createLimited3Table(tableName);break;
            case grooveStyleName[4]:createLimited4Table(tableName);break;
            case grooveStyleName[5]:createLimited5Table(tableName);break;
            case grooveStyleName[6]:createLimited6Table(tableName);break;
            case grooveStyleName[7]:createLimited7Table(tableName);break;
            case grooveStyleName[8]:createLimited8Table(tableName);break;
            }
        }else
            return -1;
    }
}
