/**
* REALLY simple processing sketch for using webcam input
* This sends 100 input values to port 6448 using message /wek/inputs
**/

import processing.video.*;
import processing.sound.*;
import oscP5.*;

import netP5.*;


float myHue, myfeq;

int numPixelsOrig;
int numPixels;
boolean first = true;

int boxWidth = 64;
int boxHeight = 48;

int numHoriz = 640/boxWidth;
int numVert = 480/boxHeight;

color[] downPix = new color[numHoriz * numVert];


Capture video;

OscP5 oscP5;
SinOsc sine;
NetAddress dest;

void setup() {
 // colorMode(HSB);
  myHue = 255;
  myfeq = 1;
  //sendOscNames();
  
  sine = new SinOsc(this);

  
  size(640, 480, P2D);
  
  

  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    video = new Capture(this, 640, 480);
  } if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
   /* println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    } */

   video = new Capture(this, 640, 480);
    
    // Start capturing the images from the camera
    video.start();
    
    numPixelsOrig = video.width * video.height;
    loadPixels();
    noStroke();
  }
  
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);
  dest = new NetAddress("127.0.0.1",6448);
  
}

void draw() {

  if (video.available() == true) {
    video.read();
    
    video.loadPixels(); // Make the pixels of video available
    /*for (int i = 0; i < numPixels; i++) {
      int x = i % video.width;
      int y = i / video.width;
      float xscl = (float) width / (float) video.width;
      float yscl = (float) height / (float) video.height;
      
      float gradient = diff(i, -1) + diff(i, +1) + diff(i, -video.width) + diff(i, video.width);
      fill(color(gradient, gradient, gradient));
      rect(x * xscl, y * yscl, xscl, yscl);
    } */
  int boxNum = 0;
  int tot = boxWidth*boxHeight;
  for (int x = 0; x < 640; x += boxWidth) {
     for (int y = 0; y < 480; y += boxHeight) {
        float red = 0, green = 0, blue = 0;
        
        for (int i = 0; i < boxWidth; i++) {
           for (int j = 0; j < boxHeight; j++) {
              int index = (x + i) + (y + j) * 640;
              red += red(video.pixels[index]);
              green += green(video.pixels[index]);
              blue += blue(video.pixels[index]);
           } 
        }
       downPix[boxNum] =  color(red/tot, green/tot, blue/tot);
      // downPix[boxNum] = color((float)red/tot, (float)green/tot, (float)blue/tot);
       fill(downPix[boxNum]);
       
       int index = x + 640*y;
       red += red(video.pixels[index]);
       green += green(video.pixels[index]);
       blue += blue(video.pixels[index]);
      // fill (color(red, green, blue));
       rect(x, y, boxWidth, boxHeight);
       boxNum++;
      /* if (first) {
         println(boxNum);
       } */
     } 
  }
  if(frameCount % 2 == 0)
    sendOsc(downPix);

  }
  first = false;
  
  if (myfeq == 400){
  
  sine.freq(523.25);
  sine.play();
  
  } else if (myfeq == 800){
  
  sine.freq(783.99);
  sine.play();
    
  } else if (myfeq == 1200){
    
    sine.freq(1046.50);
    sine.play();
    
  } else if (myfeq == 1600){
  
    sine.freq(1174.66);
    sine.play();
  } else if (myfeq == 2000){
  sine.freq(1318.51);
  sine.play();
  } else {
  sine.stop();
  }
  print(myfeq);
  pushMatrix();
  popMatrix();

}

float diff(int p, int off) {
  if(p + off < 0 || p + off >= numPixels)
    return 0;
  return red(video.pixels[p+off]) - red(video.pixels[p]) +
         green(video.pixels[p+off]) - green(video.pixels[p]) +
         blue(video.pixels[p+off]) - blue(video.pixels[p]);
}

void oscEvent(OscMessage theOscMessage) {
 if (theOscMessage.checkAddrPattern("/wek/outputs")==true) {
     if(theOscMessage.checkTypetag("f")) { // looking for 2 parameters
        float receivedfeq = theOscMessage.get(0).floatValue();
        myfeq = map(receivedfeq, 0, 1, 0, 400);
     
       // println("Received new output values from Wekinator");  
      } else {
        println("Error: unexpected OSC message received by Processing: ");
        theOscMessage.print();
      }
 }
}

void sendOsc(int[] px) {
  OscMessage msg = new OscMessage("/wek/inputs");
 // msg.add(px);
   for (int i = 0; i < px.length; i++) {
      msg.add(float(px[i])); 
   }
   oscP5.send(msg, dest);
  
}

/*void sendOscNames(){
  
  OscMessage msg = new OscMessage("/wekinator/control/setOutputNames");
  msg.add("Size");
  oscP5.send(msg, dest);
}*/
