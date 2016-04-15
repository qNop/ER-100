#include "weldmath.h"
//WeldRules::WeldRules(){

//}
//QString WeldRules::C1(){return M_C1;}
//QString WeldRules::C2(){return M_C2;}
//QString WeldRules::C3(){return M_C3;}
//QString WeldRules::C4(){return M_C4;}
//QString WeldRules::C5(){return M_C5;}
//QString WeldRules::C6(){return M_C6;}
//QString WeldRules::C7(){return M_C7;}
//QString WeldRules::C8(){return M_C8;}
//QString WeldRules::C9(){return M_C9;}
//QString WeldRules::ID(){return M_ID;}

//weldMath
WeldMath::WeldMath()
{
    reinforcementValue=0;
    meltingCoefficientValue=0;
   // map.clear();
}
float WeldMath::reinforcement(){
    return reinforcementValue;
}
void WeldMath::setReinforcement(float value){
    reinforcementValue=value;
}
float WeldMath::meltingCoefficient(){
    return meltingCoefficientValue;
}
void WeldMath::setMeltingCoefficient(float value){
    meltingCoefficientValue=value;
}

//QStringList WeldMath::weldRules(){
//    QStringList weldRulesValue;
//    //JAVA风格迭代
//    QMapIterator<QString,QString,QString,QString,QString,QString,QString,QString,QString,QString> i(rulesMap);
//    if(i.hasNext()){
//      weldRulesValue=i.value().;
//    }
//     return weldRulesValue;
//}

//void WeldMath::setWeldRules(QStringList value){
//    rulesMap<<value;
//}






