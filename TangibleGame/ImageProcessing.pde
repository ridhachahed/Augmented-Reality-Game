import gab.opencv.*;
import processing.video.*;

class ImageProcessing extends PApplet {
  
PImage img2;
PImage img;

BlobDetection bob;
OpenCV opencv;
TwoDThreeD twoDThreeD;
QuadGraph quad;
PVector rotation= new PVector(0,0,0);


void settings() {
  size(640, 480);
}

void setup() { 
  frameRate(25); 
  cam.loop();
  opencv = new OpenCV(this, 100, 100);
  bob = new BlobDetection();
  quad= new QuadGraph(); 

  twoDThreeD = new TwoDThreeD(640, 480, 0);
  rotation = new PVector(0,0,0);
  //noLoop(); // no interactive behaviour: draw() will be called only once.

}

void draw() {
  if (cam.available() == true) {
  cam.read();
  }
  img=cam.get();
  img2 = img.copy();//make a deep copy
  img2.loadPixels();// load pixels
  img2=thresholdHSB(img2, 50, 140, 100, 255, 40, 200);
  img2=bob.findConnectedComponents(img2, true);
  img2= convolute(img2, gaussian, gaussian_average);
  img2 = scharr(img2);
  img2=saturationThreshold(img2, 100 );
 
  List<PVector> lines = hough(img2);
  QuadGraph quad = new QuadGraph(); 
  quad.build(lines, img2.width, img2.height);
  List<PVector> corners = quad.findBestQuad(lines, img2.width, img2.height, (int)(img2.width*img2.height*0.8), (int)(img2.width*img2.height*0.1), false);
  
  for (PVector corner : corners) {
    corner.z = 1;
  }
  
  rotation = twoDThreeD.get3DRotations(corners);
  
  image(img, 0, 0);
  drawCorners(corners);
  plotLines(lines, img);
}


void plotLines(List<PVector> lines, PImage edgeImg) {
  for (int idx = 0; idx < lines.size(); idx++) {
    PVector line=lines.get(idx);
    float r = line.x;
    float phi = line.y;
    // Cartesian equation of a line: y = ax + b
    // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
    // => y = 0 : x = r / cos(phi)
    // => x = 0 : y = r / sin(phi)
    // compute the intersection of this line with the 4 borders of
    // the image
    int x0 = 0;
    int y0 = (int) (r / sin(phi));
    int x1 = (int) (r / cos(phi));
    int y1 = 0;
    int x2 = edgeImg.width;
    int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
    int y3 = edgeImg.width;
    int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
    // Finally, plot the lines
    stroke(204, 102, 0);
    if (y0 > 0) {
      if (x1 > 0)
        line(x0, y0, x1, y1);
      else if (y2 > 0)
        line(x0, y0, x2, y2);
      else
        line(x0, y0, x3, y3);
    } else {
      if (x1 > 0) {
        if (y2 > 0)
          line(x1, y1, x2, y2);
        else
          line(x1, y1, x3, y3);
      } else
        line(x2, y2, x3, y3);
    }
  }
}

PImage saturationThreshold(PImage img, int threshold) {
  // create a new, initially transparent, 'result' image
  PImage result = createImage(img.width, img.height, RGB);
  for (int i = 0; i < img.width * img.height; i++) {
    if (brightness(img.pixels[i]) < threshold) { 
      result.pixels[i]=color(0);
    } else {
      result.pixels[i]=color(255);
    }
  }
  return result;
}

PImage hueThreshold(PImage img, int min, int max) {
  // create a new, initially transparent, 'result' image
  PImage result = createImage(img.width, img.height, RGB);
  for (int i = 0; i < img.width * img.height; i++) {
    if (hue(img.pixels[i])<min || hue(img.pixels[i])>max) {  
      result.pixels[i]=0;
    } else {
      result.pixels[i]=color(255);
    }
  }
  return result;
}

PImage thresholdHSB(PImage img, int minH, int maxH, int minS, int maxS, int minB, int maxB) {
  PImage result = createImage(img.width, img.height, RGB);
  for (int i = 0; i < img.width * img.height; i++) {
    if (hue(img.pixels[i])<minH || hue(img.pixels[i])>maxH ||
      brightness(img.pixels[i])<minB || brightness(img.pixels[i]) >maxB ||
      saturation(img.pixels[i])<minS || saturation(img.pixels[i])>maxS) {
      result.pixels[i]=color(0);
    } else {
      result.pixels[i]=color(255);
    }
  }
  result.updatePixels();
  return result;
}

boolean imagesEqual(PImage img1, PImage img2) {
  if (img1.width != img2.width || img1.height != img2.height) return false;
  for (int i = 0; i < img1.width*img1.height; i++)
    //assuming that all the three channels have the same value
    if (red(img1.pixels[i]) != red(img2.pixels[i]))return false;
  return true;
}

// to use as arguments in the convolute method
float[][] gaussian = {{9, 12, 9}, {12, 15, 12}, {9, 12, 9}};
float gaussian_average=99;


PImage threshold(PImage img, int threshold) {
  // create a new, initially transparent, 'result' image
  PImage result = createImage(img.width, img.height, RGB);
  for (int i = 0; i < img.width * img.height; i++) {
    // do something with the pixel img.pixels[i]
    if ((img.pixels[i])<threshold) {
      result.pixels[i]=color(0);
    } else {
      result.pixels[i]=color(255);
    }
  }
  return result;
}




PImage convolute(PImage img, float[][] kernel, float normFactor) {
  // create a greyscale image (type: ALPHA) for output
  PImage result = createImage(img.width, img.height, ALPHA);
  int N=3;
  for (int x=0; x<img.width; ++x) {
    for (int y=0; y<img.height; ++y) {
      float temp=0;
      for (int i=-N/2; i<=N/2; ++i) {
        for (int j=-N/2; j<=N/2; ++j) {
          if (x+i>=0 && x+i <width && y+j>=0 && y+j<height) {
            temp+=brightness(img.get(x+i, y+j)) * kernel[i+N/2][j+N/2];
          }
        }
      }
      temp/=normFactor;
      result.pixels[y * img.width + x]=color(temp*255);
    }
  }
  return result;
}


PImage scharr(PImage img) {
  float[][] vKernel = {
    { 3, 0, -3}, 
    { 10, 0, -10}, 
    { 3, 0, -3} 
  };

  float[][] hKernel = {
    { 3, 10, 3}, 
    { 0, 0, 0 }, 
    { -3, -10, -3}
  };

  PImage result = createImage(img.width, img.height, ALPHA);
  // clear the image
  for (int i = 0; i < img.width * img.height; i++) {
    result.pixels[i] = color(0);
  }
  float max=0;
  float[] buffer = new float[img.width * img.height];
  for (int y=2; y<img.height-2; y++) {
    for (int x=2; x<img.width-2; x++) {
      float temp_h=0;
      float temp_v=0;
      int temp=0;
      for (int k= -1; k<=1; k++) {
        for (int l =-1; l<=1; l++) {
          temp_h+=img.get(x+l, y+k)*hKernel[k+1][l+1];
          temp_v+=img.get(x+l, y+k)*vKernel[k+1][l+1];
        }
      }
      temp=(int) sqrt(pow(temp_h, 2)+ pow(temp_v, 2));
      if (temp>max) {
        max=temp;
      }
      buffer[y*img.width+x]=temp;
    }
  }

  for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
    for (int x = 2; x < img.width - 2; x++) { // Skip left and right
      if (buffer[y*img.width + x]> (int) (max*0.3f)) {
        result.pixels[y*img.width + x] = color(255);
      } else { 
        result.pixels[y*img.width + x]=color(0);
      }
    }
  }
  return result;
}


void drawCorners(List<PVector> corners ) {
  for (int i = 0; i< corners.size(); i++) {
    float x = corners.get(i).x;
    float y = corners.get(i).y;
    stroke(0, 0, 200);
    ellipse(x, y, 30, 30);
  }
}

PVector getRotation() {
    return rotation;
}

} 