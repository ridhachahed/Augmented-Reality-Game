import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;
import java.util.Map;
import java.util.TreeMap;

class BlobDetection {
  
  
PImage findConnectedComponents(PImage input, boolean onlyBiggest){
  
// First pass: label the pixels and store labels' equivalences
int [] labels= new int [input.width*input.height];
List<TreeSet<Integer>> labelsEquivalences= new ArrayList<TreeSet<Integer>>();
int currentLabel=1;

PImage coloredImage = new PImage(input.width, input.height);
coloredImage.loadPixels();
  
  for(int i = 0; i < input.width * input.height; i++) {
    labels[i]=Integer.MAX_VALUE;
  }
  
  for(int y = 0; y < input.height; y++){
      for(int x = 0; x < input.width; x++) {
         if(brightness(input.pixels[x+y*input.width]) != 0){    //for now if white must change ? 
         
       //on doit prendre les voisins 
       TreeSet<Integer> neighbors = new TreeSet<Integer>();
       int horizontale=Math.max(0,x-1);
       
       for(int i=horizontale; i<Math.min(input.width,1+x);++i) {
        
          if (y != 0 && labels[(y-1)*input.width+i] != Integer.MAX_VALUE){
                      neighbors.add(labels[(y-1)*input.width+i]);
            }
       }
       
       if (x != 0 && labels[y*input.width+x-1] != Integer.MAX_VALUE){
                      neighbors.add(labels[y*input.width+x-1]);
       }
     
       
       if (!neighbors.isEmpty()) {  
             
             int smallest_neighbor = neighbors.first();
              
             labels[y*input.width+x] = smallest_neighbor;
             
             //mettre à jour les classes equivalences
             TreeSet<Integer> newNeighborsEquivalence = new TreeSet<Integer>();
             
             for(Integer elem : neighbors){
              newNeighborsEquivalence.addAll(labelsEquivalences.get(elem-1)); 
            }
             for(Integer elem : neighbors){
               labelsEquivalences.set(elem-1,newNeighborsEquivalence);     //ou elem-1 ?
             }
        
             // remember that the two labels are neighbors
           }else {   
             labelsEquivalences.add(new TreeSet<Integer>());
             labelsEquivalences.get(currentLabel-1).add(currentLabel);    //le label i a pour index i
             labels[x + y*input.width]=currentLabel;
             currentLabel+=1;
             
    }
  }   
 }
}
      

// TODO!
// Second pass: re-label the pixels by their equivalent class
// if onlyBiggest==true, count the number of pixels for each label

Map<Integer, Integer> occurences = new TreeMap<Integer, Integer>();   //labelNumber -> numberOfOccurences

  for (int i = 0; i < input.height*input.width; i++) {
       if (brightness(input.pixels[i]) != 0) {
         labels[i] = labelsEquivalences.get(labels[i]-1).first();
         if(onlyBiggest) {
         occurences.put(labels[i], occurences.getOrDefault(labels[i], 0)+1);  // -1
         }
      }
  }
  
 // TODO!
// Finally,
// if onlyBiggest==false, output an image with each blob colored in one uniform color
// if onlyBiggest==true, output an image with the biggest blob colored in white and the others in black
// TODO!


int max=0;
int maxLabel=0;
for(Map.Entry<Integer, Integer> entry : occurences.entrySet()) {
    if(entry.getValue() > max) {
      maxLabel=entry.getKey();
      max=entry.getValue();
    }
 }


// Third pass, coloring the image
     for(int i = 0; i < labels.length; i++){
       if (labels[i] == Integer.MAX_VALUE){
           coloredImage.pixels[i] = 0;
       }
       else if (onlyBiggest) {
         coloredImage.pixels[i] = labels[i] == maxLabel ? color(255) : color(0);
       }
       else {
         colorMode(HSB, 255, 255, 255);
         int col =(int) map(labels[i],0,currentLabel+1,0,255); 
         coloredImage.pixels[i] = color(col, 255 , 255 );
         colorMode(RGB, 255, 255, 255);
       }
     }
    
     coloredImage.updatePixels();
     return coloredImage;
}

  
 
}
