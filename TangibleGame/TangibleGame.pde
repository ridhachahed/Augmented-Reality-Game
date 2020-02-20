//Box 
final float BOX_WIDTH=500;
final float BOX_HEIGHT=25;
final float BOX_DEPTH=500;

//Rotation angles
float rx=0; 
float ry=0;

//turning speed
float speed=1;

//Sphere
final float SPHERE_RADIUS=25;

//Shiftmod
boolean shiftMod = false;

//Movie



//Cylinders
final float CYLINDER_BASE_SIZE = 50;
final float CYLINDER_HEIGHT = 50;
final int CYLINDER_RESOLUTION = 40;
final float CYLINDER_RADIUS=23f;
ArrayList<Cylinder> listeOfCylinder= new ArrayList<Cylinder>();

Mover mover;
//Data visualisation
PGraphics gameSurface;
PGraphics dataVisualisation;
PGraphics topView;
PGraphics scoreBoard;
PGraphics barChart;
float scoreDivisor=5;
float score=0;
float oldScore=0;
HScrollbar scrollbar;
float ANGLE_ACC = 0.06;

//imgproc
ImageProcessing imgproc;
PVector rot;
Movie cam;

void settings() {
  size(displayWidth, displayHeight, P3D);
}
void setup() {
  cam =   new Movie(this,"testvideo.avi");
  gameSurface=createGraphics(width, int(height*0.8), P3D);
  dataVisualisation=createGraphics(width, int(height*0.2), P3D);
  topView=createGraphics(int(height*0.2*0.9), int(height*0.2*0.9), P2D);
  scoreBoard=createGraphics(int(width*0.08), int(height*0.18), P2D);
  barChart=createGraphics(int(width*0.72), int(height*0.14), P2D);
  scrollbar=new HScrollbar(int( 2*int(height*0.18) + 2.5*int(height*0.02))+45, int(height*(1- 1/53.3)-int(height*0.02)/2.0f)-20, int(width*0.72), int(height/53.3f));

  mover = new Mover();
  
  imgproc = new ImageProcessing();
  String []args = {"Image processing window"};
  PApplet.runSketch(args, imgproc);
  
  rot= new PVector(0,0,0);

}

void draw() {
  background(255, 255, 255);
  drawGame();
  dataVisualisation.beginDraw();
  background(255, 229, 204);
  dataVisualisation.endDraw();
  drawTopView();
  drawBarChart();
  drawScoreBoard();
  
  image(gameSurface, 0, 0);
  image(dataVisualisation, 0, height*0.8);
  image(topView, width*0.01, height*0.81);
  image(scoreBoard, width*0.15, height*0.81);
  image(barChart, width*0.25, height*0.81);
  
  rot= imgproc.getRotation();
  if (rot.y > rx) {
    rx = min(rot.y, rx +  ANGLE_ACC);
  } else {
    rx = max(rot.y, rx -  ANGLE_ACC);
  }

  if (rot.z > ry) {
    ry = min(rot.z, ry + ANGLE_ACC);
  } else {
    ry = max(rot.z, ry -  ANGLE_ACC);
}
  rx = constrain(rx, -PI/3, PI/3);
  ry = constrain(ry, -PI/3, PI/3);
}
void drawGame() {
  //lights
  gameSurface.beginDraw();
  gameSurface.directionalLight(50, 100, 125, 0.4, 0.2, -0.8);
  gameSurface.ambientLight(102, 102, 102);
  gameSurface.background(200); 

  if (shiftMod)
    drawShiftMode();
  else 
  drawNoShiftMode();

  drawCylinders();

  gameSurface.endDraw();
}

void drawBarChart() {
  barChart.beginDraw();
  
  barChart.background(255, 255, 200);
  scrollbar.update();
  scrollbar.display();

  int rectWidth = (int) (scrollbar.getPos() * 10);
  if (rectWidth<1) rectWidth=1;
  rectWidth*=3;

  int rectHeight = 10;
  int xRect = 0;
  int yRect = barChart.height - rectHeight;
  scoreDivisor = 10;
  
  for (int i=0; i<mover.scores.size(); ++i) {
    for (int j = 0; j < mover.scores.get(i) / scoreDivisor; j++) {
      barChart.rect(xRect, yRect, rectWidth, rectHeight, 1);

      yRect -= 10;
    }
    xRect += rectWidth + 2;
    yRect = barChart.height - rectHeight;
     
  }

  barChart.endDraw();
}

void drawScoreBoard() {
  scoreBoard.beginDraw();
  scoreBoard.pushMatrix();
  scoreBoard.background(200, 0, 0);
  scoreBoard.fill(255, 255, 255);
  scoreBoard.textSize(18);
  scoreBoard.text("Total Score", width/384, height/71);

  scoreBoard.text(score, width/384, height/30);
  scoreBoard.text("Velocity", width/384, height/16);
  scoreBoard.text( (mover.velocity.mag()), width/384, height/13);
  scoreBoard.text("Last Score", width/384, height/9);
  scoreBoard.text(oldScore, width/384, height/8);
  scoreBoard.popMatrix();
  scoreBoard.endDraw();
}


