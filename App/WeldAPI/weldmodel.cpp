#include "weldmodel.h"
#include "gloabldefine.h"
#include <QFile>
#include <QSql>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QSql>
#include <QSqlDatabase>

WeldModel::WeldModel()
{

}
/*
 *
 */
bool File_Is_Exist(QString Qfilename){
     QFile tempfile(Qfilename);
     return tempfile.exists();
}
/*
 *
 */
bool openDatabase(QString Databasename,QString Username,QString Password,QString Hostname,\
                     QString type ){
    if(File_Is_Exist("/"+Databasename)){
        QSqlDatabase db = QSqlDatabase::database(Databasename);
        if(db.open()){
             qDebug()<<"打开数据库"+Databasename+"成功！";
        }
        else{
             qDebug()<<"打开数据库"+Databasename+"失败！";
        }
    }
    else{
        QSqlDatabase db = QSqlDatabase::addDatabase(type);
        db.setDatabaseName(Databasename);
        db.setHostName(Hostname);
        db.setUserName(Username);
        db.setPassword(Password);
        if(db.open()){
            qDebug()<<"创建数据库"+Databasename+"成功！";
        }
        else
        {
            qDebug()<<"创建数据库"+Databasename+"失败！";
        }
    }
}

/*
 *
 */
bool ExecuteSql(QString sql)
{
    QSqlQuery query;
    return query.exec(sql);
}
/*
 *
 */
LocalStruct * GrooveModel::teachMode(){
    QString sqlComand;
    QSqlQuery  Query;
    LocalStruct res;
    int index;
    sqlComand = "select teachmode form groovemodel";
    Query.exec(sqlComand);
    index = Query.record().indexOf("description");
    res.description = Query.value(index).toString();

    index = Query.record().indexOf("description");
    res.init = Query.value(index).toString();

    return res;
}
void GrooveModel::setteachMode(QString mode){

}
