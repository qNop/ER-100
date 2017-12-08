#include "MySQL.h"
/*
 * 定义StringList
 *  [0] 代表读写的状态  成功和失败两种
 *  [1] 代表 文件名 写入的文件名，哪个文件写入的返还给哪个文件
 *  [2] 代表 field
 *  [3] 代表 name
 *  [...]仿上述
 *
 *
 * 定义Cmd
 *
 * [0] 代表文件名
 * [..] 代表命令
 *
 *
 *
 * 一种想法 可不可以用文件名区分 而生成不同的信号
 * 1 TeachConditon
 * 2 WeldConditon
 * 3 GrooveTable
 * 4 WeldTable
 * 5 AccountTable
 * 6 ErrorTable(已经没有了)
 * 7 LimitedTable
 * 8 坡口名称+次列表
 * 9 坡口名称+列表
 * 10 检测错误表
 *
 */

SqlThread::SqlThread(){
    pCmdBuf=&cmdBuf;
}
SqlThread::~SqlThread(){
    qDebug()<<"SqlThread::~SqlThread()";
}

int SqlThread::getTableJson(QString tableName,QList<QJsonObject> *pQJson){
    if(tableName!=""){
        QString str="SELECT * FROM "+tableName;
        QSqlQuery query(str); //获取数据库
        QSqlRecord res;
        QJsonObject pJson;
        while (query.next()) {
            res=query.record();//获取记录
            for(int i=0;i<res.count();i++){
                qDebug()<<res.fieldName(i)<<res.field(i).value();
            }
            pQJson->append(pJson);
        }
        return 1;
    }else
        return -1;
}

void SqlThread::run(){
    for(;;){
        //qDebug()<<"SqlThread run";
        if(cmdBuf.count()){//如果存在命令则 执行命令行
            QStringList cmd=cmdBuf.dequeue();
            QList<QJsonObject> qJsonList;
            qJsonList.clear();
            if(cmd[1]=="getTableJson"){
                getTableJson(cmd[0],&qJsonList);
                emit sqlThreadSignal(qJsonList);
            }else{//命令不被支持

            }
        }else{//线程挂起50ms
            msleep(50);
        }
    }
}

MySQL::MySQL(){
    //添加链接
    myDataBases=QSqlDatabase::addDatabase("QSQLITE");
    //myDataBases.setHostName("ER-100");
    //存储位置
    myDataBases.setDatabaseName(qgetenv("HOME")+"/.local/share/TangShanKaiYuanSpecialWeldingEquipmentCo.,Ltd/ER-100/QML/OfflineStorage/Databases/433abb168a2ae7adeaa1ec24c2e3a59a.sqlite");//"ER-100.sqlite");
    //myDataBases.setUserName("");
    //myDataBases.setPassword("");
    qDebug()<<"open myDataBases"<<myDataBases.open();
    pSqlThread = new SqlThread();
     connect(pSqlThread,&SqlThread::sqlThreadSignal,this,&MySQL::mySqlChanged);

    pSqlThread->start();
}
MySQL::~MySQL(){
    myDataBases.close();
    myDataBases.removeDatabase(qgetenv("HOME")+"/.local/share/TangShanKaiYuanSpecialWeldingEquipmentCo.,Ltd/ER-100/QML/OfflineStorage/Databases/433abb168a2ae7adeaa1ec24c2e3a59a.sqlite");
}

void MySQL::setSqlCommand(QStringList Cmd){
    //队列插入命令
    pSqlThread->pCmdBuf->enqueue(Cmd);
}


