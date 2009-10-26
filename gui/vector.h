/* 
 * File:   vector.h
 * Author: Michal Kottman
 *
 * Created on October 24, 2009, 11:16 PM
 */

#ifndef _VECTOR_H
#define	_VECTOR_H

class vector2 {
public:
    double x, y;

    vector2() : x(0), y(0) {
    }

    vector2(const vector2& orig) : x(orig.x), y(orig.y) {
    }

    vector2(double xx, double yy) : x(xx), y(yy) {
    }
    ~vector2();

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
    // Multiplication and division by scalar

    vector2 operator *(double a) const {
        return vector2(x*a, y*a);
    }

    vector2 operator /(double a) const {
        double oneOverA = 1.0f / a; // NOTE: no check for divide by zero here
        return vector2(x*oneOverA, y*oneOverA);
    }

};

#endif	/* _VECTOR_H */

