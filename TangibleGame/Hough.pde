import java.util.List;
final static int MAXIMA_REGION = 10;

List<PVector> hough(PImage edgeImg) {

  float discretizationStepsPhi = 0.06f; 
  float discretizationStepsR = 2.5f; 
  int minVotes=175; //to adjust later 

  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi +1);

  //The max radius is the image diagonal, but it can be also negative
  int rDim = (int) ((sqrt(edgeImg.width*edgeImg.width +
    edgeImg.height*edgeImg.height) * 2) / discretizationStepsR +1);

  // our accumulator
  int[] accumulator = new int[phiDim * rDim];

  //pre-compute the sin and cos values
  float[] tabSin = new float[phiDim];
  float[] tabCos = new float[phiDim];
  
  float ang = 0;
  float inverseR = 1.f / discretizationStepsR;
  
  for(int accPhi =0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++){
    tabSin[accPhi]= (float) (Math.sin(ang) * inverseR);
    tabCos[accPhi]= (float) (Math.cos(ang) * inverseR );
    
  }
  // Fill the accumulator: on edge points (ie, white pixels of the edge
  // image), store all possible (r, phi) pairs describing lines going
  // through the point.
  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
        // ...determine here all the lines (r, phi) passing through
        // pixel (x,y), convert (r,phi) to coordinates in the
        // accumulator, and increment accordingly the accumulator.
        // Be careful: r may be negative, so you may want to center onto
        // the accumulator: r += rDim / 2
        float angle=0;
       for (int phi = 0; phi < phiDim; phi++) {
          int r = (int)(x*tabCos[phi] + y*tabSin[phi])+rDim/2;
           
          accumulator[phi*rDim + r] += 1;
        } 
      }
    }
  }
  
  
  HoughComparator comparator =new HoughComparator(accumulator); 
  ArrayList<Integer>bestCandidates = new ArrayList<Integer>();
  for(int i = 0; i<accumulator.length;i++){
    if((accumulator[i]>minVotes)&&isLocalMaxima(accumulator,i)){
      bestCandidates.add(i);
    }
  }
  java.util.Collections.sort(bestCandidates,comparator);

  ArrayList<PVector> lines=new ArrayList<PVector>();
  for (Integer i = 0; i < bestCandidates.size(); i++) {
      int idx = bestCandidates.get(i);
    
      // first, compute back the (r, phi) polar coordinates:
      int accPhi = (int) (idx / (rDim));
      int accR = idx - (accPhi) * (rDim);
      float r = (accR - (rDim) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;
      lines.add(new PVector(r, phi));
    
    
  }
  
  

  

  /*PImage houghImg = createImage(rDim, phiDim, ALPHA);
   for (int i = 0; i < accumulator.length; i++) {
   houghImg.pixels[i] = color(min(255, accumulator[i]));
   }
   // You may want to resize the accumulator to make it easier to see:
   houghImg.resize(400, 400);
   houghImg.updatePixels();  
   image(houghImg, 0, 0); */







  return lines;
}





boolean isLocalMaxima(int[] accumulator,int index){
  boolean result = true;
  int from = max(0,index-MAXIMA_REGION/2);
  int to = min(accumulator.length-1, index+ MAXIMA_REGION/2);
  float max = accumulator[index];
  for(int i = from; i < to ; i++){
    if((i!=index)&&(accumulator[i]>max)){
      result = false;
    }
  }
  return result;
}