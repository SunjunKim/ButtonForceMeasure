# Button pressing force measurement device
# Last update: Feb 19, 2018
# Author: Sunjun Kim (kuaa.net@gmail.com)

Works with FSS 1500 sensor & 626 Bearing

# Parts needed
* M4 x (12--25 mm) * 3 ea (+ 3 M4 nuts)
* M6 x (15--25 mm) Flat head * 2ea
* M6 Tap (for making thread on DivingBoard part)
* 3D printed parts (See https://cad.onshape.com/documents/8884241d92b3924385b88df5/w/f3e7b9c0423dc323fdf4269c/e/ec01502cc8bd3c084f737220 for the latest version)

# Assembly
 - TBA

# Firmware
 - Upload FSS1500 to an Arduino ATMega328p (e.g., UNO) or ATMega32U4 (e.g., Leonardo) based board.
 - Serial baud rate: 115200
 - You can check the serial values from Arduino Serial monitor
 - You can log the values through the logSerial.sh bash script
  USAGE: ./logSerial.sh [PORT] [BAUD] [OUTPUT FILE]
  e.g., ./logSerial.sh /dev/tty.usbmodem1421 115200 log.csv

# Visualizer
 - Coded in Processing (tested with ver. 3.3.6, Check http://processing.org/)
 - It connects to the last serial port listed in the system (works with the most setup)
 - It first find the idle value (counting stabilized signal within <2 deviation)
 - After detecting a button press (other than idle value), it visualizes it with a graph (with some lead time before and after the button press).

 # Accelerometer
 - Accelerometer (Spartkfun ADXL335 breakout board) added to A2(X-axis), A3(Y-axis), A4(Z-axis)
 - Cx, Cy, Cz filtering capacitors --> set to 0.01uF (=500Hz bandwidth)
 - Fingertip mount ()
