#include "SQLite.h"

SQLite::SQLite()
{
    db=QSqlDatabase::addDatabase("QSQLITE");
}
SQLite::~SQLite(){

}

