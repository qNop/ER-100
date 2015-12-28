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
.import QtQuick.LocalStorage 2.0 as Data

function getPageFunctionAndValueFromTable(index,mode){
    var result,str;
    var db = Data.LocalStorage.openDatabaseSync("ERoboWeldSysDataBase","1.0","DataBase", 100000);
    if(!db) return;
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
    console.log(str);
    db.transaction( function(tx) {result = tx.executeSql(str); });
    /*遍寻所有数据转换成json格式*/
    var json="[";
    for(var i=0;i<result.rows.length;i++){
        json+="\""+result.rows.item(i).function+"\""+",";
    }
        if(json.substr(json.length-1) === ","){
            json = json.substr(0,json.length -1);}
        json+="]"
        console.log(json);
        return json;
 }

    /*写入数据库相关词条的数值*/
    function setValueFromFuncOfTable(index,name,value){
        var result,str;
        var db = Data.LocalStorage.openDatabaseSync("ERoboWeldSysDataBase","1.0","DataBase", 100000);
        if(!db) return;
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
        db.transaction( function(tx) {result = tx.executeSql(str); });
    }
    /*从数据库中获取相关词条的数值*/
    function getValueFromFuncOfTable(index,func,name){
        var result,str;
        var db = Data.LocalStorage.openDatabaseSync("ERoboWeldSysDataBase","1.0","DataBase", 100000);
        if(!db) return;
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
        db.transaction( function(tx) {result = tx.executeSql(str); });
//        console.log(result.rows.item(0).setvalue);
        return result.rows.item(0).setvalue;
    }
    /*获取用户密码*/
    function getuserpassword(name){
        var result;
        var  db = Data.LocalStorage.openDatabaseSync("ERoboWeldSysDataBase","1.0","DataBase", 100000);
        if (!db){
            return;
        }
        db.transaction ( function(tx) {
            result = tx.executeSql("select * from AccountTable where name = " + "\'"+name+"\'");
            if(result.rows.length === 0) {
                //////////////
            }})
        return result;
    }
    /*获取用户名*/
    function getusrname(){
        var db;
        var result;
        db = Data.LocalStorage.openDatabaseSync("ERoboWeldSysDataBase","1.0","DataBase", 100000);
        if (!db){
            return;
        }
        db.transaction ( function(tx) {
            result = tx.executeSql("select * from AccountTable");
            if(result.rows.length === 0) {
                //////////////
            }})
        return result;
    }

    /*
  *打开数据库 输入参数 数据名称 版本 描述 类型
  */
    function openDatabase() {
        var table;
        var error;
        //创建链接
        var db = Data.LocalStorage.openDatabaseSync("ERoboWeldSysDataBase","1.0","DataBase", 100000);
        if(!db)  {
            console.log("create db is bad~");
            return ;
        }
        else{
            console.log("create db is ok~");
        }
        db.transaction( function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS FlatWeldSingleBevelGrooveT(mode TEXT,function TEXT,\
                                                setvalue TEXT,max TEXT,min TEXT,step TEXT,init TEXT,decription TEXT)');
            table = tx.executeSql("select * from FlatWeldSingleBevelGrooveT");
            if(table.rows.length === 0)
            {
                //console.log("FlatWeldSingleBevelGrooveT is not exists");
                //坡口参数初始值设置
                /**********************************************示教模式*************************************************/
                //示教模式
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','示教模式','自动','自动','手动','半自动','自动','示教模式']);
                //始终端检测
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','始终端检测','自动','自动','手动','','自动','设定终端的检测是自动或是手动']);
                //示教第1点位置
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','示教第1点位置','右方','右方','左方','','右方','设定第一点从左右哪边开始']);
                //示教1点时焊接长（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','示教1点时焊接长(mm)','300','10000','10','2','300','示教点数为1点时,设定至第二点的焊接']);
                //板厚（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['4','板厚(mm)','测定','200','8','0.1','测定','背部使用陶瓷衬垫或者不能导电时,必须设定板厚']);
                //余高（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['4','余高(mm)','1','20','-20','0.1','1','设定从板面堆起高度']);
                //坡口检测点左（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['4','坡口检测点左(mm)','-10','1000','-1000','1','-10','']);
                //坡口检测点右（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['4','坡口检测点右(mm)','-10','1000','-1000','1','-10','']);
                //板厚补正（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['2','板厚补正(mm)','0','200','-200','1','0','设定是否根据检测的板厚补正条件']);
                //角度补正（度）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['2','角度补正(度)','0','90','-90','1','0','设定是否根据检测的角度补正条件']);
                //间隙补正（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['2','间隙补正(mm)','0','200','-200','1','0','设定是否根据检测的间隙补正条件']);
                /*******************************************坡口设置*****************************************************/
                //焊接始终端偏左（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊接始终端偏左(mm)','0','1000','-1000','0.1','0','']);
                //焊接始终端偏右（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊接始终端偏右(mm)','0','1000','-1000','0.1','0','']);
                //示教点数
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','示教点数','2','30','1','1','1','']);
                //X左梯形平移（度）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','X左梯形平移(度)','0','90','-90','1','1','']);
                //X右梯形平移（度）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','X右梯形平移(度)','0','90','-90','1','1','']);
                //Y左梯形平移（度）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','Y左梯形平移(度)','0','90','-90','1','1','']);
                //Y右梯形平移（度）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','Y右梯形平移(度)','0','90','-90','1','1','']);
                //头部摆动
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','头部摆动','无','左右','无','','无','']);
                //溶敷系数
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','溶敷系数','1.00','1.5','0.5','0.01','1','']);
                //机器人设置面
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','机器人设置面','床','床','壁','','床','']);
                //焊接动作（往返/单程）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊接动作(往返/单程)','单程','单程','往返','','单程','']);
                //焊接电流偏置（A）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊接电流偏置(A)','5','100','-100','5','0','']);
                //焊接电压偏置（V）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊接电压偏置(V)','0','10','-10','1','0','']);
                //电弧跟踪
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','电弧跟踪','关闭','关闭','打开','','打开','']);
                //焊缝背面成型
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊缝背面成型','有','无','有','','无','']);
                //连续焊接时间
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','连续焊接时间','10','999','10','1','10','']);
                //连续焊接层数
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','连续焊接层数','4','99','1','1','4','']);
                //层间停止时间（秒）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','层间停止时间(秒)','5','3600','5','1','5','']);
                //最终层前停止时间（秒）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','最终层前停止时间(秒)','永久','3600','5','1','永久','']);
                //表面锥度非对应机能
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','表面锥度非对应机能','关闭','关闭','打开','','关闭','']);
                //电弧跟踪控制纠正量（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','电弧跟踪控制纠正量(mm)','0.50','10.00','0.00','0.01','0.50','']);
                //焊丝焊缝检测机能
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝焊缝检测机能','关闭','关闭','打开','','关闭','']);
                //焊丝长度（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝长度(mm)','25','50','0','1','25','']);
                //保护气体
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','保护气体','二氧化碳','二氧化碳','气体三','气体二','二氧化碳','']);
                //焊丝
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝','实芯','实芯','药芯','','实芯','']);
                //焊丝直径
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝直径','1.2','1.2','1.6','','1.6','']);
                //初层（陶瓷衬垫）-间隔
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','初层(陶瓷衬垫)-间隔','3.0','10.0','1.0','0.1','3.0','']);
                //初层（钢衬垫）-间隔
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','初层(钢瓷衬垫)-间隔','4.0','10.0','1.0','0.1','4.0','']);
                //初层以外-间隔
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','初层以外-间隔','5.0','10.0','1.0','0.1','5.0','']);
                /*
                      *  A= 30~40       A=45~60
                      *  T=9~80mm   T=9~50mm
                      *  B=4~10mm   B=0~2mm
                      */
                //板厚T1
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['254','板厚T1(mm)','34','','','0.1','','']);
                //脚长L
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['254','脚长L(mm)','10','','','0.1','','']);
                //余高Tm
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['254','余高Tm(mm)','1','','','0.1','','']);
                //角度θ1
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['254','角1(度)','34','','','','','']);
                //角度θ1
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['254','角2(度)','45','','','0.1','','']);
                //间隙b
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['254','间隙b(mm)','0','','','0.1','','']);
                /********************************************错误检测*********************************************/
                //板面高
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','板面高','5.0','100.0','-100.0','1.0','5.0','']);
                //板面下降量
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','板面下降量','6.0','100.0','-100.0','1.0','6.0','']);
                //坡口检测上高
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','坡口检测上高','2.0','100.0','-100.0','1.0','2.0','']);
                //坡口检测下高
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','坡口检测下高','3.0','100.0','-100.0','1.0','3.0','']);
                //底面检测时立板距离
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','底面检测时立板距离','2.0','50.0','-50.0','0.1','2.0','']);
                //检测错误板厚左右差--最小
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚左右差最小','4.0','10.0','0.0','0.1','4.0','']);
                //检测错误板厚左右差--最大
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚左右差最大','7.0','10.0','0.0','0.1','7.0','']);
                //检测错误板厚容许值--最小
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚容许值最小','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚容许值--最大
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚容许值最大','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差左右差--最小
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差左右差最小','4.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差左右差--最大
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差左右差最大','7.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差容许值--最小
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差容许值最小','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差容许值--最大
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差容许值最大','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误角度左右差--最小
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度左右差最小','5.0','10.0','0.0','0.1','5.0','']);
                //检测错误角度左右差--最大
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度左右差最大','10.0','10.0','0.0','0.1','10.0','']);
                //检测错误角度容许值--最小
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度容许值最小','28.0','90.0','0.0','0.1','28.0','']);
                //检测错误角度容许值--最大
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度容许值最大','65.0','90.0','0.0','0.1','65.0','']);
                //检测错误间隙左右差--最小
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙左右差最小','6.0','10.0','0.0','0.1','6.0','']);
                //检测错误间隙左右差--最大
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙左右差最大','12.0','10.0','0.0','0.1','12.0','']);
                //检测错误间隙容许值--最小
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙容许值最小','4.0','20.0','0.0','0.1','4.0','']);
                //检测错误间隙容许值--最大
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙容许值最大','10.0','20.0','0.0','0.1','10.0','']);
                /***************************************************焊接规范限制**********************************************/
                //初层陶衬垫电流前侧
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流前侧','230','500','10','10','230','']);
                //初层陶衬垫电流中间
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流中间','230','500','10','10','230','']);
                //初层陶衬垫电流后侧
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流后侧','230','500','10','10','230','']);
                //初层陶衬垫端部停止时间前（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫端部停止时间前(ms)','400','5000','0','10','400','']);
                //初层陶衬垫端部停止时间后（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫端部停止时间后(ms)','400','5000','0','10','400','']);
                //初层陶衬垫堆高MAX
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫堆高MAX','9.0','20.0','1.0','0.1','9.0','']);
                //初层陶衬垫接近-前
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //初层陶衬垫接近-后
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //初层陶衬垫分开最大摆动宽度
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-前','20.0','100.0','1.0','0.1','20.0','']);
                //初层陶衬垫摆动宽度间隔
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫摆动宽度间隔','100.0','100.0','0.0','0.1','100.0','']);
                //初层陶衬垫分开结束/开始比
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫分开结束/开始比','0.85','10.0','0.10','0.01','0.85','']);
                //初层陶衬垫焊接电压
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫焊接电压','自动设定','50','1','1','自动设定','']);



                //初层电流前侧
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流前侧','300','500','10','10','300','']);
                //初层电流中间
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流中间','300','500','10','10','300','']);
                //初层电流后侧
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流后侧','300','500','10','10','300','']);
                //初层端部停止时间前（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层端部停止时间前(ms)','500','5000','0','10','500','']);
                //初层端部停止时间后（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层端部停止时间后(ms)','500','5000','0','10','500','']);
                //初层堆高MAX
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层堆高MAX','7.0','10.0','1.0','0.1','7.0','']);
                //初层接近-前
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //初层接近-后
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //初层分开最大摆动宽度
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-前','20.0','100.0','1.0','0.1','20.0','']);
                //初层摆动宽度间隔
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层摆动宽度间隔','100.0','100.0','0.0','0.1','100.0','']);
                //初层分开结束/开始比
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层分开结束/开始比','1.00','10.0','0.10','0.01','1.00','']);
                //初层焊接电压
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层焊接电压','自动设定','50','1','1','自动设定','']);

                //第二层电流前侧
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流前侧','290','500','10','10','290','']);
                //第二层电流中间
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流中间','290','500','10','10','290','']);
                //第二层电流后侧
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流后侧','290','500','10','10','290','']);
                //第二层端部停止时间前（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层端部停止时间前(ms)','100','5000','0','10','100','']);
                //第二层端部停止时间后（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层端部停止时间后(ms)','100','5000','0','10','100','']);
                //第二层堆高MAX
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层堆高MAX','5.0','10.0','1.0','0.1','5.0','']);
                //第二层接近-前
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //第二层接近-后
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //第二层分开最大摆动宽度
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-前','16.0','100.0','1.0','0.1','16.0','']);
                //第二层摆动宽度间隔
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //第二层分开结束/开始比
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层分开结束/开始比','0.85','10.0','0.10','0.01','0.85','']);
                //第二层焊接电压
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层焊接电压','自动设定','50','1','1','自动设定','']);


                //中间层电流前侧
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流前侧','290','500','10','10','290','']);
                //中间层电流中间
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流中间','290','500','10','10','290','']);
                //中间层电流后侧
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流后侧','290','500','10','10','290','']);
                //中间层端部停止时间前（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层端部停止时间前(ms)','50','5000','0','10','50','']);
                //中间层端部停止时间后（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层端部停止时间后(ms)','50','5000','0','10','50','']);
                //中间层堆高MAX
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层堆高MAX','4.0','10.0','1.0','0.1','4.0','']);
                //中间层接近-前
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //中间层接近-后
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //中间层分开最大摆动宽度
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-前','14.0','100.0','1.0','0.1','14.0','']);
                //中间层摆动宽度间隔
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //中间层分开结束/开始比
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //中间层焊接电压
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层焊接电压','自动设定','50','1','1','自动设定','']);

                //表面层电流前侧
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流前侧','280','500','10','10','280','']);
                //表面层电流中间
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流中间','280','500','10','10','280','']);
                //表面层电流后侧
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流后侧','280','500','10','10','280','']);
                //表面层端部停止时间前（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层端部停止时间前(ms)','0','5000','0','10','0','']);
                //表面层端部停止时间后（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层端部停止时间后(ms)','0','5000','0','10','0','']);
                //表面层堆高MAX
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层堆高MAX','4.0','10.0','1.0','0.1','4.0','']);
                //表面层接近-前
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //表面层接近-后
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //表面层分开最大摆动宽度
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-前','11.0','100.0','1.0','0.1','11.0','']);
                //表面层摆动宽度间隔
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //表面层分开结束/开始比
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //表面层焊接电压
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层焊接电压','自动设定','50','1','1','自动设定','']);

                //表面层余高层数
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层余高层数','0.0','10.0','0.0','1.00','0.00','']);
                //表面层分开方向
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层分开方向','反方向','标准/反方向','标准','','反方向','']);
                //表面层起弧位置
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层起弧位置','收弧位置','坐标/收弧位置','坐标','','收弧位置','']);
                //开始位置坐标X（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标X(mm)','4.0','-50.0','50.0','1.00','4.0','']);
                //开始位置坐标Y（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标Y(mm)','0.0','-50.0','50.0','1.00','0.0','']);
                //开始位置坐标z（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标Z(mm)','-3.0','-50.0','50.0','1.00','-3.0','']);
                //表面层收弧动作
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层收弧动作','单程','往返/单程','往返','','单程','']);
                //表面层返回步骤距离
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层返回步骤距离','5.0','100.0','0.1','1.0','5.0','']);


                //立板余高层电流前侧
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流前侧','250','500','10','10','250','']);
                //立板余高层电流中间
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流中间','250','500','10','10','250','']);
                //立板余高层电流后侧
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流后侧','250','500','10','10','250','']);
                //立板余高层端部停止时间前（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层端部停止时间前(ms)','0','5000','0','10','0','']);
                //立板余高层端部停止时间后（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层端部停止时间后(ms)','0','5000','0','10','0','']);
                //立板余高层堆高MAX
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层堆高MAX','5.0','10.0','1.0','0.1','5.0','']);
                //立板余高层接近-前
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //立板余高层接近-后
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-后','15.0','100.0','-50.0','0.1','15.0','']);
                //立板余高层分开最大摆动宽度
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-前','10.0','100.0','1.0','0.1','10.0','']);
                //立板余高层摆动宽度间隔
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //立板余高层分开结束/开始比
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //立板余高层焊接电压
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层焊接电压','自动设定','50','1','1','自动设定','']);
                //立板余高层MAX焊接速度
                tx.executeSql('insert into FlatWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层MAX焊接速度','500.0','5000.0','0.0','10.0','500','']);

                /***************************************************焊接规范列表**********************************************/

            }

            tx.executeSql('CREATE TABLE IF NOT EXISTS FlatWeldSingleBevelGroove(mode TEXT,function TEXT,\
                                                setvalue TEXT,max TEXT,min TEXT,step TEXT,init TEXT,decription TEXT)');
            table = tx.executeSql("select * from FlatWeldSingleBevelGroove");
            if(table.rows.length === 0)
            {
                //console.log("FlatWeldSingleBevelGroove is not exists");
                //坡口参数初始值设置
                /**********************************************示教模式*************************************************/
                //示教模式
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','示教模式','自动','自动','手动','半自动','自动','示教模式']);
                //始终端检测
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','始终端检测','自动','自动','手动','','自动','设定终端的检测是自动或是手动']);
                //示教第1点位置
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','示教第1点位置','右方','右方','左方','','右方','设定第一点从左右哪边开始']);
                //示教1点时焊接长（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','示教1点时焊接长(mm)','300','10000','10','2','300','示教点数为1点时,设定至第二点的焊接']);
                //板厚（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['4','板厚(mm)','测定','200','8','0.1','测定','背部使用陶瓷衬垫或者不能导电时,必须设定板厚']);
                //余高（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['4','余高(mm)','1','20','-20','0.1','1','设定从板面堆起高度']);
                //坡口检测点左（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['4','坡口检测点左(mm)','-10','1000','-1000','1','-10','']);
                //坡口检测点右（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['4','坡口检测点右(mm)','-10','1000','-1000','1','-10','']);
                //板厚补正（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['2','板厚补正(mm)','0','200','-200','1','0','设定是否根据检测的板厚补正条件']);
                //角度补正（度）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['2','角度补正(度)','0','90','-90','1','0','设定是否根据检测的角度补正条件']);
                //间隙补正（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['2','间隙补正(mm)','0','200','-200','1','0','设定是否根据检测的间隙补正条件']);
                /*******************************************坡口设置*****************************************************/
                //焊接始终端偏左（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接始终端偏左(mm)','0','1000','-1000','0.1','0','']);
                //焊接始终端偏右（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接始终端偏右(mm)','0','1000','-1000','0.1','0','']);
                //示教点数
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','示教点数','2','30','1','1','1','']);
                //X左梯形平移（度）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','X左梯形平移(度)','0','90','-90','1','1','']);
                //X右梯形平移（度）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','X右梯形平移(度)','0','90','-90','1','1','']);
                //Y左梯形平移（度）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','Y左梯形平移(度)','0','90','-90','1','1','']);
                //Y右梯形平移（度）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','Y右梯形平移(度)','0','90','-90','1','1','']);
                //头部摆动
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','头部摆动','无','左右','无','','无','']);
                //溶敷系数
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','溶敷系数','1.00','1.5','0.5','0.01','1','']);
                //机器人设置面
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','机器人设置面','床','床','壁','','床','']);
                //焊接动作（往返/单程）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接动作(往返/单程)','单程','单程','往返','','单程','']);
                //焊接电流偏置（A）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接电流偏置(A)','5','100','-100','5','0','']);
                //焊接电压偏置（V）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接电压偏置(V)','0','10','-10','1','0','']);
                //电弧跟踪
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','电弧跟踪','关闭','关闭','打开','','打开','']);
                //焊缝背面成型
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊缝背面成型','有','无','有','','无','']);
                //连续焊接时间
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','连续焊接时间','10','999','10','1','10','']);
                //连续焊接层数
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','连续焊接层数','4','99','1','1','4','']);
                //层间停止时间（秒）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','层间停止时间(秒)','5','3600','5','1','5','']);
                //最终层前停止时间（秒）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','最终层前停止时间(秒)','永久','3600','5','1','永久','']);
                //表面锥度非对应机能
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','表面锥度非对应机能','关闭','关闭','打开','','关闭','']);
                //电弧跟踪控制纠正量（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','电弧跟踪控制纠正量(mm)','0.50','10.00','0.00','0.01','0.50','']);
                //焊丝焊缝检测机能
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝焊缝检测机能','关闭','关闭','打开','','关闭','']);
                //焊丝长度（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝长度(mm)','25','50','0','1','25','']);
                //保护气体
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','保护气体','二氧化碳','二氧化碳','气体三','气体二','二氧化碳','']);
                //焊丝
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝','实芯','实芯','药芯','','实芯','']);
                //焊丝直径
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝直径','1.2','1.2','1.6','','1.6','']);
                //初层（陶瓷衬垫）-间隔
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','初层(陶瓷衬垫)-间隔','3.0','10.0','1.0','0.1','3.0','']);
                //初层（钢衬垫）-间隔
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','初层(钢瓷衬垫)-间隔','4.0','10.0','1.0','0.1','4.0','']);
                //初层以外-间隔
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','初层以外-间隔','5.0','10.0','1.0','0.1','5.0','']);
                /*
                      *  A= 30~40       A=45~60
                      *  T=9~80mm   T=9~50mm
                      *  B=4~10mm   B=0~2mm
                      */
                //板厚T1
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['254','板厚T1(mm)','34','','','0.1','','']);
                //脚长L
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['254','脚长L(mm)','10','','','0.1','','']);
                //余高Tm
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['254','余高Tm(mm)','1','','','0.1','','']);
                //角度θ1
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['254','角1(度)','34','','','','','']);
                //角度θ1
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['254','角2(度)','45','','','0.1','','']);
                //间隙b
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['254','间隙b(mm)','0','','','0.1','','']);
                /********************************************错误检测*********************************************/
                //板面高
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','板面高','5.0','100.0','-100.0','1.0','5.0','']);
                //板面下降量
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','板面下降量','6.0','100.0','-100.0','1.0','6.0','']);
                //坡口检测上高
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','坡口检测上高','2.0','100.0','-100.0','1.0','2.0','']);
                //坡口检测下高
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','坡口检测下高','3.0','100.0','-100.0','1.0','3.0','']);
                //底面检测时立板距离
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','底面检测时立板距离','2.0','50.0','-50.0','0.1','2.0','']);
                //检测错误板厚左右差--最小
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚左右差最小','4.0','10.0','0.0','0.1','4.0','']);
                //检测错误板厚左右差--最大
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚左右差最大','7.0','10.0','0.0','0.1','7.0','']);
                //检测错误板厚容许值--最小
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚容许值最小','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚容许值--最大
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚容许值最大','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差左右差--最小
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差左右差最小','4.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差左右差--最大
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差左右差最大','7.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差容许值--最小
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差容许值最小','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差容许值--最大
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差容许值最大','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误角度左右差--最小
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度左右差最小','5.0','10.0','0.0','0.1','5.0','']);
                //检测错误角度左右差--最大
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度左右差最大','10.0','10.0','0.0','0.1','10.0','']);
                //检测错误角度容许值--最小
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度容许值最小','28.0','90.0','0.0','0.1','28.0','']);
                //检测错误角度容许值--最大
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度容许值最大','65.0','90.0','0.0','0.1','65.0','']);
                //检测错误间隙左右差--最小
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙左右差最小','6.0','10.0','0.0','0.1','6.0','']);
                //检测错误间隙左右差--最大
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙左右差最大','12.0','10.0','0.0','0.1','12.0','']);
                //检测错误间隙容许值--最小
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙容许值最小','4.0','20.0','0.0','0.1','4.0','']);
                //检测错误间隙容许值--最大
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙容许值最大','10.0','20.0','0.0','0.1','10.0','']);
                /***************************************************焊接规范限制**********************************************/
                //初层陶衬垫电流前侧
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流前侧','230','500','10','10','230','']);
                //初层陶衬垫电流中间
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流中间','230','500','10','10','230','']);
                //初层陶衬垫电流后侧
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流后侧','230','500','10','10','230','']);
                //初层陶衬垫端部停止时间前（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫端部停止时间前(ms)','400','5000','0','10','400','']);
                //初层陶衬垫端部停止时间后（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫端部停止时间后(ms)','400','5000','0','10','400','']);
                //初层陶衬垫堆高MAX
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫堆高MAX','9.0','20.0','1.0','0.1','9.0','']);
                //初层陶衬垫接近-前
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //初层陶衬垫接近-后
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //初层陶衬垫分开最大摆动宽度
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-前','20.0','100.0','1.0','0.1','20.0','']);
                //初层陶衬垫摆动宽度间隔
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫摆动宽度间隔','100.0','100.0','0.0','0.1','100.0','']);
                //初层陶衬垫分开结束/开始比
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫分开结束/开始比','0.85','10.0','0.10','0.01','0.85','']);
                //初层陶衬垫焊接电压
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫焊接电压','自动设定','50','1','1','自动设定','']);



                //初层电流前侧
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流前侧','300','500','10','10','300','']);
                //初层电流中间
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流中间','300','500','10','10','300','']);
                //初层电流后侧
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流后侧','300','500','10','10','300','']);
                //初层端部停止时间前（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层端部停止时间前(ms)','500','5000','0','10','500','']);
                //初层端部停止时间后（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层端部停止时间后(ms)','500','5000','0','10','500','']);
                //初层堆高MAX
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层堆高MAX','7.0','10.0','1.0','0.1','7.0','']);
                //初层接近-前
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //初层接近-后
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //初层分开最大摆动宽度
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-前','20.0','100.0','1.0','0.1','20.0','']);
                //初层摆动宽度间隔
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层摆动宽度间隔','100.0','100.0','0.0','0.1','100.0','']);
                //初层分开结束/开始比
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层分开结束/开始比','1.00','10.0','0.10','0.01','1.00','']);
                //初层焊接电压
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层焊接电压','自动设定','50','1','1','自动设定','']);

                //第二层电流前侧
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流前侧','290','500','10','10','290','']);
                //第二层电流中间
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流中间','290','500','10','10','290','']);
                //第二层电流后侧
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流后侧','290','500','10','10','290','']);
                //第二层端部停止时间前（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层端部停止时间前(ms)','100','5000','0','10','100','']);
                //第二层端部停止时间后（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层端部停止时间后(ms)','100','5000','0','10','100','']);
                //第二层堆高MAX
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层堆高MAX','5.0','10.0','1.0','0.1','5.0','']);
                //第二层接近-前
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //第二层接近-后
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //第二层分开最大摆动宽度
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-前','16.0','100.0','1.0','0.1','16.0','']);
                //第二层摆动宽度间隔
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //第二层分开结束/开始比
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层分开结束/开始比','0.85','10.0','0.10','0.01','0.85','']);
                //第二层焊接电压
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层焊接电压','自动设定','50','1','1','自动设定','']);


                //中间层电流前侧
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流前侧','290','500','10','10','290','']);
                //中间层电流中间
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流中间','290','500','10','10','290','']);
                //中间层电流后侧
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流后侧','290','500','10','10','290','']);
                //中间层端部停止时间前（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层端部停止时间前(ms)','50','5000','0','10','50','']);
                //中间层端部停止时间后（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层端部停止时间后(ms)','50','5000','0','10','50','']);
                //中间层堆高MAX
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层堆高MAX','4.0','10.0','1.0','0.1','4.0','']);
                //中间层接近-前
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //中间层接近-后
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //中间层分开最大摆动宽度
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-前','14.0','100.0','1.0','0.1','14.0','']);
                //中间层摆动宽度间隔
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //中间层分开结束/开始比
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //中间层焊接电压
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层焊接电压','自动设定','50','1','1','自动设定','']);

                //表面层电流前侧
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流前侧','280','500','10','10','280','']);
                //表面层电流中间
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流中间','280','500','10','10','280','']);
                //表面层电流后侧
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流后侧','280','500','10','10','280','']);
                //表面层端部停止时间前（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层端部停止时间前(ms)','0','5000','0','10','0','']);
                //表面层端部停止时间后（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层端部停止时间后(ms)','0','5000','0','10','0','']);
                //表面层堆高MAX
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层堆高MAX','4.0','10.0','1.0','0.1','4.0','']);
                //表面层接近-前
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //表面层接近-后
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //表面层分开最大摆动宽度
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-前','11.0','100.0','1.0','0.1','11.0','']);
                //表面层摆动宽度间隔
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //表面层分开结束/开始比
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //表面层焊接电压
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层焊接电压','自动设定','50','1','1','自动设定','']);

                //表面层余高层数
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层余高层数','0.0','10.0','0.0','1.00','0.00','']);
                //表面层分开方向
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层分开方向','反方向','标准/反方向','标准','','反方向','']);
                //表面层起弧位置
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层起弧位置','收弧位置','坐标/收弧位置','坐标','','收弧位置','']);
                //开始位置坐标X（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标X(mm)','4.0','-50.0','50.0','1.00','4.0','']);
                //开始位置坐标Y（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标Y(mm)','0.0','-50.0','50.0','1.00','0.0','']);
                //开始位置坐标z（mm）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标Z(mm)','-3.0','-50.0','50.0','1.00','-3.0','']);
                //表面层收弧动作
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层收弧动作','单程','往返/单程','往返','','单程','']);
                //表面层返回步骤距离
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层返回步骤距离','5.0','100.0','0.1','1.0','5.0','']);


                //立板余高层电流前侧
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流前侧','250','500','10','10','250','']);
                //立板余高层电流中间
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流中间','250','500','10','10','250','']);
                //立板余高层电流后侧
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流后侧','250','500','10','10','250','']);
                //立板余高层端部停止时间前（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层端部停止时间前(ms)','0','5000','0','10','0','']);
                //立板余高层端部停止时间后（ms）
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层端部停止时间后(ms)','0','5000','0','10','0','']);
                //立板余高层堆高MAX
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层堆高MAX','5.0','10.0','1.0','0.1','5.0','']);
                //立板余高层接近-前
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //立板余高层接近-后
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-后','15.0','100.0','-50.0','0.1','15.0','']);
                //立板余高层分开最大摆动宽度
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-前','10.0','100.0','1.0','0.1','10.0','']);
                //立板余高层摆动宽度间隔
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //立板余高层分开结束/开始比
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //立板余高层焊接电压
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层焊接电压','自动设定','50','1','1','自动设定','']);
                //立板余高层MAX焊接速度
                tx.executeSql('insert into FlatWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层MAX焊接速度','500.0','5000.0','0.0','10.0','500','']);

                /***************************************************焊接规范列表**********************************************/

            }
            tx.executeSql('CREATE TABLE IF NOT EXISTS FlatWeldVGroove(mode TEXT,function TEXT,\
                                                setvalue TEXT,max TEXT,min TEXT,step TEXT,init TEXT,decription TEXT)');
            table = tx.executeSql("select * from FlatWeldVGroove");
            if(table.rows.length === 0)
            {
                //console.log("FlatWeldVGroove is not exists");
                //坡口参数初始值设置
                /**********************************************示教模式*************************************************/
                //示教模式
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','示教模式','自动','自动','手动','半自动','自动','示教模式']);
                //始终端检测
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','始终端检测','自动','自动','手动','','自动','设定终端的检测是自动或是手动']);
                //示教第1点位置
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','示教第1点位置','右方','右方','左方','','右方','设定第一点从左右哪边开始']);
                //示教1点时焊接长（mm）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','示教1点时焊接长(mm)','300','10000','10','2','300','示教点数为1点时,设定至第二点的焊接']);
                //板厚（mm）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['4','板厚(mm)','测定','200','8','0.1','测定','背部使用陶瓷衬垫或者不能导电时,必须设定板厚']);
                //余高（mm）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['4','余高(mm)','1','20','-20','0.1','1','设定从板面堆起高度']);
                //坡口检测点左（mm）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['4','坡口检测点左(mm)','-10','1000','-1000','1','-10','']);
                //坡口检测点右（mm）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['4','坡口检测点右(mm)','-10','1000','-1000','1','-10','']);
                //板厚补正（mm）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['2','板厚补正(mm)','0','200','-200','1','0','设定是否根据检测的板厚补正条件']);
                //角度补正（度）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['2','角度补正(度)','0','90','-90','1','0','设定是否根据检测的角度补正条件']);
                //间隙补正（mm）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['2','间隙补正(mm)','0','200','-200','1','0','设定是否根据检测的间隙补正条件']);
                /*******************************************坡口设置*****************************************************/
                //焊接始终端偏左（mm）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接始终端偏左(mm)','0','1000','-1000','0.1','0','']);
                //焊接始终端偏右（mm）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接始终端偏右(mm)','0','1000','-1000','0.1','0','']);
                //示教点数
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','示教点数','2','30','1','1','1','']);
                //X左梯形平移（度）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','X左梯形平移(度)','0','90','-90','1','1','']);
                //X右梯形平移（度）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','X右梯形平移(度)','0','90','-90','1','1','']);
                //Y左梯形平移（度）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','Y左梯形平移(度)','0','90','-90','1','1','']);
                //Y右梯形平移（度）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','Y右梯形平移(度)','0','90','-90','1','1','']);
                //头部摆动
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','头部摆动','无','左右','无','','无','']);
                //溶敷系数
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','溶敷系数','1.00','1.5','0.5','0.01','1','']);
                //机器人设置面
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','机器人设置面','床','床','壁','','床','']);
                //焊接动作（往返/单程）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接动作(往返/单程)','单程','单程','往返','','单程','']);
                //焊接电流偏置（A）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接电流偏置(A)','5','100','-100','5','0','']);
                //焊接电压偏置（V）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接电压偏置(V)','0','10','-10','1','0','']);
                //电弧跟踪
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','电弧跟踪','关闭','关闭','打开','','打开','']);
                //焊缝背面成型
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊缝背面成型','有','无','有','','无','']);
                //连续焊接时间
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','连续焊接时间','10','999','10','1','10','']);
                //连续焊接层数
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','连续焊接层数','4','99','1','1','4','']);
                //层间停止时间（秒）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','层间停止时间(秒)','5','3600','5','1','5','']);
                //最终层前停止时间（秒）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','最终层前停止时间(秒)','永久','3600','5','1','永久','']);
                //表面锥度非对应机能
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','表面锥度非对应机能','关闭','关闭','打开','','关闭','']);
                //电弧跟踪控制纠正量（mm）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','电弧跟踪控制纠正量(mm)','0.50','10.00','0.00','0.01','0.50','']);
                //焊丝焊缝检测机能
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝焊缝检测机能','关闭','关闭','打开','','关闭','']);
                //焊丝长度（mm）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝长度(mm)','25','50','0','1','25','']);
                //保护气体
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','保护气体','二氧化碳','二氧化碳','气体三','气体二','二氧化碳','']);
                //焊丝
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝','实芯','实芯','药芯','','实芯','']);
                //焊丝直径
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝直径','1.2','1.2','1.6','','1.6','']);
                //初层（陶瓷衬垫）-间隔
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','初层(陶瓷衬垫)-间隔','3.0','10.0','1.0','0.1','3.0','']);
                //初层（钢衬垫）-间隔
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','初层(钢瓷衬垫)-间隔','4.0','10.0','1.0','0.1','4.0','']);
                //初层以外-间隔
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','初层以外-间隔','5.0','10.0','1.0','0.1','5.0','']);
                /*
                      *  A= 30~40       A=45~60
                      *  T=9~80mm   T=9~50mm
                      *  B=4~10mm   B=0~2mm
                      */
                //板厚T1
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['254','板厚T1(mm)','34','','','0.1','','']);
                //脚长L
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['254','脚长L(mm)','10','','','0.1','','']);
                //余高Tm
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['254','余高Tm(mm)','1','','','0.1','','']);
                //角度θ1
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['254','角1(度)','34','','','','','']);
                //角度θ1
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['254','角2(度)','45','','','0.1','','']);
                //间隙b
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['254','间隙b(mm)','0','','','0.1','','']);
                /********************************************错误检测*********************************************/
                //板面高
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','板面高','5.0','100.0','-100.0','1.0','5.0','']);
                //板面下降量
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','板面下降量','6.0','100.0','-100.0','1.0','6.0','']);
                //坡口检测上高
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','坡口检测上高','2.0','100.0','-100.0','1.0','2.0','']);
                //坡口检测下高
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','坡口检测下高','3.0','100.0','-100.0','1.0','3.0','']);
                //底面检测时立板距离
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','底面检测时立板距离','2.0','50.0','-50.0','0.1','2.0','']);
                //检测错误板厚左右差--最小
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚左右差最小','4.0','10.0','0.0','0.1','4.0','']);
                //检测错误板厚左右差--最大
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚左右差最大','7.0','10.0','0.0','0.1','7.0','']);
                //检测错误板厚容许值--最小
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚容许值最小','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚容许值--最大
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚容许值最大','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差左右差--最小
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差左右差最小','4.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差左右差--最大
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差左右差最大','7.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差容许值--最小
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差容许值最小','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差容许值--最大
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差容许值最大','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误角度左右差--最小
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度左右差最小','5.0','10.0','0.0','0.1','5.0','']);
                //检测错误角度左右差--最大
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度左右差最大','10.0','10.0','0.0','0.1','10.0','']);
                //检测错误角度容许值--最小
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度容许值最小','28.0','90.0','0.0','0.1','28.0','']);
                //检测错误角度容许值--最大
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度容许值最大','65.0','90.0','0.0','0.1','65.0','']);
                //检测错误间隙左右差--最小
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙左右差最小','6.0','10.0','0.0','0.1','6.0','']);
                //检测错误间隙左右差--最大
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙左右差最大','12.0','10.0','0.0','0.1','12.0','']);
                //检测错误间隙容许值--最小
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙容许值最小','4.0','20.0','0.0','0.1','4.0','']);
                //检测错误间隙容许值--最大
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙容许值最大','10.0','20.0','0.0','0.1','10.0','']);
                /***************************************************焊接规范限制**********************************************/
                //初层陶衬垫电流前侧
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流前侧','230','500','10','10','230','']);
                //初层陶衬垫电流中间
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流中间','230','500','10','10','230','']);
                //初层陶衬垫电流后侧
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流后侧','230','500','10','10','230','']);
                //初层陶衬垫端部停止时间前（ms）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫端部停止时间前(ms)','400','5000','0','10','400','']);
                //初层陶衬垫端部停止时间后（ms）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫端部停止时间后(ms)','400','5000','0','10','400','']);
                //初层陶衬垫堆高MAX
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫堆高MAX','9.0','20.0','1.0','0.1','9.0','']);
                //初层陶衬垫接近-前
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //初层陶衬垫接近-后
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //初层陶衬垫分开最大摆动宽度
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-前','20.0','100.0','1.0','0.1','20.0','']);
                //初层陶衬垫摆动宽度间隔
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫摆动宽度间隔','100.0','100.0','0.0','0.1','100.0','']);
                //初层陶衬垫分开结束/开始比
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫分开结束/开始比','0.85','10.0','0.10','0.01','0.85','']);
                //初层陶衬垫焊接电压
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫焊接电压','自动设定','50','1','1','自动设定','']);



                //初层电流前侧
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流前侧','300','500','10','10','300','']);
                //初层电流中间
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流中间','300','500','10','10','300','']);
                //初层电流后侧
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流后侧','300','500','10','10','300','']);
                //初层端部停止时间前（ms）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层端部停止时间前(ms)','500','5000','0','10','500','']);
                //初层端部停止时间后（ms）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层端部停止时间后(ms)','500','5000','0','10','500','']);
                //初层堆高MAX
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层堆高MAX','7.0','10.0','1.0','0.1','7.0','']);
                //初层接近-前
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //初层接近-后
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //初层分开最大摆动宽度
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-前','20.0','100.0','1.0','0.1','20.0','']);
                //初层摆动宽度间隔
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层摆动宽度间隔','100.0','100.0','0.0','0.1','100.0','']);
                //初层分开结束/开始比
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层分开结束/开始比','1.00','10.0','0.10','0.01','1.00','']);
                //初层焊接电压
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层焊接电压','自动设定','50','1','1','自动设定','']);

                //第二层电流前侧
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流前侧','290','500','10','10','290','']);
                //第二层电流中间
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流中间','290','500','10','10','290','']);
                //第二层电流后侧
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流后侧','290','500','10','10','290','']);
                //第二层端部停止时间前（ms）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层端部停止时间前(ms)','100','5000','0','10','100','']);
                //第二层端部停止时间后（ms）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层端部停止时间后(ms)','100','5000','0','10','100','']);
                //第二层堆高MAX
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层堆高MAX','5.0','10.0','1.0','0.1','5.0','']);
                //第二层接近-前
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //第二层接近-后
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //第二层分开最大摆动宽度
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-前','16.0','100.0','1.0','0.1','16.0','']);
                //第二层摆动宽度间隔
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //第二层分开结束/开始比
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层分开结束/开始比','0.85','10.0','0.10','0.01','0.85','']);
                //第二层焊接电压
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层焊接电压','自动设定','50','1','1','自动设定','']);


                //中间层电流前侧
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流前侧','290','500','10','10','290','']);
                //中间层电流中间
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流中间','290','500','10','10','290','']);
                //中间层电流后侧
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流后侧','290','500','10','10','290','']);
                //中间层端部停止时间前（ms）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层端部停止时间前(ms)','50','5000','0','10','50','']);
                //中间层端部停止时间后（ms）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层端部停止时间后(ms)','50','5000','0','10','50','']);
                //中间层堆高MAX
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层堆高MAX','4.0','10.0','1.0','0.1','4.0','']);
                //中间层接近-前
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //中间层接近-后
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //中间层分开最大摆动宽度
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-前','14.0','100.0','1.0','0.1','14.0','']);
                //中间层摆动宽度间隔
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //中间层分开结束/开始比
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //中间层焊接电压
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层焊接电压','自动设定','50','1','1','自动设定','']);

                //表面层电流前侧
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流前侧','280','500','10','10','280','']);
                //表面层电流中间
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流中间','280','500','10','10','280','']);
                //表面层电流后侧
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流后侧','280','500','10','10','280','']);
                //表面层端部停止时间前（ms）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层端部停止时间前(ms)','0','5000','0','10','0','']);
                //表面层端部停止时间后（ms）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层端部停止时间后(ms)','0','5000','0','10','0','']);
                //表面层堆高MAX
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层堆高MAX','4.0','10.0','1.0','0.1','4.0','']);
                //表面层接近-前
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //表面层接近-后
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //表面层分开最大摆动宽度
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-前','11.0','100.0','1.0','0.1','11.0','']);
                //表面层摆动宽度间隔
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //表面层分开结束/开始比
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //表面层焊接电压
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层焊接电压','自动设定','50','1','1','自动设定','']);

                //表面层余高层数
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层余高层数','0.0','10.0','0.0','1.00','0.00','']);
                //表面层分开方向
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层分开方向','反方向','标准/反方向','标准','','反方向','']);
                //表面层起弧位置
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层起弧位置','收弧位置','坐标/收弧位置','坐标','','收弧位置','']);
                //开始位置坐标X（mm）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标X(mm)','4.0','-50.0','50.0','1.00','4.0','']);
                //开始位置坐标Y（mm）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标Y(mm)','0.0','-50.0','50.0','1.00','0.0','']);
                //开始位置坐标z（mm）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标Z(mm)','-3.0','-50.0','50.0','1.00','-3.0','']);
                //表面层收弧动作
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层收弧动作','单程','往返/单程','往返','','单程','']);
                //表面层返回步骤距离
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层返回步骤距离','5.0','100.0','0.1','1.0','5.0','']);


                //立板余高层电流前侧
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流前侧','250','500','10','10','250','']);
                //立板余高层电流中间
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流中间','250','500','10','10','250','']);
                //立板余高层电流后侧
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流后侧','250','500','10','10','250','']);
                //立板余高层端部停止时间前（ms）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层端部停止时间前(ms)','0','5000','0','10','0','']);
                //立板余高层端部停止时间后（ms）
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层端部停止时间后(ms)','0','5000','0','10','0','']);
                //立板余高层堆高MAX
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层堆高MAX','5.0','10.0','1.0','0.1','5.0','']);
                //立板余高层接近-前
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //立板余高层接近-后
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-后','15.0','100.0','-50.0','0.1','15.0','']);
                //立板余高层分开最大摆动宽度
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-前','10.0','100.0','1.0','0.1','10.0','']);
                //立板余高层摆动宽度间隔
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //立板余高层分开结束/开始比
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //立板余高层焊接电压
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层焊接电压','自动设定','50','1','1','自动设定','']);
                //立板余高层MAX焊接速度
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层MAX焊接速度','500.0','5000.0','0.0','10.0','500','']);

                /***************************************************焊接规范列表**********************************************/

            }
            tx.executeSql('CREATE TABLE IF NOT EXISTS FlatFillet(mode TEXT,function TEXT,\
                                                setvalue TEXT,max TEXT,min TEXT,step TEXT,init TEXT,decription TEXT)');
            table = tx.executeSql("select * from FlatFillet");
            if(table.rows.length === 0)
            {
                //console.log("FlatFillet is not exists");
                //坡口参数初始值设置
                /**********************************************示教模式*************************************************/
                //示教模式
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','示教模式','自动','自动','手动','半自动','自动','示教模式']);
                //始终端检测
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','始终端检测','自动','自动','手动','','自动','设定终端的检测是自动或是手动']);
                //示教第1点位置
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','示教第1点位置','右方','右方','左方','','右方','设定第一点从左右哪边开始']);
                //示教1点时焊接长（mm）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','示教1点时焊接长(mm)','300','10000','10','2','300','示教点数为1点时,设定至第二点的焊接']);
                //板厚（mm）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['4','板厚(mm)','测定','200','8','0.1','测定','背部使用陶瓷衬垫或者不能导电时,必须设定板厚']);
                //余高（mm）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['4','余高(mm)','1','20','-20','0.1','1','设定从板面堆起高度']);
                //坡口检测点左（mm）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['4','坡口检测点左(mm)','-10','1000','-1000','1','-10','']);
                //坡口检测点右（mm）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['4','坡口检测点右(mm)','-10','1000','-1000','1','-10','']);
                //板厚补正（mm）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['2','板厚补正(mm)','0','200','-200','1','0','设定是否根据检测的板厚补正条件']);
                //角度补正（度）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['2','角度补正(度)','0','90','-90','1','0','设定是否根据检测的角度补正条件']);
                //间隙补正（mm）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['2','间隙补正(mm)','0','200','-200','1','0','设定是否根据检测的间隙补正条件']);
                /*******************************************坡口设置*****************************************************/
                //焊接始终端偏左（mm）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','焊接始终端偏左(mm)','0','1000','-1000','0.1','0','']);
                //焊接始终端偏右（mm）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','焊接始终端偏右(mm)','0','1000','-1000','0.1','0','']);
                //示教点数
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','示教点数','2','30','1','1','1','']);
                //X左梯形平移（度）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','X左梯形平移(度)','0','90','-90','1','1','']);
                //X右梯形平移（度）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','X右梯形平移(度)','0','90','-90','1','1','']);
                //Y左梯形平移（度）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','Y左梯形平移(度)','0','90','-90','1','1','']);
                //Y右梯形平移（度）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','Y右梯形平移(度)','0','90','-90','1','1','']);
                //头部摆动
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','头部摆动','无','左右','无','','无','']);
                //溶敷系数
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','溶敷系数','1.00','1.5','0.5','0.01','1','']);
                //机器人设置面
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','机器人设置面','床','床','壁','','床','']);
                //焊接动作（往返/单程）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','焊接动作(往返/单程)','单程','单程','往返','','单程','']);
                //焊接电流偏置（A）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','焊接电流偏置(A)','5','100','-100','5','0','']);
                //焊接电压偏置（V）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','焊接电压偏置(V)','0','10','-10','1','0','']);
                //电弧跟踪
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','电弧跟踪','关闭','关闭','打开','','打开','']);
                //焊缝背面成型
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','焊缝背面成型','有','无','有','','无','']);
                //连续焊接时间
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','连续焊接时间','10','999','10','1','10','']);
                //连续焊接层数
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','连续焊接层数','4','99','1','1','4','']);
                //层间停止时间（秒）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','层间停止时间(秒)','5','3600','5','1','5','']);
                //最终层前停止时间（秒）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','最终层前停止时间(秒)','永久','3600','5','1','永久','']);
                //表面锥度非对应机能
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','表面锥度非对应机能','关闭','关闭','打开','','关闭','']);
                //电弧跟踪控制纠正量（mm）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','电弧跟踪控制纠正量(mm)','0.50','10.00','0.00','0.01','0.50','']);
                //焊丝焊缝检测机能
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝焊缝检测机能','关闭','关闭','打开','','关闭','']);
                //焊丝长度（mm）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝长度(mm)','25','50','0','1','25','']);
                //保护气体
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','保护气体','二氧化碳','二氧化碳','气体三','气体二','二氧化碳','']);
                //焊丝
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝','实芯','实芯','药芯','','实芯','']);
                //焊丝直径
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝直径','1.2','1.2','1.6','','1.6','']);
                //初层（陶瓷衬垫）-间隔
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','初层(陶瓷衬垫)-间隔','3.0','10.0','1.0','0.1','3.0','']);
                //初层（钢衬垫）-间隔
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','初层(钢瓷衬垫)-间隔','4.0','10.0','1.0','0.1','4.0','']);
                //初层以外-间隔
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['255','初层以外-间隔','5.0','10.0','1.0','0.1','5.0','']);
                /*
                      *  A= 30~40       A=45~60
                      *  T=9~80mm   T=9~50mm
                      *  B=4~10mm   B=0~2mm
                      */
                //板厚T1
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['254','板厚T1(mm)','34','','','0.1','','']);
                //脚长L
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['254','脚长L(mm)','10','','','0.1','','']);
                //余高Tm
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['254','余高Tm(mm)','1','','','0.1','','']);
                //角度θ1
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['254','角1(度)','34','','','','','']);
                //角度θ1
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['254','角2(度)','45','','','0.1','','']);
                //间隙b
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['254','间隙b(mm)','0','','','0.1','','']);
                /********************************************错误检测*********************************************/
                //板面高
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','板面高','5.0','100.0','-100.0','1.0','5.0','']);
                //板面下降量
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','板面下降量','6.0','100.0','-100.0','1.0','6.0','']);
                //坡口检测上高
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','坡口检测上高','2.0','100.0','-100.0','1.0','2.0','']);
                //坡口检测下高
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','坡口检测下高','3.0','100.0','-100.0','1.0','3.0','']);
                //底面检测时立板距离
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','底面检测时立板距离','2.0','50.0','-50.0','0.1','2.0','']);
                //检测错误板厚左右差--最小
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚左右差最小','4.0','10.0','0.0','0.1','4.0','']);
                //检测错误板厚左右差--最大
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚左右差最大','7.0','10.0','0.0','0.1','7.0','']);
                //检测错误板厚容许值--最小
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚容许值最小','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚容许值--最大
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚容许值最大','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差左右差--最小
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差左右差最小','4.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差左右差--最大
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差左右差最大','7.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差容许值--最小
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差容许值最小','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差容许值--最大
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差容许值最大','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误角度左右差--最小
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度左右差最小','5.0','10.0','0.0','0.1','5.0','']);
                //检测错误角度左右差--最大
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度左右差最大','10.0','10.0','0.0','0.1','10.0','']);
                //检测错误角度容许值--最小
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度容许值最小','28.0','90.0','0.0','0.1','28.0','']);
                //检测错误角度容许值--最大
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度容许值最大','65.0','90.0','0.0','0.1','65.0','']);
                //检测错误间隙左右差--最小
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙左右差最小','6.0','10.0','0.0','0.1','6.0','']);
                //检测错误间隙左右差--最大
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙左右差最大','12.0','10.0','0.0','0.1','12.0','']);
                //检测错误间隙容许值--最小
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙容许值最小','4.0','20.0','0.0','0.1','4.0','']);
                //检测错误间隙容许值--最大
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙容许值最大','10.0','20.0','0.0','0.1','10.0','']);
                /***************************************************焊接规范限制**********************************************/
                //初层陶衬垫电流前侧
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流前侧','230','500','10','10','230','']);
                //初层陶衬垫电流中间
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流中间','230','500','10','10','230','']);
                //初层陶衬垫电流后侧
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流后侧','230','500','10','10','230','']);
                //初层陶衬垫端部停止时间前（ms）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫端部停止时间前(ms)','400','5000','0','10','400','']);
                //初层陶衬垫端部停止时间后（ms）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫端部停止时间后(ms)','400','5000','0','10','400','']);
                //初层陶衬垫堆高MAX
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫堆高MAX','9.0','20.0','1.0','0.1','9.0','']);
                //初层陶衬垫接近-前
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //初层陶衬垫接近-后
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //初层陶衬垫分开最大摆动宽度
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-前','20.0','100.0','1.0','0.1','20.0','']);
                //初层陶衬垫摆动宽度间隔
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫摆动宽度间隔','100.0','100.0','0.0','0.1','100.0','']);
                //初层陶衬垫分开结束/开始比
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫分开结束/开始比','0.85','10.0','0.10','0.01','0.85','']);
                //初层陶衬垫焊接电压
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫焊接电压','自动设定','50','1','1','自动设定','']);



                //初层电流前侧
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流前侧','300','500','10','10','300','']);
                //初层电流中间
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流中间','300','500','10','10','300','']);
                //初层电流后侧
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流后侧','300','500','10','10','300','']);
                //初层端部停止时间前（ms）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','初层端部停止时间前(ms)','500','5000','0','10','500','']);
                //初层端部停止时间后（ms）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','初层端部停止时间后(ms)','500','5000','0','10','500','']);
                //初层堆高MAX
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','初层堆高MAX','7.0','10.0','1.0','0.1','7.0','']);
                //初层接近-前
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //初层接近-后
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //初层分开最大摆动宽度
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-前','20.0','100.0','1.0','0.1','20.0','']);
                //初层摆动宽度间隔
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','初层摆动宽度间隔','100.0','100.0','0.0','0.1','100.0','']);
                //初层分开结束/开始比
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','初层分开结束/开始比','1.00','10.0','0.10','0.01','1.00','']);
                //初层焊接电压
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','初层焊接电压','自动设定','50','1','1','自动设定','']);

                //第二层电流前侧
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流前侧','290','500','10','10','290','']);
                //第二层电流中间
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流中间','290','500','10','10','290','']);
                //第二层电流后侧
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流后侧','290','500','10','10','290','']);
                //第二层端部停止时间前（ms）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','第二层端部停止时间前(ms)','100','5000','0','10','100','']);
                //第二层端部停止时间后（ms）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','第二层端部停止时间后(ms)','100','5000','0','10','100','']);
                //第二层堆高MAX
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','第二层堆高MAX','5.0','10.0','1.0','0.1','5.0','']);
                //第二层接近-前
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //第二层接近-后
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //第二层分开最大摆动宽度
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-前','16.0','100.0','1.0','0.1','16.0','']);
                //第二层摆动宽度间隔
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','第二层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //第二层分开结束/开始比
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','第二层分开结束/开始比','0.85','10.0','0.10','0.01','0.85','']);
                //第二层焊接电压
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','第二层焊接电压','自动设定','50','1','1','自动设定','']);


                //中间层电流前侧
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流前侧','290','500','10','10','290','']);
                //中间层电流中间
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流中间','290','500','10','10','290','']);
                //中间层电流后侧
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流后侧','290','500','10','10','290','']);
                //中间层端部停止时间前（ms）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','中间层端部停止时间前(ms)','50','5000','0','10','50','']);
                //中间层端部停止时间后（ms）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','中间层端部停止时间后(ms)','50','5000','0','10','50','']);
                //中间层堆高MAX
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','中间层堆高MAX','4.0','10.0','1.0','0.1','4.0','']);
                //中间层接近-前
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //中间层接近-后
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //中间层分开最大摆动宽度
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-前','14.0','100.0','1.0','0.1','14.0','']);
                //中间层摆动宽度间隔
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','中间层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //中间层分开结束/开始比
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','中间层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //中间层焊接电压
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','中间层焊接电压','自动设定','50','1','1','自动设定','']);

                //表面层电流前侧
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流前侧','280','500','10','10','280','']);
                //表面层电流中间
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流中间','280','500','10','10','280','']);
                //表面层电流后侧
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流后侧','280','500','10','10','280','']);
                //表面层端部停止时间前（ms）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','表面层端部停止时间前(ms)','0','5000','0','10','0','']);
                //表面层端部停止时间后（ms）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','表面层端部停止时间后(ms)','0','5000','0','10','0','']);
                //表面层堆高MAX
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','表面层堆高MAX','4.0','10.0','1.0','0.1','4.0','']);
                //表面层接近-前
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //表面层接近-后
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //表面层分开最大摆动宽度
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-前','11.0','100.0','1.0','0.1','11.0','']);
                //表面层摆动宽度间隔
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','表面层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //表面层分开结束/开始比
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','表面层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //表面层焊接电压
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','表面层焊接电压','自动设定','50','1','1','自动设定','']);

                //表面层余高层数
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','表面层余高层数','0.0','10.0','0.0','1.00','0.00','']);
                //表面层分开方向
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','表面层分开方向','反方向','标准/反方向','标准','','反方向','']);
                //表面层起弧位置
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','表面层起弧位置','收弧位置','坐标/收弧位置','坐标','','收弧位置','']);
                //开始位置坐标X（mm）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标X(mm)','4.0','-50.0','50.0','1.00','4.0','']);
                //开始位置坐标Y（mm）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标Y(mm)','0.0','-50.0','50.0','1.00','0.0','']);
                //开始位置坐标z（mm）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标Z(mm)','-3.0','-50.0','50.0','1.00','-3.0','']);
                //表面层收弧动作
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','表面层收弧动作','单程','往返/单程','往返','','单程','']);
                //表面层返回步骤距离
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','表面层返回步骤距离','5.0','100.0','0.1','1.0','5.0','']);


                //立板余高层电流前侧
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流前侧','250','500','10','10','250','']);
                //立板余高层电流中间
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流中间','250','500','10','10','250','']);
                //立板余高层电流后侧
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流后侧','250','500','10','10','250','']);
                //立板余高层端部停止时间前（ms）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层端部停止时间前(ms)','0','5000','0','10','0','']);
                //立板余高层端部停止时间后（ms）
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层端部停止时间后(ms)','0','5000','0','10','0','']);
                //立板余高层堆高MAX
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层堆高MAX','5.0','10.0','1.0','0.1','5.0','']);
                //立板余高层接近-前
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //立板余高层接近-后
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-后','15.0','100.0','-50.0','0.1','15.0','']);
                //立板余高层分开最大摆动宽度
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-前','10.0','100.0','1.0','0.1','10.0','']);
                //立板余高层摆动宽度间隔
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //立板余高层分开结束/开始比
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //立板余高层焊接电压
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层焊接电压','自动设定','50','1','1','自动设定','']);
                //立板余高层MAX焊接速度
                tx.executeSql('insert into FlatFillet values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层MAX焊接速度','500.0','5000.0','0.0','10.0','500','']);

                /***************************************************焊接规范列表**********************************************/

            }
            tx.executeSql('CREATE TABLE IF NOT EXISTS HorizontalWeldSingleBevelGrooveT(mode TEXT,function TEXT,\
                                                setvalue TEXT,max TEXT,min TEXT,step TEXT,init TEXT,decription TEXT)');
            table = tx.executeSql("select * from HorizontalWeldSingleBevelGrooveT");
            if(table.rows.length === 0)
            {
                //console.log("HorizontalWeldSingleBevelGrooveT is not exists");
                //坡口参数初始值设置
                /**********************************************示教模式*************************************************/
                //示教模式
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','示教模式','自动','自动','手动','半自动','自动','示教模式']);
                //始终端检测
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','始终端检测','自动','自动','手动','','自动','设定终端的检测是自动或是手动']);
                //示教第1点位置
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','示教第1点位置','右方','右方','左方','','右方','设定第一点从左右哪边开始']);
                //示教1点时焊接长（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','示教1点时焊接长(mm)','300','10000','10','2','300','示教点数为1点时,设定至第二点的焊接']);
                //板厚（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['4','板厚(mm)','测定','200','8','0.1','测定','背部使用陶瓷衬垫或者不能导电时,必须设定板厚']);
                //余高（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['4','余高(mm)','1','20','-20','0.1','1','设定从板面堆起高度']);
                //坡口检测点左（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['4','坡口检测点左(mm)','-10','1000','-1000','1','-10','']);
                //坡口检测点右（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['4','坡口检测点右(mm)','-10','1000','-1000','1','-10','']);
                //板厚补正（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['2','板厚补正(mm)','0','200','-200','1','0','设定是否根据检测的板厚补正条件']);
                //角度补正（度）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['2','角度补正(度)','0','90','-90','1','0','设定是否根据检测的角度补正条件']);
                //间隙补正（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['2','间隙补正(mm)','0','200','-200','1','0','设定是否根据检测的间隙补正条件']);
                /*******************************************坡口设置*****************************************************/
                //焊接始终端偏左（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊接始终端偏左(mm)','0','1000','-1000','0.1','0','']);
                //焊接始终端偏右（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊接始终端偏右(mm)','0','1000','-1000','0.1','0','']);
                //示教点数
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','示教点数','2','30','1','1','1','']);
                //X左梯形平移（度）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','X左梯形平移(度)','0','90','-90','1','1','']);
                //X右梯形平移（度）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','X右梯形平移(度)','0','90','-90','1','1','']);
                //Y左梯形平移（度）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','Y左梯形平移(度)','0','90','-90','1','1','']);
                //Y右梯形平移（度）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','Y右梯形平移(度)','0','90','-90','1','1','']);
                //头部摆动
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','头部摆动','无','左右','无','','无','']);
                //溶敷系数
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','溶敷系数','1.00','1.5','0.5','0.01','1','']);
                //机器人设置面
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','机器人设置面','床','床','壁','','床','']);
                //焊接动作（往返/单程）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊接动作(往返/单程)','单程','单程','往返','','单程','']);
                //焊接电流偏置（A）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊接电流偏置(A)','5','100','-100','5','0','']);
                //焊接电压偏置（V）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊接电压偏置(V)','0','10','-10','1','0','']);
                //电弧跟踪
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','电弧跟踪','关闭','关闭','打开','','打开','']);
                //焊缝背面成型
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊缝背面成型','有','无','有','','无','']);
                //连续焊接时间
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','连续焊接时间','10','999','10','1','10','']);
                //连续焊接层数
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','连续焊接层数','4','99','1','1','4','']);
                //层间停止时间（秒）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','层间停止时间(秒)','5','3600','5','1','5','']);
                //最终层前停止时间（秒）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','最终层前停止时间(秒)','永久','3600','5','1','永久','']);
                //表面锥度非对应机能
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','表面锥度非对应机能','关闭','关闭','打开','','关闭','']);
                //电弧跟踪控制纠正量（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','电弧跟踪控制纠正量(mm)','0.50','10.00','0.00','0.01','0.50','']);
                //焊丝焊缝检测机能
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝焊缝检测机能','关闭','关闭','打开','','关闭','']);
                //焊丝长度（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝长度(mm)','25','50','0','1','25','']);
                //保护气体
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','保护气体','二氧化碳','二氧化碳','气体三','气体二','二氧化碳','']);
                //焊丝
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝','实芯','实芯','药芯','','实芯','']);
                //焊丝直径
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝直径','1.2','1.2','1.6','','1.6','']);
                //初层（陶瓷衬垫）-间隔
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','初层(陶瓷衬垫)-间隔','3.0','10.0','1.0','0.1','3.0','']);
                //初层（钢衬垫）-间隔
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','初层(钢瓷衬垫)-间隔','4.0','10.0','1.0','0.1','4.0','']);
                //初层以外-间隔
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','初层以外-间隔','5.0','10.0','1.0','0.1','5.0','']);
                /*
                      *  A= 30~40       A=45~60
                      *  T=9~80mm   T=9~50mm
                      *  B=4~10mm   B=0~2mm
                      */
                //板厚T1
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['254','板厚T1(mm)','34','','','0.1','','']);
                //脚长L
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['254','脚长L(mm)','10','','','0.1','','']);
                //余高Tm
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['254','余高Tm(mm)','1','','','0.1','','']);
                //角度θ1
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['254','角1(度)','34','','','','','']);
                //角度θ1
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['254','角2(度)','45','','','0.1','','']);
                //间隙b
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['254','间隙b(mm)','0','','','0.1','','']);
                /********************************************错误检测*********************************************/
                //板面高
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','板面高','5.0','100.0','-100.0','1.0','5.0','']);
                //板面下降量
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','板面下降量','6.0','100.0','-100.0','1.0','6.0','']);
                //坡口检测上高
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','坡口检测上高','2.0','100.0','-100.0','1.0','2.0','']);
                //坡口检测下高
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','坡口检测下高','3.0','100.0','-100.0','1.0','3.0','']);
                //底面检测时立板距离
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','底面检测时立板距离','2.0','50.0','-50.0','0.1','2.0','']);
                //检测错误板厚左右差--最小
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚左右差最小','4.0','10.0','0.0','0.1','4.0','']);
                //检测错误板厚左右差--最大
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚左右差最大','7.0','10.0','0.0','0.1','7.0','']);
                //检测错误板厚容许值--最小
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚容许值最小','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚容许值--最大
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚容许值最大','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差左右差--最小
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差左右差最小','4.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差左右差--最大
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差左右差最大','7.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差容许值--最小
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差容许值最小','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差容许值--最大
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差容许值最大','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误角度左右差--最小
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度左右差最小','5.0','10.0','0.0','0.1','5.0','']);
                //检测错误角度左右差--最大
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度左右差最大','10.0','10.0','0.0','0.1','10.0','']);
                //检测错误角度容许值--最小
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度容许值最小','28.0','90.0','0.0','0.1','28.0','']);
                //检测错误角度容许值--最大
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度容许值最大','65.0','90.0','0.0','0.1','65.0','']);
                //检测错误间隙左右差--最小
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙左右差最小','6.0','10.0','0.0','0.1','6.0','']);
                //检测错误间隙左右差--最大
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙左右差最大','12.0','10.0','0.0','0.1','12.0','']);
                //检测错误间隙容许值--最小
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙容许值最小','4.0','20.0','0.0','0.1','4.0','']);
                //检测错误间隙容许值--最大
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙容许值最大','10.0','20.0','0.0','0.1','10.0','']);
                /***************************************************焊接规范限制**********************************************/
                //初层陶衬垫电流前侧
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流前侧','230','500','10','10','230','']);
                //初层陶衬垫电流中间
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流中间','230','500','10','10','230','']);
                //初层陶衬垫电流后侧
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流后侧','230','500','10','10','230','']);
                //初层陶衬垫端部停止时间前（ms）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫端部停止时间前(ms)','400','5000','0','10','400','']);
                //初层陶衬垫端部停止时间后（ms）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫端部停止时间后(ms)','400','5000','0','10','400','']);
                //初层陶衬垫堆高MAX
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫堆高MAX','9.0','20.0','1.0','0.1','9.0','']);
                //初层陶衬垫接近-前
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //初层陶衬垫接近-后
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //初层陶衬垫分开最大摆动宽度
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-前','20.0','100.0','1.0','0.1','20.0','']);
                //初层陶衬垫摆动宽度间隔
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫摆动宽度间隔','100.0','100.0','0.0','0.1','100.0','']);
                //初层陶衬垫分开结束/开始比
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫分开结束/开始比','0.85','10.0','0.10','0.01','0.85','']);
                //初层陶衬垫焊接电压
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫焊接电压','自动设定','50','1','1','自动设定','']);



                //初层电流前侧
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流前侧','300','500','10','10','300','']);
                //初层电流中间
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流中间','300','500','10','10','300','']);
                //初层电流后侧
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流后侧','300','500','10','10','300','']);
                //初层端部停止时间前（ms）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层端部停止时间前(ms)','500','5000','0','10','500','']);
                //初层端部停止时间后（ms）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层端部停止时间后(ms)','500','5000','0','10','500','']);
                //初层堆高MAX
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层堆高MAX','7.0','10.0','1.0','0.1','7.0','']);
                //初层接近-前
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //初层接近-后
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //初层分开最大摆动宽度
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-前','20.0','100.0','1.0','0.1','20.0','']);
                //初层摆动宽度间隔
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层摆动宽度间隔','100.0','100.0','0.0','0.1','100.0','']);
                //初层分开结束/开始比
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层分开结束/开始比','1.00','10.0','0.10','0.01','1.00','']);
                //初层焊接电压
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层焊接电压','自动设定','50','1','1','自动设定','']);

                //第二层电流前侧
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流前侧','290','500','10','10','290','']);
                //第二层电流中间
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流中间','290','500','10','10','290','']);
                //第二层电流后侧
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流后侧','290','500','10','10','290','']);
                //第二层端部停止时间前（ms）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层端部停止时间前(ms)','100','5000','0','10','100','']);
                //第二层端部停止时间后（ms）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层端部停止时间后(ms)','100','5000','0','10','100','']);
                //第二层堆高MAX
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层堆高MAX','5.0','10.0','1.0','0.1','5.0','']);
                //第二层接近-前
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //第二层接近-后
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //第二层分开最大摆动宽度
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-前','16.0','100.0','1.0','0.1','16.0','']);
                //第二层摆动宽度间隔
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //第二层分开结束/开始比
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层分开结束/开始比','0.85','10.0','0.10','0.01','0.85','']);
                //第二层焊接电压
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层焊接电压','自动设定','50','1','1','自动设定','']);


                //中间层电流前侧
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流前侧','290','500','10','10','290','']);
                //中间层电流中间
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流中间','290','500','10','10','290','']);
                //中间层电流后侧
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流后侧','290','500','10','10','290','']);
                //中间层端部停止时间前（ms）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层端部停止时间前(ms)','50','5000','0','10','50','']);
                //中间层端部停止时间后（ms）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层端部停止时间后(ms)','50','5000','0','10','50','']);
                //中间层堆高MAX
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层堆高MAX','4.0','10.0','1.0','0.1','4.0','']);
                //中间层接近-前
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //中间层接近-后
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //中间层分开最大摆动宽度
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-前','14.0','100.0','1.0','0.1','14.0','']);
                //中间层摆动宽度间隔
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //中间层分开结束/开始比
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //中间层焊接电压
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层焊接电压','自动设定','50','1','1','自动设定','']);

                //表面层电流前侧
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流前侧','280','500','10','10','280','']);
                //表面层电流中间
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流中间','280','500','10','10','280','']);
                //表面层电流后侧
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流后侧','280','500','10','10','280','']);
                //表面层端部停止时间前（ms）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层端部停止时间前(ms)','0','5000','0','10','0','']);
                //表面层端部停止时间后（ms）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层端部停止时间后(ms)','0','5000','0','10','0','']);
                //表面层堆高MAX
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层堆高MAX','4.0','10.0','1.0','0.1','4.0','']);
                //表面层接近-前
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //表面层接近-后
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //表面层分开最大摆动宽度
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-前','11.0','100.0','1.0','0.1','11.0','']);
                //表面层摆动宽度间隔
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //表面层分开结束/开始比
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //表面层焊接电压
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层焊接电压','自动设定','50','1','1','自动设定','']);

                //表面层余高层数
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层余高层数','0.0','10.0','0.0','1.00','0.00','']);
                //表面层分开方向
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层分开方向','反方向','标准/反方向','标准','','反方向','']);
                //表面层起弧位置
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层起弧位置','收弧位置','坐标/收弧位置','坐标','','收弧位置','']);
                //开始位置坐标X（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标X(mm)','4.0','-50.0','50.0','1.00','4.0','']);
                //开始位置坐标Y（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标Y(mm)','0.0','-50.0','50.0','1.00','0.0','']);
                //开始位置坐标z（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标Z(mm)','-3.0','-50.0','50.0','1.00','-3.0','']);
                //表面层收弧动作
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层收弧动作','单程','往返/单程','往返','','单程','']);
                //表面层返回步骤距离
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层返回步骤距离','5.0','100.0','0.1','1.0','5.0','']);


                //立板余高层电流前侧
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流前侧','250','500','10','10','250','']);
                //立板余高层电流中间
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流中间','250','500','10','10','250','']);
                //立板余高层电流后侧
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流后侧','250','500','10','10','250','']);
                //立板余高层端部停止时间前（ms）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层端部停止时间前(ms)','0','5000','0','10','0','']);
                //立板余高层端部停止时间后（ms）
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层端部停止时间后(ms)','0','5000','0','10','0','']);
                //立板余高层堆高MAX
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层堆高MAX','5.0','10.0','1.0','0.1','5.0','']);
                //立板余高层接近-前
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //立板余高层接近-后
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-后','15.0','100.0','-50.0','0.1','15.0','']);
                //立板余高层分开最大摆动宽度
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-前','10.0','100.0','1.0','0.1','10.0','']);
                //立板余高层摆动宽度间隔
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //立板余高层分开结束/开始比
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //立板余高层焊接电压
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层焊接电压','自动设定','50','1','1','自动设定','']);
                //立板余高层MAX焊接速度
                tx.executeSql('insert into HorizontalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层MAX焊接速度','500.0','5000.0','0.0','10.0','500','']);

                /***************************************************焊接规范列表**********************************************/

            }

            tx.executeSql('CREATE TABLE IF NOT EXISTS HorizontalWeldSingleBevelGroove(mode TEXT,function TEXT,\
                                                setvalue TEXT,max TEXT,min TEXT,step TEXT,init TEXT,decription TEXT)');
            table = tx.executeSql("select * from HorizontalWeldSingleBevelGroove");
            if(table.rows.length === 0)
            {
                //console.log("HorizontalWeldSingleBevelGroove is not exists");
                //坡口参数初始值设置
                /**********************************************示教模式*************************************************/
                //示教模式
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','示教模式','自动','自动','手动','半自动','自动','示教模式']);
                //始终端检测
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','始终端检测','自动','自动','手动','','自动','设定终端的检测是自动或是手动']);
                //示教第1点位置
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','示教第1点位置','右方','右方','左方','','右方','设定第一点从左右哪边开始']);
                //示教1点时焊接长（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','示教1点时焊接长(mm)','300','10000','10','2','300','示教点数为1点时,设定至第二点的焊接']);
                //板厚（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['4','板厚(mm)','测定','200','8','0.1','测定','背部使用陶瓷衬垫或者不能导电时,必须设定板厚']);
                //余高（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['4','余高(mm)','1','20','-20','0.1','1','设定从板面堆起高度']);
                //坡口检测点左（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['4','坡口检测点左(mm)','-10','1000','-1000','1','-10','']);
                //坡口检测点右（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['4','坡口检测点右(mm)','-10','1000','-1000','1','-10','']);
                //板厚补正（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['2','板厚补正(mm)','0','200','-200','1','0','设定是否根据检测的板厚补正条件']);
                //角度补正（度）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['2','角度补正(度)','0','90','-90','1','0','设定是否根据检测的角度补正条件']);
                //间隙补正（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['2','间隙补正(mm)','0','200','-200','1','0','设定是否根据检测的间隙补正条件']);
                /*******************************************坡口设置*****************************************************/
                //焊接始终端偏左（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接始终端偏左(mm)','0','1000','-1000','0.1','0','']);
                //焊接始终端偏右（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接始终端偏右(mm)','0','1000','-1000','0.1','0','']);
                //示教点数
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','示教点数','2','30','1','1','1','']);
                //X左梯形平移（度）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','X左梯形平移(度)','0','90','-90','1','1','']);
                //X右梯形平移（度）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','X右梯形平移(度)','0','90','-90','1','1','']);
                //Y左梯形平移（度）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','Y左梯形平移(度)','0','90','-90','1','1','']);
                //Y右梯形平移（度）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','Y右梯形平移(度)','0','90','-90','1','1','']);
                //头部摆动
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','头部摆动','无','左右','无','','无','']);
                //溶敷系数
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','溶敷系数','1.00','1.5','0.5','0.01','1','']);
                //机器人设置面
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','机器人设置面','床','床','壁','','床','']);
                //焊接动作（往返/单程）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接动作(往返/单程)','单程','单程','往返','','单程','']);
                //焊接电流偏置（A）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接电流偏置(A)','5','100','-100','5','0','']);
                //焊接电压偏置（V）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接电压偏置(V)','0','10','-10','1','0','']);
                //电弧跟踪
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','电弧跟踪','关闭','关闭','打开','','打开','']);
                //焊缝背面成型
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊缝背面成型','有','无','有','','无','']);
                //连续焊接时间
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','连续焊接时间','10','999','10','1','10','']);
                //连续焊接层数
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','连续焊接层数','4','99','1','1','4','']);
                //层间停止时间（秒）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','层间停止时间(秒)','5','3600','5','1','5','']);
                //最终层前停止时间（秒）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','最终层前停止时间(秒)','永久','3600','5','1','永久','']);
                //表面锥度非对应机能
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','表面锥度非对应机能','关闭','关闭','打开','','关闭','']);
                //电弧跟踪控制纠正量（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','电弧跟踪控制纠正量(mm)','0.50','10.00','0.00','0.01','0.50','']);
                //焊丝焊缝检测机能
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝焊缝检测机能','关闭','关闭','打开','','关闭','']);
                //焊丝长度（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝长度(mm)','25','50','0','1','25','']);
                //保护气体
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','保护气体','二氧化碳','二氧化碳','气体三','气体二','二氧化碳','']);
                //焊丝
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝','实芯','实芯','药芯','','实芯','']);
                //焊丝直径
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝直径','1.2','1.2','1.6','','1.6','']);
                //初层（陶瓷衬垫）-间隔
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','初层(陶瓷衬垫)-间隔','3.0','10.0','1.0','0.1','3.0','']);
                //初层（钢衬垫）-间隔
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','初层(钢瓷衬垫)-间隔','4.0','10.0','1.0','0.1','4.0','']);
                //初层以外-间隔
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','初层以外-间隔','5.0','10.0','1.0','0.1','5.0','']);
                /*
                      *  A= 30~40       A=45~60
                      *  T=9~80mm   T=9~50mm
                      *  B=4~10mm   B=0~2mm
                      */
                //板厚T1
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['254','板厚T1(mm)','34','','','0.1','','']);
                //脚长L
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['254','脚长L(mm)','10','','','0.1','','']);
                //余高Tm
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['254','余高Tm(mm)','1','','','0.1','','']);
                //角度θ1
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['254','角1(度)','34','','','','','']);
                //角度θ1
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['254','角2(度)','45','','','0.1','','']);
                //间隙b
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['254','间隙b(mm)','0','','','0.1','','']);
                /********************************************错误检测*********************************************/
                //板面高
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','板面高','5.0','100.0','-100.0','1.0','5.0','']);
                //板面下降量
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','板面下降量','6.0','100.0','-100.0','1.0','6.0','']);
                //坡口检测上高
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','坡口检测上高','2.0','100.0','-100.0','1.0','2.0','']);
                //坡口检测下高
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','坡口检测下高','3.0','100.0','-100.0','1.0','3.0','']);
                //底面检测时立板距离
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','底面检测时立板距离','2.0','50.0','-50.0','0.1','2.0','']);
                //检测错误板厚左右差--最小
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚左右差最小','4.0','10.0','0.0','0.1','4.0','']);
                //检测错误板厚左右差--最大
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚左右差最大','7.0','10.0','0.0','0.1','7.0','']);
                //检测错误板厚容许值--最小
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚容许值最小','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚容许值--最大
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚容许值最大','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差左右差--最小
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差左右差最小','4.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差左右差--最大
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差左右差最大','7.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差容许值--最小
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差容许值最小','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差容许值--最大
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差容许值最大','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误角度左右差--最小
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度左右差最小','5.0','10.0','0.0','0.1','5.0','']);
                //检测错误角度左右差--最大
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度左右差最大','10.0','10.0','0.0','0.1','10.0','']);
                //检测错误角度容许值--最小
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度容许值最小','28.0','90.0','0.0','0.1','28.0','']);
                //检测错误角度容许值--最大
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度容许值最大','65.0','90.0','0.0','0.1','65.0','']);
                //检测错误间隙左右差--最小
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙左右差最小','6.0','10.0','0.0','0.1','6.0','']);
                //检测错误间隙左右差--最大
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙左右差最大','12.0','10.0','0.0','0.1','12.0','']);
                //检测错误间隙容许值--最小
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙容许值最小','4.0','20.0','0.0','0.1','4.0','']);
                //检测错误间隙容许值--最大
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙容许值最大','10.0','20.0','0.0','0.1','10.0','']);
                /***************************************************焊接规范限制**********************************************/
                //初层陶衬垫电流前侧
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流前侧','230','500','10','10','230','']);
                //初层陶衬垫电流中间
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流中间','230','500','10','10','230','']);
                //初层陶衬垫电流后侧
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流后侧','230','500','10','10','230','']);
                //初层陶衬垫端部停止时间前（ms）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫端部停止时间前(ms)','400','5000','0','10','400','']);
                //初层陶衬垫端部停止时间后（ms）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫端部停止时间后(ms)','400','5000','0','10','400','']);
                //初层陶衬垫堆高MAX
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫堆高MAX','9.0','20.0','1.0','0.1','9.0','']);
                //初层陶衬垫接近-前
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //初层陶衬垫接近-后
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //初层陶衬垫分开最大摆动宽度
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-前','20.0','100.0','1.0','0.1','20.0','']);
                //初层陶衬垫摆动宽度间隔
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫摆动宽度间隔','100.0','100.0','0.0','0.1','100.0','']);
                //初层陶衬垫分开结束/开始比
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫分开结束/开始比','0.85','10.0','0.10','0.01','0.85','']);
                //初层陶衬垫焊接电压
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫焊接电压','自动设定','50','1','1','自动设定','']);



                //初层电流前侧
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流前侧','300','500','10','10','300','']);
                //初层电流中间
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流中间','300','500','10','10','300','']);
                //初层电流后侧
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流后侧','300','500','10','10','300','']);
                //初层端部停止时间前（ms）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层端部停止时间前(ms)','500','5000','0','10','500','']);
                //初层端部停止时间后（ms）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层端部停止时间后(ms)','500','5000','0','10','500','']);
                //初层堆高MAX
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层堆高MAX','7.0','10.0','1.0','0.1','7.0','']);
                //初层接近-前
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //初层接近-后
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //初层分开最大摆动宽度
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-前','20.0','100.0','1.0','0.1','20.0','']);
                //初层摆动宽度间隔
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层摆动宽度间隔','100.0','100.0','0.0','0.1','100.0','']);
                //初层分开结束/开始比
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层分开结束/开始比','1.00','10.0','0.10','0.01','1.00','']);
                //初层焊接电压
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层焊接电压','自动设定','50','1','1','自动设定','']);

                //第二层电流前侧
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流前侧','290','500','10','10','290','']);
                //第二层电流中间
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流中间','290','500','10','10','290','']);
                //第二层电流后侧
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流后侧','290','500','10','10','290','']);
                //第二层端部停止时间前（ms）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层端部停止时间前(ms)','100','5000','0','10','100','']);
                //第二层端部停止时间后（ms）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层端部停止时间后(ms)','100','5000','0','10','100','']);
                //第二层堆高MAX
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层堆高MAX','5.0','10.0','1.0','0.1','5.0','']);
                //第二层接近-前
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //第二层接近-后
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //第二层分开最大摆动宽度
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-前','16.0','100.0','1.0','0.1','16.0','']);
                //第二层摆动宽度间隔
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //第二层分开结束/开始比
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层分开结束/开始比','0.85','10.0','0.10','0.01','0.85','']);
                //第二层焊接电压
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层焊接电压','自动设定','50','1','1','自动设定','']);


                //中间层电流前侧
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流前侧','290','500','10','10','290','']);
                //中间层电流中间
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流中间','290','500','10','10','290','']);
                //中间层电流后侧
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流后侧','290','500','10','10','290','']);
                //中间层端部停止时间前（ms）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层端部停止时间前(ms)','50','5000','0','10','50','']);
                //中间层端部停止时间后（ms）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层端部停止时间后(ms)','50','5000','0','10','50','']);
                //中间层堆高MAX
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层堆高MAX','4.0','10.0','1.0','0.1','4.0','']);
                //中间层接近-前
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //中间层接近-后
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //中间层分开最大摆动宽度
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-前','14.0','100.0','1.0','0.1','14.0','']);
                //中间层摆动宽度间隔
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //中间层分开结束/开始比
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //中间层焊接电压
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层焊接电压','自动设定','50','1','1','自动设定','']);

                //表面层电流前侧
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流前侧','280','500','10','10','280','']);
                //表面层电流中间
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流中间','280','500','10','10','280','']);
                //表面层电流后侧
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流后侧','280','500','10','10','280','']);
                //表面层端部停止时间前（ms）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层端部停止时间前(ms)','0','5000','0','10','0','']);
                //表面层端部停止时间后（ms）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层端部停止时间后(ms)','0','5000','0','10','0','']);
                //表面层堆高MAX
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层堆高MAX','4.0','10.0','1.0','0.1','4.0','']);
                //表面层接近-前
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //表面层接近-后
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //表面层分开最大摆动宽度
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-前','11.0','100.0','1.0','0.1','11.0','']);
                //表面层摆动宽度间隔
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //表面层分开结束/开始比
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //表面层焊接电压
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层焊接电压','自动设定','50','1','1','自动设定','']);

                //表面层余高层数
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层余高层数','0.0','10.0','0.0','1.00','0.00','']);
                //表面层分开方向
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层分开方向','反方向','标准/反方向','标准','','反方向','']);
                //表面层起弧位置
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层起弧位置','收弧位置','坐标/收弧位置','坐标','','收弧位置','']);
                //开始位置坐标X（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标X(mm)','4.0','-50.0','50.0','1.00','4.0','']);
                //开始位置坐标Y（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标Y(mm)','0.0','-50.0','50.0','1.00','0.0','']);
                //开始位置坐标z（mm）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标Z(mm)','-3.0','-50.0','50.0','1.00','-3.0','']);
                //表面层收弧动作
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层收弧动作','单程','往返/单程','往返','','单程','']);
                //表面层返回步骤距离
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层返回步骤距离','5.0','100.0','0.1','1.0','5.0','']);


                //立板余高层电流前侧
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流前侧','250','500','10','10','250','']);
                //立板余高层电流中间
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流中间','250','500','10','10','250','']);
                //立板余高层电流后侧
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流后侧','250','500','10','10','250','']);
                //立板余高层端部停止时间前（ms）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层端部停止时间前(ms)','0','5000','0','10','0','']);
                //立板余高层端部停止时间后（ms）
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层端部停止时间后(ms)','0','5000','0','10','0','']);
                //立板余高层堆高MAX
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层堆高MAX','5.0','10.0','1.0','0.1','5.0','']);
                //立板余高层接近-前
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //立板余高层接近-后
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-后','15.0','100.0','-50.0','0.1','15.0','']);
                //立板余高层分开最大摆动宽度
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-前','10.0','100.0','1.0','0.1','10.0','']);
                //立板余高层摆动宽度间隔
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //立板余高层分开结束/开始比
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //立板余高层焊接电压
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层焊接电压','自动设定','50','1','1','自动设定','']);
                //立板余高层MAX焊接速度
                tx.executeSql('insert into HorizontalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层MAX焊接速度','500.0','5000.0','0.0','10.0','500','']);

                /***************************************************焊接规范列表**********************************************/

            }
            tx.executeSql('CREATE TABLE IF NOT EXISTS VerticalWeldSingleBevelGrooveT(mode TEXT,function TEXT,\
                                                setvalue TEXT,max TEXT,min TEXT,step TEXT,init TEXT,decription TEXT)');
            table = tx.executeSql("select * from VerticalWeldSingleBevelGrooveT");
            if(table.rows.length === 0)
            {
                //console.log("VerticalWeldSingleBevelGrooveT is not exists");
                //坡口参数初始值设置
                /**********************************************示教模式*************************************************/
                //示教模式
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','示教模式','自动','自动','手动','半自动','自动','示教模式']);
                //始终端检测
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','始终端检测','自动','自动','手动','','自动','设定终端的检测是自动或是手动']);
                //示教第1点位置
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','示教第1点位置','右方','右方','左方','','右方','设定第一点从左右哪边开始']);
                //示教1点时焊接长（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','示教1点时焊接长(mm)','300','10000','10','2','300','示教点数为1点时,设定至第二点的焊接']);
                //板厚（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['4','板厚(mm)','测定','200','8','0.1','测定','背部使用陶瓷衬垫或者不能导电时,必须设定板厚']);
                //余高（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['4','余高(mm)','1','20','-20','0.1','1','设定从板面堆起高度']);
                //坡口检测点左（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['4','坡口检测点左(mm)','-10','1000','-1000','1','-10','']);
                //坡口检测点右（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['4','坡口检测点右(mm)','-10','1000','-1000','1','-10','']);
                //板厚补正（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['2','板厚补正(mm)','0','200','-200','1','0','设定是否根据检测的板厚补正条件']);
                //角度补正（度）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['2','角度补正(度)','0','90','-90','1','0','设定是否根据检测的角度补正条件']);
                //间隙补正（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['2','间隙补正(mm)','0','200','-200','1','0','设定是否根据检测的间隙补正条件']);
                /*******************************************坡口设置*****************************************************/
                //焊接始终端偏左（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊接始终端偏左(mm)','0','1000','-1000','0.1','0','']);
                //焊接始终端偏右（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊接始终端偏右(mm)','0','1000','-1000','0.1','0','']);
                //示教点数
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','示教点数','2','30','1','1','1','']);
                //X左梯形平移（度）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','X左梯形平移(度)','0','90','-90','1','1','']);
                //X右梯形平移（度）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','X右梯形平移(度)','0','90','-90','1','1','']);
                //Y左梯形平移（度）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','Y左梯形平移(度)','0','90','-90','1','1','']);
                //Y右梯形平移（度）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','Y右梯形平移(度)','0','90','-90','1','1','']);
                //头部摆动
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','头部摆动','无','左右','无','','无','']);
                //溶敷系数
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','溶敷系数','1.00','1.5','0.5','0.01','1','']);
                //机器人设置面
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','机器人设置面','床','床','壁','','床','']);
                //焊接动作（往返/单程）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊接动作(往返/单程)','单程','单程','往返','','单程','']);
                //焊接电流偏置（A）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊接电流偏置(A)','5','100','-100','5','0','']);
                //焊接电压偏置（V）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊接电压偏置(V)','0','10','-10','1','0','']);
                //电弧跟踪
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','电弧跟踪','关闭','关闭','打开','','打开','']);
                //焊缝背面成型
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊缝背面成型','有','无','有','','无','']);
                //连续焊接时间
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','连续焊接时间','10','999','10','1','10','']);
                //连续焊接层数
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','连续焊接层数','4','99','1','1','4','']);
                //层间停止时间（秒）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','层间停止时间(秒)','5','3600','5','1','5','']);
                //最终层前停止时间（秒）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','最终层前停止时间(秒)','永久','3600','5','1','永久','']);
                //表面锥度非对应机能
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','表面锥度非对应机能','关闭','关闭','打开','','关闭','']);
                //电弧跟踪控制纠正量（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','电弧跟踪控制纠正量(mm)','0.50','10.00','0.00','0.01','0.50','']);
                //焊丝焊缝检测机能
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝焊缝检测机能','关闭','关闭','打开','','关闭','']);
                //焊丝长度（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝长度(mm)','25','50','0','1','25','']);
                //保护气体
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','保护气体','二氧化碳','二氧化碳','气体三','气体二','二氧化碳','']);
                //焊丝
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝','实芯','实芯','药芯','','实芯','']);
                //焊丝直径
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝直径','1.2','1.2','1.6','','1.6','']);
                //初层（陶瓷衬垫）-间隔
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','初层(陶瓷衬垫)-间隔','3.0','10.0','1.0','0.1','3.0','']);
                //初层（钢衬垫）-间隔
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','初层(钢瓷衬垫)-间隔','4.0','10.0','1.0','0.1','4.0','']);
                //初层以外-间隔
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['255','初层以外-间隔','5.0','10.0','1.0','0.1','5.0','']);
                /*
                      *  A= 30~40       A=45~60
                      *  T=9~80mm   T=9~50mm
                      *  B=4~10mm   B=0~2mm
                      */
                //板厚T1
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['254','板厚T1(mm)','34','','','0.1','','']);
                //脚长L
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['254','脚长L(mm)','10','','','0.1','','']);
                //余高Tm
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['254','余高Tm(mm)','1','','','0.1','','']);
                //角度θ1
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['254','角1(度)','34','','','','','']);
                //角度θ1
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['254','角2(度)','45','','','0.1','','']);
                //间隙b
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['254','间隙b(mm)','0','','','0.1','','']);
                /********************************************错误检测*********************************************/
                //板面高
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','板面高','5.0','100.0','-100.0','1.0','5.0','']);
                //板面下降量
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','板面下降量','6.0','100.0','-100.0','1.0','6.0','']);
                //坡口检测上高
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','坡口检测上高','2.0','100.0','-100.0','1.0','2.0','']);
                //坡口检测下高
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','坡口检测下高','3.0','100.0','-100.0','1.0','3.0','']);
                //底面检测时立板距离
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','底面检测时立板距离','2.0','50.0','-50.0','0.1','2.0','']);
                //检测错误板厚左右差--最小
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚左右差最小','4.0','10.0','0.0','0.1','4.0','']);
                //检测错误板厚左右差--最大
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚左右差最大','7.0','10.0','0.0','0.1','7.0','']);
                //检测错误板厚容许值--最小
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚容许值最小','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚容许值--最大
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚容许值最大','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差左右差--最小
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差左右差最小','4.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差左右差--最大
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差左右差最大','7.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差容许值--最小
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差容许值最小','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差容许值--最大
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差容许值最大','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误角度左右差--最小
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度左右差最小','5.0','10.0','0.0','0.1','5.0','']);
                //检测错误角度左右差--最大
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度左右差最大','10.0','10.0','0.0','0.1','10.0','']);
                //检测错误角度容许值--最小
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度容许值最小','28.0','90.0','0.0','0.1','28.0','']);
                //检测错误角度容许值--最大
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度容许值最大','65.0','90.0','0.0','0.1','65.0','']);
                //检测错误间隙左右差--最小
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙左右差最小','6.0','10.0','0.0','0.1','6.0','']);
                //检测错误间隙左右差--最大
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙左右差最大','12.0','10.0','0.0','0.1','12.0','']);
                //检测错误间隙容许值--最小
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙容许值最小','4.0','20.0','0.0','0.1','4.0','']);
                //检测错误间隙容许值--最大
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙容许值最大','10.0','20.0','0.0','0.1','10.0','']);
                /***************************************************焊接规范限制**********************************************/
                //初层陶衬垫电流前侧
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流前侧','230','500','10','10','230','']);
                //初层陶衬垫电流中间
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流中间','230','500','10','10','230','']);
                //初层陶衬垫电流后侧
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流后侧','230','500','10','10','230','']);
                //初层陶衬垫端部停止时间前（ms）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫端部停止时间前(ms)','400','5000','0','10','400','']);
                //初层陶衬垫端部停止时间后（ms）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫端部停止时间后(ms)','400','5000','0','10','400','']);
                //初层陶衬垫堆高MAX
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫堆高MAX','9.0','20.0','1.0','0.1','9.0','']);
                //初层陶衬垫接近-前
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //初层陶衬垫接近-后
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //初层陶衬垫分开最大摆动宽度
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-前','20.0','100.0','1.0','0.1','20.0','']);
                //初层陶衬垫摆动宽度间隔
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫摆动宽度间隔','100.0','100.0','0.0','0.1','100.0','']);
                //初层陶衬垫分开结束/开始比
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫分开结束/开始比','0.85','10.0','0.10','0.01','0.85','']);
                //初层陶衬垫焊接电压
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫焊接电压','自动设定','50','1','1','自动设定','']);



                //初层电流前侧
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流前侧','300','500','10','10','300','']);
                //初层电流中间
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流中间','300','500','10','10','300','']);
                //初层电流后侧
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流后侧','300','500','10','10','300','']);
                //初层端部停止时间前（ms）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层端部停止时间前(ms)','500','5000','0','10','500','']);
                //初层端部停止时间后（ms）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层端部停止时间后(ms)','500','5000','0','10','500','']);
                //初层堆高MAX
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层堆高MAX','7.0','10.0','1.0','0.1','7.0','']);
                //初层接近-前
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //初层接近-后
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //初层分开最大摆动宽度
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-前','20.0','100.0','1.0','0.1','20.0','']);
                //初层摆动宽度间隔
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层摆动宽度间隔','100.0','100.0','0.0','0.1','100.0','']);
                //初层分开结束/开始比
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层分开结束/开始比','1.00','10.0','0.10','0.01','1.00','']);
                //初层焊接电压
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','初层焊接电压','自动设定','50','1','1','自动设定','']);

                //第二层电流前侧
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流前侧','290','500','10','10','290','']);
                //第二层电流中间
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流中间','290','500','10','10','290','']);
                //第二层电流后侧
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流后侧','290','500','10','10','290','']);
                //第二层端部停止时间前（ms）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层端部停止时间前(ms)','100','5000','0','10','100','']);
                //第二层端部停止时间后（ms）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层端部停止时间后(ms)','100','5000','0','10','100','']);
                //第二层堆高MAX
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层堆高MAX','5.0','10.0','1.0','0.1','5.0','']);
                //第二层接近-前
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //第二层接近-后
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //第二层分开最大摆动宽度
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-前','16.0','100.0','1.0','0.1','16.0','']);
                //第二层摆动宽度间隔
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //第二层分开结束/开始比
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层分开结束/开始比','0.85','10.0','0.10','0.01','0.85','']);
                //第二层焊接电压
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','第二层焊接电压','自动设定','50','1','1','自动设定','']);


                //中间层电流前侧
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流前侧','290','500','10','10','290','']);
                //中间层电流中间
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流中间','290','500','10','10','290','']);
                //中间层电流后侧
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流后侧','290','500','10','10','290','']);
                //中间层端部停止时间前（ms）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层端部停止时间前(ms)','50','5000','0','10','50','']);
                //中间层端部停止时间后（ms）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层端部停止时间后(ms)','50','5000','0','10','50','']);
                //中间层堆高MAX
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层堆高MAX','4.0','10.0','1.0','0.1','4.0','']);
                //中间层接近-前
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //中间层接近-后
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //中间层分开最大摆动宽度
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-前','14.0','100.0','1.0','0.1','14.0','']);
                //中间层摆动宽度间隔
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //中间层分开结束/开始比
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //中间层焊接电压
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','中间层焊接电压','自动设定','50','1','1','自动设定','']);

                //表面层电流前侧
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流前侧','280','500','10','10','280','']);
                //表面层电流中间
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流中间','280','500','10','10','280','']);
                //表面层电流后侧
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流后侧','280','500','10','10','280','']);
                //表面层端部停止时间前（ms）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层端部停止时间前(ms)','0','5000','0','10','0','']);
                //表面层端部停止时间后（ms）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层端部停止时间后(ms)','0','5000','0','10','0','']);
                //表面层堆高MAX
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层堆高MAX','4.0','10.0','1.0','0.1','4.0','']);
                //表面层接近-前
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //表面层接近-后
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //表面层分开最大摆动宽度
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-前','11.0','100.0','1.0','0.1','11.0','']);
                //表面层摆动宽度间隔
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //表面层分开结束/开始比
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //表面层焊接电压
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层焊接电压','自动设定','50','1','1','自动设定','']);

                //表面层余高层数
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层余高层数','0.0','10.0','0.0','1.00','0.00','']);
                //表面层分开方向
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层分开方向','反方向','标准/反方向','标准','','反方向','']);
                //表面层起弧位置
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层起弧位置','收弧位置','坐标/收弧位置','坐标','','收弧位置','']);
                //开始位置坐标X（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标X(mm)','4.0','-50.0','50.0','1.00','4.0','']);
                //开始位置坐标Y（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标Y(mm)','0.0','-50.0','50.0','1.00','0.0','']);
                //开始位置坐标z（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标Z(mm)','-3.0','-50.0','50.0','1.00','-3.0','']);
                //表面层收弧动作
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层收弧动作','单程','往返/单程','往返','','单程','']);
                //表面层返回步骤距离
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','表面层返回步骤距离','5.0','100.0','0.1','1.0','5.0','']);


                //立板余高层电流前侧
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流前侧','250','500','10','10','250','']);
                //立板余高层电流中间
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流中间','250','500','10','10','250','']);
                //立板余高层电流后侧
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流后侧','250','500','10','10','250','']);
                //立板余高层端部停止时间前（ms）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层端部停止时间前(ms)','0','5000','0','10','0','']);
                //立板余高层端部停止时间后（ms）
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层端部停止时间后(ms)','0','5000','0','10','0','']);
                //立板余高层堆高MAX
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层堆高MAX','5.0','10.0','1.0','0.1','5.0','']);
                //立板余高层接近-前
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //立板余高层接近-后
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-后','15.0','100.0','-50.0','0.1','15.0','']);
                //立板余高层分开最大摆动宽度
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-前','10.0','100.0','1.0','0.1','10.0','']);
                //立板余高层摆动宽度间隔
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //立板余高层分开结束/开始比
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //立板余高层焊接电压
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层焊接电压','自动设定','50','1','1','自动设定','']);
                //立板余高层MAX焊接速度
                tx.executeSql('insert into VerticalWeldSingleBevelGrooveT values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层MAX焊接速度','500.0','5000.0','0.0','10.0','500','']);

                /***************************************************焊接规范列表**********************************************/

            }

            tx.executeSql('CREATE TABLE IF NOT EXISTS VerticalWeldSingleBevelGroove(mode TEXT,function TEXT,\
                                                setvalue TEXT,max TEXT,min TEXT,step TEXT,init TEXT,decription TEXT)');
            table = tx.executeSql("select * from VerticalWeldSingleBevelGroove");
            if(table.rows.length === 0)
            {
                //console.log("VerticalWeldSingleBevelGroove is not exists");
                //坡口参数初始值设置
                /**********************************************示教模式*************************************************/
                //示教模式
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','示教模式','自动','自动','手动','半自动','自动','示教模式']);
                //始终端检测
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','始终端检测','自动','自动','手动','','自动','设定终端的检测是自动或是手动']);
                //示教第1点位置
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','示教第1点位置','右方','右方','左方','','右方','设定第一点从左右哪边开始']);
                //示教1点时焊接长（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','示教1点时焊接长(mm)','300','10000','10','2','300','示教点数为1点时,设定至第二点的焊接']);
                //板厚（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['4','板厚(mm)','测定','200','8','0.1','测定','背部使用陶瓷衬垫或者不能导电时,必须设定板厚']);
                //余高（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['4','余高(mm)','1','20','-20','0.1','1','设定从板面堆起高度']);
                //坡口检测点左（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['4','坡口检测点左(mm)','-10','1000','-1000','1','-10','']);
                //坡口检测点右（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['4','坡口检测点右(mm)','-10','1000','-1000','1','-10','']);
                //板厚补正（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['2','板厚补正(mm)','0','200','-200','1','0','设定是否根据检测的板厚补正条件']);
                //角度补正（度）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['2','角度补正(度)','0','90','-90','1','0','设定是否根据检测的角度补正条件']);
                //间隙补正（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['2','间隙补正(mm)','0','200','-200','1','0','设定是否根据检测的间隙补正条件']);
                /*******************************************坡口设置*****************************************************/
                //焊接始终端偏左（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接始终端偏左(mm)','0','1000','-1000','0.1','0','']);
                //焊接始终端偏右（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接始终端偏右(mm)','0','1000','-1000','0.1','0','']);
                //示教点数
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','示教点数','2','30','1','1','1','']);
                //X左梯形平移（度）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','X左梯形平移(度)','0','90','-90','1','1','']);
                //X右梯形平移（度）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','X右梯形平移(度)','0','90','-90','1','1','']);
                //Y左梯形平移（度）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','Y左梯形平移(度)','0','90','-90','1','1','']);
                //Y右梯形平移（度）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','Y右梯形平移(度)','0','90','-90','1','1','']);
                //头部摆动
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','头部摆动','无','左右','无','','无','']);
                //溶敷系数
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','溶敷系数','1.00','1.5','0.5','0.01','1','']);
                //机器人设置面
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','机器人设置面','床','床','壁','','床','']);
                //焊接动作（往返/单程）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接动作(往返/单程)','单程','单程','往返','','单程','']);
                //焊接电流偏置（A）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接电流偏置(A)','5','100','-100','5','0','']);
                //焊接电压偏置（V）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接电压偏置(V)','0','10','-10','1','0','']);
                //电弧跟踪
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','电弧跟踪','关闭','关闭','打开','','打开','']);
                //焊缝背面成型
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊缝背面成型','有','无','有','','无','']);
                //连续焊接时间
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','连续焊接时间','10','999','10','1','10','']);
                //连续焊接层数
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','连续焊接层数','4','99','1','1','4','']);
                //层间停止时间（秒）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','层间停止时间(秒)','5','3600','5','1','5','']);
                //最终层前停止时间（秒）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','最终层前停止时间(秒)','永久','3600','5','1','永久','']);
                //表面锥度非对应机能
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','表面锥度非对应机能','关闭','关闭','打开','','关闭','']);
                //电弧跟踪控制纠正量（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','电弧跟踪控制纠正量(mm)','0.50','10.00','0.00','0.01','0.50','']);
                //焊丝焊缝检测机能
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝焊缝检测机能','关闭','关闭','打开','','关闭','']);
                //焊丝长度（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝长度(mm)','25','50','0','1','25','']);
                //保护气体
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','保护气体','二氧化碳','二氧化碳','气体三','气体二','二氧化碳','']);
                //焊丝
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝','实芯','实芯','药芯','','实芯','']);
                //焊丝直径
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝直径','1.2','1.2','1.6','','1.6','']);
                //初层（陶瓷衬垫）-间隔
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','初层(陶瓷衬垫)-间隔','3.0','10.0','1.0','0.1','3.0','']);
                //初层（钢衬垫）-间隔
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','初层(钢瓷衬垫)-间隔','4.0','10.0','1.0','0.1','4.0','']);
                //初层以外-间隔
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['255','初层以外-间隔','5.0','10.0','1.0','0.1','5.0','']);
                /*
                      *  A= 30~40       A=45~60
                      *  T=9~80mm   T=9~50mm
                      *  B=4~10mm   B=0~2mm
                      */
                //板厚T1
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['254','板厚T1(mm)','34','','','0.1','','']);
                //脚长L
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['254','脚长L(mm)','10','','','0.1','','']);
                //余高Tm
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['254','余高Tm(mm)','1','','','0.1','','']);
                //角度θ1
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['254','角1(度)','34','','','','','']);
                //角度θ1
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['254','角2(度)','45','','','0.1','','']);
                //间隙b
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['254','间隙b(mm)','0','','','0.1','','']);
                /********************************************错误检测*********************************************/
                //板面高
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','板面高','5.0','100.0','-100.0','1.0','5.0','']);
                //板面下降量
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','板面下降量','6.0','100.0','-100.0','1.0','6.0','']);
                //坡口检测上高
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','坡口检测上高','2.0','100.0','-100.0','1.0','2.0','']);
                //坡口检测下高
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','坡口检测下高','3.0','100.0','-100.0','1.0','3.0','']);
                //底面检测时立板距离
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','底面检测时立板距离','2.0','50.0','-50.0','0.1','2.0','']);
                //检测错误板厚左右差--最小
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚左右差最小','4.0','10.0','0.0','0.1','4.0','']);
                //检测错误板厚左右差--最大
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚左右差最大','7.0','10.0','0.0','0.1','7.0','']);
                //检测错误板厚容许值--最小
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚容许值最小','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚容许值--最大
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚容许值最大','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差左右差--最小
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差左右差最小','4.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差左右差--最大
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差左右差最大','7.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差容许值--最小
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差容许值最小','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差容许值--最大
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差容许值最大','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误角度左右差--最小
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度左右差最小','5.0','10.0','0.0','0.1','5.0','']);
                //检测错误角度左右差--最大
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度左右差最大','10.0','10.0','0.0','0.1','10.0','']);
                //检测错误角度容许值--最小
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度容许值最小','28.0','90.0','0.0','0.1','28.0','']);
                //检测错误角度容许值--最大
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度容许值最大','65.0','90.0','0.0','0.1','65.0','']);
                //检测错误间隙左右差--最小
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙左右差最小','6.0','10.0','0.0','0.1','6.0','']);
                //检测错误间隙左右差--最大
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙左右差最大','12.0','10.0','0.0','0.1','12.0','']);
                //检测错误间隙容许值--最小
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙容许值最小','4.0','20.0','0.0','0.1','4.0','']);
                //检测错误间隙容许值--最大
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙容许值最大','10.0','20.0','0.0','0.1','10.0','']);
                /***************************************************焊接规范限制**********************************************/
                //初层陶衬垫电流前侧
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流前侧','230','500','10','10','230','']);
                //初层陶衬垫电流中间
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流中间','230','500','10','10','230','']);
                //初层陶衬垫电流后侧
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流后侧','230','500','10','10','230','']);
                //初层陶衬垫端部停止时间前（ms）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫端部停止时间前(ms)','400','5000','0','10','400','']);
                //初层陶衬垫端部停止时间后（ms）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫端部停止时间后(ms)','400','5000','0','10','400','']);
                //初层陶衬垫堆高MAX
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫堆高MAX','9.0','20.0','1.0','0.1','9.0','']);
                //初层陶衬垫接近-前
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //初层陶衬垫接近-后
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //初层陶衬垫分开最大摆动宽度
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-前','20.0','100.0','1.0','0.1','20.0','']);
                //初层陶衬垫摆动宽度间隔
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫摆动宽度间隔','100.0','100.0','0.0','0.1','100.0','']);
                //初层陶衬垫分开结束/开始比
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫分开结束/开始比','0.85','10.0','0.10','0.01','0.85','']);
                //初层陶衬垫焊接电压
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫焊接电压','自动设定','50','1','1','自动设定','']);



                //初层电流前侧
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流前侧','300','500','10','10','300','']);
                //初层电流中间
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流中间','300','500','10','10','300','']);
                //初层电流后侧
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流后侧','300','500','10','10','300','']);
                //初层端部停止时间前（ms）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层端部停止时间前(ms)','500','5000','0','10','500','']);
                //初层端部停止时间后（ms）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层端部停止时间后(ms)','500','5000','0','10','500','']);
                //初层堆高MAX
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层堆高MAX','7.0','10.0','1.0','0.1','7.0','']);
                //初层接近-前
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //初层接近-后
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //初层分开最大摆动宽度
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-前','20.0','100.0','1.0','0.1','20.0','']);
                //初层摆动宽度间隔
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层摆动宽度间隔','100.0','100.0','0.0','0.1','100.0','']);
                //初层分开结束/开始比
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层分开结束/开始比','1.00','10.0','0.10','0.01','1.00','']);
                //初层焊接电压
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层焊接电压','自动设定','50','1','1','自动设定','']);

                //第二层电流前侧
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流前侧','290','500','10','10','290','']);
                //第二层电流中间
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流中间','290','500','10','10','290','']);
                //第二层电流后侧
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流后侧','290','500','10','10','290','']);
                //第二层端部停止时间前（ms）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层端部停止时间前(ms)','100','5000','0','10','100','']);
                //第二层端部停止时间后（ms）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层端部停止时间后(ms)','100','5000','0','10','100','']);
                //第二层堆高MAX
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层堆高MAX','5.0','10.0','1.0','0.1','5.0','']);
                //第二层接近-前
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //第二层接近-后
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //第二层分开最大摆动宽度
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-前','16.0','100.0','1.0','0.1','16.0','']);
                //第二层摆动宽度间隔
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //第二层分开结束/开始比
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层分开结束/开始比','0.85','10.0','0.10','0.01','0.85','']);
                //第二层焊接电压
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层焊接电压','自动设定','50','1','1','自动设定','']);


                //中间层电流前侧
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流前侧','290','500','10','10','290','']);
                //中间层电流中间
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流中间','290','500','10','10','290','']);
                //中间层电流后侧
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流后侧','290','500','10','10','290','']);
                //中间层端部停止时间前（ms）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层端部停止时间前(ms)','50','5000','0','10','50','']);
                //中间层端部停止时间后（ms）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层端部停止时间后(ms)','50','5000','0','10','50','']);
                //中间层堆高MAX
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层堆高MAX','4.0','10.0','1.0','0.1','4.0','']);
                //中间层接近-前
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //中间层接近-后
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //中间层分开最大摆动宽度
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-前','14.0','100.0','1.0','0.1','14.0','']);
                //中间层摆动宽度间隔
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //中间层分开结束/开始比
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //中间层焊接电压
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层焊接电压','自动设定','50','1','1','自动设定','']);

                //表面层电流前侧
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流前侧','280','500','10','10','280','']);
                //表面层电流中间
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流中间','280','500','10','10','280','']);
                //表面层电流后侧
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流后侧','280','500','10','10','280','']);
                //表面层端部停止时间前（ms）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层端部停止时间前(ms)','0','5000','0','10','0','']);
                //表面层端部停止时间后（ms）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层端部停止时间后(ms)','0','5000','0','10','0','']);
                //表面层堆高MAX
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层堆高MAX','4.0','10.0','1.0','0.1','4.0','']);
                //表面层接近-前
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //表面层接近-后
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //表面层分开最大摆动宽度
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-前','11.0','100.0','1.0','0.1','11.0','']);
                //表面层摆动宽度间隔
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //表面层分开结束/开始比
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //表面层焊接电压
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层焊接电压','自动设定','50','1','1','自动设定','']);

                //表面层余高层数
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层余高层数','0.0','10.0','0.0','1.00','0.00','']);
                //表面层分开方向
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层分开方向','反方向','标准/反方向','标准','','反方向','']);
                //表面层起弧位置
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层起弧位置','收弧位置','坐标/收弧位置','坐标','','收弧位置','']);
                //开始位置坐标X（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标X(mm)','4.0','-50.0','50.0','1.00','4.0','']);
                //开始位置坐标Y（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标Y(mm)','0.0','-50.0','50.0','1.00','0.0','']);
                //开始位置坐标z（mm）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标Z(mm)','-3.0','-50.0','50.0','1.00','-3.0','']);
                //表面层收弧动作
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层收弧动作','单程','往返/单程','往返','','单程','']);
                //表面层返回步骤距离
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层返回步骤距离','5.0','100.0','0.1','1.0','5.0','']);


                //立板余高层电流前侧
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流前侧','250','500','10','10','250','']);
                //立板余高层电流中间
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流中间','250','500','10','10','250','']);
                //立板余高层电流后侧
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流后侧','250','500','10','10','250','']);
                //立板余高层端部停止时间前（ms）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层端部停止时间前(ms)','0','5000','0','10','0','']);
                //立板余高层端部停止时间后（ms）
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层端部停止时间后(ms)','0','5000','0','10','0','']);
                //立板余高层堆高MAX
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层堆高MAX','5.0','10.0','1.0','0.1','5.0','']);
                //立板余高层接近-前
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //立板余高层接近-后
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-后','15.0','100.0','-50.0','0.1','15.0','']);
                //立板余高层分开最大摆动宽度
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-前','10.0','100.0','1.0','0.1','10.0','']);
                //立板余高层摆动宽度间隔
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //立板余高层分开结束/开始比
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //立板余高层焊接电压
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层焊接电压','自动设定','50','1','1','自动设定','']);
                //立板余高层MAX焊接速度
                tx.executeSql('insert into VerticalWeldSingleBevelGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层MAX焊接速度','500.0','5000.0','0.0','10.0','500','']);

                /***************************************************焊接规范列表**********************************************/

            }
            tx.executeSql('CREATE TABLE IF NOT EXISTS VerticalWeldVGroove(mode TEXT,function TEXT,\
                                                setvalue TEXT,max TEXT,min TEXT,step TEXT,init TEXT,decription TEXT)');
            table = tx.executeSql("select * from VerticalWeldVGroove");
            if(table.rows.length === 0)
            {
                //console.log("VerticalWeldVGroove is not exists");
                //坡口参数初始值设置
                /**********************************************示教模式*************************************************/
                //示教模式
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','示教模式','自动','自动','手动','半自动','自动','示教模式']);
                //始终端检测
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','始终端检测','自动','自动','手动','','自动','设定终端的检测是自动或是手动']);
                //示教第1点位置
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','示教第1点位置','右方','右方','左方','','右方','设定第一点从左右哪边开始']);
                //示教1点时焊接长（mm）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','示教1点时焊接长(mm)','300','10000','10','2','300','示教点数为1点时,设定至第二点的焊接']);
                //板厚（mm）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['4','板厚(mm)','测定','200','8','0.1','测定','背部使用陶瓷衬垫或者不能导电时,必须设定板厚']);
                //余高（mm）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['4','余高(mm)','1','20','-20','0.1','1','设定从板面堆起高度']);
                //坡口检测点左（mm）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['4','坡口检测点左(mm)','-10','1000','-1000','1','-10','']);
                //坡口检测点右（mm）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['4','坡口检测点右(mm)','-10','1000','-1000','1','-10','']);
                //板厚补正（mm）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['2','板厚补正(mm)','0','200','-200','1','0','设定是否根据检测的板厚补正条件']);
                //角度补正（度）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['2','角度补正(度)','0','90','-90','1','0','设定是否根据检测的角度补正条件']);
                //间隙补正（mm）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['2','间隙补正(mm)','0','200','-200','1','0','设定是否根据检测的间隙补正条件']);
                /*******************************************坡口设置*****************************************************/
                //焊接始终端偏左（mm）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接始终端偏左(mm)','0','1000','-1000','0.1','0','']);
                //焊接始终端偏右（mm）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接始终端偏右(mm)','0','1000','-1000','0.1','0','']);
                //示教点数
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','示教点数','2','30','1','1','1','']);
                //X左梯形平移（度）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','X左梯形平移(度)','0','90','-90','1','1','']);
                //X右梯形平移（度）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','X右梯形平移(度)','0','90','-90','1','1','']);
                //Y左梯形平移（度）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','Y左梯形平移(度)','0','90','-90','1','1','']);
                //Y右梯形平移（度）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','Y右梯形平移(度)','0','90','-90','1','1','']);
                //头部摆动
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','头部摆动','无','左右','无','','无','']);
                //溶敷系数
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','溶敷系数','1.00','1.5','0.5','0.01','1','']);
                //机器人设置面
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','机器人设置面','床','床','壁','','床','']);
                //焊接动作（往返/单程）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接动作(往返/单程)','单程','单程','往返','','单程','']);
                //焊接电流偏置（A）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接电流偏置(A)','5','100','-100','5','0','']);
                //焊接电压偏置（V）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊接电压偏置(V)','0','10','-10','1','0','']);
                //电弧跟踪
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','电弧跟踪','关闭','关闭','打开','','打开','']);
                //焊缝背面成型
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊缝背面成型','有','无','有','','无','']);
                //连续焊接时间
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','连续焊接时间','10','999','10','1','10','']);
                //连续焊接层数
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','连续焊接层数','4','99','1','1','4','']);
                //层间停止时间（秒）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','层间停止时间(秒)','5','3600','5','1','5','']);
                //最终层前停止时间（秒）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','最终层前停止时间(秒)','永久','3600','5','1','永久','']);
                //表面锥度非对应机能
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','表面锥度非对应机能','关闭','关闭','打开','','关闭','']);
                //电弧跟踪控制纠正量（mm）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','电弧跟踪控制纠正量(mm)','0.50','10.00','0.00','0.01','0.50','']);
                //焊丝焊缝检测机能
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝焊缝检测机能','关闭','关闭','打开','','关闭','']);
                //焊丝长度（mm）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝长度(mm)','25','50','0','1','25','']);
                //保护气体
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','保护气体','二氧化碳','二氧化碳','气体三','气体二','二氧化碳','']);
                //焊丝
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝','实芯','实芯','药芯','','实芯','']);
                //焊丝直径
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','焊丝直径','1.2','1.2','1.6','','1.6','']);
                //初层（陶瓷衬垫）-间隔
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','初层(陶瓷衬垫)-间隔','3.0','10.0','1.0','0.1','3.0','']);
                //初层（钢衬垫）-间隔
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','初层(钢瓷衬垫)-间隔','4.0','10.0','1.0','0.1','4.0','']);
                //初层以外-间隔
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['255','初层以外-间隔','5.0','10.0','1.0','0.1','5.0','']);
                /*
                      *  A= 30~40       A=45~60
                      *  T=9~80mm   T=9~50mm
                      *  B=4~10mm   B=0~2mm
                      */
                //板厚T1
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['254','板厚T1(mm)','34','','','0.1','','']);
                //脚长L
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['254','脚长L(mm)','10','','','0.1','','']);
                //余高Tm
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['254','余高Tm(mm)','1','','','0.1','','']);
                //角度θ1
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['254','角1(度)','34','','','','','']);
                //角度θ1
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['254','角2(度)','45','','','0.1','','']);
                //间隙b
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['254','间隙b(mm)','0','','','0.1','','']);
                /********************************************错误检测*********************************************/
                //板面高
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','板面高','5.0','100.0','-100.0','1.0','5.0','']);
                //板面下降量
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','板面下降量','6.0','100.0','-100.0','1.0','6.0','']);
                //坡口检测上高
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','坡口检测上高','2.0','100.0','-100.0','1.0','2.0','']);
                //坡口检测下高
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','坡口检测下高','3.0','100.0','-100.0','1.0','3.0','']);
                //底面检测时立板距离
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','底面检测时立板距离','2.0','50.0','-50.0','0.1','2.0','']);
                //检测错误板厚左右差--最小
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚左右差最小','4.0','10.0','0.0','0.1','4.0','']);
                //检测错误板厚左右差--最大
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚左右差最大','7.0','10.0','0.0','0.1','7.0','']);
                //检测错误板厚容许值--最小
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚容许值最小','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚容许值--最大
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚容许值最大','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差左右差--最小
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差左右差最小','4.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差左右差--最大
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差左右差最大','7.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差容许值--最小
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差容许值最小','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误板厚差容许值--最大
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误板厚差容许值最大','0.0','10.0','0.0','0.1','0.0','']);
                //检测错误角度左右差--最小
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度左右差最小','5.0','10.0','0.0','0.1','5.0','']);
                //检测错误角度左右差--最大
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度左右差最大','10.0','10.0','0.0','0.1','10.0','']);
                //检测错误角度容许值--最小
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度容许值最小','28.0','90.0','0.0','0.1','28.0','']);
                //检测错误角度容许值--最大
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误角度容许值最大','65.0','90.0','0.0','0.1','65.0','']);
                //检测错误间隙左右差--最小
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙左右差最小','6.0','10.0','0.0','0.1','6.0','']);
                //检测错误间隙左右差--最大
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙左右差最大','12.0','10.0','0.0','0.1','12.0','']);
                //检测错误间隙容许值--最小
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙容许值最小','4.0','20.0','0.0','0.1','4.0','']);
                //检测错误间隙容许值--最大
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','检测错误间隙容许值最大','10.0','20.0','0.0','0.1','10.0','']);
                /***************************************************焊接规范限制**********************************************/
                //初层陶衬垫电流前侧
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流前侧','230','500','10','10','230','']);
                //初层陶衬垫电流中间
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流中间','230','500','10','10','230','']);
                //初层陶衬垫电流后侧
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫电流后侧','230','500','10','10','230','']);
                //初层陶衬垫端部停止时间前（ms）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫端部停止时间前(ms)','400','5000','0','10','400','']);
                //初层陶衬垫端部停止时间后（ms）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫端部停止时间后(ms)','400','5000','0','10','400','']);
                //初层陶衬垫堆高MAX
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫堆高MAX','9.0','20.0','1.0','0.1','9.0','']);
                //初层陶衬垫接近-前
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //初层陶衬垫接近-后
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //初层陶衬垫分开最大摆动宽度
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫接近-前','20.0','100.0','1.0','0.1','20.0','']);
                //初层陶衬垫摆动宽度间隔
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫摆动宽度间隔','100.0','100.0','0.0','0.1','100.0','']);
                //初层陶衬垫分开结束/开始比
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫分开结束/开始比','0.85','10.0','0.10','0.01','0.85','']);
                //初层陶衬垫焊接电压
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层陶衬垫焊接电压','自动设定','50','1','1','自动设定','']);



                //初层电流前侧
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流前侧','300','500','10','10','300','']);
                //初层电流中间
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流中间','300','500','10','10','300','']);
                //初层电流后侧
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层电流后侧','300','500','10','10','300','']);
                //初层端部停止时间前（ms）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层端部停止时间前(ms)','500','5000','0','10','500','']);
                //初层端部停止时间后（ms）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层端部停止时间后(ms)','500','5000','0','10','500','']);
                //初层堆高MAX
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层堆高MAX','7.0','10.0','1.0','0.1','7.0','']);
                //初层接近-前
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //初层接近-后
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //初层分开最大摆动宽度
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层接近-前','20.0','100.0','1.0','0.1','20.0','']);
                //初层摆动宽度间隔
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层摆动宽度间隔','100.0','100.0','0.0','0.1','100.0','']);
                //初层分开结束/开始比
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层分开结束/开始比','1.00','10.0','0.10','0.01','1.00','']);
                //初层焊接电压
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','初层焊接电压','自动设定','50','1','1','自动设定','']);

                //第二层电流前侧
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流前侧','290','500','10','10','290','']);
                //第二层电流中间
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流中间','290','500','10','10','290','']);
                //第二层电流后侧
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层电流后侧','290','500','10','10','290','']);
                //第二层端部停止时间前（ms）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层端部停止时间前(ms)','100','5000','0','10','100','']);
                //第二层端部停止时间后（ms）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层端部停止时间后(ms)','100','5000','0','10','100','']);
                //第二层堆高MAX
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层堆高MAX','5.0','10.0','1.0','0.1','5.0','']);
                //第二层接近-前
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //第二层接近-后
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //第二层分开最大摆动宽度
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层接近-前','16.0','100.0','1.0','0.1','16.0','']);
                //第二层摆动宽度间隔
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //第二层分开结束/开始比
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层分开结束/开始比','0.85','10.0','0.10','0.01','0.85','']);
                //第二层焊接电压
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','第二层焊接电压','自动设定','50','1','1','自动设定','']);


                //中间层电流前侧
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流前侧','290','500','10','10','290','']);
                //中间层电流中间
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流中间','290','500','10','10','290','']);
                //中间层电流后侧
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层电流后侧','290','500','10','10','290','']);
                //中间层端部停止时间前（ms）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层端部停止时间前(ms)','50','5000','0','10','50','']);
                //中间层端部停止时间后（ms）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层端部停止时间后(ms)','50','5000','0','10','50','']);
                //中间层堆高MAX
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层堆高MAX','4.0','10.0','1.0','0.1','4.0','']);
                //中间层接近-前
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-前','1.0','50.0','-50.0','0.1','1.0','']);
                //中间层接近-后
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //中间层分开最大摆动宽度
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层接近-前','14.0','100.0','1.0','0.1','14.0','']);
                //中间层摆动宽度间隔
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //中间层分开结束/开始比
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //中间层焊接电压
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','中间层焊接电压','自动设定','50','1','1','自动设定','']);

                //表面层电流前侧
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流前侧','280','500','10','10','280','']);
                //表面层电流中间
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流中间','280','500','10','10','280','']);
                //表面层电流后侧
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层电流后侧','280','500','10','10','280','']);
                //表面层端部停止时间前（ms）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层端部停止时间前(ms)','0','5000','0','10','0','']);
                //表面层端部停止时间后（ms）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层端部停止时间后(ms)','0','5000','0','10','0','']);
                //表面层堆高MAX
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层堆高MAX','4.0','10.0','1.0','0.1','4.0','']);
                //表面层接近-前
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //表面层接近-后
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-后','2.0','50.0','-50.0','0.1','2.0','']);
                //表面层分开最大摆动宽度
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层接近-前','11.0','100.0','1.0','0.1','11.0','']);
                //表面层摆动宽度间隔
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //表面层分开结束/开始比
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //表面层焊接电压
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层焊接电压','自动设定','50','1','1','自动设定','']);

                //表面层余高层数
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层余高层数','0.0','10.0','0.0','1.00','0.00','']);
                //表面层分开方向
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层分开方向','反方向','标准/反方向','标准','','反方向','']);
                //表面层起弧位置
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层起弧位置','收弧位置','坐标/收弧位置','坐标','','收弧位置','']);
                //开始位置坐标X（mm）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标X(mm)','4.0','-50.0','50.0','1.00','4.0','']);
                //开始位置坐标Y（mm）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标Y(mm)','0.0','-50.0','50.0','1.00','0.0','']);
                //开始位置坐标z（mm）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','开始位置坐标Z(mm)','-3.0','-50.0','50.0','1.00','-3.0','']);
                //表面层收弧动作
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层收弧动作','单程','往返/单程','往返','','单程','']);
                //表面层返回步骤距离
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','表面层返回步骤距离','5.0','100.0','0.1','1.0','5.0','']);


                //立板余高层电流前侧
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流前侧','250','500','10','10','250','']);
                //立板余高层电流中间
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流中间','250','500','10','10','250','']);
                //立板余高层电流后侧
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层电流后侧','250','500','10','10','250','']);
                //立板余高层端部停止时间前（ms）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层端部停止时间前(ms)','0','5000','0','10','0','']);
                //立板余高层端部停止时间后（ms）
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层端部停止时间后(ms)','0','5000','0','10','0','']);
                //立板余高层堆高MAX
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层堆高MAX','5.0','10.0','1.0','0.1','5.0','']);
                //立板余高层接近-前
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-前','2.0','50.0','-50.0','0.1','2.0','']);
                //立板余高层接近-后
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-后','15.0','100.0','-50.0','0.1','15.0','']);
                //立板余高层分开最大摆动宽度
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层接近-前','10.0','100.0','1.0','0.1','10.0','']);
                //立板余高层摆动宽度间隔
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层摆动宽度间隔','5.0','100.0','0.0','0.1','5.0','']);
                //立板余高层分开结束/开始比
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层分开结束/开始比','1.00','10.0','0.10','0.01','0.85','']);
                //立板余高层焊接电压
                tx.executeSql('insert into VerticalWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层焊接电压','自动设定','50','1','1','自动设定','']);
                //立板余高层MAX焊接速度
                tx.executeSql('insert into FlatWeldVGroove values(?,?,?,?,?,?,?,?)',
                              ['0','立板余高层MAX焊接速度','500.0','5000.0','0.0','10.0','500','']);

                /***************************************************焊接规范列表**********************************************/

            }

            tx.executeSql('CREATE TABLE IF NOT EXISTS AccountTable(name TEXT,password TEXT,type TEXT)');
            table = tx.executeSql("select * from AccountTable");
            if(table.rows.length === 0)
            {
                // console.log("AccountTable is not exists");
                //admin
                tx.executeSql('insert into AccountTable values(?,?,?)',
                              ['Admin','Admin','SuperUser']);
            }
            tx.executeSql('CREATE TABLE IF NOT EXISTS ErrorTable(name TEXT,time TEXT,type TEXT)');
            tx.executeSql('CREATE TABLE IF NOT EXISTS TableRecond(name TEXT,time TEXT,type TEXT)');
            table = tx.executeSql("select * from TableRecond");
        });
        return error;
    }






