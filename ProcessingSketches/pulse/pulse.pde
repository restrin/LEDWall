// "Adalight" is a do-it-yourself facsimile of the Philips Ambilight concept
// for desktop computers and home theater PCs.  This is the host PC-side code
// written in Processing, intended for use with a USB-connected Arduino
// microcontroller running the accompanying LED streaming code.  Requires one
// or more strands of Digital RGB LED Pixels (Adafruit product ID #322,
// specifically the newer WS2801-based type, strand of 25) and a 5 Volt power
// supply (such as Adafruit #276).  You may need to adapt the code and the
// hardware arrangement for your specific display configuration.
// Screen capture adapted from code by Cedrik Kiefer (processing.org forum)

// --------------------------------------------------------------------
//   This file is part of Adalight.

//   Adalight is free software: you can redistribute it and/or modify
//   it under the terms of the GNU Lesser General Public License as
//   published by the Free Software Foundation, either version 3 of
//   the License, or (at your option) any later version.

//   Adalight is distributed in the hope that it will be useful,
//   but WITHOUT ANY WARRANTY; without even the implied warranty of
//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//   GNU Lesser General Public License for more details.

//   You should have received a copy of the GNU Lesser General Public
//   License along with Adalight.  If not, see
//   <http://www.gnu.org/licenses/>.
// --------------------------------------------------------------------

import java.awt.*;
import java.awt.image.*;
import processing.serial.*;
import java.util.concurrent.ArrayBlockingQueue;
import ddf.minim.*;
import ddf.minim.analysis.*;

// CONFIGURABLE PROGRAM CONSTANTS --------------------------------------------

// Minimum LED brightness; some users prefer a small amount of backlighting
// at all times, regardless of screen content.  Higher values are brighter,
// or set to 0 to disable this feature.

static final short minBrightness = 120;

// LED transition speed; it's sometimes distracting if LEDs instantaneously
// track screen contents (such as during bright flashing sequences), so this
// feature enables a gradual fade to each new LED state.  Higher numbers yield
// slower transitions (max of 255), or set to 0 to disable this feature
// (immediate transition of all LEDs).

static final short fade = 75;

// Pixel size for the live preview image.

static final int pixelSize = 20;

// Depending on many factors, it may be faster either to capture full
// screens and process only the pixels needed, or to capture multiple
// smaller sub-blocks bounding each region to be processed.  Try both,
// look at the reported frame rates in the Processing output console,
// and run with whichever works best for you.

static final boolean useFullScreenCaps = true;

// Serial device timeout (in milliseconds), for locating Arduino device
// running the corresponding LEDstream code.  See notes later in the code...
// in some situations you may want to entirely comment out that block.

static final int timeout = 5000; // 5 seconds

// PER-DISPLAY INFORMATION ---------------------------------------------------

// This array contains details for each display that the software will
// process.  If you have screen(s) attached that are not among those being
// "Adalighted," they should not be in this list.  Each triplet in this
// array represents one display.  The first number is the system screen
// number...typically the "primary" display on most systems is identified
// as screen #1, but since arrays are indexed from zero, use 0 to indicate
// the first screen, 1 to indicate the second screen, and so forth.  This
// is the ONLY place system screen numbers are used...ANY subsequent
// references to displays are an index into this list, NOT necessarily the
// same as the system screen number.  For example, if you have a three-
// screen setup and are illuminating only the third display, use '2' for
// the screen number here...and then, in subsequent section, '0' will be
// used to refer to the first/only display in this list.
// The second and third numbers of each triplet represent the width and
// height of a grid of LED pixels attached to the perimeter of this display.
// For example, '9,6' = 9 LEDs across, 6 LEDs down.

static final int displays[][] = new int[][] {
   {0,18,11} // Screen 0, 18 LEDs across, 11 LEDs down
//,{1,9,6} // Screen 1, also 9 LEDs across and 6 LEDs down
};

