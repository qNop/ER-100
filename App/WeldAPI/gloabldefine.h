#ifndef GLOABLDEFINE
#define GLOABLDEFINE

#include <QtCore>
#include <QtGlobal>

#define USE_MODBUS

#define NO_ERROR                                     1
#define ERROR_OTHER                              -1
#define ERROR_CURRENT_MIN                -2
#define ERROR_CURRENT_MAX                -3
#define ERROR_GET_CURRENT                 -4
#define ERROR_GET_VOLTAGE                  -5
#define ERROR_GET_FEEDSPEED              -6
#define ERROR_GET_TRAVELSPEED          -7
#define ERROR_WELDNUM_MAX              -8
#define ERROR_ANGEL                              -9
#define ERROR_HEIGHT                            -10
#define ERROR_NO_GROOVERULES         -11
#define ERROR_TEACHPOINT_MAX          -12
#define ERROR_TEACHPOINT_MIN           -13
#define ERROR_WELDFLOOR_MAX           -14
//#define ERROR_WELDNUM_MAX             -15

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
#define  WAVE_SPEED_ACCE_DECE       300        //步进电机加减速（每10个脉冲）

#define WAVE_CODE_NUM                    20   //20个脉冲对应0.1mm
#define WAVE_MAX_SPEED                    2000   //2400mm/min
#define GET_WAVE_PULSE(X)                                       (X/6)*WAVE_CODE_NUM   //最高转速对应的脉冲频率

#define GET_WAVE_SPEED(X)                                       (X/WAVE_CODE_NUM)*6     //通过脉冲数求速度

#define GET_CERAMICBACK_R(WIDTH,DEEP)             (WIDTH*WIDTH+4*DEEP*DEEP)/(8*DEEP)

#define GET_CERAMICBACK_AREA(WIDTH,DEEP)      qAsin(WIDTH/(2*GET_CERAMICBACK_R(WIDTH,DEEP)))*GET_CERAMICBACK_R(WIDTH,DEEP)*GET_CERAMICBACK_R(WIDTH,DEEP)-WIDTH*(GET_CERAMICBACK_R(WIDTH,DEEP)-DEEP)/2  //qAsin 得到的是弧度 弧度*R为弧长 弧长*R/2为扇形面积。

//#define ENABLE_SOLVE_FIRST
#define CURRENT_COUNT_DEC                            30
#define CURRENT_COUNT_PLUAS                        20
#define CURRENT_MAX                                         300
#define CURRENT_MIN                                         150
#define CURRENT_P_MIN                                     100
#define WAVE_MIN_SPEED                                   800

#define WAVE_MAX_VERTICAL_SPEED                 1500

#define GET_TRAVELSPEED(COEFFICIENT,WIRE_D,FEEDSPEED,S)                        (COEFFICIENT*WIRE_D*FEEDSPEED)/(S*100)
#define GET_WELDFILL_AREA(COEFFICIENT,WIRE_D,FEEDSPEED,TRAVELSPEED)      (COEFFICIENT*WIRE_D*FEEDSPEED)/(TRAVELSPEED*100)

#define GET_VERTICAL_TRAVERLSPEED(COEFFICIENT,WIRE_D,FEEDSPEED,S,SWINGHZ,STAYTIME)   (COEFFICIENT*WIRE_D*FEEDSPEED*60)/(S*100*SWINGHZ*STAYTIME)
#define GET_VERTICAL_WELDFILL_AREA(COEFFICIENT,WIRE_D,FEEDSPEED,TRAVELSPEED,SWINGHZ,STAYTIME)      (COEFFICIENT*WIRE_D*60*FEEDSPEED)/(TRAVELSPEED*SWINGHZ*STAYTIME*100)

