#ifndef GLOABLDEFINE
#define GLOABLDEFINE

#include <QtCore>
#include <QtGlobal>

/***********************************************************************/

#define EROBOWELDSYS_DIR                                             ""
#define EROBOWELDSYS_CURRENT_USER_NAME            "NOP"
#define EROBOWELDSYS_CURRENT_USER_PASSWORD   "NOP"
#define EROBOWELDSYS_CURRENT_USER_TYPE              "User"
#define EROBOWELDSYS_LAST_USER_NAME                    "NOP"
#define EROBOWELDSYS_LAST_USER_TYPE                       "User"
#define EROBOWELDSYS_SCREEN_HEGHT                         480
#define EROBOWELDSYS_SCREEN_WIDTH                         640
#define EROBOWELDSYS_SOFTWAREVREASION               "0.1"
#define EROBOWELDSYS_SOFTWAREAUTHOR                  "陈世豪"
#define EROBOWELDSYS_SOFTWARECOMPANY               "唐山开元特种焊接设备有限公司"
#define EROBOWELDSYS_SOFTWAREDESCRIPTION         "便携式MAG焊接机器人系统"
#define EROBOWELDSYS_THEMEPRIMARYCOLOR            "blue"
#define EROBOWELDSYS_THEMEBACKGROUNDCOLOR   "white"
#define EROBOWELDSYS_THEMEACCENTCOLOR               "yellow"
#define EROBOWELDSYS_BACKLIGHT                                 50

#define EROBOWELDSYS_PLATFORM                                  1//1代表TKSW内核 0代表陈世豪内核

/************************************************************************/

#define EROBOWELDSYS_MODE                                           "Auto"
//#define EROBOWELDSYS_WELDSTART
//平焊单边V型坡口T接头
#define GROOVE_SIGNEL_V_T                                               0
//平焊单边V型坡口平对接

/*
 * 串口配置
 */
#define ERROR_SERIALPORT_OPEN                                      "打开串口失败！"
#define ERROR_SERIALPORT_TIMEOUT                                "串口超时"

/*
 *算法限制条件排序
 */

#define   PI                                                3.141592654
#define   CURRENT_LEFT                          0
#define   CURRENT                                   1
#define   CURRENT_RIGHT                       2
#define   SWING_LEFT_STAYTIME            3
#define   SWING_RIGHT_STAYTIME         4
#define   MAX_HEIGHT                             6
#define   MIN_HEIGHT                             5
#define   SWING_LEFT_LENGTH              7
#define   SWING_RIGHT_LENGTH           8
#define   MAX_SWING_LENGTH              9
#define   SWING_SPACING                      10
#define   K                                                 11
#define   VOLTAGE                                    12
#define   MIN_SPEED                               13
#define   MAX_SPEED                               14
#define   FILL_COE                                   15

#define  BOTTOM_0                                  0
#define  BOTTOM_1                                 16
#define  SECOND                                      32
#define  FILL                                             48
#define  TOP                                             64
#define  OVER                                           80

#define  WAVE_SPEED_START_STOP      400        //步进电机起始停止脉冲频率			————120mm/min
#define  WAVE_SPEED_ACCE_DECE       350        //步进电机加减速（每10个脉冲）

#define WAVE_CODE_NUM                    20   //20个脉冲对应0.1mm
#define WAVE_MAX_SPEED                    2300   //2400mm/min
#define GET_WAVE_PULSE(X)                                       (X/6)*WAVE_CODE_NUM   //最高转速对应的脉冲频率

#define GET_WAVE_SPEED(X)                                       (X/WAVE_CODE_NUM)*6     //通过脉冲数求速度

#define GET_CERAMICBACK_R(WIDTH,DEEP)             (WIDTH*WIDTH+4*DEEP*DEEP)/(8*DEEP)

#define GET_CERAMICBACK_AREA(WIDTH,DEEP)      qAsin(WIDTH/(2*GET_CERAMICBACK_R(WIDTH,DEEP)))*GET_CERAMICBACK_R(WIDTH,DEEP)*GET_CERAMICBACK_R(WIDTH,DEEP)-WIDTH*(GET_CERAMICBACK_R(WIDTH,DEEP)-DEEP)/2  //qAsin 得到的是弧度 弧度*R为弧长 弧长*R/2为扇形面积。

#define ENABLE_SOLVE_FIRST                              1
#define CURRENT_COUNT_DEC                            30
#define CURRENT_COUNT_PLUAS                        20
#define CURRENT_MAX                                         300
#define CURRENT_MIN                                         150
#define CURRENT_P_MIN                                     100
#define WAVE_MIN_SPEED                                   1200

#define WAVE_MAX_VERTICAL_SPEED                 1400

#define GET_TRAVELSPEED(COEFFICIENT,WIRE_D,FEEDSPEED,S,FILL_COEFFICIENT)                        (COEFFICIENT*WIRE_D*FEEDSPEED)/(S*100)/FILL_COEFFICIENT
#define GET_WELDFILL_AREA(COEFFICIENT,WIRE_D,FEEDSPEED,TRAVELSPEED,FILL_COEFFICIENT)      (COEFFICIENT*WIRE_D*FEEDSPEED)/(TRAVELSPEED*100)/FILL_COEFFICIENT

#define GET_VERTICAL_TRAVERLSPEED(COEFFICIENT,WIRE_D,FEEDSPEED,S,FILL_COEFFICIENT,SWINGHZ,STAYTIME)   (COEFFICIENT*WIRE_D*FEEDSPEED*60)/(S*100*SWINGHZ*STAYTIME)/FILL_COEFFICIENT
#define GET_VERTICAL_WELDFILL_AREA(COEFFICIENT,WIRE_D,FEEDSPEED,TRAVELSPEED,FILL_COEFFICIENT,SWINGHZ,STAYTIME)      (COEFFICIENT*WIRE_D*60*FEEDSPEED)/(TRAVELSPEED*SWINGHZ*STAYTIME*100)/FILL_COEFFICIENT

//#define DEBUG_VERTICAL

struct FloorCondition
{       //电流
    int current;
    //电流左侧
    int current_left;
    //电流右侧
    int current_right;
    //电流中间侧
    int current_middle;
    //电压
    float voltage;
    //层高限制
    float maxHeight;
    //层高最小限制
    float minHeight;
    //层高
    float height;
    //层内分道个数
    int num;
    //摆动距离坡口左侧距离
    float swingLeftLength;
    //摆动距离坡口右侧距离
    float swingRightLength;
    //最大摆动宽度
    float maxSwingLength;
    //分道摆动间隔 同一层 不同焊道之间间隔距离
    float weldSwingSpacing;
    //左侧摆动停留时间
    float swingLeftStayTime;
    //右侧摆动停止时间
    float swingRightStayTime;
    //总停留时间
    float totalStayTime;
    //末道填充与初道填充比 也是用于 多层多道
    float k;
    //最大填充量
    float maxFillMetal;
    //最小填充量
    float minFillMetal;
    //最大摆动频率
  //  float maxSwingHz;
    //最小摆动频率
//    float minSwingHz;
    //最大焊接速度
    float maxWeldSpeed;
    //最小焊接速度
    float minWeldSpeed;
    //填充系数
    float fillCoefficient;
    //NAME
    QString name;
};


#endif // GLOABLDEFINE
