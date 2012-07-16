#include "SPI.h"
#include "Adafruit_WS2801.h"

#define ALIVE 255 // Alive cell colour (blue)
#define DEAD 16711680 // Dead cell colour (red)
#define ALIVE_LOWER 2 // lower bound for # of adj cells required to stay alive
#define ALIVE_UPPER 3 // upper bound for # of adj cells required to stay alive
#define RESSURECT 3 // # of adj cells required to bring dead cell to live
#define WAIT 50 // delay between iterations

int dataPin  = 2;    // Yellow wire on Adafruit Pixels
int clockPin = 3;    // Green wire on Adafruit Pixels

Adafruit_WS2801 strip = Adafruit_WS2801(200, dataPin, clockPin, WS2801_RGB, 18, 11);

int cellState [11][18];

void setup() {
  
  int i,j;
  
  strip.begin();

  // set all of the cellState entries to 0
  for (i = 0; i < strip.h(); i++) {
    for (j = 0; j < strip.w(); j++ ) {
      cellState[i][j] = 0;
    }
  }

  cellState[0][0] = 1;
  cellState[1][1] = 1;
  cellState[1][2] = 1;
  cellState[2][0] = 1;
  cellState[2][1] = 1;

  // Update LED contents, to start they are all 'off'
  strip.show();
}

void loop() {
  // does one iteration of conway's game
  int i, j;
  
  // shift every int in array 1 bit left
  for (i = 0; i < strip.h(); i++) {
    for (j = 0; j < strip.w(); j++ ) {
      cellState[i][j] <<= 1;
    }
  }
  
  for (i = 0; i < strip.h(); i++) {
    for (j = 0; j < strip.w(); j++ ) {
      if (aliveNextIteration(i,j)) {
        cellState[i][j] |= 1; // append the int with a 1 at the end to represent alive cell
        // if not alive, the last bit will be left a 0
        strip.spc(i, j, ALIVE);
      }
      else {
        strip.spc(i, j, DEAD);
      }
    }
  }
  
  strip.show();
  delay(WAIT);
}

int aliveNextIteration(int i, int j) {
   int liveAdjCells = numberOfLiveAdjCells(i,j);
   if (cellAlive(i,j)) // check if cell is alive
      return (ALIVE_LOWER <= liveAdjCells <= ALIVE_UPPER);
   else
      return (liveAdjCells == RESSURECT);
}

// Counts number of live neighbour cells
int numberOfLiveAdjCells(int i, int j) {
   // we mod in the event the cell goes beyond the edge, so the board 'wraps around'
   return cellAlive((i-1) % strip.h(), (j-1) % strip.w()) + 
          cellAlive((i-1) % strip.h(), (j) % strip.w()) + 
          cellAlive((i-1) % strip.h(), (j+1) % strip.w()) + 
          cellAlive((i) % strip.h(), (j-1) % strip.w()) + 
          cellAlive((i) % strip.h(), (j+1) % strip.w()) + 
          cellAlive((i+1) % strip.h(), (j-1) % strip.w()) + 
          cellAlive((i+1) % strip.h(), (j) % strip.w()) + 
          cellAlive((i+1) % strip.h(), (j+1) % strip.w());
}

// Checks second last bit if cell is alive
int cellAlive(int i, int j) {
   return ((cellState[i][j] << 6) >> 7);
}
