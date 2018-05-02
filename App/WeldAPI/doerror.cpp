#include "DoError.h"
#include <QDateTime>

DoError::DoError()
{
    oldError=0;
    errorCount=0;
}
 QString errorName[]={"主控制器错误","CAN通讯错误","急停报警","摇动电机过热过流","摇动电机右限位","摇动电机左限位","摇动电机原点搜索","摇动电机堵转", "摆动电机过热过流","摆动电机内限位",
        "摆动电机外限位","摆动电机原点搜索","摆动电机堵转", "上下电机过热过流","上下电机下限位","上下电机上限位","上下电机原点搜索","上下电机堵转", "行走电机过热过流","行走电机右限位",
        "行走电机左限位","行走电机原点搜索","行走电机堵转","驱动器急停报警","手持盒通讯错误","示教器通讯错误","焊接电源通讯错误","焊接电源粘丝错误","焊接电源其他错误","坡口参数表格内无数据",
        "生成焊接规范错误","焊接规范表格内无数据",
        "未插入钥匙","坡口检测未检测到工件错误","坡口检测碰触工件错误","机头未接入错误","坡口检测摆动速度错误","未定义错误","未定义错误","未定义错误", "未定义错误","未定义错误",
        "未定义错误","未定义错误","未定义错误", "未定义错误","未定义错误","未定义错误","未定义错误","未定义错误", "未定义错误","未定义错误",
        "未定义错误","未定义错误","未定义错误","未定义错误","未定义错误","未定义错误","未定义错误","未定义错误","未定义错误","未定义错误",
        "未定义错误","未定义错误"};
void DoError::errorMath(long long errorCode){
    long long errorXor;
    errorXor=oldError^errorCode;
    QDateTime currentDateTime=QDateTime::currentDateTime();
    QString errorTime=currentDateTime.toString("yyyy-MM-dd h:mm:ss");
    QJsonObject json;
    QJsonObject jsonHistroy;
    QString errorHistroyStatus;
    //存储当前数据
    oldError=errorCode;
    //获取时间
    for(int i=0;i<64;i++){
        if(errorXor&0x01){
            json.insert("ID",QJsonValue(QString::number(i+1)));
            if(errorCode&0x01){ //错误存在
                json.insert("C1",QJsonValue(errorName[i]));
                json.insert("C2",QJsonValue(errorTime));
                errorHistroyStatus="发生";
                //发射更新错误
                emit upDateError("insert",json);
            }else{//错误消失
                errorHistroyStatus="解除";
                emit upDateError("remove",json);
            }
            errorCount++;
            jsonHistroy.insert("ID",QJsonValue(QString::number(errorCount)));
            jsonHistroy.insert("C1",QJsonValue(QString::number(i+1)));
            jsonHistroy.insert("C2",QJsonValue(errorHistroyStatus));
            jsonHistroy.insert("C3",QJsonValue("TKSW"));
            jsonHistroy.insert("C4",QJsonValue(errorName[i]));
            jsonHistroy.insert("C5",QJsonValue(errorTime));
            //发射更新历史记录
            emit upDateHistory("insert",jsonHistroy);
        }
        //数据左移
        errorCode>>=1;
        errorXor>>=1;
    }

}
