import java.util.ArrayList;
import java.util.Collections;

int index = 0;

// Your input code should modify these!!
float screenTransX = 0;
float screenTransY = 0;
float screenRotation = 0;
float screenZ = 200f;

int trialCount = 4;         // This will be set higher for the bakeoff
float border = 0;           // Have some padding from the sides
int trialIndex = 0;         // What trial are we on
int errorCount = 0;         // Used to keep track of errors
float errorPenalty = 0.5f;  // For every error, add this to mean time
int startTime = 0;          // Time starts when the first click is captured
int finishTime = 0;         // Records the time of the final click
boolean userDone = false;

final int screenPPI = 199;  // What is the DPI of the screen you are using
// Many phones listed here: https://en.wikipedia.org/wiki/Comparison_of_high-definition_smartphone_displays 

private class Target {
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Target> targets = new ArrayList<Target>();

float inchesToPixels(float inch) {
  return inch * screenPPI;
}

void setup() {
  // Size does not let you use variables, so you have to manually compute this
  size(400, 700);  // Set this, based on your sceen's PPI to be a 2x3.5" area.

  rectMode(CENTER);
  textFont(createFont("Arial", inchesToPixels(.15f)));  // Sets the font to Arial that is .3" tall
  textAlign(CENTER);

  // Don't change this! 
  border = inchesToPixels(.2f);  // Padding of 0.2 inches

  for (int i = 0; i < trialCount; i++) {  // Don't change this! 
    Target t = new Target();
    t.x = random(- width / 2 + border, width / 2 - border);    // Set a random x with some padding
    t.y = random(- height / 2 + border, height / 2 - border);  // Set a random y with some padding
    t.rotation = random(0, 360);                               // Random rotation between 0 and 360
    t.z = ((i % 20) + 1)*inchesToPixels(.15f);                 // Increasing size from .15 up to 3.0"
    targets.add(t);
    println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
  }

  Collections.shuffle(targets);  // Randomize the order of the button; don't change this.
}

void draw() {
  background(60);  // Background is dark grey
  fill(200);
  noStroke();

  if (startTime == 0) {
    startTime = millis();
  }

  if (userDone) {
    text("User completed " + trialCount + " trials", width / 2, inchesToPixels(.2f));
    text("User had " + errorCount + " error(s)", width / 2, inchesToPixels(.2f) * 2);
    text("User took " + (finishTime - startTime) / 1000f / trialCount + " sec per target", width / 2, inchesToPixels(.2f) * 3);
    text("User took " + ((finishTime - startTime) / 1000f / trialCount + (errorCount * errorPenalty)) + " sec per target inc. penalty", width / 2, inchesToPixels(.2f) * 4);
    return;
  }

  // ========== DRAW TARGET SQUARE ==========
  pushMatrix();
  translate(width / 2, height / 2);  // Center the drawing coordinates to the center of the screen

  Target t = targets.get(trialIndex);


  translate(t.x, t.y);  // Center the drawing coordinates to the center of the screen
  translate(screenTransX, screenTransY);  // Center the drawing coordinates to the center of the screen

  rotate(radians(t.rotation));

  fill(255, 0, 0);  // Set color to semi translucent
  rect(0, 0, t.z, t.z);

  popMatrix();

  // =========== DRAW TARGETTING SQUARE ===========
  pushMatrix();
  translate(width / 2, height / 2);  // Center the drawing coordinates to the center of the screen
  rotate(radians(screenRotation));

  //custom shifts:
  //translate(screenTransX,screenTransY);  // Center the drawing coordinates to the center of the screen

  fill(255, 128);  // Set color to semi translucent
  rect(0, 0, screenZ, screenZ);

  popMatrix();

  scaffoldControlLogic();  // You are going to want to replace this!

  fill(255);
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchesToPixels(.5f));
}

boolean translateOn = true;
boolean rotateOn = false;
boolean scaleOn = false;
boolean overTarget = false, overCircle = false;