// PER-LED INFORMATION -------------------------------------------------------

// This array contains the 2D coordinates corresponding to each pixel in the
// LED strand, in the order that they're connected (i.e. the first element
// here belongs to the first LED in the strand, second element is the second
// LED, and so forth).  Each triplet in this array consists of a display
// number (an index into the display array above, NOT necessarily the same as
// the system screen number) and an X and Y coordinate specified in the grid
// units given for that display.  {0,0,0} is the top-left corner of the first
// display in the array.
// For our example purposes, the coordinate list below forms a ring around
// the perimeter of a single screen, with a one pixel gap at the bottom to
// accommodate a monitor stand.  Modify this to match your own setup:

static final int leds[][] = new int[][] {
  {0,0,0}, {0,1,0}, {0,2,0}, {0,3,0}, {0,4,0}, {0,5,0}, {0,6,0}, {0,7,0}, {0,8,0}, {0,9,0}, {0,10,0}, {0,11,0}, {0,12,0}, {0,13,0}, {0,14,0}, {0,15,0}, {0,16,0}, {0,17,0}, {0,17,1}, {0,16,1}, {0,15,1}, {0,14,1}, {0,13,1}, {0,12,1}, {0,11,1}, {0,10,1}, {0,9,1}, {0,8,1}, {0,7,1}, {0,6,1}, {0,5,1}, {0,4,1}, {0,3,1}, {0,2,1}, {0,1,1}, {0,0,1}, {0,0,2}, {0,1,2}, {0,2,2}, {0,3,2}, {0,4,2}, {0,5,2}, {0,6,2}, {0,7,2}, {0,8,2}, {0,9,2}, {0,10,2}, {0,11,2}, {0,12,2}, {0,13,2}, {0,14,2}, {0,15,2}, {0,16,2}, {0,17,2}, {0,17,3}, {0,16,3}, {0,15,3}, {0,14,3}, {0,13,3}, {0,12,3}, {0,11,3}, {0,10,3}, {0,9,3}, {0,8,3}, {0,7,3}, {0,6,3}, {0,5,3}, {0,4,3}, {0,3,3}, {0,2,3}, {0,1,3}, {0,0,3}, {0,0,4}, {0,1,4}, {0,2,4}, {0,3,4}, {0,4,4}, {0,5,4}, {0,6,4}, {0,7,4}, {0,8,4}, {0,9,4}, {0,10,4}, {0,11,4}, {0,12,4}, {0,13,4}, {0,14,4}, {0,15,4}, {0,16,4}, {0,17,4}, {0,17,5}, {0,16,5}, {0,15,5}, {0,14,5}, {0,13,5}, {0,12,5}, {0,11,5}, {0,10,5}, {0,9,5}, {0,8,5}, {0,7,5}, {0,6,5}, {0,5,5}, {0,4,5}, {0,3,5}, {0,2,5}, {0,1,5}, {0,0,5}, {0,0,6}, {0,1,6}, {0,2,6}, {0,3,6}, {0,4,6}, {0,5,6}, {0,6,6}, {0,7,6}, {0,8,6}, {0,9,6}, {0,10,6}, {0,11,6}, {0,12,6}, {0,13,6}, {0,14,6}, {0,15,6}, {0,16,6}, {0,17,6}, {0,17,7}, {0,16,7}, {0,15,7}, {0,14,7}, {0,13,7}, {0,12,7}, {0,11,7}, {0,10,7}, {0,9,7}, {0,8,7}, {0,7,7}, {0,6,7}, {0,5,7}, {0,4,7}, {0,3,7}, {0,2,7}, {0,1,7}, {0,0,7}, {0,0,8}, {0,1,8}, {0,2,8}, {0,3,8}, {0,4,8}, {0,5,8}, {0,6,8}, {0,7,8}, {0,8,8}, {0,9,8}, {0,10,8}, {0,11,8}, {0,12,8}, {0,13,8}, {0,14,8}, {0,15,8}, {0,16,8}, {0,17,8}, {0,17,9}, {0,16,9}, {0,15,9}, {0,14,9}, {0,13,9}, {0,12,9}, {0,11,9}, {0,10,9}, {0,9,9}, {0,8,9}, {0,7,9}, {0,6,9}, {0,5,9}, {0,4,9}, {0,3,9}, {0,2,9}, {0,1,9}, {0,0,9}, {0,0,10}, {0,1,10}, {0,2,10}, {0,3,10}, {0,4,10}, {0,5,10}, {0,6,10}, {0,7,10}, {0,8,10}, {0,9,10}, {0,10,10}, {0,11,10}, {0,12,10}, {0,13,10}, {0,14,10}, {0,15,10}, {0,16,10}, {0,17,10}

/* Hypothetical second display has the same arrangement as the first.
   But you might not want both displays completely ringed with LEDs;
   the screens might be positioned where they share an edge in common.
 ,{1,3,5}, {1,2,5}, {1,1,5}, {1,0,5}, // Bottom edge, left half
  {1,0,4}, {1,0,3}, {1,0,2}, {1,0,1}, // Left edge
  {1,0,0}, {1,1,0}, {1,2,0}, {1,3,0}, {1,4,0}, // Top edge
           {1,5,0}, {1,6,0}, {1,7,0}, {1,8,0}, // More top edge
  {1,8,1}, {1,8,2}, {1,8,3}, {1,8,4}, // Right edge
  {1,8,5}, {1,7,5}, {1,6,5}, {1,5,5}  // Bottom edge, right half
*/
};

