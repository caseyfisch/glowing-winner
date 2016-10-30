import java.util.ArrayList;
import java.util.Collections;

import android.content.Context;
import android.os.Vibrator;

int index = 0;

// Your input code should modify these!!
float screenTransX = 0;
float screenTransY = 0;
float screenRotation = 0;
float screenZ = 200f;

int trialCount = 20;         // This will be set higher for the bakeoff
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

Vibrator v;
long[] vibPattern = {0,300, 100};

void setup() {
  // Size does not let you use variables, so you have to manually compute this
  size(400, 700);  // Set this, based on your sceen's PPI to be a 2x3.5" area.

  rectMode(CENTER);
  textFont(createFont("Arial", inchesToPixels(.08f)));  // Sets the font to Arial that is .3" tall
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
  
  v = (Vibrator) getActivity().getSystemService(Context.VIBRATOR_SERVICE);
}

boolean printOnce = true;

void draw() {
  if (xyCloseEnough() && rotCloseEnough() && sizeCloseEnough()) {
    background(169, 204, 174);
    v.vibrate(vibPattern, 0);
  } else {
    v.cancel();
    background(60);  // Background is dark grey
  }
  
  if (printOnce) {
    if (!userDone) {
      Target t = targets.get(trialIndex);
      System.out.println(t.x + " " + t.y + " " + t.z + " " + t.rotation);
      printOnce = false;
    }
  }
  
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

  fill(255, 221, 70);  // Set color to yellow
  rect(0, 0, t.z, t.z);
  if (xyCloseEnough()) {
    fill(105, 229, 124);
  } else {
    fill(255);
  }
  ellipse(0, 0, inchesToPixels(.05f), inchesToPixels(.05f));

  popMatrix();

  // =========== DRAW TARGETTING SQUARE ===========
  pushMatrix();
  translate(width / 2, height / 2);  // Center the drawing coordinates to the center of the screen
  rotate(radians(screenRotation));

  //custom shifts:
  //translate(screenTransX,screenTransY);  // Center the drawing coordinates to the center of the screen

  fill(255, 128);  // Set color to semi translucent
  rect(0, 0, screenZ, screenZ);
  if (xyCloseEnough()) {
    fill(105, 229, 124);
  } else {
    fill(127, 127);    
  }
  ellipse(0, 0, 2 * inchesToPixels(.05f), 2 * inchesToPixels(.05f));

  popMatrix();
  
  stroke(255);
  strokeWeight(2);
  line(width / 2 + t.x, height / 2 + t.y, width / 2, height / 2);
  noStroke();

  scaffoldControlLogic();  // You are going to want to replace this!

  fill(255);
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchesToPixels(.5f));
}

boolean xyCloseEnough() {
  if (userDone) return false;
  
  Target t = targets.get(trialIndex); 
  return dist(t.x, t.y, -screenTransX, -screenTransY) < inchesToPixels(.05f); 
}

boolean rotCloseEnough() {
  if (userDone) return false;
  Target t = targets.get(trialIndex); 
  return calculateDifferenceBetweenAngles(t.rotation,screenRotation) <= 5; 
}

boolean sizeCloseEnough() {
  if (userDone) return false;
  Target t = targets.get(trialIndex); 
  return abs(t.z - screenZ) < inchesToPixels(.05f); 
}

boolean translateOn = true;
boolean rotateOn = false;
boolean scaleOn = false;
boolean overTarget = false, overCircle = false;

void scaffoldControlLogic() {
  
  
  Target t = targets.get(trialIndex);
  
  // Control which mode is toggled on
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
    
    startingAng = t.rotation;
    firstTouch = true;
  } else if (mousePressed & inchesToPixels(1.2f) <= mouseX && mouseX <= inchesToPixels(1.7) 
    && height - inchesToPixels(0.5f) <= mouseY && mouseY <= height - inchesToPixels(0.1f)) {
    translateOn = false;
    rotateOn = false;
    scaleOn = true;
  }
  
  // If we're scaling, detect where the mouse has grabbed the corner
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
    if (xyCloseEnough()) {
      fill(105, 229, 124);
    } else {
      fill(255); 
    }
    noStroke();
  } else {
    if (xyCloseEnough()) {
      stroke(105, 229, 124);
    } else {
      stroke(255);
    }
    strokeWeight(4);
    fill(0, 0);
  }
  rect(inchesToPixels(0.25f), height - inchesToPixels(0.25f), inchesToPixels(0.5f), inchesToPixels(0.5f));  

  if (rotateOn) {
    if (rotCloseEnough()) {
      fill(105, 229, 124);
    } else {
      fill(255); 
    }
    noStroke();
  } else {
    if (rotCloseEnough()) {
      stroke(105, 229, 124);
    } else {
      stroke(255);
    }
    strokeWeight(4);
    fill(0, 0);
  }
  rect(inchesToPixels(0.85f), height - inchesToPixels(0.25f), inchesToPixels(0.5f), inchesToPixels(0.5f)); 
  
  if (scaleOn) {
    if (sizeCloseEnough()) {
      fill(105, 229, 124);
    } else {
      fill(255); 
    }
    noStroke();
  } else {
    if (sizeCloseEnough()) {
      stroke(105, 229, 124);
    } else {
      stroke(255);
    }
    strokeWeight(4);
    fill(0, 0);
  } 
  rect(inchesToPixels(1.45f), height - inchesToPixels(0.25f), inchesToPixels(0.5f), inchesToPixels(0.5f));   
  
  noStroke();
  fill(255);
}

