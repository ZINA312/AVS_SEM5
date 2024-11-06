#ifndef REEDSWITCHES_H
#define REEDSWITCHES_H

#include "response_struct.h"

#define REED_SWITCH1_PIN 3
#define REED_SWITCH2_PIN 18

#define LED_PIN 25

void setupReedSwitches() {
    pinMode(REED_SWITCH1_PIN, INPUT_PULLUP);
    pinMode(REED_SWITCH2_PIN, INPUT_PULLUP);
    pinMode(LED_PIN, OUTPUT); 
}

response readReedSwitches() {
    response resp;
    resp.ErrorState = 0;
    resp.ErrorRate = 0;
    resp.ERR_LED_PIN = LED_PIN;

    resp.data1 = digitalRead(REED_SWITCH1_PIN) == HIGH ? 1 : 0;
    resp.data2 = digitalRead(REED_SWITCH2_PIN) == HIGH ? 1 : 0;

    if(resp.data1 != resp.data2){
      resp.ErrorState = 1;
      resp.ErrorRate = 100;
    }
    if(resp.data1 == 0 && resp.data2 == 0){
      resp.ErrorState = 0;
    }
    if(resp.data1 == 1 && resp.data2 == 1){
      resp.ErrorState = 2;
    }
    
    return resp;
}

#endif // REEDSWITCHES_H