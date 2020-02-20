float angleX=0;
float angleY=0;
float scaleFactor =1;
float yPrev =0;
// Dragging to implement

void settings(){
  //fullScreen(P3D,SPAN);
  
  size(500,500,P3D);
 
}
// demander par rapport à la couleur et à l'affichage de ce truc
void setup(){  
}

void draw(){
  
 background(255,255,255);
 My3DPoint eye = new My3DPoint(0,0,-5000); 
 
 My3DPoint origin = new My3DPoint(0,0,0);
 My3DBox boite= new My3DBox(origin,100,100,100);
 boite = transformBox(boite,rotateXMatrix(angleX));
 boite = transformBox(boite,rotateYMatrix(angleY));
 float [][] translation = translationMatrix(200,200,0);
 boite = transformBox( boite, translation);
 boite = transformBox(boite,scaleMatrix(scaleFactor,scaleFactor,scaleFactor));
 
 
 projectBox(eye,boite).render();
 
 
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      angleX +=50 ;
  }  
  if (keyCode == DOWN) {
      angleX -= 50;
    } 
 if (keyCode==LEFT) {
   angleY+=50;
 }
 
 if (keyCode==RIGHT) {
   angleY-=50;
 }
}
}

void mousePressed(MouseEvent m){
  yPrev=m.getY();  
}

void mouseDragged(MouseEvent m){
  if(m.getY()>yPrev){
scaleFactor += 0.1;  
  } else {
    scaleFactor = max(scaleFactor-0.1,1);
  }
  
}

//Le but est de dessiner des formes de 3D en 2D en utilisant la perspective


class My2DPoint{ // Juste un point en 2D
  float x;
  float y;
  My2DPoint(float x, float y){
    this.x=x;
    this.y=y;
  }
} 
  My2DPoint projectPoint(My3DPoint eye, My3DPoint p){ // une methode pour transformer un point 3D en 2D perspective) les formules sont trouvées à la main
 
  float factor = -eye.z/(p.z - eye.z); // parce que la 4eme coordonee doit etre 1, faut faire un scaling
  return new My2DPoint((p.x - eye.x)*factor, (p.y - eye.y)*factor);
  }
  
  // git test
  // commentaire ajouté


class My3DPoint{
  float x;
  float y;
  float z;
  My3DPoint(float x, float y,float z){
    this.x=x;
    this.y=y;
    this.z=z;
  }
}

class My2DBox {
 My2DPoint[] s;
 
 My2DBox(My2DPoint[] s){
 this.s=s;  
 }
 
  void render(){ // Render fait un rendu graphique d'un cuboid pour l'afficher
   
    strokeWeight(3); // stroke weight definit l'epaisseur du trait pour l'affichage   
    stroke(0,255,0); // Ici du vert
    line(s[5].x, s[5].y, s[6].x, s[6].y);
    line(s[6].x, s[6].y, s[7].x, s[7].y);
    line(s[4].x, s[4].y, s[5].x, s[5].y);    
    line(s[4].x, s[4].y, s[7].x, s[7].y);
    
    stroke(0,0,255); // stroke ajoute de la couleur : ici du bleu pur
    line(s[3].x, s[3].y, s[7].x, s[7].y);
    line(s[0].x, s[0].y, s[4].x, s[4].y);
    line(s[5].x, s[5].y, s[1].x, s[1].y);
    line(s[2].x, s[2].y, s[6].x, s[6].y);
    
    stroke(255,0,0); // ici du rouge
    line(s[0].x, s[0].y, s[1].x, s[1].y);
    line(s[0].x, s[0].y, s[3].x, s[3].y);
    line(s[2].x, s[2].y, s[3].x, s[3].y);
    line(s[2].x, s[2].y, s[1].x, s[1].y);
  }
}

class My3DBox { // La boite prend en parametre un array de points 3d et construit une boite (ou un cuboid) en 3D dans le constructeur
// avec les dimensions du cuboid, avec le point d'origine
  My3DPoint[] p;
  