boolean firstTouch = true;
float startingAng = 0.0;
float touchAng = 0.0;

boolean notSet = true;
int startingY = 0;
int startingMouseY = 0;
int startingMouseX = 0;
float diff = 0.0f;

void mousePressed() {
  if (userDone) return;

  Target t = targets.get(trialIndex);
  
  startingY = mouseY; 
  if (notSet && scaleOn) {
    startingMouseY = mouseY;
    startingMouseX = mouseX;
    diff = t.z - screenZ;
    notSet = false;
    System.out.println("Setting: " + startingMouseX + ", " + startingMouseY + ", " + t.z + ", " + diff);
  }
}

void mouseDragged() {
  if (userDone) return;
  if (mouseY > height - inchesToPixels(0.5f)) return;
  if (dist(0, 0, mouseX, mouseY) < inchesToPixels(.5f)) return;

  Target t = targets.get(trialIndex);
  
  // If translating, just move relative to the mouseX and mouseY
  if (translateOn) {
    t.x += mouseX - pmouseX;
    t.y += mouseY - pmouseY;
    
    if (xyCloseEnough()) {
      v.vibrate(100);
    }
  }
  
  // If scaling, scale linearly with mouseY 
  if (scaleOn) {
    t.z = constrain(t.z + (startingY - mouseY), inchesToPixels(0.15f), inchesToPixels(3.0f));
    startingY = mouseY;
    
    fill(255);
    stroke(157, 224, 103);
    strokeWeight(2 * inchesToPixels(.05f));
    line(0, startingMouseY + diff, width, startingMouseY + diff);
    
    stroke(255);
    strokeWeight(1.2 * inchesToPixels(.05f));
    line(0, mouseY, width, mouseY);
    noStroke();
    
    if (sizeCloseEnough()) {
      v.vibrate(100);
    }
  }
  
  // If rotating, rotate as the mouse moves around square
  if (rotateOn) {
    pushMatrix();
    translate(width / 2, height / 2);
    float ang = degrees(atan2(mouseY - height / 2 - t.y, mouseX - width / 2 - t.x));
    
    if (firstTouch) {
      startingAng = t.rotation; 
      firstTouch = false;
      touchAng = ang;
    }
    
    t.rotation = startingAng + (ang - touchAng); 
    
    System.out.println(degrees(atan2(height / 2 - mouseY, width / 2 - mouseX)) + " , " + t.rotation);
    
    if (rotCloseEnough()) {  
      v.vibrate(100);
    }
    
  }
}

void mouseReleased() {
  if (userDone) return;
  
  // Can't submit unless all values are good
  
  Target t = targets.get(trialIndex);
  startingAng = t.rotation;
  firstTouch = true;
  notSet = true;
  
  if (translateOn && xyCloseEnough()) {
    translateOn = false;
    if (!rotCloseEnough()) {
      rotateOn = true;
      scaleOn = false;
    } else if (!sizeCloseEnough()) {
      scaleOn = true;
      rotateOn = false;
    } else {
      scaleOn = false;
      rotateOn = false;
    }
  } else if (rotateOn && rotCloseEnough()) {
    translateOn = false;
    if (!sizeCloseEnough()) {
      scaleOn = true;
      rotateOn = false;
    } else if (!xyCloseEnough()) {
      translateOn = true;
      rotateOn = false;
      scaleOn = false;
    } else {
      scaleOn = false;
      rotateOn= false;
      translateOn = false;
    }
  } else if (scaleOn && sizeCloseEnough()) {
    scaleOn = false;
    if (!xyCloseEnough()) {
      translateOn = true;
      rotateOn = false;
    } else if (!rotCloseEnough()) {
      rotateOn = true;
      translateOn = false;
    } else {
      rotateOn = false;
      translateOn = false;
    }
  }
  
  if (!(xyCloseEnough() && rotCloseEnough() && sizeCloseEnough())) return;

  
  // Check to see if user clicked middle of screen
  if (dist(0, 0, mouseX, mouseY) < inchesToPixels(.5f)) {
    v.cancel();
    
    if (userDone == false && !checkForSuccess()) {
      errorCount++;
    }

    // And move on to next trial
    trialIndex++;

    screenTransX = 0;
    screenTransY = 0;
    screenZ = 200f;
    screenRotation = 0;
    
    translateOn = true;
    rotateOn = false;
    scaleOn = false;
    
    printOnce = true;

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
  diff %= 90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}