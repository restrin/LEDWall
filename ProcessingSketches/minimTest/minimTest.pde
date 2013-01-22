import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

Minim minim;
AudioPlayer song;
AudioInput input;
FFT fft;

void setup()
{
size(1600, 900);

minim = new Minim(this);
song = minim.loadFile("Kalimba.mp3", 512);
song.play();
input = minim.getLineIn();

// Trying fft
fft = new FFT(song.bufferSize(), song.sampleRate());
}

void draw()
{
// do what you do

  background(0);
  
  fft.forward(song.mix);
  
  stroke(255, 0, 0, 128);
  
  for(int i = 0; i < fft.specSize(); i++)
  {
    rect(i/18, height, i/18 + 18, height - fft.getBand(i/18)*4);
  }
  // we draw the waveform by connecting neighbor values with a line
  // we multiply each of the values by 50
  // because the values in the buffers are normalized
  // this means that they have values between -1 and 1.
  // If we don’t scale them up our waveform
  // will look more or less like a straight line.
  for(int i = 0; i < song.bufferSize() - 1; i++)
  {
    for(int j = 0; j < 50; j++) {
      line(3*i, 250+j + song.left.get(i)*250, 3*(i+1), 250+j + song.left.get(i+1)*250);
    }
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