#define GET_MAX_FILLMETAL(COEFFICIENT,WIRE_D,FEEDSPEED,MIN_TRAVELSPEED)     GET_WELDFILL_AREA(COEFFICIENT,WIRE_D,FEEDSPEED,MIN_TRAVELSPEED)
#define GET_MIN_FILLMETAL(COEFFICIENT,WIRE_D,FEEDSPEED,MAX_TRAVELSPEED)     GET_WELDFILL_AREA(COEFFICIENT,WIRE_D,FEEDSPEED,MAX_TRAVELSPEED)

#define MAX_TEACHPOINT                               30
#define MAX_WELDNUM                                   20
#define MAX_WELDFLOOR                                50
//#define DEBUG_VERTICAL


/***/
//系统状态
#define REG_SYSTEM_STATUS                    0
//系统登陆
#define REG_SYSTEM_UP                            25

/*示教寄存器定义*/
#define REG_TEACH_MODE                        100
#define REG_START_STOP                           101
#define REG_TEACH_FIRST_POINT             102
#define REG_TEACH_POINT                        103
#define REG_WELD_LENGTH                       104
#define REG_TEACH_LEFT                            105
#define REG_TEACH_RIGHT                         106
/*焊接条件*/
#define REG_WELD_WIRE_LENGTH             120

#define REG_ROCK_WAY                               99
#define REG_ROCK_LEFT                              130
#define REG_ROCK_RIGHT                           131

#define REG_WIRE_TYPE                                126
#define REG_GROOVE_DIR                             122
#define REG_WIRE_D                                      123
#define REG_GAS                                            124
#define REG_PULSE                                         119
#define REG_CURRENT_ADD                          128
#define REG_VOLTAGE_ADD                           129
#define REG_START_GAS_TIME                       132
#define REG_STOP_GAS_TIME                        133
#define REG_START_ARC_STAY_TIME             134
#define REG_STOP_ARC_STAY_TIME              135
#define REG_START_CURRENT                       136
#define REG_STOP_CURRENT                        138
#define REG_START_VOLTAGE                        137
#define REG_STOP_VOLTAGE                         139

#define REG_STOP_ARC_BACK_LENGTH        303
#define REG_STOP_ARC_BACK_SPEED           304
#define REG_STOP_ARC_BACK_TIME             305

#define REG_BURN_BACK_VOLTAGE             300
#define REG_BURN_BACK1                            301
#define REG_BURN_BACK2                            302

#define REG_ROOTFACE                                 161
#define REG_START_ACR_STAY_TIME             148
#define REG_START_ACR_SWING_SPEED       149

#define REG_GROOVE_DATA                           150
#define REG_SEND_WELD_RULES                   200
#define REG_READ_DATETIME                        510

#define REG_ROCK_MOTO_CURRENT_POINT                            1022
#define  REG_SWING_MOTO_CURRENT_POINT                         1024
#define REG_AVC_MOTO_CURRENT_POINT                               1025
#define  REG_TARVEL_MOTO_CURRENT_POINT                        1026

#define REG_MOTO_ORG                                 0
#define REG_MOTO_ERROR                             1
#define REG_MOTO_TEST                                2
#define REG_MOTO_PECT                                3
#define REG_MOTO_SPEED                             4

#define REG_ROCK_MOTO_ORG             26
#define REG_ROCK_MOTO_ERROR         REG_ROCK_MOTO_ORG+REG_MOTO_ERROR
#define REG_ROCK_MOTO_TEST             REG_ROCK_MOTO_ORG+REG_MOTO_TEST
#define REG_ROCK_MOTO_PECT            REG_ROCK_MOTO_ORG+REG_MOTO_PECT
#define REG_ROCK_MOTO_SPEED          REG_ROCK_MOTO_ORG+REG_MOTO_SPEED

#define REG_SWING_MOTO_ORG             REG_ROCK_MOTO_SPEED+1
#define REG_SWING_MOTO_ERROR         REG_SWING_MOTO_ORG+REG_MOTO_ERROR
#define REG_SWING_MOTO_TEST             REG_SWING_MOTO_ORG+REG_MOTO_TEST
#define REG_SWING_MOTO_PECT            REG_SWING_MOTO_ORG+REG_MOTO_PECT
#define REG_SWING_MOTO_SPEED          REG_SWING_MOTO_ORG+REG_MOTO_SPEED

