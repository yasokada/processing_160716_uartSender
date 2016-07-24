import processing.serial.*;
import controlP5.*;
import java.util.*;

/*
 * v0.5 2016 Jul. 25
 *   - add checkbox to turn ON/OFF the output of items
 *   - refactor for array usage
 * v0.4 2016 Jul. 22
 *   - comment out index serial tx
 *   - add slider to change interval second
 *   - add slider to change amplitude of the data
 *     + modify sendTestString() to use the amplitude
 *     + add amplitudeUI_setup()
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

ControlP5 cp5;
int sliderValue;
final int numSerial = 5;
int curSerial = -1;
int previousSecond = -1;

CheckBox checkbox;

final String kAmplitudeName1 = "amplitude1";
final String kAmplitudeName2 = "amplitude2";
final String kAmplitudeName3 = "amplitude3";
final String kAmplitudeName4 = "amplitude4";
final String kIntervalUI = "interval_sec";

ControlP5 btnOpen;

void amplitudeUI_setup() {
    cp5.addSlider(kAmplitudeName1)
      .setPosition(100, 250)
      .setSize(20, 140)
      .setRange(0, 300)
      .setValue(31.41)
      ;
    cp5.addSlider(kAmplitudeName2)
      .setPosition(170, 250)
      .setSize(20, 140)
      .setRange(0, 300)
      .setValue(27.18)
      ;
    cp5.addSlider(kAmplitudeName3)
      .setPosition(240, 250)
      .setSize(20, 140)
      .setRange(0, 300)
      .setValue(60.22)
      ;
    cp5.addSlider(kAmplitudeName4)
      .setPosition(310, 250)
      .setSize(20, 140)
      .setRange(0, 300)
      .setValue(102.3)
      ;
}

void intervalUI_setup() {
    cp5.addSlider(kIntervalUI)
      .setPosition(100, 420)
      .setSize(250, 20)
      .setRange(1, 300)
      .setValue(10)
      ;    
}

void turnOnOffUI_setup() {
  checkbox = cp5.addCheckBox("checkBox")
    .setPosition(100, 220)
    .setSize(20, 20)
    .setItemsPerRow(4)
    .setSpacingColumn(50)
    .addItem("ITEM0", 0)
    .addItem("ITEM1", 1)
    .addItem("ITEM2", 2)
    .addItem("ITEM3", 3) 
    ;
}

void setup() {
  size(500,500);
  frameRate(10);
  
  cp5 = new ControlP5(this);
  
  amplitudeUI_setup();
  intervalUI_setup();
  turnOnOffUI_setup();

  List lst = Arrays.asList(Serial.list());
  
  cp5.addScrollableList("dropdownCOM")
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
  //final float itvl_sec = 10;
  int itvl_sec = int( cp5.getController(kIntervalUI).getValue() );
  
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
  final int numItems = 4;
  
  if (curSerial >= 0) {
    String ret = "";
    float[] amplitude = new float[numItems];
    amplitude[0] = cp5.getController(kAmplitudeName1).getValue();
    amplitude[1] = cp5.getController(kAmplitudeName2).getValue();
    amplitude[2] = cp5.getController(kAmplitudeName3).getValue();
    amplitude[3] = cp5.getController(kAmplitudeName4).getValue();

    wrkstr = "";
    for(int idx=0; idx<numItems; idx++) {
      int ckd = (int)checkbox.getArrayValue()[idx];
      if (ckd == 0) {
        continue;
      }
      if (wrkstr.length() > 0) {
        wrkstr = wrkstr + "  ";
      }
      wrkstr = wrkstr + String.format("%.2f", getIntervaledValue(amplitude[idx], elapsed_sec) );
    }
      
    //ret = str(elapsed_sec);
    //ret = ret + "  " + wrkstr;
    ret = wrkstr;

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