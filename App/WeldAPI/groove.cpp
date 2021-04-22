#include "groove.h"
#include "gloabldefine.h"

groove::groove()
{
    index=0;
}

//float getGrooveArea(int index,float hUsed,float h){
//    grooveRulesType* pGrooveRule=pGrooveRulesTable+index;
//    float a,b;
//    b=hUsed-pGrooveRule->rootFace;
//    a=h+b;
//    return (pGrooveRule->rootGap)*(h+hUsed)+(a*a+2*a*b)*(pGrooveRule->grooveAngel1Tan+pGrooveRule->grooveAngel2Tan)/2;
//}
//change p2->p1
void groove::changeGrooveRules(grooveRulesType *p1,grooveRulesType*p2){
    p1->index=p2->index;
    p1-> grooveHeight=p2-> grooveHeight;
    p1-> grooveHeightError=p2-> grooveHeightError;
    p1-> rootGap=p2-> rootGap;
    p1-> grooveAngel1= p2-> grooveAngel1;
    p1-> grooveAngel1Tan=p2-> grooveAngel1Tan;
    p1-> grooveAngel2=p2-> grooveAngel2;
    p1-> grooveAngel2Tan=p2-> grooveAngel2Tan;
    p1-> x=p2->x;
    p1-> y=p2->y;
    p1-> z=p2->z;
    p1-> angel=p2->angel;
    p1-> s=p2->s;
    p1-> basic_x=p2->basic_x;
    p1-> basic_y=p2->basic_y;
    p1-> rootFace=p2->rootFace;
    p1->c1=p2->c1;
    p1->c2=p2->c2;
    p1->c3=p2->c3;
    p1->c4=p2->c4;
    p1->c5=p2->c5;
    p1->c6=p2->c6;
    p1->c7=p2->c7;
    p1->c8=p2->c8;
}
/*
 * UpOrDown 1 UP 0 DWON
 * 按照Z轴重新排序
*/
void groove::reorderGrooveList(weldDataTableType* pData,bool UpOrDown){
    grooveRulesType tempTable;
    grooveRulesType *p1;
    grooveRulesType *p2;
    //冒泡法将坡口数组排序
    for(int i=0;i<(index-1);i++){
        for(int j=0;j<(index-1-i);j++){
            p1=&((pData+j)->grooveRules);
            p2=&((pData+j+1)->grooveRules);
            if(UpOrDown){
                if((p1->z)>(p2->z)){
                    changeGrooveRules(&tempTable,p1);
                    changeGrooveRules(p1,p2);
                    changeGrooveRules(p2,&tempTable);
                }
            }else{
                if((p1->z)<(p2->z)){
                    changeGrooveRules(&tempTable,p1);
                    changeGrooveRules(p1,p2);
                    changeGrooveRules(p2,&tempTable);
                }
            }
        }
    }
}

