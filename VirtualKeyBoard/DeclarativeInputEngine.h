#ifndef DECLARATIVEINPUTENGINE_H
#define DECLARATIVEINPUTENGINE_H
//============================================================================
/// \file   DeclarativeInputEngine.h
/// \author Uwe Kindler
/// \date   08.01.2015
/// \brief  Declaration of CDeclarativeInputEngine
///
/// Copyright 2015 Uwe Kindler
/// Licensed under MIT see LICENSE.MIT in project root
//============================================================================

//============================================================================
//                                   INCLUDES
//============================================================================
#include <QObject>
#include <QRect>
#include <QQuickItem>

struct DeclarativeInputEnginePrivate;

/**
 * The input engine provides input context information and is responsible
 * for routing input events to focused QML items.
 * The InputEngine can be accessed as singleton instance from QML
 */
class DeclarativeInputEngine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QRect keyboardRectangle READ keyboardRectangle WRITE setKeyboardRectangle NOTIFY keyboardRectangleChanged FINAL)
    Q_PROPERTY(int inputMode READ inputMode WRITE setInputMode NOTIFY inputModeChanged FINAL)
    Q_PROPERTY(QObject* inputPanel READ inputPanel WRITE setInputPanel NOTIFY inputPanelChanged)
    Q_PROPERTY(QStringList chineseList READ getchineseList WRITE setchineseList NOTIFY chineseListChanged FINAL)
    Q_ENUMS(InputMode)

private:
    DeclarativeInputEnginePrivate* d;

    friend class DeclarativeInputEnginePrivate;
public:
    QStringList getchineseList();
    QQuickItem* InputPanelItem;//输入焦点所在Item
    void setchineseList(QStringList list);
    /**
     * The InputMode enum provides a list of valid input modes
     */
    enum InputMode {Latin, Numeric, Chinese};
    /**
     * Creates a dclarative input engine with the given parent
     */
    explicit DeclarativeInputEngine(QObject *parent = 0);

    /**
     * Virtual destructor
     */
    virtual ~DeclarativeInputEngine();

    /**
     * Returns the kesyboard rectangle
     */
    QRect keyboardRectangle() const;

    /**
     * Returns the current input mode
     * \see InputMode for a list of valid input modes
     */
    int inputMode() const;

    QObject* inputPanel();

public slots:
    /**
     *
     */
    void macthing(QString str);
    /**
    * Use this function to set the current input mode
    * \see InputMode for a list of valid input modes
    */
    void setInputMode(int Mode);
    /**
     * This function sends the given text to the focused QML item
     * \note This function will get replaced by virtualKeyClick function later
     */
    void sendKeyToFocusItem(const QString &keyText);

    /**
     * Reports the active keyboard rectangle to the engine
     */
    void setKeyboardRectangle(const QRect& Rect);

    void setInputPanel(QObject* Object);

signals:

    /**
     * Notify signal of keyboardRectangle property
     */
    void keyboardRectangleChanged();
    /**
     * Notify signal of inputModep property
     */
    void inputModeChanged(int Mode);

    void chineseListChanged(QStringList list);

    void inputPanelChanged(QObject* Object);
}; // class CDeclarativeInputEngine


//---------------------------------------------------------------------------
#endif // DECLARATIVEINPUTENGINE_H
