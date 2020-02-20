class Mover {
  PVector location;
  PVector velocity;
  PVector gravityForce;
  float gravityConstant=0.3;
  double delta=2.1;
  PVector friction;
  final double BOUNCE_MARGIN = 20;
  ArrayList<Float> scores=new ArrayList<Float>();



  Mover() {
    location = new PVector(0, -(BOX_HEIGHT/2 + SPHERE_RADIUS), 0); 
    velocity = new PVector(0, 0, 0);
    gravityForce=new PVector(0.2, 0, 0.4);
    friction=velocity.copy();
  }
  void update() {
    if (!shiftMod) {
      location.add(velocity);
      velocity.add(gravityForce).add(friction);
      gravityForce.x = sin(rx) * gravityConstant;
      gravityForce.z = sin(-ry) * gravityConstant;
      float normalForce = 1;
      float mu = 0.05;
      float frictionMagnitude = normalForce * mu;
      friction = velocity.copy();
      friction.mult(-1);
      friction.normalize();
      friction.mult(frictionMagnitude);
    }
  }
  void display() {
    gameSurface.stroke(0);
    gameSurface.strokeWeight(2);
    gameSurface.fill(127);
    gameSurface.translate(location.x, location.y, location.z);
    gameSurface.sphere(SPHERE_RADIUS);
  }

  void checkEdges() {
    if (location.z >= (BOX_DEPTH- SPHERE_RADIUS)/2  || location.z <= -((BOX_DEPTH- SPHERE_RADIUS)/2 )) {
       oldScore=score;
      score-=velocity.mag();
      scores.add(score);
      velocity.z = velocity.z * -1;
    }
    if (location.x >= (BOX_WIDTH- SPHERE_RADIUS)/2  || location.x <= -((BOX_WIDTH- SPHERE_RADIUS)/2 )) {
       oldScore=score;
    
      score-=velocity.mag();
      scores.add(score);
      velocity.x = velocity.x * -1;
    }
  }


  boolean collisionCondition(float cylinderX, float cylinderZ, float ballX, float ballY) {
    return dist(cylinderX, cylinderZ, ballX, ballY) <= SPHERE_RADIUS+CYLINDER_RADIUS+BOUNCE_MARGIN;
  }

  void checkCylinderCollision() {

    for (int i=0; i<listeOfCylinder.size(); ++i) {
      PVector cylinderPosition = listeOfCylinder.get(i).position;
      if (collisionCondition(cylinderPosition.x, cylinderPosition.z, location.x, location.z)) {   

        oldScore=score;
        score+= velocity.mag();
        scores.add(score);
        PVector n = new PVector(location.x-cylinderPosition.x, 0, location.z-cylinderPosition.z);
        n.normalize();
        float x=2* PVector.dot(velocity, n);
        velocity= velocity.sub(PVector.mult(n, x));
      }
    }
  }
}
