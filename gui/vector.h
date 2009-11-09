/* 
 * File:   vector.h
 * Author: Michal Kottman
 *
 * Created on October 24, 2009, 11:16 PM
 */

#ifndef _MY_VECTOR_H
#define	_MY_VECTOR_H

#include <math.h>
#include <QPointF>

class vector2 {
public:
    double x, y;

    vector2() : x(0), y(0) {
    }

    vector2(const QPointF &p) : x(p.x()), y(p.y()) {}

    vector2(const vector2& orig) : x(orig.x), y(orig.y) {}

    vector2(double xx, double yy) : x(xx), y(yy) {
    }

    ~vector2() {}

    vector2 & operator =(const vector2 &a) {
        x = a.x;
        y = a.y;
        return *this;
    }

    vector2 operator -() const {
        return vector2(-x, -y);
    }

    vector2 operator +(const vector2 &a) const {
        return vector2(x + a.x, y + a.y);
    }

    vector2 operator -(const vector2 &a) const {
        return vector2(x - a.x, y - a.y);
    }

    void operator +=(const vector2 &a) {
        x += a.x; y += a.y;
    }

    void operator -=(const vector2 &a) {
        x -= a.x; y -= a.y;
    }

    vector2 operator *(double a) const {
        return vector2(x*a, y*a);
    }

    void operator *=(double a) {
       x *= a; y *= a;
    }

    vector2 operator /(double a) const {
        double oneOverA = 1.0f / a;
        return vector2(x*oneOverA, y*oneOverA);
    }

    void operator /=(double a) {
        double oneOverA = 1.0f / a;
        x *= oneOverA; y *= oneOverA;
    }

    double length() const {
        return sqrt(x*x + y*y);
    }

    void normalize() {
        double len = length();
        *this /= len;
    }

};

#endif	/* _MY_VECTOR_H */

