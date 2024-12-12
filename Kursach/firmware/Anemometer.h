#ifndef ANEMOMETER_H
#define ANEMOMETER_H

#include <FreqCount.h>
#include "response_struct.h"

#define ANEMO_SELECT_PIN 2
#define LED_PIN 26 
#define DIFFERENCE_THRESHOLD 20

const unsigned long TIMEOUT = 2000; 
const unsigned long THRESHOLD = 5;  

void setupAnemometer() {
    pinMode(ANEMO_SELECT_PIN, OUTPUT);
    pinMode(LED_PIN, OUTPUT); 
}

bool checkAnemometerConnection() {
  unsigned long startMillis = millis();
  unsigned long count = 0;
  FreqCount.begin(500);
  while (millis() - startMillis < TIMEOUT) {
      if (FreqCount.available()) {
          FreqCount.end();
          count += FreqCount.read();
      }
  }
  return count > THRESHOLD;
}

response readAnemometers() {
    response resp;
    resp.ErrorState = 0;
    resp.ErrorRate = 0;
    resp.ERR_LED_PIN = LED_PIN;

    digitalWrite(ANEMO_SELECT_PIN, HIGH);
    bool connected1 = checkAnemometerConnection();
    digitalWrite(ANEMO_SELECT_PIN, LOW);
    bool connected2 = checkAnemometerConnection();
    int count1 = 0, count2 = 0;
    
    digitalWrite(ANEMO_SELECT_PIN, HIGH);
    if (connected1) {
      FreqCount.begin(500);
      while(!FreqCount.available()){continue;}
      FreqCount.end();
      count1 = FreqCount.read();
      resp.data1 = count1 * 0.01; 
    }
    else{
      resp.data1 = NAN;
    }
    
    digitalWrite(ANEMO_SELECT_PIN, LOW);
    if (connected2) {
      FreqCount.begin(500);
      while(!FreqCount.available()){continue;}
      FreqCount.end();
      count2 = FreqCount.read();
      resp.data2 = count2 * 0.01; 
    }
    else{
      resp.data2 = NAN; 
    }

    if (connected1 && connected2 ){
      float difference = abs(count1 - count2);
      float average = (count1 + count2) / 2.0;
      float percentageDifference = (difference / average) * 100.0;
      resp.ErrorRate = percentageDifference;
      if (percentageDifference > DIFFERENCE_THRESHOLD) {
        resp.ErrorState = 1;
      }
    }
    else{
      resp.ErrorRate = NAN;
    }

    if (!connected1 && !connected2) {
        resp.ErrorState = 2;
    } else if (!connected1 || !connected2) {
        resp.ErrorState = 1;
    } 

    return resp;
}

#endif // ANEMOMETER_H