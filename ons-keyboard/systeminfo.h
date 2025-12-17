// systeminfo.h my beloved <3
#ifndef SYSTEMINFO_H
#define SYSTEMINFO_H

#include <QObject>
#include <QString>
#include <QProcess>

class SystemInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString hostname READ hostname NOTIFY systemInfoChanged)
    Q_PROPERTY(QString distro READ distro NOTIFY systemInfoChanged)
    Q_PROPERTY(QString cpu READ cpu NOTIFY systemInfoChanged)
    Q_PROPERTY(QString ramUsed READ ramUsed NOTIFY systemInfoChanged)
    Q_PROPERTY(QString ramTotal READ ramTotal NOTIFY systemInfoChanged)
    Q_PROPERTY(QString cpuTemp READ cpuTemp NOTIFY systemInfoChanged)

public:
    explicit SystemInfo(QObject *parent = nullptr);
    
    QString hostname() const { return m_hostname; }
    QString distro() const { return m_distro; }
    QString cpu() const { return m_cpu; }
    QString ramUsed() const { return m_ramUsed; }
    QString ramTotal() const { return m_ramTotal; }
    QString cpuTemp() const { return m_cpuTemp; }
    
    Q_INVOKABLE void refresh();

signals:
    void systemInfoChanged();

private:
    QString execCommand(const QString &command);
    void fetchSystemInfo();
    
    QString m_hostname;
    QString m_distro;
    QString m_cpu;
    QString m_ramUsed;
    QString m_ramTotal;
    QString m_cpuTemp;
};

#endif // SYSTEMINFO_H