// GLOBAL VARIABLES ---- You probably won't need to modify any of this -------

byte[]           serialCopy  = new byte[6 + leds.length * 3];
byte[]           serialData  = new byte[6 + leds.length * 3];
short[][]        ledColor    = new short[leds.length][3],
                 prevColor   = new short[leds.length][3];
byte[][]         gamma       = new byte[256][3];
int              nDisplays   = displays.length;
Robot[]          bot         = new Robot[displays.length];
Rectangle[]      dispBounds  = new Rectangle[displays.length],
                 ledBounds;  // Alloc'd only if per-LED captures
int[][]          pixelOffset = new int[leds.length][256],
                 screenData; // Alloc'd only if full-screen captures
PImage[]         preview     = new PImage[displays.length];
Serial           port;
DisposeHandler   dh; // For disabling LEDs on exit

int              w           = 18;
int              h           = 11;
int              iterCnt     = 0;

Minim minim;
AudioPlayer song;
FFT fft;
BeatDetect beat;
BeatListener bl;
// INITIALIZATION ------------------------------------------------------------

void setup() {
  initialize();
  
  for (int i = 0; i < w; i++) {
    for (int j = 0; j < h; j++) {
      spc(i,j, (int) random((255 << 16) + (255 << 8) + 255));
    } 
  }
  
  minim = new Minim(this);
  song = minim.loadFile("C:/Users/Ron/Downloads/Paralyzer [With Lyrics] - Finger Eleven (1).mp3", 512);
  song.play();
  
  fft = new FFT(song.bufferSize(), song.sampleRate());
  beat = new BeatDetect(song.bufferSize(), song.sampleRate());
  beat.setSensitivity(10);
  bl = new BeatListener(beat, song);
}

// Open and return serial connection to Arduino running LEDstream code.  This
// attempts to open and read from each serial device on the system, until the
// matching "Ada\n" acknowledgement string is found.  Due to the serial
// timeout, if you have multiple serial devices/ports and the Arduino is late
// in the list, this can take seemingly forever...so if you KNOW the Arduino
// will always be on a specific port (e.g. "COM6"), you might want to comment
// out most of this to bypass the checks and instead just open that port
// directly!  (Modify last line in this method with the serial port name.)