void scaffoldControlLogic() {
  
  Target t = targets.get(trialIndex);
  
  if (mousePressed & inchesToPixels(.1f) <= mouseX && mouseX <= inchesToPixels(0.5) 
    && height - inchesToPixels(0.5f) <= mouseY && mouseY <= height - inchesToPixels(0.1f)) {
    translateOn = true;
    rotateOn = false;
    scaleOn = false;
  } else if (mousePressed & inchesToPixels(.6f) <= mouseX && mouseX <= inchesToPixels(1.1) 
    && height - inchesToPixels(0.5f) <= mouseY && mouseY <= height - inchesToPixels(0.1f)) {
    translateOn = false;
    rotateOn = true;
    scaleOn = false;
  } else if (mousePressed & inchesToPixels(1.2f) <= mouseX && mouseX <= inchesToPixels(1.7) 
    && height - inchesToPixels(0.5f) <= mouseY && mouseY <= height - inchesToPixels(0.1f)) {
    translateOn = false;
    rotateOn = false;
    scaleOn = true;
  }
  
  if (scaleOn) {
    if (dist(mouseX, mouseY, width / 2 + t.x, height / 2 + t.y) < t.z / 2) {
      overCircle = true;
      overTarget = true;
    } else if (width / 2 + t.x - t.z / 2 <= mouseX && mouseX <= width / 2 + t.x + t.z / 2 &&
              height / 2 + t.y - t.z / 2 <= mouseY && mouseY <= height / 2 + t.z + t.x / 2) {
      overCircle = false;
      overTarget = true;
    } else {
      overCircle = false;
      overTarget = false;
    } 
  }
  
  
  if (translateOn) {
    fill(255);
  } else {
    stroke(255);
    strokeWeight(4);
    fill(60);
  }
  rect(inchesToPixels(0.25f), height - inchesToPixels(0.25f), inchesToPixels(0.5f), inchesToPixels(0.5f));  

  if (rotateOn) {
    fill(255);
  } else {
    stroke(255);
    strokeWeight(4);
    fill(60);
  }
  rect(inchesToPixels(0.85f), height - inchesToPixels(0.25f), inchesToPixels(0.5f), inchesToPixels(0.5f)); 
  
  if (scaleOn) {
    fill(255);
  } else {
    stroke(255);
    strokeWeight(4);
    fill(60);
  } 
  rect(inchesToPixels(1.45f), height - inchesToPixels(0.25f), inchesToPixels(0.5f), inchesToPixels(0.5f));   
  
  noStroke();
  
  fill(255);
}

void mouseDragged() {
  Target t = targets.get(trialIndex);
  if (translateOn) {
    t.x += mouseX - pmouseX;
    t.y += mouseY - pmouseY;
  }
  
  if (scaleOn && overTarget && !overCircle) {
    System.out.println("In here!");
    t.z = 2 * dist(mouseX, mouseY, width / 2 + t.x, height / 2 + t.y); 
  }
  
  if (rotateOn) {
    pushMatrix();
    translate(width / 2 + t.x, height / 2 + t.y);
    float ang = atan2(mouseY - height / 2 - t.y, mouseX - width / 2 - t.x);
    popMatrix();
    t.rotation = ang; 
  }
}

void mouseReleased() {
  // Check to see if user clicked middle of screen
  if (dist(0, 0, mouseX, mouseY) < inchesToPixels(.5f)) {
    if (userDone == false && !checkForSuccess()) {
      errorCount++;
    }

    // And move on to next trial
    trialIndex++;

    screenTransX = 0;
    screenTransY = 0;
    screenZ = 200f;
    screenRotation = 0;
    

    if (trialIndex == trialCount && userDone == false) {
      userDone = true;
      finishTime = millis();
    }
  }
}

public boolean checkForSuccess() {
  Target t = targets.get(trialIndex);  
  boolean closeDist = dist(t.x,t.y,-screenTransX,-screenTransY)<inchesToPixels(.05f);  // Has to be within .1"
  boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
  boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.05f);  // Has to be within .1"  
  
  println("Close Enough Distance: " + closeDist);
  println("Close Enough Rotation: " + closeRotation + "(dist="+calculateDifferenceBetweenAngles(t.rotation,screenRotation)+")");
  println("Close Enough Z: " + closeZ);
  
  return closeDist && closeRotation && closeZ;  
}

double calculateDifferenceBetweenAngles(float a1, float a2) {
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}