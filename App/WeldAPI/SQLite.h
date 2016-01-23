#ifndef SQLITE_H
#define SQLITE_H

#include <QQuickItem>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlDriver>
#include <QSql>

class SQLite: public QObject
{
public:
    SQLite();
    ~SQLite();
private:
    QSqlDatabase db;

};

#endif // SQLITE_H
