#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QtQml>

#include "appmanager.h"

int main(int argc, char *argv[])
{
    qmlRegisterType<AppManager>("App", 1, 0, "AppManager");

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    return app.exec();
}
