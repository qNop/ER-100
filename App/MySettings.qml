import Qt.labs.settings 1.0

Settings{
    id:root
    category: "ER-100"
    property string primaryColor
    property string accentColor
    property string backgroundColor

    property string lastUserName
    property string currentUserName
    property string currentUserType
    property string currentUserPassword

    property int backLightValue

    property int weldStyle
    property int grooveStyle
    property int connectStyle

    property int bottomStyle
    property int bottomStyleWidth
    property int bottomStyleDeep

    property int xSpeed
    property int ySpeed
    property int zSpeed
    property int swingSpeed

    property int xMoto
    property int yMoto
    property int zMoto
    property int swingMoto

    property bool fixHeight;
    property bool fixAngel;
    property bool fixGap;
    //welding 0:kongxian 1:pokoujiance 2:hanjie
    property int welding;

    property int a;
    property int b;
    property int c;
    property int d;
    property int e;

    property bool fixWeld;

    property int cmd;
    property int top;
    property int bottom;

    property int deep;
    property int speed;
    property int xCenter;
    property int yCenter;

    property int bOut;
    property int bIn;
    property int tOut;
    property int tIn;


    property int arcAvcEn;
    property double arcAvcAdj;
    property int arcAvcMax;

    property int arcSwEn;
    property double arcSwAdj;
    property int arcSwMax;

    property int arcSwWEn;
    property double arcSwWAdj;
    property int arcSwWMax;

}

