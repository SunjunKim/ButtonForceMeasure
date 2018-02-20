/*
  Analog Input
  Demonstrates analog input by reading an analog sensor on analog pin 0 and
  turning on and off a light emitting diode(LED)  connected to digital pin 13.
  The amount of time the LED will be on and off depends on
  the value obtained by analogRead().

  The circuit:
   Potentiometer attached to analog input 0
   center pin of the potentiometer to the analog pin
   one side pin (either one) to ground
   the other side pin to +5V
   LED anode (long leg) attached to digital output 13
   LED cathode (short leg) attached to ground

   Note: because most Arduinos have a built-in LED attached
  to pin 13 on the board, the LED is optional.


  Created by David Cuartielles
  modified 30 Aug 2011
  By Tom Igoe

  This example code is in the public domain.

  http://arduino.cc/en/Tutorial/AnalogInput

*/

int repeat = 4;

int analogInPin = A0;    // select the input pin for the potentiometer
int sensorValue = 0;  // variable to store the value coming from the sensor

void setup() {
  Serial.begin(115200);
}

void loop() {
  int val[repeat];
  int i;

  if (repeat == 1)
  {
    sensorValue = analogRead(analogInPin);
  }
  else
  {
    int maxVal = 0, minVal = 1024;
    for (i = 0; i < repeat; i++) {
      val[i] = analogRead(analogInPin);
      maxVal = max(maxVal, val[i]);
      minVal = min(minVal, val[i]);
    }

    long sumVal = 0;
    for (i = 0; i < repeat; i++) {
      sumVal += val[i];
    }

    if (repeat > 2)
    {
      sumVal = sumVal - minVal - maxVal;
      sumVal = sumVal / (repeat - 2);
    }
    else
    {
      sumVal = sumVal / repeat;
    }

    sensorValue = sumVal;
  }


  Serial.println(sensorValue);
}