int groove::setGrooveRules(grooveRulesType *p,QObject *value){
    p->index=index;
    p->c1=value->property("C1").toFloat();
    p->c2=value->property("C2").toFloat();
    p->c3=value->property("C3").toFloat();
    p->c4=value->property("C4").toFloat();
    p->c5=value->property("C5").toFloat();
    p->c6=value->property("C6").toFloat();
    p->c7=value->property("C7").toFloat();
    p->c8=value->property("C8").toFloat();

    index++;

    p->s=0;
    p->rootFace=rootFace;
    if(name!="水平角焊"){
        p->grooveHeight=p->c1;
        p->grooveHeightError=p->c2;
        p->rootGap=p->c3;
        if(name=="T接头"){
            //float a,b,c,c2,angel1,angel2,angela,angelc;
            float angel1,angel2;
            if(grooveDir)//非坡口侧
            {  angel1=p->c5;
                angel2=p->c4;
            }else{
                angel1=p->c4;
                angel2=p->c5;
            }
            ResType res= getAngelT(angel1,angel2,p->grooveHeight,p->rootGap,\
                                   p->grooveHeightError);
            if(!res.error){
                p->angel=res.angel;
                p->grooveHeight=res.height;
                p->rootGap=res.rootGap;
                p->s=res.s;
                p->basic_x=res.basic_x;
                p->basic_y=res.basic_y;
                if(grooveDir){
                    p->grooveAngel2=angel1-p->angel;
                    p->grooveAngel1=angel2+p->angel;
                }else{
                    p->grooveAngel1=angel1-p->angel;
                    p->grooveAngel2=angel2+p->angel;
                }
            }else{
                return ERROR_ANGEL;
            }
        }else{ //输入的板厚已经和板厚差做出变化
            p->grooveAngel1=p->c4;
            p->grooveAngel2=p->c5;
        }
    }else{//水平角焊
        p->grooveHeight=p->c1;
        p->grooveHeightError=p->c2;
        p->angel=qAtan(p->grooveHeightError/p->grooveHeight)*180/PI;
        p->grooveHeight=p->grooveHeightError*qCos(p->angel*PI/180);
        p->rootGap=0;
        if(grooveDir){//非坡口侧
            p->grooveAngel1=p->c4+p->angel;
            p->grooveAngel2=p->c5-p->angel;
        }else{
            p->grooveAngel1=p->c4-p->angel;
            p->grooveAngel2=p->c5+p->angel;
        }
    }
    p->x=p->c6;
    p->y=p->c7;
    p->z=p->c8;
    p->grooveAngel1Tan=qTan( p->grooveAngel1*PI/180);
    p->grooveAngel2Tan=qTan( p->grooveAngel2*PI/180);
    qDebug()<< p->grooveHeight<<p->grooveHeightError<<p->angel<<p->grooveAngel1<<p->grooveAngel2<<p->rootGap;
    return NO_ERROR;
}

