#include "SPI.h"
#include "Adafruit_WS2801.h"

/*****************************************************************************
Example sketch for driving Adafruit WS2801 pixels!


  Designed specifically to work with the Adafruit RGB Pixels!
  12mm Bullet shape ----> https://www.adafruit.com/products/322
  12mm Flat shape   ----> https://www.adafruit.com/products/738
  36mm Square shape ----> https://www.adafruit.com/products/683

  These pixels use SPI to transmit the strip.color data, and have built in
  high speed PWM drivers for 24 bit strip.color per pixel
  2 pins are required to interface

  Adafruit invests time and resources providing this open source code, 
  please support Adafruit and open-source hardware by purchasing 
  products from Adafruit!

  Written by Limor Fried/Ladyada for Adafruit Industries.  
  BSD license, all text above must be included in any redistribution

*****************************************************************************/

// Choose which 2 pins you will use for output.
// Can be any valid output pins.
// The strip.colors of the wires may be totally different so
// BE SURE TO CHECK YOUR PIXELS TO SEE WHICH WIRES TO USE!
int dataPin  = 2;    // Yellow wire on Adafruit Pixels
int clockPin = 3;    // Green wire on Adafruit Pixels

// Don't forget to connect the ground wire to Arduino ground,
// and the +5V wire to a +5V supply

// Set the first variable to the NUMBER of pixels. 25 = 25 pixels in a row
Adafruit_WS2801 strip = Adafruit_WS2801(200, dataPin, clockPin, WS2801_RGB);

// Optional: leave off pin numbers to use hardware SPI
// (pinout is then specific to each board and can't be changed)
//Adafruit_WS2801 strip = Adafruit_WS2801(25);

// For 36mm LED pixels: these pixels internally represent strip.color in a
// different format.  Either of the above constructors can accept an
// optional extra parameter: WS2801_RGB is 'conventional' RGB order
// WS2801_GRB is the GRB order required by the 36mm pixels.  Other
// than this parameter, your code does not need to do anything different;
// the library will handle the format change.  Examples:
//Adafruit_WS2801 strip = Adafruit_WS2801(25, dataPin, clockPin, WS2801_GRB);
//Adafruit_WS2801 strip = Adafruit_WS2801(25, WS2801_GRB);

void setup() {
    
  strip.begin();

  // Update LED contents, to start they are all 'off'
  strip.show();
}

void loop() {
  // Some example procedures showing how to display to the pixels
  
  strip.show();
  
  colorWipe(strip.color(255, 0, 0), 50);
  colorWipe(strip.color(0, 255, 0), 50);
  colorWipe(strip.color(0, 0, 255), 50);
  rainbow(20);
  rainbowCycle(20);
}

void rainbow(uint8_t wait) {
  int i, j, k;
   
  for (k=0; k < 256; k++) {     // 3 cycles of all 256 strip.colors in the wheel
    for (i=0; i < strip.h(); i++) {
      for (j = 0; j < strip.w(); j++) {
        strip.spc(i, j, Wheel( (i + j + k) % 255));
      }
    }  
    strip.show();   // write all the pixels out
    delay(wait);
  }
}

// Slightly different, this one makes the rainbow wheel equally distributed 
// along the chain
void rainbowCycle(uint8_t wait) {
  int i, j, k;
  
  for (k=0; k < 256 * 5; k++) {     // 5 cycles of all 25 strip.colors in the wheel
    for (i=0; i < strip.h(); i++) {
      for (j=0; j < strip.w(); j++) {
        // tricky math! we use each pixel as a fraction of the full 96-strip.color wheel
        // (thats the i / strip.numPixels() part)
        // Then add in k which makes the strip.colors go around per pixel
        // the % 96 is to make the wheel cycle around
        strip.spc(i, j, Wheel( (((i+j) * 256 / strip.numPixels()) + k) % 256) );
      }
    }  
    strip.show();   // write all the pixels out
    delay(wait);
  }
}

// fill the dots one after the other with said strip.color
// good for testing purposes
void colorWipe(uint32_t c, uint8_t wait) {
  int i;
  int j;
  
  for (i=0; i < strip.h(); i++) {
    for (j = 0; j < strip.w(); j++) {
      strip.spc(i, j, c);
      strip.show();
      delay(wait);
    }
  }
}

/* Helper functions */

//Input a value 0 to 255 to get a strip.color value.
//The colours are a transition r - g -b - back to r
uint32_t Wheel(byte WheelPos)
{
  if (WheelPos < 85) {
   return strip.color(WheelPos * 3, 255 - WheelPos * 3, 0);
  } else if (WheelPos < 170) {
   WheelPos -= 85;
   return strip.color(255 - WheelPos * 3, 0, WheelPos * 3);
  } else {
   WheelPos -= 170; 
   return strip.color(0, WheelPos * 3, 255 - WheelPos * 3);
  }
}
