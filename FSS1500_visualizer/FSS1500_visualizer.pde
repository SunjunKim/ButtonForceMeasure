import processing.serial.*;

Serial buttonPort;
int lf = 10; // linefeed char

int[] valueArray = new int[10000];
int[] displayArray = null;
int displayDuration = 0;

int numValues = 0;

int idleValue = 0;
int stabilizationCount = 50;  // number of values needed for stabilization
int stabilizationLimt = 2;

int numMarginalData = 10;
int timeKeeper = 0;

float FPMS = 0;

void setup()
{
  size(1000, 500);
  String portName =  Serial.list()[Serial.list().length - 1];
  println(portName);
  buttonPort = new Serial(this, portName, 115200);
  buttonPort.clear();
  
  background(0);
}

void draw()
{
  while (buttonPort.available() > 0) 
  {
    String str = buttonPort.readStringUntil(lf);
    if (str != null)
    {
      try
      {
        int val = Integer.parseInt(trim(str));
        if (feedValue(val))
        {
          background(0);
          translate(50, 25);
          drawChart(900, 450, displayArray, FPMS);
        }
      } 
      catch(NumberFormatException e) {
      }
    }
  }
}

boolean feedValue(int v)
{ 
  if(numValues > 9999)
  {
    numValues = 0;
    idleValue = 0;
  }
  
  if (idleValue == 0)    // idle value not detected. Do idle value detection.
  {
    valueArray[numValues++] = v;
    if (numValues >= stabilizationCount) // if collected enough values...
    {
      // calculate variance
      boolean stabilized = true;
      double mean = valueArray[0];
      for (int i=1; i<stabilizationCount; i++)
      {
        mean += valueArray[i];
        if (abs(valueArray[i] - valueArray[0]) > stabilizationLimt) // if any value deviates overs the limit; stabilization is failed. 
        {
          stabilized = false;
        }
        numValues = 0;
      }

      if (stabilized)
      {
        idleValue = (int)(mean/stabilizationCount);
        println("Stabilized: "+idleValue);
      }
    }
    return false;
  } 

  // Collecting a data  
  valueArray[numValues++] = v;
  

  // check the last subsegment of the data
  boolean pressed = false;  
  if (numValues >= numMarginalData)
  {
    for (int i=numValues - numMarginalData; i<numValues; i++)
    {
      if (abs(valueArray[i] - idleValue) > stabilizationLimt)
      {
        pressed = true;
      }
    }
  }

  if (!pressed && numValues == numMarginalData)
  {
    // shift the window. (button not pressed)
    for (int i=1; i<numMarginalData; i++)
    {
      valueArray[i-1] = valueArray[i];
    }
    numValues--;
    timeKeeper = millis();
  } else if (!pressed && numValues > numMarginalData*3)
  {
    displayDuration = millis() - timeKeeper;

    displayArray = new int[numValues];
    for (int i=0; i<numValues; i++)
    {
      displayArray[i] = valueArray[i];
    }
    // frame per millisecond
    FPMS = (float)(numValues - numMarginalData) / displayDuration;
    println("detected a button press, collected "+numValues+" datapoints in "+ displayDuration +" ms");
    
    numValues = numMarginalData-1;
    return true;
  }

  return false;
}


void drawChart(int w, int h, int[] values, float fpms)
{
  int maxVal = 0;
  int nVal = values.length;
  // find the maximum value
  for (int i=0; i<nVal; i++)
  {
    maxVal = max(maxVal, values[i]);
  }

  // fine the nearest value rounded by 20
  int graphBound = max(300, (maxVal / 20 + 1) * 20);
  // fine the nearest tick value 
  float tick = 20 * fpms; // 50 ms in frame number
  int timeBound = (int)((int)(nVal/tick + 1) * tick) + 10;
  
  float hRatio = (float)h / graphBound;
  float wRatio = ((float)w-50) / timeBound;
 
  // draw lines
  textSize(12);
  strokeWeight(1);

  // draw Horizontal lines
  for (int i=0; i<=graphBound; i+=20)
  {
    if (i % 50 == 0)
    {
      fill(255);
      noStroke();
      text(""+i, 0, h - i * hRatio - 2);

      noFill();
      stroke(0xAA);
    } else
      stroke(0x77);

    line(0, h - i * hRatio, w, h - i * hRatio);
  }  
  
  float startFrame = numMarginalData-2;
  
  // draw vertical lines
  for(float i=startFrame;i<timeBound-numMarginalData;i+=tick)
  {
    fill(255);
    noStroke();
    text((int)((i-startFrame)/fpms)+" ms", 25 + i*wRatio + 5, h - 5);

    noFill();
    stroke(0x77);
    line(25 + i*wRatio , 0, 25 + i*wRatio, h);
  }

  for (int i=1; i<nVal-1; i++)
  {
    int p1 = values[i];
    int p2 = values[i+1];

    noFill();
    strokeWeight(2);
    stroke(0xFF, 0xFF, 0x00);

    line(25 + i*wRatio, h - p1*hRatio, 25 + (i+1)*wRatio, h - p2*hRatio);
  }
}