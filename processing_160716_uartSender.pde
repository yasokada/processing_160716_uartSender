import processing.serial.*;
import controlP5.*;

Serial myPort;

ControlP5 slider;
int sliderValue;
int numSerial = 5;
int curSerial = -1;

ControlP5 btnOpen;

void setup() {
  size(500,500);
  frameRate(10);
  slider = new ControlP5(this);
  slider.addSlider("COM")
    .setRange(-1, numSerial - 1)
    .setValue(-1)
    .setPosition(50,40)
    .setSize(200, 20)
    .setNumberOfTickMarks(numSerial + 1);

  btnOpen = new ControlP5(this);
  btnOpen.addButton("openPort")
    .setLabel("Open")
    .setPosition(275, 40)
    .setSize(100, 30);    
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isController()) {
     if (theEvent.getName() == "COM") {
       if (curSerial != slider.getValue("COM")) {
         curSerial = (int)slider.getValue("COM");
       }
     }
  }
}

void serialEvent(Serial myPort) { 
   String mystr = myPort.readStringUntil('\n');
   mystr = trim(mystr);
   println(mystr);
}

void openPort() {
   println("Open Port"); 
   if (myPort != null) {
      myPort.stop(); 
   }
   myPort = new Serial(this, Serial.list()[(int)curSerial], 9600);
   myPort.bufferUntil('\n');
 }

void sendTestString()
{
  if (myPort == null) {
    return;
  }
  if (curSerial >= 0) {
    String ret = "3.14, 2.71, 6.022, 1023\r\n";
//    println(ret);
    myPort.write(ret);
  }
}


int preSec = -1;
void draw() {
  background(0);  

  // for 1 second interval
  int curSec = second();
  if (curSec == preSec) {
    return;
  }
  preSec = curSec;
 
  //
  sendTestString();
}