#include "SQL.h"
SqlThread::SqlThread(){
    myDataBases=QSqlDatabase::addDatabase("QSQLITE");
    // myDataBases.setHostName("ER-100");
    myDataBases.setDatabaseName("ER-100.db");
    //myDataBases.setUserName("");
    //   myDataBases.setPassword("");
    myDataBases.open();
}

SQL::SQL(){
        pSqlThread = new SqlThread();
}