Serial openPort() {
  String[] ports;
  String   ack;
  int      i, start;
  Serial   s;

  ports = Serial.list(); // List of all serial ports/devices on system.

  for(i=0; i<ports.length; i++) { // For each serial port...
    System.out.format("Trying serial port %s\n",ports[i]);
    try {
      s = new Serial(this, ports[i], 115200);
    }
    catch(Exception e) {
      // Can't open port, probably in use by other software.
      continue;
    }
    // Port open...watch for acknowledgement string...
    start = millis();
    while((millis() - start) < timeout) {
      if((s.available() >= 4) &&
        ((ack = s.readString()) != null) &&
        ack.contains("Ada\n")) {
          return s; // Got it!
      }
    }
    // Connection timed out.  Close port and move on to the next.
    s.stop();
  }

  // Didn't locate a device returning the acknowledgment string.
  // Maybe it's out there but running the old LEDstream code, which
  // didn't have the ACK.  Can't say for sure, so we'll take our
  // changes with the first/only serial device out there...
  return new Serial(this, ports[0], 115200);
}


// PER_FRAME PROCESSING ------------------------------------------------------

void draw () {
 
  fft.forward(song.mix);
//  if (iterCnt % 10 == 0)
    iterate();
  
  if ((fft.getBand(1) > 20 || fft.getBand(15) > 15 || beat.isKick()) && iterCnt % 3 == 0) {
    pulse((int) random(18), (int) random(11), (int) random((255 << 16) + (255 << 8) + 255));
  }
  
  preview();
  
  if(port != null) port.write(serialData); // Issue data to Arduino
  
  //println(frameRate); // How are we doing?

  // Copy LED color data to prior frame array for next pass
  arraycopy(ledColor, 0, prevColor, 0, ledColor.length);
  
  iterCnt += 1;
}

// HELPER FUNCTIONS ----------------------------------------------------------

// Show live preview image(s)
void preview() {
  color c;
  int r,g,b;
  noStroke();
  for(int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++) {
      r = serialData[3*(y*w + x) + 6];
      g = serialData[3*(y*w + x) + 1 + 6];
      b = serialData[3*(y*w + x) + 2 + 6];
      
      // Need to turn into unsigned value
      c = color(r & 0xff,
                g & 0xff,
                b & 0xff);
      fill(c);

      if (y % 2 == 0) {
        rect(x*20, y*20, 20, 20);
      }
      else {
        rect((w-x-1)*20, y*20, 20, 20);
      }
    }
  } 
}

// Colours the pixel at (x,y) (with 0 based indexing) to colour c
// c is 24-bit integer using RGB format
// IMPORTANT: Our board's wiring isn't fantastic, and there is  bit corruption
//            during transmission. Use colour values with as many 1's as possible
//            in the binary representation for the colour. Otherwise some pixels
//            will flicker or be the wrong colour (it's usually the same ones each
//            time. So change brightness accordingly.
//            eg/ 32 = 100000 is bad, 31 = 111111 is good.
void spc(int x, int y, int c) {
  if (0 <= y && y < h && 0 <= x && x < w) {
    if (y % 2 == 0) {
      serialData[6+3*(w*y + x)] = (byte) ((c >> 16) & 255);
      serialData[6+3*(w*y + x)+1] = (byte) ((c >> 8) & 255);
      serialData[6+3*(w*y + x)+2] = (byte) (c & 255);
    }
    else {
      serialData[6+3*(w*y + ((w - 1) - x))] = (byte) ((c >> 16) & 255);
      serialData[6+3*(w*y + ((w - 1) - x))+1] = (byte) ((c >> 8) & 255);
      serialData[6+3*(w*y + ((w - 1) - x))+2] = (byte) (c & 255);
    }
  }
}

void spc(int x, int y, Colour c) {
  spc(x, y, c.returnInt()); 
}

