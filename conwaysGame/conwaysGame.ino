#include "SPI.h"
#include "Adafruit_WS2801.h"

#define ALIVE 25 // Alive cell colour (blue)
#define DEAD 1638400 // Dead cell colour (red)
#define ALIVE_LOWER 2 // lower bound for # of adj cells required to stay alive
#define ALIVE_UPPER 3 // upper bound for # of adj cells required to stay alive
#define RESSURECT 3 // # of adj cells required to bring dead cell to live
#define WAIT 50 // delay between iterations

int dataPin  = 2;    // Yellow wire on Adafruit Pixels
int clockPin = 3;    // Green wire on Adafruit Pixels

Adafruit_WS2801 strip = Adafruit_WS2801(200, dataPin, clockPin, WS2801_RGB, 18, 11);

uint8_t cellState [11][18];

void setup() {
  
  strip.begin();
  
  int i,j;

  // set all of the cellState entries to 0
  for (i = 0; i < strip.h(); i++) {
    for (j = 0; j < strip.w(); j++ ) {
      cellState[i][j] = 0;
    }
  }

  //Seed the random generator
  randomSeed(analogRead(0));
  randomizeBoard();
  showCurrentState();
  
  delay(WAIT);
}

void loop() {

  conwaysGameIteration();
  
  delay(WAIT);
  
  if (steadyState()) {
     int i;
    
     for (i = 0; i < 10; i++) {
       conwaysGameIteration(); 
     }
    
     randomizeBoard(); 
  }
}

// does one iteration of conway's game
void conwaysGameIteration() { 
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
      }
    }
  }
  
  showCurrentState();
}

void showCurrentState() {
   int i,j;
  
   for(i = 0; i < strip.h(); i++) {
      for(j = 0; j < strip.w(); j++) {
         if ((cellState[i][j] % 2) > 0)
           strip.spc(i,j,ALIVE);
         else
           strip.spc(i,j,DEAD);
      } 
   }
   
   strip.show();
}

boolean aliveNextIteration(int i, int j) {
   int liveAdjCells = numberOfLiveAdjCells(i,j);
   if (cellAlive(i,j) > 0) // check if cell is alive
      return ((ALIVE_LOWER <= liveAdjCells) && (liveAdjCells <= ALIVE_UPPER));
   else
      return (liveAdjCells == RESSURECT);
}

// Counts number of live neighbour cells
uint8_t numberOfLiveAdjCells(uint8_t i,uint8_t j) {
   // we mod in the event the cell goes beyond the edge, so the board 'wraps around'
   return cellAlive((strip.h() + i-1) % strip.h(), (strip.w() + j-1) % strip.w()) + // add a strip.h() for cases where i-1 < 0, same for strip.w() and j-1<0
          cellAlive((strip.h() + i-1) % strip.h(), (j) % strip.w()) + 
          cellAlive((strip.h() + i-1) % strip.h(), (j+1) % strip.w()) + 
          cellAlive((i) % strip.h(), (strip.w() + j-1) % strip.w()) + 
          cellAlive((i) % strip.h(), (j+1) % strip.w()) + 
          cellAlive((i+1) % strip.h(), (strip.w() + j-1) % strip.w()) + 
          cellAlive((i+1) % strip.h(), (j) % strip.w()) + 
          cellAlive((i+1) % strip.h(), (j+1) % strip.w());
}

// Checks second last bit if cell is alive, returns 1 if true
uint8_t cellAlive(uint8_t i,uint8_t j) {
   return ((cellState[i][j] >> 1 ) % 2);
}

// Creates initial board configuration
void randomizeBoard() {
   int i;
   int numberOfCells = random(10,100);
   
   for (i = 0; i < numberOfCells; i++) {
      cellState[random(strip.h())][random(strip.w())] = 1;
   }
}

// Checks if current game has reached a steady state
boolean steadyState() {
  int i;
  boolean steady = false;
  
  for (i = 1; i < 8; i++) {
     steady = steady || steadyWRTState(i);
  }
  
  return steady;
}

// Checks if current game has reached a steady state with respect to n board states before the current one
boolean steadyWRTState(int n) {
  int i,j;
  int steady = true;
  
  for (i = 0; i < strip.h(); i++) {
     for (j = 0; j < strip.w(); j++) {
        steady = steady && ((cellState[i][j] % 2) == ((cellState[i][j] >> n) % 2));
     } 
  }
  
  return steady;
}

