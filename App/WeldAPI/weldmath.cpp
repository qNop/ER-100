#include "weldmath.h"

//weldMath
WeldMath::WeldMath()
{
    reinforcementValue=0;
    meltingCoefficientValue=0;

}
float WeldMath::reinforcement(){
    return reinforcementValue;
}
WeldMath::setreinforcement(float value){
    reinforcementValue=value;
}

float WeldMath::meltingCoefficient(){
    return meltingCoefficientValue;
}

float WeldMath::setMeltingCoefficient(float value){
    meltingCoefficientValue=value;
}