#define REG_AVG_MOTO_ORG                  REG_SWING_MOTO_SPEED+1
#define REG_AVG_MOTO_ERROR              REG_AVG_MOTO_ORG+REG_MOTO_ERROR
#define REG_AVG_MOTO_TEST                 REG_AVG_MOTO_ORG+REG_MOTO_TEST
#define REG_AVG_MOTO_PECT                REG_AVG_MOTO_ORG+REG_MOTO_PECT
#define REG_AVG_MOTO_SPEED              REG_AVG_MOTO_ORG+REG_MOTO_SPEED

#define REG_TRAVEL_MOTO_ORG            REG_AVG_MOTO_SPEED+1
#define REG_TRAVEL_MOTO_ERROR         REG_TRAVEL_MOTO_ORG+REG_MOTO_ERROR
#define REG_TRAVEL_MOTO_TEST             REG_TRAVEL_MOTO_ORG+REG_MOTO_TEST
#define REG_TRAVEL_MOTO_PECT            REG_TRAVEL_MOTO_ORG+REG_MOTO_PECT
#define REG_TRAVEL_MOTO_SPEED          REG_TRAVEL_MOTO_ORG+REG_MOTO_SPEED

#define REG_WELD_FLOOR                        201
#define REG_WELD_CURRENT                   202
#define REG_WELD_VOLTAGE                    203
#define REG_WELD_SWING_LENGTH       204
#define REG_WELD_SWING_SPEED          205
#define REG_WELD_TRAVEL_SPEED         206
#define REG_WELD_X                                207
#define REG_WELD_Y                                208
#define REG_WELD_LEFT_TIME                209
#define REG_WELD_RIGHT_TIME             210
#define REG_WELD_STOP_TIME               211
#define REG_WELD_S1                              212
#define REG_WELD_S2                              213
#define REG_WELD_START_X                    214
#define REG_WELD_START_Y                    215
#define REG_WELD_START_Z                    216
#define REG_WELD_TOTAL_NUM             217
#define REG_WELD_STOP_X                     218
#define REG_WELD_STOP_Y                     219
#define REG_WELD_STOP_Z                     220

#define REG_PATH                                    221

#define REG_WELD_STYLE                       88
#define REG_GROOVE_STYLE                  89
#define REG_CONNECT_STYLE                90
#define REG_BOTTOM_STYLE                  91

#define REG_VERSION                             500

#define REG_ARC_AVC_EN                      250
#define REG_ARC_AVC_ADJ                     254
#define REG_ARC_AVC_MAX                   255
#define REG_ARC_SW_EN                       256
#define REG_ARC_SW_ADJ                      258
#define REG_ARC_SW_MAX                    260

#define REG_ARC_SW_W_EN                 261
#define REG_ARC_SW_W_ADJ                262
#define REG_ARC_SW_W_MAX              264

#define REG_CONTROL_STATUS           1100

/***/

struct FloorCondition
{   //电流
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
    //层数
    int num;
    //摆动距离坡口左侧距离
    float swingLeftLength;
    //摆动距离坡口右侧距离
    float swingRightLength;
    //摆动宽度
    float swingLength;
    //最大摆动宽度
    float maxSwingLength;
    //分道摆动间隔 同一层 不同焊道之间间隔距离
    float weldSwingSpacing;
    //左侧摆动停留时间
    float swingGrooveStayTime;
    //右侧摆动停止时间
    float swingNotGrooveStayTime;
    //总停留时间
    float totalStayTime;
    //末道填充与初道填充比 也是用于 多层多道
    float k;
    //最大填充量
    float maxFillMetal;
    //最小填充量
    float minFillMetal;
    //最大摆动频率
    //float maxSwingHz;
    //最小摆动频率
    //float minSwingHz;
    //最大焊接速度
    float maxWeldSpeed;
    //最小焊接速度
    float minWeldSpeed;
    //填充系数
    //float fillCoefficient;
    //NAME
    QString name;
};

