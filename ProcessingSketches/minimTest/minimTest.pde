import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

Minim minim;
AudioPlayer song;
AudioInput input;
FFT fft;
float[] buffer = new float[512];

int m = 0;

void setup()
{
size(512 , 200);

minim = new Minim(this);
song = minim.loadFile("C:/Users/Ron/Downloads/Nine Inch Nails - The Hand That Feeds.mp3", 512);
song.play();
input = minim.getLineIn();

// Trying fft
fft = new FFT(song.bufferSize(), song.sampleRate());
fft.linAverages(10);
}

void draw()
{
// do what you do

  background(0);
  
  fft.forward(song.mix);
  
  stroke(255, 0, 0, 128);
  
  int num = 512;
  
  for(int i = 0; i < num; i++)
  { 
    if (fft.getBand(i) > m)
      m = (int) fft.getBand(i);  
  }
  
  for(int i = 0; i < num; i++)
  { 
    rect(i*512/num, height, 512/num, height - pow(fft.getBand(i)/m, 0.25)*400);
//    print(pow(fft.getBand(i)/m, 0.1) + " ");
  }
  
//  println();
//  println();
  
  m = 0;
  // we draw the waveform by connecting neighbor values with a line
  // we multiply each of the values by 50
  // because the values in the buffers are normalized
  // this means that they have values between -1 and 1.
  // If we don’t scale them up our waveform
  // will look more or less like a straight line.
  for(int i = 0; i < song.bufferSize() - 1; i++)
  {
//    for(int j = 0; j < 50; j++) {
      line(3*i, 100 + song.left.get(i)*100, 3*(i+1), 100 + song.left.get(i+1)*100);
//    }
  }
}

void stop()
{
  // the AudioPlayer you got from Minim.loadFile()
  song.close();
  // the AudioInput you got from Minim.getLineIn()
  input.close();
  minim.stop();

  // this calls the stop method that
  // you are overriding by defining your own
  // it must be called so that your application
  // can do all the cleanup it would normally do
  super.stop();
}