ResType groove::getAngelT(float angel1,float angel2,float height,float rootgap,float heightError){
    ResType res;
    res.angel=0;
    res.height=0;
    res.error=false;
    res.rootGap=0;
    float Lk,Lb,Rk;
    Rk=0;
    point A,B,C,E,F,M,N;
    if(angel1!=0){
        Lb=-rootgap/qTan(angel1*PI/180); //线段b b
        Lk=-1/qTan(angel1*PI/180);//线段b 斜率
        A.y=height;
        A.x=(A.y-Lb)/Lk;//A点坐标
        if(angel2==0){
            C.x=0; //C点坐标
            C.y=Lb;
            B.x=0; //B点坐标
            B.y=height+heightError;
        }else{
            Rk=1/qTan(angel2*PI/180);//线段a 斜率
            C.x=Lb/(Rk-Lk); //C点坐标
            C.y=C.x*Rk;
            B.y=height+heightError*qCos(angel2*PI/180);//B点坐标
            B.x=B.y/Rk;
        }
        //求c边长
        float b,a,c;
        b=(A.x-C.x)*(A.x-C.x)+(A.y-C.y)*(A.y-C.y);
        b=qSqrt(b);
        a=(B.x-C.x)*(B.x-C.x)+(B.y-C.y)*(B.y-C.y);
        a=qSqrt(a);
        c=a*a+b*b-a*b*2*qCos((angel1+angel2)*PI/180);
        c=qSqrt(c);
        //求B角度
        float angelB;
        angelB=qAcos((a*a+c*c-b*b)/(2*a*c))*180/PI;
        res.angel=90-angel2-angelB;
        //求坡口高度
        float zb,za;
        point D;
        float d;
        //求垂线斜率
        if((B.y-A.y)==0){
            res.angel=0;
            res.height=height;
            res.rootGap=rootgap;
            res.basic_x=0;
            res.basic_y=0;
            res.s=0;
        }else{
            za=-(B.x-A.x)/(B.y-A.y);
            zb=C.y-za*C.x;
            D.x=-zb/za;
            D.y=0;
            d=(D.x-C.x)*(D.x-C.x)+(D.y-C.y)*(D.y-C.y);
            d=qSqrt(d);
            res.height=a*qSin(angelB*PI/180)-d;
            res.rootGap=d*qTan((90-angelB)*PI/180)+d*qTan((angel1+angel2+angelB-90)*PI/180);
            float s=(res.rootGap+c)*res.height/2;
            res.s=c*a*qSin(angelB*PI/180)/2-rootgap*qAbs(C.y)/2-s;

            E.y=0;
            E.x=-rootgap/2;

            float fa,fb;
            fa=-1/za;
            fb=D.y-fa*D.x;

            M.x=(fb-Lb)/(Lk-fa);
            M.y=M.x*fa+fb;

            if(angel2==0){
                N.x=0;
                N.y=fb;
            }else{
                N.x=(fb)/(Rk-fa);
                N.y=N.x*fa+fb;
            }

            F.x=(M.x+N.x)/2;
            F.y=(M.y+N.y)/2;

            res.basic_x=E.x-F.x;
            res.basic_y=E.y-F.y;

        }
    }else{
        //左边角度不能为0
        res.error=true;
    }
    return res;
}
/*获取坡口平均数据*/
int groove::getGrooveRulesAv(grooveRulesType *p,weldDataTableType* pData,int length){
    p->index=255;
    grooveRulesType* pGrooveRules;
    unsigned char i=0;
    p->c1=0;
    p->c2=0;
    p->c3=0;
    p->c4=0;
    p->c5=0;
    p->c6=0;
    p->c7=0;
    p->c8=0;
    for(i=0;i<length;i++){
        pGrooveRules=&((pData+i)->grooveRules);
        p->c1+=pGrooveRules->c1;
        p->c2+=pGrooveRules->c2;
        p->c3+=pGrooveRules->c3;
        p->c4+=pGrooveRules->c4;
        p->c5+=pGrooveRules->c5;
        p->c6+=pGrooveRules->c6;
        p->c7+=pGrooveRules->c7;
        p->c8+=pGrooveRules->c8;
    }
    /*均布坡口*/
    p->c1/=length;
    p->c2/=length;
    p->c3/=length;
    p->c4/=length;
    p->c5/=length;
    p->c6/=length;
    p->c7/=length;
    p->c8/=length;

    p->s=0;
    p->rootFace=pGrooveRules->rootFace;
    if(name!="水平角焊"){
        p->grooveHeight=p->c1;
        p->grooveHeightError=p->c2;
        p->rootGap=p->c3;
        if(name=="T接头"){
            //float a,b,c,c2,angel1,angel2,angela,angelc;
            float angel1,angel2;
            if(grooveDir)//非坡口侧
            {  angel1=p->c5;
                angel2=p->c4;
            }else{
                angel1=p->c4;
                angel2=p->c5;
            }
            ResType res= getAngelT(angel1,angel2,p->grooveHeight,p->rootGap,\
                                   p->grooveHeightError);
            if(!res.error){
                p->angel=res.angel;
                p->grooveHeight=res.height;
                p->rootGap=res.rootGap;
                p->s=res.s;
                p->basic_x=res.basic_x;
                p->basic_y=res.basic_y;
                if(grooveDir){
                    p->grooveAngel2=angel1-p->angel;
                    p->grooveAngel1=angel2+p->angel;
                }else{
                    p->grooveAngel1=angel1-p->angel;
                    p->grooveAngel2=angel2+p->angel;
                }
            }else{
                return ERROR_ANGEL;
            }
        }else{ //输入的板厚已经和板厚差做出变化
            p->grooveAngel1=p->c4;
            p->grooveAngel2=p->c5;
        }
    }else{//水平角焊
        p->grooveHeight=p->c1;
        p->grooveHeightError=p->c2;
        p->angel=qAtan(p->grooveHeightError/p->grooveHeight)*180/PI;
        p->grooveHeight=p->grooveHeightError*qCos(p->angel*PI/180);
        p->rootGap=0;
        if(grooveDir){//非坡口侧
            p->grooveAngel1=p->c4+p->angel;
            p->grooveAngel2=p->c5-p->angel;
        }else{
            p->grooveAngel1=p->c4-p->angel;
            p->grooveAngel2=p->c5+p->angel;
        }
    }
    for(i=0;i<length;i++){
        pGrooveRules=&((pData+i)->grooveRules);
        pGrooveRules->grooveHeight=p->grooveHeight;
    }
    p->x=p->c6;
    p->y=p->c7;
    p->z=p->c8;
    p->grooveAngel1Tan=qTan( p->grooveAngel1*PI/180);
    p->grooveAngel2Tan=qTan( p->grooveAngel2*PI/180);
    return NO_ERROR;
}


