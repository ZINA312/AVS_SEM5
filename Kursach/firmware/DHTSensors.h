#ifndef DHTSENSORS_H
#define DHTSENSORS_H

#include <DHT.h>
#include "response_struct.h"

#define DHTPIN0 22
#define DHTPIN1 23
#define DHTTYPE DHT22
#define LED_PIN 28
#define DIFFERENCE_THRESHOLD 5

DHT dht0(DHTPIN0, DHTTYPE);
DHT dht1(DHTPIN1, DHTTYPE);

void setupDHTSensors() {
    pinMode(LED_PIN, OUTPUT);
    dht0.begin();
    dht1.begin();
}

response readDHTSensors() {
    float hum0 = dht0.readHumidity();
    float hum1 = dht1.readHumidity();


    response resp;
    resp.ERR_LED_PIN = LED_PIN;
    resp.ErrorState = 0;
    resp.ErrorRate = 0;

    resp.data1 = hum0;
    resp.data2 = hum1;
    
    if (hum0 != NAN && hum1 != NAN){
      float difference = abs(hum0 - hum1);
      float average = (hum0 + hum1) / 2.0;
      float percentageDifference = (difference / average) * 100.0;
      resp.ErrorRate = percentageDifference;
      if (percentageDifference > DIFFERENCE_THRESHOLD) {
        resp.ErrorState = 1;
      }
    }
    else{
      resp.ErrorRate = NAN;
    }
    
    if (isnan(hum0) && isnan(hum1)) {
      resp.data1 = NAN; 
      resp.data2 = NAN;
      resp.ErrorState = 2;
      return resp;
    }

    if (isnan(hum0) || isnan(hum1)) {

        if (isnan(hum0)) {
            resp.data1 = NAN; 
            resp.data2 = hum1; 
        } else {
            resp.data1 = hum0; 
            resp.data2 = NAN; 
        }
        resp.ErrorState = 1;
    }

    return resp;
}

#endif // DHTSENSORS_H