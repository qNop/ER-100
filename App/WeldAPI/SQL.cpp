#include "SQL.h"
SqlThread::SqlThread(){
    //完成后删除
    connect(this,&SqlThread::finished,this,&SqlThread::deleteLater);
}
SqlThread::~SqlThread(){
    delete timer;
    qDebug()<<"SqlThread::~SqlThread()";
}
void SqlThread::run(){
    lockThread->lock();
    timer =new QTimer();
    timer->setInterval(1000);
    timer->start();
    QSqlQuery query(function);
    QSqlRecord res;
    qDebug()<<timer->remainingTime();
    timer->stop();
    while (query.next()) {
        res=query.record();
        for(int i=0;i<res.count();i++){
            qDebug()<<res.fieldName(i)<<res.field(i).value();
        }
    }
    lockThread->unlock();
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


