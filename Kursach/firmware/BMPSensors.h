#ifndef BMPSENSORS_H
#define BMPSENSORS_H

#include <SFE_BMP180.h>
#include "response_struct.h"

#define BMP_SELECT_PIN 19
#define LED_PIN 27 
#define DIFFERENCE_THRESHOLD 5

SFE_BMP180 bmp1, bmp2;

void setupBMPSensors() {
    pinMode(BMP_SELECT_PIN, OUTPUT);
    pinMode(LED_PIN, OUTPUT); 

    digitalWrite(BMP_SELECT_PIN, HIGH);
    bmp1.begin();

    digitalWrite(BMP_SELECT_PIN, LOW);
    bmp2.begin();   
}

response readBMPSensors() {
    response resp;
    resp.ErrorState = 0;
    resp.ErrorRate = 0;
    resp.ERR_LED_PIN = LED_PIN;

    bool sensor1Failed = false;
    bool sensor2Failed = false;

    char status1, status2;
    double T1, T2, P1, P2;

    digitalWrite(BMP_SELECT_PIN, HIGH);
    status1 = bmp1.startPressure(3);
    digitalWrite(BMP_SELECT_PIN, LOW);
    status2 = bmp2.startPressure(3);

    if (status1 != 0 || status2 != 0) {
        delay(max(status1, status2));
        digitalWrite(BMP_SELECT_PIN, HIGH);
        status1 = bmp1.getPressure(P1, T1);
        digitalWrite(BMP_SELECT_PIN, LOW);
        status2 = bmp2.getPressure(P2, T2);

        if (status1 != 0) {
            resp.data1 = P1; 
        }
        if (status2 != 0) {
            resp.data2 = P2; 
        }
    }
    if (status1 == 0){
      sensor1Failed = true;
      resp.data1 = NAN;
    }
    if (status2 == 0){
      sensor2Failed = true;
      resp.data2 = NAN;
    }

    if (P1 != NAN && P2 != NAN){
      float difference = abs(P1 - P2);
      float average = (P1 + P2) / 2.0;
      float percentageDifference = (difference / average) * 100.0;
      resp.ErrorRate = percentageDifference;
      if (percentageDifference > DIFFERENCE_THRESHOLD) {
        resp.ErrorState = 1;
      }
    }
    else{
      resp.ErrorRate = NAN;
    }

    if (sensor1Failed && sensor2Failed) {
        resp.ErrorState = 2;
    } else if (sensor1Failed || sensor2Failed) {
        resp.ErrorState = 1;
    } 

    return resp;
}

#endif // BMPSENSORS_H