// Grabs pixel colour as 24 bit integer at position (x,y)
int gpc(int x, int y) {
  int r,g,b;
  if (0 <= y && y < h && 0 <= x && x < w) {
    if (y % 2 == 0) {
      r = serialCopy[3*(y*w + x) + 6];
      g = serialCopy[3*(y*w + x) + 1 + 6];
      b = serialCopy[3*(y*w + x) + 2 + 6];
    }
    else {
      r = serialCopy[6+3*(w*y + ((w - 1) - x))];
      g = serialCopy[6+3*(w*y + ((w - 1) - x))+1];
      b = serialCopy[6+3*(w*y + ((w - 1) - x))+2];
    }
    r &= 0xff;
    g &= 0xff;
    b &= 0xff;
    return (r << 16) + (g << 8) + b;
  } 
  return -1;
}

// sets the background colour
void clearBackground(int c) {
  for(int i = 0; i < w; i++) {
    for(int j = 0; j < h; j++) {
      spc(i,j,c);
    }
  } 
}

// SKETCH SPECIFIC FUNCTIONS -------------------------------------------------

// Performs one iteration, mixing a pixels adjacent colours
void iterate() {
   int new_i, new_j;
   byte[][] dir = {{1,0},{0,1},{-1,0},{0,-1}};
   
   // Swap the byte buffers
   byte [] temp = serialCopy;
   serialCopy = serialData;
   serialData = temp;
   
   Colour c;
   ArrayList<Colour> loc;
   for(int x = 0; x < w; x++) {
     for(int y = 0; y < h; y++) {
       
       c = new Colour(gpc(x,y));
       
       loc = new ArrayList<Colour>();
       
       for (int k = 0; k < 4; k++) {
         new_i = x + dir[k][0];
         new_j = y + dir[k][1];
         if (new_i >= w || new_j >= h || new_i < 0 || new_j < 0)
           continue;
         loc.add(new Colour(gpc(new_i, new_j)));
       }
       
       c.colourAdd(loc);
       if (c.colourNorm() > 200)
         c.colourScale(0.8);
       else {
         if (c.colourNorm() > 50)
           c.colourScale(0.9);
         else
           c.colourScale(1.05);
       }
       
       spc(x,y,c);
       
     }
   }
   
}

void pulse(int x, int y, int colour) {
  byte[][] dir = {{1,0},{0,1},{-1,0},{0,-1}};

  int i, j, new_i, new_j;
  Colour c, cc,o;
  
  // Map of already accessed pixels
  byte[] m = new byte[w*h];
  
  // Set m's elements to 0
  for (i = 0; i < w*h; i++)
    m[i] = 0;
  
  // Initialize queue for BFS
  ArrayBlockingQueue<Integer> q = new ArrayBlockingQueue<Integer>(2*w*h);
  q.add(x);
  q.add(y);
  c = new Colour(colour);
  spc(x,y,c);
  
  while (q.size() != 0) {
     i = q.remove();
     j = q.remove();
     // Set element as accessed
     m[j * w + i] = 1;
     
     for (int k = 0; k < 4; k++) {
       new_i = i + dir[k][0];
       new_j = j + dir[k][1];
       if (new_i >= w || new_j >= h || new_i < 0 || new_j < 0)
         continue;
       if (m[new_j * w + new_i] == 0) {
         o = new Colour(gpc(new_i, new_j));
         cc = new Colour(c.returnInt());
         cc.colourScale(1/pow((x-new_i)*(x-new_i) + (y-new_j)*(y-new_j), 0.75));
         o.colourAdd(cc);
         spc(new_i,new_j, o);
         q.add(new_i);
         q.add(new_j);
         m[new_j * w + new_i] = 1;
       }
     }
  }
}

// CLEANUP -------------------------------------------------------------------