//坡口参数
typedef struct{
    int index;
    float grooveHeight;
    float grooveHeightError;
    float rootGap;
    float grooveAngel1;
    float grooveAngel1Tan;
    float grooveAngel2;
    float grooveAngel2Tan;
    float x;
    float y;
    float z;
    float angel;
    float s;
    float basic_x;
    float basic_y;
    float rootFace;

    float c1;
    float c2;
    float c3;
    float c4;
    float c5;
    float c6;
    float c7;
    float c8;
}grooveRulesType;

typedef struct {
    //焊接中心线x
    float weldLineX;
    //焊接中心线y
    float weldLineY;
    //起弧坐标x
    float startArcX;
    //起弧坐标Y
    float startArcY;
    //起弧坐标Z
    float startArcZ;
    //收弧坐标X
    float stopArcX;
    //收弧坐标Y
    float stopArcY;
    //收弧坐标Z
    float stopArcZ;
}weldPointType;

/*焊接相关数据结构*/
typedef struct {
    //索引
    int index;
    //层号
    int floor;
    //道号
    int num;
    //焊接电流
    int weldCurrent;
    //焊接电压
    float weldVoltage;
    //送丝速度
    float weldFeedSpeed;
    //焊接速度
    float weldTravelSpeed;
    //摆动速度
    float swingSpeed;
    //前停留
    float outSwingStayTime;
    //后停留
    float interSwingStayTime;
    //摆动频率
    float swingHz;
    //摆动宽度
    float swingLength;
    //摆动间隔
    float A;
    //填充量
    float weldFill;
    //停止时间
    float stopTime;
    //层填充量
    float s;
    //坐标点
   // weldPointType *pWeldPoint;
    QString name;

}weldDataType;

typedef struct{
    //焊接数据存储表格
    weldDataType weldDataTable[MAX_WELDNUM];
    //焊接坐标点表格
    weldPointType weldPointTable[MAX_WELDNUM];
    //道深度
    int length;
}weldDataFloorType;

typedef struct{
    //每层数据表格
    weldDataFloorType weldDataFloorTable[MAX_WELDFLOOR];
    //参数表格
    int length;
    //坡口参数
    grooveRulesType grooveRules;
    int totalNum;
}weldDataTableType;

typedef struct{
    //焊接电流
    int weldCurrent;
    //焊接电压
    float weldVoltage;
    //送丝速度
    float swingLength;
    //焊接速度
    float weldTravelSpeed;
    //摆动速度
    float swingSpeed;
    //焊接中心线x
    float x;
    //焊接中心线y
    float y;
    //前停留
    float outSwingStayTime;
    //后停留
    float interSwingStayTime;
}modBusWeldType;

typedef struct{
    int32_t  travel;
    int avc;
    int swing;
    int rock;
}motoPointType;

typedef struct{
    unsigned char rockWay;
    unsigned char teachMode;
    unsigned char startEnd;
    unsigned char teachFirstPoint;
    unsigned char teachPoint;
    int length;
}teachSetType;

typedef struct{
    //焊接电流
    int weldCurrent;
    //焊接电压
    float weldVoltage;
    //焊接速度
    float weldTravelSpeed;
    //摆动速度
    float swingSpeed;
    //前停留
    float outSwingStayTime;
    //后停留
    float interSwingStayTime;
    //摆动宽度
    float swingLength;
    //停止时间
    float stopTime;
    //焊接中心线x
    float weldLineX;
    //焊接中心线y
    float weldLineY;
    //起弧坐标x
    float startArcX;
    //起弧坐标Y
    float startArcY;
    //起弧坐标Z
    float startArcZ;
    //收弧坐标X
    float stopArcX;
    //收弧坐标Y
    float stopArcY;
    //收弧坐标Z
    float stopArcZ;
}weldADDType;

#endif // GLOABLDEFINE
