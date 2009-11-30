/* 
 * File:   incidence.h
 * Author: miky
 *
 * Created on November 3, 2009, 2:20 PM
 */

#ifndef _INCIDENCE_H
#define	_INCIDENCE_H

#include <QString>
#include <QHash>

enum IncidenceDirection {
    ERROR=0, IN=1, OUT=2
};

class Incidence {
public:
    Incidence() {}
    Incidence(QString nName, IncidenceDirection dDir) : name(nName), dir(dDir) {}

    QString name;
    IncidenceDirection dir;
};

inline uint qHash(const Incidence &i) {
    return qHash(i.name) ^ i.dir;
}

inline bool operator ==(const Incidence &i1, const Incidence &i2) {
    return i1.name == i2.name;
}

#endif	/* _INCIDENCE_H */

