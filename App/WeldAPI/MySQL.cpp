#include "MySQL.h"
#include <iterator>
/*
*/

SqlThread::SqlThread(){
    pCmdBuf=&cmdBuf;
}
SqlThread::~SqlThread(){
    qDebug()<<"SqlThread::~SqlThread()";
}

void SqlThread::run(){
    QString cmd;
    QSqlQuery query;
    bool status;
    QString tableName;
    QSqlRecord res;
    for(;;){
        if(cmdBuf.count()){//如果存在命令则 执行命令行
            QStringList list=cmdBuf.dequeue().split("+");
            cmd=list.at(0);
            tableName=list.at(1);
            if(cmd.startsWith("SELECT")){//包含选择命令
                status=query.exec(cmd);
                if(status){ //获取数据库
                    while (query.next()) {
                        res=query.record();//获取记录
                        for(int i=0;i<res.count();i++){ //组织成Json
                            pJson.insert(res.fieldName(i),QJsonValue(res.field(i).value().toString()));
                        }
                        qJsonList.append(QVariant(pJson));
                      while(!pJson.empty()){
                        pJson.erase(pJson.begin());
                      }
                    }
                    emit sqlThreadSignal(qJsonList,tableName);
                    qJsonList.clear();
                }
            }else if(cmd.startsWith("CREATE")){//创建数据库
                status=query.exec(cmd);
            }else if(cmd.startsWith("INSERT")){//插入数据库
                status=query.exec(cmd);
            }else if(cmd.startsWith("UPDATE")){//插入数据库
                status=query.exec(cmd);
            }else if(cmd.startsWith("DELETE")){//删除数据库
                status=query.exec(cmd);
            }else if(cmd.startsWith("ALTER")){//重命名数据库或添加字段
                status=query.exec(cmd);
            }else if(cmd.startsWith("DROP")){//重命名数据库或添加字段
                status=query.exec(cmd);
            }else{//不支持的命令
                status=false;
            }
            emit sqlThreadFinished(status,tableName);
        }else{//线程挂起20ms
            msleep(20);
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
    myDataBases.open();
    pSqlThread = new SqlThread();
    connect(pSqlThread,&SqlThread::sqlThreadSignal,this,&MySQL::mySqlChanged);
    connect(pSqlThread,&SqlThread::sqlThreadFinished,this,&MySQL::mySqlStatusChanged);
    pSqlThread->start();
}
MySQL::~MySQL(){
    myDataBases.close();
    myDataBases.removeDatabase(qgetenv("HOME")+"/.local/share/TangShanKaiYuanSpecialWeldingEquipmentCo.,Ltd/ER-100/QML/OfflineStorage/Databases/433abb168a2ae7adeaa1ec24c2e3a59a.sqlite");
}
/*以下为命令的解析*/
void MySQL::getJsonTable(QString tableName){
    if(!tableName.isEmpty())
        pSqlThread->pCmdBuf->enqueue("SELECT * FROM "+tableName+"+"+tableName);
    else
        emit mySqlStatusChanged(false,tableName);
}

void MySQL::alterTable(QString tableName, QString columnName){
    if((!tableName.isEmpty())&&(!columnName.isEmpty()))
        pSqlThread->pCmdBuf->enqueue("ALTER TABLE "+tableName+" ADD COLUMN "+columnName+"+"+tableName);
    else
        emit mySqlStatusChanged(false,tableName);
}

void MySQL::renameTable(QString oldName, QString newName){
    if((!oldName.isEmpty())&&(!newName.isEmpty()))
        pSqlThread->pCmdBuf->enqueue("ALTER TABLE "+oldName+" RENAME TO "+newName+"+"+oldName);
    else
        emit mySqlStatusChanged(false,oldName);
}

void MySQL::insertTable(QString tableName,QObject* data){
    if(!tableName.isEmpty()&&data){
        const QMetaObject* meta= data->metaObject();
        QString s=" (";
        QString s1=" (";
        for(int i=1;i<meta->propertyCount();i++){
            QVariant value=data->property(meta->property(i).name());
            s1+=meta->property(i).name();
            s1+=",";
            s+="\'"+value.toString()+"\'";
            s+=",";
        }
        s.remove(s.length()-1,1);
        s+=")";
        s1.remove(s1.length()-1,1);
        s1+=")";
        pSqlThread->pCmdBuf->enqueue("INSERT INTO "+tableName+s1+" VALUES"+s+"+"+tableName);
       ;
    }else
        emit mySqlStatusChanged(false,tableName);
}

void MySQL::insertTableByJson(QString tableName,QJsonObject data){
    if(!tableName.isEmpty()){
        QStringList sList=data.keys();
        QString s=" (";
        QString s1=" (";
        for(int i=0;i<sList.length();i++){
            QJsonValue value=data.value(sList.at(i));
            s1+=sList.at(i);
            s1+=",";
            s+="\'"+value.toString()+"\'";
            s+=",";
        }
        s.remove(s.length()-1,1);
        s+=")";
        s1.remove(s1.length()-1,1);
        s1+=")";
        pSqlThread->pCmdBuf->enqueue("INSERT INTO "+tableName+s1+" VALUES"+s+"+"+tableName);
    }else
        emit mySqlStatusChanged(false,tableName);
}

void MySQL::deleteTable(QString tableName){
    if(!tableName.isEmpty())
        pSqlThread->pCmdBuf->enqueue("DROP TABLE "+tableName+"+"+tableName);
    else
        emit mySqlStatusChanged(false,tableName);
}

void MySQL::createTable(QString tableName,QString format){
    if((!tableName.isEmpty())&&(!format.isEmpty()))
        pSqlThread->pCmdBuf->enqueue("CREATE TABLE IF NOT EXISTS "+tableName+"("+format+")"+"+"+tableName);
    else
        emit mySqlStatusChanged(false,tableName);
}

void MySQL::clearTable(QString tableName, QString func,QString value){
    if(!tableName.isEmpty()){
        if((!func.isEmpty())&&(!value.isEmpty()))
            pSqlThread->pCmdBuf->enqueue("DELETE FROM "+tableName+" WHERE "+func+" = "+"\'"+value+"\'"+"+"+tableName);
        else
            pSqlThread->pCmdBuf->enqueue("DELETE FROM "+tableName+"+"+tableName);
    }
    else
        emit mySqlStatusChanged(false,tableName);
}

void MySQL::getDataOrderByTime(QString tableName,QString func){
    if((!tableName.isEmpty())&&(!func.isEmpty()))
        pSqlThread->pCmdBuf->enqueue("SELECT * FROM "+tableName+" ORDER BY "+func+" DESC"+"+"+tableName);
    else
        emit mySqlStatusChanged(false,tableName);
}

void MySQL::setValue(QString tableName,QString funcI,QString id,QString funcV,QString value){
    if((!tableName.isEmpty())&&(!id.isEmpty())&&(!value.isEmpty())&&(!funcI.isEmpty())&&(!funcV.isEmpty()))
        pSqlThread->pCmdBuf->enqueue("UPDATE "+tableName+" SET "+funcV+ " = "+"\'"+value+"\'"+" WHERE "+funcI+" = "+"\'"+id+"\'"+"+"+tableName);
    else
        emit mySqlStatusChanged(false,tableName);
}

void MySQL::getValue(QString tableName,QString func,QString id){
    if((!tableName.isEmpty())&&(!id.isEmpty())&&(!func.isEmpty()))
        pSqlThread->pCmdBuf->enqueue("SELECT * FROM "+tableName+" WHERE "+func+" ="+"\'"+id+"\'"+"+"+tableName);
    else
        emit mySqlStatusChanged(false,tableName);
}

void MySQL::mySqlChanged(QList<QVariant> jsonObject,QString tableName){
    //判断是哪个数据库
    if(tableName.contains("AccountTable")){
        emit accountTableChanged(jsonObject);
    }else if(tableName.endsWith("坡口条件")){
        emit grooveTableChanged(jsonObject);
    }else if(tableName.contains("限制条件")&&!tableName.contains("限制条件列表")){
        emit limitedTableChanged(jsonObject);
    }else if(tableName.endsWith("焊接规范")){
        emit weldTableChanged(jsonObject);
    }else if(tableName.endsWith("坡口条件列表")){
        emit grooveTableListChanged(jsonObject);
    }else if(tableName.contains("限制条件列表")){
        emit limitedTableListChanged(jsonObject);
    }else if(tableName.endsWith("焊接规范列表")){
        emit weldTableListChanged(jsonObject);
    }else if(tableName.contains("TeachCondition")){
        emit teachConditionChanged(jsonObject);
    }else if(tableName.contains("WeldCondition")){
        emit weldConditionChanged(jsonObject);
    }else {
        emit mySqlStatusChanged(false,tableName);
    }
}



