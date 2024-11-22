#include <Arduino.h>
#include "DHTSensors.h"
#include "BMPSensors.h"
#include "Anemometer.h"
#include "ReedSwitches.h"

#define DIFFERENCE_THRESHOLD 5
#define ANEMO_DIFFERENCE_THRESHOLD 20
#define LED_PIN 24
static unsigned long previousMillis = 0;

response DHT_Response;
response BMP_Response;
response Anemo_Response;
response Reed_Response;

void setup() {
    Serial.begin(9600);
    setupDHTSensors();
    setupBMPSensors();
    setupAnemometer();
    setupReedSwitches();
    pinMode(LED_PIN, OUTPUT);
}

void loop() {
    delay(100);
    DHT_Response = readDHTSensors();
    manageLED(DHT_Response.ERR_LED_PIN, DHT_Response.ErrorState);
    BMP_Response = readBMPSensors();
    manageLED(BMP_Response.ERR_LED_PIN, BMP_Response.ErrorState);
    Anemo_Response = readAnemometers();
    manageLED(Anemo_Response.ERR_LED_PIN, Anemo_Response.ErrorState);
    Reed_Response = readReedSwitches();
    manageLED(Reed_Response.ERR_LED_PIN, Reed_Response.ErrorState);

    if (canOpenRoof() == false)
    {
      Serial.println("Cant open roof"); 
      digitalWrite(LED_PIN, LOW);
    }
    else{
      Serial.println("Can open roof"); 
      digitalWrite(LED_PIN, HIGH);
    }
}

void manageLED(short int PIN, short int errorState) {
    const long interval = 100; // Интервал для мигания

    if (errorState == 0) {
        digitalWrite(PIN, LOW); // Выключаем светодиод
    } else if (errorState == 1) {
        // Мигает
        unsigned long currentMillis = millis();
        if (currentMillis - previousMillis >= interval) {
          for(int i = 0; i < 10; i++){
            
            int ledState = digitalRead(PIN);
            delay(100);
            digitalWrite(PIN, !ledState); // Переключаем состояние
          }
          previousMillis = currentMillis;
            
        }
    } else if (errorState == 2) {
        digitalWrite(PIN, HIGH); // Постоянное горение
    }
}

bool canOpenRoof() {
    bool DHT_NAN = isnan(DHT_Response.data1) && isnan(DHT_Response.data2);
    bool BMP_NAN = isnan(BMP_Response.data1) && isnan(BMP_Response.data2);
    bool Anemo_NAN = isnan(Anemo_Response.data1) && isnan(Anemo_Response.data2);
    bool Reed_NAN = isnan(Reed_Response.data1) && isnan(Reed_Response.data2);

    if (DHT_NAN || BMP_NAN || Anemo_NAN || Reed_NAN) {
        return false; 
    }

    if(DHT_Response.ErrorRate > DIFFERENCE_THRESHOLD || BMP_Response.ErrorRate > DIFFERENCE_THRESHOLD || 
        Anemo_Response.ErrorRate > ANEMO_DIFFERENCE_THRESHOLD || Reed_Response.ErrorRate > DIFFERENCE_THRESHOLD){
          return false;
        }

    float dht_value = DHT_NAN ? DHT_Response.data2 : DHT_Response.data1;
    float bmp_value = BMP_NAN ? BMP_Response.data2 : BMP_Response.data1;
    float anemo_value = Anemo_NAN ? Anemo_Response.data2 : Anemo_Response.data1;

    if (dht_value > 85 || bmp_value < 950 || anemo_value > 54) {
        return false; 
    }

    return true; 
}