  My3DBox (My3DPoint origin, float dimX,float dimY, float dimZ){ // Le constructeur qui prend les dimentions et l origine du cuboid
    float x = origin.x;
    float y = origin.y;
    float z = origin.z;
    this.p= new My3DPoint[]{
      new My3DPoint(x,y +dimY,z + dimZ),
      new My3DPoint(x,y,z + dimZ),
      new My3DPoint(x+dimX,y,z + dimZ),
      new My3DPoint(x+dimX,y+dimY,z + dimZ),
      new My3DPoint(x,y +dimY,z),
      origin,
      new My3DPoint(x+dimX,y,z),
      new My3DPoint(x+dimX,y +dimY,z)};
  }
 
  My3DBox(My3DPoint[] p){ // un autre constructeur qui construit la boite avec un array de points
    this.p=p;
  }
  
}


My2DBox projectBox (My3DPoint eye, My3DBox box){
  My3DPoint[] points = box.p;
  My2DPoint[] ar = new My2DPoint[8] ;
  for(int i=0;i<=7;++i){
    ar[i]= projectPoint(eye,points[i]);
  }
  return (new My2DBox(ar)); 
}


float[] homogeneous3DPoint(My3DPoint p){
  float[] result = { p.x, p.y,p.z,1};
  return result;
}

float[][]  rotateXMatrix(float angle) {
  return(
    new float[][] {
      {1, 0 , 0 , 0},
      {0, cos(angle), sin(angle) , 0},
      {0, -sin(angle) , cos(angle) , 0},
      {0, 0 , 0 , 1}});
}

float[][]  rotateYMatrix(float angle) {
  return(
    new float[][] {
      {cos(angle), 0 , -sin(angle) , 0},
      {0,           1,     0 ,       0},
      {sin(angle), 0 , cos(angle) , 0},
      {0, 0 , 0 , 1}});
}

float[][]  rotateZMatrix(float angle) {
  return(
    new float[][] {
      {cos(angle), sin(angle) , 0 , 0},
      {-sin(angle), cos(angle), 0 , 0},
      {0, 0 , 1 , 0},
      {0, 0 , 0 , 1}});
}

float[][]  scaleMatrix(float x, float y, float z) {
  return(
    new float[][] {
      {x, 0 , 0 , 0},
      {0, y,  0 , 0},
      {0, 0 , z , 0},
      {0, 0 , 0 , 1}});
}

float[][]  translationMatrix(float x, float y, float z) {
  return(
    new float[][] {
      {1, 0 , 0 , x},
      {0, 1 , 0 , y},
      {0, 0 , 1 , z},
      {0, 0 , 0 , 1}});
}

float[] matrixProduct(float[][] a, float [] b){
  float result[] = new float[4];
 for ( int i=0;i<4;++i){
   float temp =0;
   for(int j=0;j<4;++j){ temp+= a[i][j] * b[j];}
   result[i] =  temp;  
 }  
 return result;
}

My3DPoint euclidian3DPoint (float [] a) {
 My3DPoint result = new My3DPoint(a[0]/a[3],a[1]/a[3],a[2]/a[3]);
 return result;
} 


My3DBox transformBox(My3DBox box, float[][] transformMatrix){ // applique la transformation à la box 
  My3DPoint nonHomo3DPoints[] = box.p;
  float homo3D[][] = new float [8][4];
  float transformedHomo3D [][] = new float [8][4];
  My3DPoint listForTransformedBox[]= new My3DPoint[8];
  
  for (int i=0;i<8;++i){
    homo3D[i] = homogeneous3DPoint(nonHomo3DPoints[i]);
  }   
 for(int i=0; i<8;++i){
  transformedHomo3D[i] = matrixProduct(transformMatrix,homo3D[i]);
 } 
 for (int i=0;i<8;++i){
 listForTransformedBox[i] = euclidian3DPoint(transformedHomo3D[i]);
 }
 return (new My3DBox (listForTransformedBox));
}