// The DisposeHandler is called on program exit (but before the Serial library
// is shutdown), in order to turn off the LEDs (reportedly more reliable than
// stop()).  Seems to work for the window close box and escape key exit, but
// not the 'Quit' menu option.  Thanks to phi.lho in the Processing forums.

public class DisposeHandler {
  DisposeHandler(PApplet pa) {
    pa.registerDispose(this);
  }
  public void dispose() {
    // Fill serialData (after header) with 0's, and issue to Arduino...
//    Arrays.fill(serialData, 6, serialData.length, (byte)0);
    java.util.Arrays.fill(serialData, 6, serialData.length, (byte)0);
    if(port != null) port.write(serialData);
  }
}

// INITIALIZATION FUNCTION ---------------------------------------------------
void initialize() {
  GraphicsEnvironment     ge;
  GraphicsConfiguration[] gc;
  GraphicsDevice[]        gd;
  int                     d, i, totalWidth, maxHeight, row, col, rowOffset;
  int[]                   x = new int[16], y = new int[16];
  float                   f, range, step, start;

  dh = new DisposeHandler(this); // Init DisposeHandler ASAP

  // Open serial port.  As written here, this assumes the Arduino is the
  // first/only serial device on the system.  If that's not the case,
  // change "Serial.list()[0]" to the name of the port to be used:
  port = new Serial(this, Serial.list()[0], 115200);
  // Alternately, in certain situations the following line can be used
  // to detect the Arduino automatically.  But this works ONLY with SOME
  // Arduino boards and versions of Processing!  This is so convoluted
  // to explain, it's easier just to test it yourself and see whether
  // it works...if not, leave it commented out and use the prior port-
  // opening technique.
  // port = openPort();
  // And finally, to test the software alone without an Arduino connected,
  // don't open a port...just comment out the serial lines above.

  // Initialize screen capture code for each display's dimensions.
  dispBounds = new Rectangle[displays.length];
  if(useFullScreenCaps == true) {
    screenData = new int[displays.length][];
    // ledBounds[] not used
  } else {
    ledBounds  = new Rectangle[leds.length];
    // screenData[][] not used
  }
  ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
  gd = ge.getScreenDevices();
  if(nDisplays > gd.length) nDisplays = gd.length;
  totalWidth = maxHeight = 0;
  for(d=0; d<nDisplays; d++) { // For each display...
    try {
      bot[d] = new Robot(gd[displays[d][0]]);
    }
    catch(AWTException e) {
      System.out.println("new Robot() failed");
      continue;
    }
    gc              = gd[displays[d][0]].getConfigurations();
    dispBounds[d]   = gc[0].getBounds();
    dispBounds[d].x = dispBounds[d].y = 0;
    preview[d]      = createImage(displays[d][1], displays[d][2], RGB);
    preview[d].loadPixels();
    totalWidth     += displays[d][1];
    if(d > 0) totalWidth++;
    if(displays[d][2] > maxHeight) maxHeight = displays[d][2];
  }

  // Precompute locations of every pixel to read when downsampling.
  // Saves a bunch of math on each frame, at the expense of a chunk
  // of RAM.  Number of samples is now fixed at 256; this allows for
  // some crazy optimizations in the downsampling code.
  for(i=0; i<leds.length; i++) { // For each LED...
    d = leds[i][0]; // Corresponding display index

    // Precompute columns, rows of each sampled point for this LED
    range = (float)dispBounds[d].width / (float)displays[d][1];
    step  = range / 16.0;
    start = range * (float)leds[i][1] + step * 0.5;
    for(col=0; col<16; col++) x[col] = (int)(start + step * (float)col);
    range = (float)dispBounds[d].height / (float)displays[d][2];
    step  = range / 16.0;
    start = range * (float)leds[i][2] + step * 0.5;
    for(row=0; row<16; row++) y[row] = (int)(start + step * (float)row);

    if(useFullScreenCaps == true) {
      // Get offset to each pixel within full screen capture
      for(row=0; row<16; row++) {
        for(col=0; col<16; col++) {
          pixelOffset[i][row * 16 + col] =
            y[row] * dispBounds[d].width + x[col];
        }
      }
    } else {
      // Calc min bounding rect for LED, get offset to each pixel within
      ledBounds[i] = new Rectangle(x[0], y[0], x[15]-x[0]+1, y[15]-y[0]+1);
      for(row=0; row<16; row++) {
        for(col=0; col<16; col++) {
          pixelOffset[i][row * 16 + col] =
            (y[row] - y[0]) * ledBounds[i].width + x[col] - x[0];
        }
      }
    }
  }

  for(i=0; i<prevColor.length; i++) {
    prevColor[i][0] = prevColor[i][1] = prevColor[i][2] =
      minBrightness / 3;
  }

  // Preview window shows all screens side-by-side
  size(totalWidth * pixelSize, maxHeight * pixelSize, JAVA2D);
  noSmooth();

  // A special header / magic word is expected by the corresponding LED
  // streaming code running on the Arduino.  This only needs to be initialized
  // once (not in draw() loop) because the number of LEDs remains constant:
  serialData[0] = 'A';                              // Magic word
  serialData[1] = 'd';
  serialData[2] = 'a';
  serialData[3] = (byte)((leds.length - 1) >> 8);   // LED count high byte
  serialData[4] = (byte)((leds.length - 1) & 0xff); // LED count low byte
  serialData[5] = (byte)(serialData[3] ^ serialData[4] ^ 0x55); // Checksum

  // Pre-compute gamma correction table for LED brightness levels:
  for(i=0; i<256; i++) {
    f           = pow((float)i / 255.0, 2.8);
    gamma[i][0] = (byte)(f * 255.0);
    gamma[i][1] = (byte)(f * 240.0);
    gamma[i][2] = (byte)(f * 220.0);
  }
}