void drawTopView() {
  topView.beginDraw();
  topView.background(0, 0, 120);
  float bx= map(mover.location.x, -BOX_WIDTH/2, BOX_WIDTH/2, 0, int(height*0.2*0.9));
  float by= map(mover.location.z, -BOX_DEPTH/2, BOX_DEPTH/2, 0, int(height*0.2*0.9));
  topView.fill(255, 0, 0);    //topView.fill(0)
  
  topView.ellipse(bx, by, 13, 13);    //topView.ellipse(bx,by,12,12);   
  for (int i=0; i<listeOfCylinder.size(); ++i) {
    float x= map(listeOfCylinder.get(i).position.x, -BOX_WIDTH/2, BOX_WIDTH/2, 0, int(height*0.2*0.9));
    float y= map(listeOfCylinder.get(i).position.z, -BOX_DEPTH/2, BOX_DEPTH/2, 0, int(height*0.2*0.9));
    topView.fill(255, 153, 102);   //topView.fill(100)
      
    topView.ellipse(x, y, 26, 26);  //topView.ellipse(x,y,20,20)
  }
  topView.endDraw();
}

void drawCylinders() {

  for (int i=0; i<listeOfCylinder.size(); ++i) {
    gameSurface.pushMatrix();
    gameSurface.translate(width/2, height/2);
    if (!shiftMod) {
      gameSurface.rotateZ(rx);
      gameSurface.rotateX(ry);
    }
    listeOfCylinder.get(i).display();
    gameSurface.popMatrix();
  }
}

void drawNoShiftMode() {
  gameSurface.pushMatrix();
  gameSurface.translate(width/2, height/2); 
 
  gameSurface.rotateZ(rx);
  gameSurface.rotateX(ry);
  gameSurface.box(BOX_WIDTH, BOX_HEIGHT, BOX_DEPTH);
  gameSurface.pushMatrix();
  mover.update();
  mover.checkEdges();
  mover.checkCylinderCollision();
  mover.display();
  gameSurface.popMatrix();
  gameSurface.popMatrix();
}

void drawShiftMode() {
  gameSurface.pushMatrix();
  gameSurface.translate(width/2, height/2);
  gameSurface.box(BOX_WIDTH, BOX_DEPTH, BOX_HEIGHT);
  gameSurface.pushMatrix();
  gameSurface.translate(mover.location.x, mover.location.z, (BOX_HEIGHT/2 + SPHERE_RADIUS));
  gameSurface.sphere(SPHERE_RADIUS);
  gameSurface.popMatrix();
  gameSurface.popMatrix();
}

public void mouseDragged(MouseEvent e) {
  float deltaX = mouseX - pmouseX;
  float deltaY = mouseY - pmouseY;

  rx = rx + speed*map(deltaX, 0, width, 0, PI/3);
  ry = ry + speed*map(deltaY, 0, height, 0, -PI/3);
  rx = constrain(rx, -PI/3, PI/3);
  ry = constrain(ry, -PI/3, PI/3);
}

void mouseWheel(MouseEvent event) {
  speed = constrain(speed - event.getCount(), 0.2, 2);
}

void keyPressed() {
  if (key==CODED) {
    if (keyCode==SHIFT) {
      shiftMod=true;
    }
  }
}

void keyReleased() {
  if (key==CODED) {
    if (keyCode==SHIFT) {
      shiftMod=false;
    }
  }
}

//conditions for mousepressed( cylinders in frame)
boolean conditionOnMouseX() {
  return  mouseX >=( (width-BOX_WIDTH)/2 +CYLINDER_RADIUS) && mouseX <=( (width+BOX_WIDTH)/2 -CYLINDER_RADIUS);
}
boolean conditionOnMouseY() {
  return mouseY >=( (height-BOX_DEPTH)/2 +CYLINDER_RADIUS) && mouseY <=( (height+BOX_DEPTH)/2 -CYLINDER_RADIUS);
}

boolean conditionOnDistance(){
double distance = Math.sqrt( ( (mouseX-width/2) - mover.location.x) * ( (mouseX-width/2) - mover.location.x) + ( (mouseY-height/2) - mover.location.z) * ( (mouseY-height/2) - mover.location.z));
return distance >= 1.4*(CYLINDER_RADIUS+SPHERE_RADIUS);
}

void mousePressed() {
  if (shiftMod && conditionOnMouseX() && conditionOnMouseY()  && conditionOnDistance()) {
    Cylinder cyl1= new Cylinder(new PVector(mouseX-width/2, -BOX_HEIGHT/2, mouseY-height/2));
    listeOfCylinder.add(cyl1);
  }
}