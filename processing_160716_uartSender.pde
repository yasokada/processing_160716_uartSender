import processing.serial.*;
import controlP5.*;
import java.util.*;

/*
 * v0.3 2016 Jul. 19
 *   - add ScrollableList for COM port selection
 *   - remove COM button
 *   - remove slider
 * v0.2 2016 Jul. 17
 *   - add getIntervaledValue()
 * v0.1 2016 Jul. 16
 *   - send text through COM port
 *   - add sendTestString() to send interval
 *   - add 1 second interval in draw()
 *   - add button to open COM port
 *   - add slider for COM port setting
 */

Serial myPort;

ControlP5 comList;
int sliderValue;
final int numSerial = 5;
int curSerial = -1;
int previousSecond = -1;


ControlP5 btnOpen;

void setup() {
  size(500,500);
  frameRate(10);
  
  comList = new ControlP5(this);
  List lst = Arrays.asList(Serial.list());
  
  comList.addScrollableList("dropdownCOM")
     .setPosition(100, 100)
     .setSize(200, 100)
     .setBarHeight(20)
     .setItemHeight(20)
     .addItems(Serial.list());     
}

void controlEvent(ControlEvent theEvent) {
}

void dropdownCOM(int n)
{
  println(n);
  curSerial = n;
  if (myPort != null) {
     myPort.stop(); 
     myPort = null;
  }
  myPort = new Serial(this, Serial.list()[curSerial], 9600);
  myPort.bufferUntil('\n');  
}

void serialEvent(Serial myPort) { 
   //String mystr = myPort.readStringUntil('\n');
   //mystr = trim(mystr);
   //println(mystr);
}

//void openPort() {
//   println("Open Port"); 
//   if (myPort != null) {
//      myPort.stop(); 
//   }
//   myPort = new Serial(this, Serial.list()[(int)curSerial], 9600);
//   myPort.bufferUntil('\n');
// }

float getIntervaledValue(float amplitude, int elapsed_sec)
{
  final float pi = acos(-1.0);
  final float itvl_sec = 10;
  
  float ret = amplitude * sin(2 * pi * elapsed_sec / itvl_sec);
  
  return ret;
}

void sendTestString()
{
  if (myPort == null) {
    return;
  }
  
  int elapsed_sec = millis() / 1000; 
  String wrkstr;
  
  if (curSerial >= 0) {
    String ret = str(elapsed_sec);
    wrkstr = String.format("%.2f", getIntervaledValue(/*amplitude=*/3.14, elapsed_sec) );
    ret = ret + "," + wrkstr;
    ret = ret + "\r\n";
//    ret = ret + ",3.14, 2.71, 6.022, 1023\r\n";
//    println(ret);
    myPort.write(ret);
  }
}

void draw() {
  background(0);  

  // for 1 second interval
  int curSec = second();
  if (curSec == previousSecond) {
    return;
  }
  previousSecond = curSec;
 
  //
  sendTestString();
}