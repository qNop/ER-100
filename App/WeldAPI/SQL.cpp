#include "SQL.h"
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
 * 6 ErrorTable
 * 7 LimitedTable
 * 8 坡口名称+次列表
 * 9 坡口名称+列表
 * 10 检测错误表
 *
 */



SqlThread::SqlThread(){
    //完成后删除
    connect(this,&SqlThread::finished,this,&SqlThread::deleteLater);
}
SqlThread::~SqlThread(){
    qDebug()<<"SqlThread::~SqlThread()";
}
void SqlThread::run(){
    lockThread->lock(); //锁定run函数
    QString status="Successed"; //状态

    QSqlQuery query(function);
    QSqlRecord res;
    while (query.next()) {
        res=query.record();
        for(int i=0;i<res.count();i++){
            qDebug()<<res.fieldName(i)<<res.field(i).value();
        }
    }
    lockThread->unlock();//解锁run函数 保证此时只有唯一的run函数在运行。
}

SQL::SQL(){
    //添加链接
    myDataBases=QSqlDatabase::addDatabase("QSQLITE");
    //myDataBases.setHostName("ER-100");
    //存储位置
    myDataBases.setDatabaseName(qgetenv("HOME")+"/.local/share/TangShanKaiYuanSpecialWeldingEquipmentCo.,Ltd/ER-100/QML/OfflineStorage/Databases/433abb168a2ae7adeaa1ec24c2e3a59a.sqlite");//"ER-100.sqlite");
    //myDataBases.setUserName("");
    //myDataBases.setPassword("");
    qDebug()<<"open myDataBases"<<myDataBases.open();
}
SQL::~SQL(){
    myDataBases.close();
    myDataBases.removeDatabase(qgetenv("HOME")+"/.local/share/TangShanKaiYuanSpecialWeldingEquipmentCo.,Ltd/ER-100/QML/OfflineStorage/Databases/433abb168a2ae7adeaa1ec24c2e3a59a.sqlite");
}

void SQL::setSqlCommand(QString Cmd){
    SqlThread* pSqlThread;
    if(Cmd.count()>2){
        pSqlThread = new SqlThread();
        pSqlThread->lockThread=&lockThread;
        pSqlThread->function=Cmd;
        connect(pSqlThread,SIGNAL(sqlThreadSignal(QStringList )),this,SIGNAL(sqlSignalChanged(QStringList)));
        pSqlThread->start();
    }
}

void SQL::openDatabases(){

}