class Colour {
  public int r;
  public int g;
  public int b;
 
  public Colour(int r, int g, int b) {
    this.r = r;
    this.g = g;
    this.b = b;
  } 
  
  public Colour(int c) {
    this.r = (c >> 16) & 255;
    this.g = (c >> 8) & 255;
    this.b = c & 255; 
  }
  
  public void colourAdd(Colour o) {
//    r *= 0.7;
    r += 0.8*o.r;
//    g *= 0.7;
    g += 0.8*o.g;
//    b *= 0.7;
    b += 0.8*o.b;
  }
  
  public void colourAdd(Colour [] loc) {
     for(int i = 0; i < loc.length; i++) {
        r = (i+1)*r/(i+2) + loc[i].r/(i+2);
        g = (i+1)*g/(i+2) + loc[i].g/(i+2);
        b = (i+1)*b/(i+2) + loc[i].b/(i+2);
     }
  }
  
  public void colourAdd(ArrayList<Colour> loc) {
     for(int i = 0; i < loc.size(); i++) {
        r = (i+1)*r/(i+2) + loc.get(i).r/(i+2);
        g = (i+1)*g/(i+2) + loc.get(i).g/(i+2);
        b = (i+1)*b/(i+2) + loc.get(i).b/(i+2);
     }
  }
  
  public int colourNorm() {
    return max(r,g,b); 
  }
  
  public void colourScale(float s) {
    r *= s;
    g *= s;
    b *= s; 
  }
  
  public int returnInt() {
    return (r << 16) + (g << 8) + b;
  }
}

class BeatListener implements AudioListener
{
  private BeatDetect beat;
  private AudioPlayer source;
  
  BeatListener(BeatDetect beat, AudioPlayer source)
  {
    this.source = source;
    this.source.addListener(this);
    this.beat = beat;
  }
  
  void samples(float[] samps)
  {
    beat.detect(source.mix);
  }
  
  void samples(float[] sampsL, float[] sampsR)
  {
    beat.detect(source.mix);
  }
}
