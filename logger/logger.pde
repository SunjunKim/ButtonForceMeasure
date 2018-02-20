import processing.serial.*;


//long startTimestamp = System.nanoTime();
Serial myPort;
PrintWriter output;
long logCounter = 0;

// synchronize
int syncCount = 0;
byte[] inBuffer = new byte[100];
boolean synced = false;

byte checkByte1 = 0x0A; // lf
byte checkByte2 = 0x41; // 'A'

int messageLength = 2*4 + 4 + 2; // 4*2-byte values + 4-byte timestamp + 2-byte checkBytes 

void setup()
{
  frameRate(2000); // as fast as possible
  printArray(Serial.list());

  String portName = Serial.list()[Serial.list().length-1];
  myPort = new Serial(this, portName, 115200);
  myPort.write('a'); // reset the timestamp counter
  myPort.buffer(30);

  output = createWriter("log.csv");
}

void draw()
{
  if(synced)
    background(0,255,0); // green light when synecd and logging has started
  else
    background(255,0,0);
}

void serialEvent(Serial myPort) {
  if(!synced) // try to synchronize the first two checkbytes.
  {
    byte r = 0;
    if (syncCount == 0)
    {
      int nBytes = myPort.readBytesUntil(checkByte1, inBuffer);
      r = (byte)myPort.read();
      for (int i=0; i<messageLength-2; i++)
      {
        myPort.readChar();
      }
    } else
    {
      for (int i=0; i<messageLength; i++)
      {
        inBuffer[i] = (byte)myPort.read();
      }
      r = inBuffer[1];
    }
  
    if (r == checkByte2)
    {    
      syncCount++;
      //println("Sync try "+syncCount);
    } else
    {
      syncCount = 0;
    }
    
    if(syncCount == 50)
    {
      println("synced successfully");
      synced = true;
    }
  }
  else // synced.
  {
    for (int i=0; i<messageLength; i++)
    {
      inBuffer[i] = (byte)myPort.read();
    }
  
    if (inBuffer[0] != checkByte1 || inBuffer[1] != checkByte2)
    {
      println("out of sync!");
    }       
     
    // retrive byte values (little-endian) and convert them into numbers
    long timestamp = (long)(inBuffer[2]&0xff) 
                  + (long)(inBuffer[3]&0xff)*0x100 
                  + (long)(inBuffer[4]&0xff)*0x10000 
                  + (long)(inBuffer[5]&0xff)*0x1000000;

    // FSS1500 sensor value              
    int v = (int)(inBuffer[6]&0xff)
          + (int)(inBuffer[7]&0xff) * 0x100;
          
    // x, y, z acceleration values
    int x = (int)(inBuffer[8]&0xff)
          + (int)(inBuffer[9]&0xff) * 0x100;          
    int y = (int)(inBuffer[10]&0xff)
          + (int)(inBuffer[11]&0xff) * 0x100;
    int z = (int)(inBuffer[12]&0xff)
          + (int)(inBuffer[13]&0xff) * 0x100;          
    
    
    output.println(timestamp+","+v+","+x+","+y+","+z);
    output.flush();

    logCounter++;

    if (logCounter%1000 == 0)
    {
      println("logged "+(logCounter/1000)+"k logs");
    }
  }
}