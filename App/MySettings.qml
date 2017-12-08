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

}
