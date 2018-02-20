/*
  FSS 1500 & Analog accelerometer (ADXL355) measurement
  
  Sunjun Kim

*/

int repeat = 1; // repeat counter for filtering the extreme values.

int analogInPin = A0;    // select the input pin for the potentiometer
int sensorValue = 0;  // variable to store the value coming from the sensor
int x, y, z;

int accelX = A2;
int accelY = A3;
int accelZ = A4;

unsigned long startTime;

void setup() {
  Serial.begin(115200);
  while (!Serial) ; // wait until the serial communication is estabilished.

  startTime = micros();

  pinMode(analogInPin, INPUT);
  pinMode(accelX, INPUT);
  pinMode(accelY, INPUT);
  pinMode(accelZ, INPUT);
}

void loop() {
  int val[repeat];
  int i;

  if(Serial.available() > 0)
  {
    Serial.read();
    startTime = micros();
  }

  unsigned long timestamp = micros() - startTime;

  analogRead(analogInPin); // discard one value reading, to reduce ADC switching noise. this will hold for 104us.
  sensorValue = analogRead(analogInPin);

  analogRead(accelZ);
  z = analogRead(accelZ);

  analogRead(accelY);
  y = analogRead(accelY);

  analogRead(accelX);
  x = analogRead(accelX);


  // encode values into little-endian bytes,
  // Send starting bit
  Serial.write( 0x0A );
  Serial.write( 0x41 );
  
  // Send timestamp (4 byte)
  Serial.write((timestamp)&0xff);
  Serial.write((timestamp>>8)&0xff);
  Serial.write((timestamp>>16)&0xff);
  Serial.write((timestamp>>24)&0xff);
  
  // Send values (2 bytes each)
  Serial.write( sensorValue & 0xff );
  Serial.write( (sensorValue >> 8) & 0xff );
  
  Serial.write( x & 0xff );
  Serial.write( (x >> 8) & 0xff );

  Serial.write( y & 0xff );
  Serial.write( (y >> 8) & 0xff );

  Serial.write( z & 0xff );
  Serial.write( (z >> 8) & 0xff );
}

