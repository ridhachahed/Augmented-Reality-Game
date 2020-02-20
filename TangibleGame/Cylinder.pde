class Cylinder {
 
  
  PShape openCylinder = new PShape();
  PShape top = new PShape();
  PShape buttom = new PShape();
  PVector position;
  PVector positionNotShifted;
  
  
  Cylinder(PVector position) {
    this.position=position;
    float angle;
    float[] x = new float[CYLINDER_RESOLUTION + 1];
    float[] y = new float[CYLINDER_RESOLUTION + 1];
    
    //get the x and y position on a circle for all the sides
    for (int i = 0; i < x.length; i++) {
      angle = (TWO_PI / CYLINDER_RESOLUTION) * i;
      x[i] = sin(angle) * CYLINDER_BASE_SIZE;
      y[i] = cos(angle) * CYLINDER_BASE_SIZE;
      positionNotShifted=new PVector(0, 0, 0);
    }
    
    //create openCylinder shape
    openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    //draw the border of the cylinder
    for (int i = 0; i < x.length; i++) {
      openCylinder.vertex(x[i], y[i], 0);
      openCylinder.vertex(x[i], y[i], CYLINDER_HEIGHT);
    } 
    openCylinder.endShape();

    //create top of the cylinder shape
    top= createShape();
    top.beginShape(TRIANGLE_FAN);
    top.vertex(0, 0,CYLINDER_HEIGHT);
    for (int i = 0; i < x.length; i++) {
      top.vertex(x[i], y[i],CYLINDER_HEIGHT);
    }
    top.endShape();
    
    //create base of cylinder shape
    buttom= createShape();
    buttom.beginShape(TRIANGLE_FAN);
    buttom.vertex(0, 0, 0);
    for (int i = 0; i < x.length; i++) {
      buttom.vertex(x[i], y[i], 0);
    }
    buttom.endShape();
  }

  void display() {
    
    if (shiftMod) {
      gameSurface.translate(position.x, position.z, 0);
    } else {  
      gameSurface.translate(position.x , position.y ,  position.z );
      gameSurface.rotateX(PI/2);  
    }
    gameSurface.shape(openCylinder);
    gameSurface.shape(top);
    gameSurface.shape(buttom);

    
  }
}
