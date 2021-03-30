/* Dec. 16, 2019
   Bernie Chen
   Mrs. Krasteva
   ICS20 ISP - Draft 1 */
   
/* References and Credits
   Arrays: processing.org
   Switch statements: w3schools.com/java/java_switch.asp
   pushMatrix(), popMatrix(): processing.org
   Parameterized and Return Methods: https://www.codingeek.com/java/methods-java-parameterized-non-parameterized-methods-returning-values/
   
   Inspiration of the art design came from Toby Fox and his video game "Undertale."
   
   Resources:
   All textures (except for during the animation): Pixilart
   Font: 8-bit operator
*/

PImage brickLeft, brick, brickRight, charlieState, topLeft, top, topRight, left, right, backLeft, backRight, cornerBR, cornerBL, cornerFL, cornerFR, back, pedestal, scroll, title, doorClosed, doorOpen; //Maze textures.
PImage torchUnlit; //Torch texture
PImage vault; //Vault texture
final PImage[] charlieForms = new PImage[16], menuForms = new PImage[5], torchLit = new PImage[4]; //Animated images
final String[] passwords = {"CODES", "GRADE", "LIVES", "GAMES", "SCORE", "TORCH", "IMAGE", "BRICK", "MAZES", "VAULT"}; //Possible passcodes for game of testing.
final String[] [] blueprint = new String[54] [54]; //The maze blueprint in an array.
String gameState = "menu"; //The game's state (animation, menu, test, maze)
PFont operatorButton, operator, operatorVault, operatorScroll; //The fonts
int xpos = 1944, ypos = 196, charlieDir = 1, walkTime = 0, menuTime = 0, gameAnim = 0, scriptTime = 0, pedestalX = -100, pedestalY = -100, fadeTime = 0, matches = 0, torchTime = 0; //The maze variables.
boolean mLeft = false, mRight = false, mUp = false, mDown = false, inWall = false, mainButtonMaze = false, mainButtonTest = false, mainButtonExit = false, nextButton = false, open = false, mazeInteract = false, stopMovement = false, introductory = false, readable = false, foundAlphanum = false, foundMorse = false, foundCaesar = false, firstAlphanum = false, firstMorse = false, firstCaesar = false, completedMaze = false, escapedMaze = false, endMenu = false; //The maze booleans.
boolean[] torchesLit = new boolean[3]; //Saves the state of the torches.
boolean wonTest = false, completedTest = false; //The game of testing booleans (lines 29 and 30)
boolean letter1 = false, letter2 = false, letter3 = false, letter4 = false, letter5 = false, enterButton = false, completedVault = false, wonVault = false, showWrong, countdown;
int startTime, timeLeft = 60, highscore = 0, wrongTime = 255; //The game of testing variables.
char[] typed = {'_', '_', '_', '_', '_'}; //Saves the letter input in the game of testing.
int letterInput = '_', code, cipher; //More game of testing variables.
String clue; //The writing on the sticky note.
String[] morse = {".-", "-...", "-.-.", "-..", ".", "..-.", "--.", "....", "..", ".---", "-.-", ".-..", "--", "-.", "---", ".--.", "--.-", ".-.", "...", "-", "..-", "...-", ".--", "-..-", "-.--", "--.."}; //The morse translation array.
int animTime = 0; //The animation time (in frames)
boolean returnButton = false;
void setup() {
  size(864, 864); //Loads screen, images, and fonts.
  frameRate(100);
  createCharlie();
  createMaze();
  createTest();
  operatorButton = createFont("8bitoperator.ttf", 32);
  operator = createFont("8bitoperator.ttf", 24);
  createMenu();
}
void keyPressed() {
  if (gameState.equals("maze")) { //Takes keyboard arrow input for the maze thru booleans mUp, mDown, mLeft, and mRight.
    if (key == CODED) {
      if (keyCode == UP){
        mUp = true;
      } else if (keyCode == DOWN) {
        mDown = true;
      }
      if (keyCode == LEFT) {
        mLeft = true;
      } else if (keyCode == RIGHT) {
        mRight = true;
      }
    }
    if (key == 'z' && !stopMovement && !mazeInteract) mazeInteract = true; //Takes 'Z' for interaction in maze.
  } else if (gameState.equals("test") && !completedTest && !countdown) {
    if (key >= 'a' && key <= 'z') { //Takes alphabetic keyboard input for the game of texting.
      letterInput = key-32;
    }
  }
}
void keyReleased() {//Takes keyboard arrow input for the maze thru booleans mUp, mDown, mLeft, and mRight.
  if (key == CODED) {
    if (keyCode == LEFT) {
      mLeft = false;
    } else if (keyCode == RIGHT) {
      mRight = false;
    }
    if (keyCode == UP){
      mUp = false;
    } else if (keyCode == DOWN) {
      mDown = false;
    }
  }
}
void draw() {
  clear();
  background(0);
  textFont(operator);
  if (gameState.equals("animation")) {
    splash(); //Plays animation.
  } else if (gameState.equals("menu")) {
    gameMenu(255-menuTime+100); //Loads menu.
    if ((nextButton && (mainButtonMaze || mainButtonTest || mainButtonExit)) || endMenu) {
      menuTime += 2; //Commences transition sequence to exit, maze, and game of testing.
      endMenu = true;
    } else if (nextButton && escapedMaze) {
      nextButton = false; //Transitions to maze game.
      mainButtonMaze = false;
      escapedMaze = false;
    } else if (nextButton && completedTest) {
      nextButton = false; //Transitions to game of testing.
      mainButtonTest = false;
      completedTest = false;
    }
  } else if (gameState.equals("maze")) {
    noTint();
    if (!(torchesLit[0] && torchesLit[1] && torchesLit[2])) { //If all torches are lighted, prime transition to menu.
      menuTime = 0;
    }
    checkBoundary(); //Check the boundaries.
    loadMaze(); //Load the maze onto the screen.
    if (!stopMovement && !escapedMaze) mazeInput(); //Without restrictions, takes keyboard input for maze game.
    torchTime++; //Animates the torches
    torchTime %= 40;
    checkTorches(); //Checks and calculates the number of matches the protagonist has.
    mazeEndSequence(); //If applicable, starts the end transition to menu.
  } else if (gameState.equals("test")) {
    noTint();
    loadTest(); //Loads the test.
  }
}
void gameMenu(int darkness) {
  if (darkness <= 0) { //Changes gameState.
    gameAnim = 0;
    if (mainButtonMaze) {
      setVarMaze();
      gameState = "maze";
    } else if (mainButtonTest) {
      setVarTest();
      gameState = "test";
    } else if (mainButtonExit) {
      exit();
    }
    scriptTime = 0;
  }
  gameAnim %= 50;
  tint(255, darkness);
  image(menuForms[(gameAnim/10)], 0, 0);
  image(title, 112, 50);
  if (mainButtonMaze) { //Shows the instructions for the maze.
    instructMaze(darkness);
  } else if (mainButtonTest) { //Shows the instructions for the game of testing.
    instructVault(darkness);
  } else if (mainButtonExit) { //Shows the goodbye sequence
    goodbye(darkness);
  } else if (escapedMaze) { //Shows the congratulatory message on completion of the maze.
    congratsMaze();
  } else if (completedTest && wonTest) { //Gives congratulations to game completion.
    congrats();
  } else if (completedTest && !wonTest) { //Gives a “Try Again!” message in the game of testing.
    retry();
  } else { //Shows the main menu with buttons.
    textFont(operatorButton);
    rectMode(CENTER);
    stroke(0);
    strokeWeight(4);
    fill(#815400, darkness);
    if (mouseX < 532 && mouseX > 332 && mouseY > 396 && mouseY < 476) { //Lets buttons to change colour when hovered on.
      fill(#B48A3A, darkness);
    }
    rect(432, 436, 200, 80);
    fill(#815400, darkness);
    if (mouseX < 532 && mouseX > 332 && mouseY > 496 && mouseY < 576) {
      fill(#B48A3A, darkness);
    }
    rect(432, 536, 200, 80);
    fill(#815400, darkness);
    if (mouseX < 532 && mouseX > 332 && mouseY > 596 && mouseY < 676) {
      fill(#B48A3A, darkness);
    }
    rect(432, 636, 200, 80);
    fill(255, darkness);
    textAlign(LEFT, BOTTOM);
    text("By Bernie Chen", 525, 820);
    textAlign(CENTER,CENTER);
    text("MAZE", 432, 432);
    if (completedMaze) text("COMPLETED!", 700, 432);
    text("TEST", 432, 532);
    if (wonTest) text("HIGHSCORE: "+highscore, 700, 532);
    text("EXIT", 432, 632);
  }
  gameAnim++;
}
void mousePressed() {
  if (!mainButtonMaze) { //On the menu, clicking a button will register its corresponding boolean.
    mainButtonMaze = mouseX < 532 && mouseX > 332 && mouseY > 396 && mouseY < 476;
    if (mainButtonMaze) scriptTime = 0;
  }
  if (!mainButtonTest) {
    mainButtonTest = mouseX < 532 && mouseX > 332 && mouseY > 496 && mouseY < 576;
    if (mainButtonTest) scriptTime = 0;
  }
  if (!mainButtonExit) {
    mainButtonExit = mouseX < 532 && mouseX > 332 && mouseY > 596 && mouseY < 676;
    if (mainButtonExit) scriptTime = 0;
  }
  if (!nextButton) nextButton = mouseX < 750 && mouseX > 550 && mouseY > 760 && mouseY < 840 && (mainButtonMaze || mainButtonTest || mazeInteract || escapedMaze || completedTest || mainButtonExit);
  else if (!mainButtonMaze && !mainButtonTest) nextButton = false;
  if (!returnButton) returnButton = mouseX < 314 && mouseX > 114 && mouseY > 760 && mouseY < 840 && (mainButtonMaze || mainButtonTest);
  if (mouseX > 332 && mouseX < 420 && mouseY > 132 && mouseY < 275 && gameState.equals("test")) { //On the game of testing, clicking a digit box will register its corresponding boolean.
    letter1 = true;
    letter2 = false;
    letter3 = false;
    letter4 = false;
    letter5 = false;
    letterInput = typed[0];
  }
  if (mouseX > 436 && mouseX < 524 && mouseY > 132 && mouseY < 275 && gameState.equals("test")) {
    letter1 = false;
    letter2 = true;
    letter3 = false;
    letter4 = false;
    letter5 = false;
    letterInput = typed[1];
  }
  if (mouseX > 540 && mouseX < 628 && mouseY > 132 && mouseY < 275 && gameState.equals("test")) {
    letter1 = false;
    letter2 = false;
    letter3 = true;
    letter4 = false;
    letter5 = false;
    letterInput = typed[2];
  }
  if (mouseX > 644 && mouseX < 732 && mouseY > 132 && mouseY < 275 && gameState.equals("test")) {
    letter1 = false;
    letter2 = false;
    letter3 = false;
    letter4 = true;
    letter5 = false;
    letterInput = typed[3];
  }
  if (mouseX > 748 && mouseX < 836 && mouseY > 132 && mouseY < 275 && gameState.equals("test")) {
    letter1 = false;
    letter2 = false;
    letter3 = false;
    letter4 = false;
    letter5 = true;
    letterInput = typed[4];
  }
  if (mouseX > 104 && mouseX < 334 && mouseY > 565 && mouseY < 665 && gameState.equals("test")) {
    enterButton = true;
    letter1 = false;
    letter2 = false;
    letter3 = false;
    letter4 = false;
    letter5 = false;
  }
}
String showScript(String script, int progress) { //Shows the "rolling" text.
  if (progress < script.length()) return script.substring(0, progress);
  else return script;
}
void goodbye(int darkness) { //Shows the final goodbye message.
  textAlign(LEFT, TOP);
  rectMode(CORNERS);
  image(scroll, 0, 0);
  fill(0);
  text(showScript("Thank you for playing Ciphus! Have a good day and hope you learned something!", scriptTime), 192, 160, 672, 848);
  fill(#815400, darkness);
  if (mouseX < 750 && mouseX > 550 && mouseY > 760 && mouseY < 840) {
    fill(#B48A3A, darkness);
  }
  rectMode(CENTER);
  rect(650, 800, 200, 80);
  textFont(operatorButton);
  textAlign(CENTER, CENTER);
  fill(255, darkness);
  text("EXIT", 650, 796);
  scriptTime++;
}
void congratsMaze() { //Shows the congratulatory message on completion of the maze.
  endMenu = false;
  textAlign(LEFT, TOP);
  rectMode(CORNERS);
  image(scroll, 0, 0);
  fill(0);
  stroke(0);
  strokeWeight(5);
  text(showScript("You escaped the maze!\nCongratulations!", scriptTime), 192, 160, 672, 848);
  fill(#815400);
  if (mouseX < 750 && mouseX > 550 && mouseY > 760 && mouseY < 840) {
    fill(#B48A3A);
  }
  rectMode(CENTER);
  rect(650, 800, 200, 80);
  textFont(operatorButton);
  textAlign(CENTER, CENTER);
  fill(255);
  text("TO MENU", 650, 796);
  scriptTime++;
  if (nextButton) {
    escapedMaze = false;
    nextButton = false;
  }
}
void congrats() { //Gives congratulations to game completion.
  endMenu = false;
  textAlign(LEFT, TOP);
  rectMode(CORNERS);
  image(scroll, 0, 0);
  fill(0);
  stroke(0);
  strokeWeight(5);
  text(showScript("You opened the vault and got the money!\nCongratulations!", scriptTime), 192, 160, 672, 848);
  fill(#815400);
  if (mouseX < 750 && mouseX > 550 && mouseY > 760 && mouseY < 840) {
    fill(#B48A3A);
  }
  rectMode(CENTER);
  rect(650, 800, 200, 80);
  textFont(operatorButton);
  textAlign(CENTER, CENTER);
  fill(255);
  text("TO MENU", 650, 796);
  scriptTime++;
  if (nextButton) {
    completedTest = false;
    nextButton = false;
  }
}
void retry() { //Gives a “Try Again!” message in the game of testing.
  endMenu = false;
  textAlign(LEFT, TOP);
  rectMode(CORNERS);
  image(scroll, 0, 0);
  fill(0);
  stroke(0);
  strokeWeight(5);
  text(showScript("Time out!\nMaybe next time you could get some decrypting tools, like a cipher wheel or reference sheet...", scriptTime), 192, 160, 672, 848);
  fill(#815400);
  if (mouseX < 750 && mouseX > 550 && mouseY > 760 && mouseY < 840) {
    fill(#B48A3A);
  }
  rectMode(CENTER);
  rect(650, 800, 200, 80);
  textFont(operatorButton);
  textAlign(CENTER, CENTER);
  fill(255);
  text("TO MENU", 650, 796);
  scriptTime++;
  if (nextButton) {
    completedTest = false;
    nextButton = false;
  }
}
void instructMaze(int darkness) { //Shows the instructions for the maze.
  textAlign(LEFT, TOP);
  rectMode(CORNERS);
  image(scroll, 0, 0);
  fill(0);
  text(showScript("Goal: To escape the maze.\nUse the arrow keys to move around and find pedestals with scrolls. Press 'Z' to interact with objects in the maze.\nIn order to open the entrance, you need to light three torches at the start.\nGood luck!", scriptTime), 192, 160, 672, 848);
  fill(#815400, darkness);
  if (mouseX < 750 && mouseX > 550 && mouseY > 760 && mouseY < 840) {
    fill(#B48A3A, darkness);
  }
  rectMode(CENTER);
  rect(650, 800, 200, 80);
  fill(#815400, darkness);
  if (mouseX < 314 && mouseX > 114 && mouseY > 760 && mouseY < 840) {
    fill(#B48A3A, darkness);
  }
  rect(214, 800, 200, 80);
  textFont(operatorButton);
  textAlign(CENTER, CENTER);
  fill(255, darkness);
  text("PLAY!", 650, 796);
  text("BACK", 214, 796);
  scriptTime++;
  if (returnButton) {
    returnButton = false;
    mainButtonMaze = false;
    scriptTime = 0;
  }
}
void instructVault(int darkness) { //Shows the instructions for the game of testing.
  textAlign(LEFT, TOP);
  rectMode(CORNERS);
  image(scroll, 0, 0);
  fill(0);
  text(showScript("Goal: To open the vault.\nUsing clues you see (hint: read the sticky note), decrypt and discover the five-letter word to unlock the vault!\nClick the black digit boxes and type in the letters that the encryption decrypts to.\nGood luck!", scriptTime), 192, 160, 672, 848);
  fill(#815400, darkness);
  if (mouseX < 750 && mouseX > 550 && mouseY > 760 && mouseY < 840) {
    fill(#B48A3A, darkness);
  }
  rectMode(CENTER);
  rect(650, 800, 200, 80);
  fill(#815400, darkness);
  if (mouseX < 314 && mouseX > 114 && mouseY > 760 && mouseY < 840) {
    fill(#B48A3A, darkness);
  }
  rect(214, 800, 200, 80);
  textFont(operatorButton);
  textAlign(CENTER, CENTER);
  fill(255, darkness);
  text("PLAY!", 650, 796);
  text("BACK", 214, 796);
  scriptTime++;
  if (returnButton) {
    returnButton = false;
    mainButtonTest = false;
    scriptTime = 0;
  }
}
void splash() { //Shows the animation
  if (animTime <= 135) {
    background(#e7cfb4); //Scene 1: child lifts sweater over counter.
    noStroke();
    ellipseMode(RADIUS);
    rectMode(CORNERS);
    fill(200);
    rect(0, 400, 864, 425);
    fill(#563232);
    for (int x = 0; x < 864; x += 128) rect(x, 380, x+16, 864);
    colorMode(HSB, 254);
    for (int x = 0; x < 864; x += 64) {
      pushMatrix();
      fill(x%254, 254, 127);
      translate(x, 350);
      stroke(100, 100);
      strokeWeight(3);
      beginShape();
      vertex(-20, 60);
      bezierVertex(-10, 70, 10, 70, 20, 60);
      bezierVertex(70, 60, 70, 60, 80, 100);
      vertex(85, 125);
      bezierVertex(90, 150, 90, 150, 90, 200);
      vertex(60, 205);
      vertex(60, 220);
      bezierVertex(20, 225, -20, 225, -60, 220);
      vertex(-60, 205);
      vertex(-90, 200);
      bezierVertex(-90, 150, -90, 150, -85, 125);
      vertex(-80, 100);
      bezierVertex(-70, 60, -70, 60, -20, 60);
      endShape();
      popMatrix();
    }
    colorMode(RGB, 255, 255, 255);
    pushMatrix();
    translate(432, 432);
    fill(#c4a344);
    rect(-15, 40, 15, 70);
    ellipse(0, 0, 60, 50);
    fill(#917732);
    arc(0, -1, 60, 15, 0, PI);
    fill(0);
    ellipse(-20, 5, 4, 12);
    ellipse(20, 5, 4, 12);
    fill(#424242);
    arc(0, -6, 80, 10, 0, PI);
    quad(-80, -6, 80, -6, 60, -16, -60, -16);
    fill(#535252);
    arc(0, -16, 60, 50, PI, TWO_PI);
    fill(#850505);
    translate(0, -20*sin(radians(animTime)));
    stroke(100, 100);
    strokeWeight(3);
    beginShape();
    vertex(-20, 60);
    bezierVertex(-10, 70, 10, 70, 20, 60);
    bezierVertex(70, 60, 70, 60, 80, 100);
    vertex(85, 125);
    bezierVertex(90, 150, 90, 150, 90, 200);
    vertex(60, 205);
    vertex(60, 220);
    bezierVertex(20, 225, -20, 225, -60, 220);
    vertex(-60, 205);
    vertex(-90, 200);
    bezierVertex(-90, 150, -90, 150, -85, 125);
    vertex(-80, 100);
    bezierVertex(-70, 60, -70, 60, -20, 60);
    endShape();
    fill(#8ac149);
    quad(80, 100, 85, 125, 60, 130, 55, 105);
    quad(-80, 100, -85, 125, -60, 130, -55, 105);
    quad(-62, 136, -55, 105, 55, 105, 62, 136);
    fill(#feebee);
    quad(81.5, 107.5, 83.5, 117.5, 58.5, 122.5, 56.5, 112.5);
    quad(-81.5, 107.5, -83.5, 117.5, -58.5, 122.5, -56.5, 112.5);
    quad(-60, 126, -57, 115, 57, 115, 60, 126);
    fill(0);
    noStroke();
    ellipse(-50, 60, 20, 10);
    ellipse(50, 60, 20, 10);
    popMatrix();
    fill(#8b5a2b);
    stroke(100, 100);
    rect(0, 532, 864, 582);
    fill(#57381b);
    rect(0, 582, 864, 864);
  } else if (animTime < 510){
    background(#844c0c); //Scene 2: child slides coins over counter, shopkeeper takes the coins.
    stroke(100, 100);
    if (animTime >= 240 && animTime <= 420) {
      fill(#ffd700);
      ellipse(432, 432, 50, 50);
      ellipse(442, 462, 50, 50);
      ellipse(415, 402, 50, 50);
    }
    noStroke();
    pushMatrix();
    fill(0);
    translate(0, -432*sin(radians(animTime-150)));
    if (animTime < 390) {
      beginShape();
      vertex(332, 864);
      bezierVertex(302, 664, 562, 664, 490, 980);
      vertex(310, 980);
      bezierVertex(280, 814, 332, 814, 332, 864);
      endShape();
      fill(#850505);
      rect(330, 980, 470, 2000);
    }
    popMatrix();
    pushMatrix();
    translate(432, 864*sin(radians(animTime-330))+432);
    rotate(PI);
    fill(0);
    noStroke();
    beginShape();
    vertex(332-432, 864);
    bezierVertex(302-432, 664, 562-432, 664, 490-432, 980);
    vertex(310-432, 980);
    bezierVertex(280-432, 814, 332-432, 814, 332-432, 864);
    endShape();
    fill(#55710E);
    rect(330-432, 980, 470-432, 2000);
    popMatrix();
  } else if (animTime < 3000){
    pushMatrix(); //Scene 3: child goes on bike, travels from town to forest with mountain in background.
    background(lerpColor(#87ceeb, #fd5e53, animTime/1750.0));
    rectMode(CORNERS);
    ellipseMode(RADIUS);
    fill(#f9d71c);
    noStroke();
    ellipse(432, (animTime-510)/3.0, 100, 100);
    translate(-animTime+510, 0);
    strokeCap(ROUND);
    stroke(100, 100);
    strokeWeight(4);
    fill(#ad8456);
    rect(20, 600, 320, 864);
    beginShape();
    vertex(320, 764);
    vertex(320, 600);
    vertex(440, 510);
    vertex(560, 600);
    vertex(560, 764);
    endShape(CLOSE);
    fill(50);
    beginShape();
    vertex(300, 610);
    vertex(10, 610);
    vertex(10, 500);
    vertex(320, 500);
    vertex(440, 500);
    vertex(580, 610);
    vertex(570, 610);
    vertex(440, 510);
    vertex(310, 610);
    vertex(300, 610);
    vertex(440, 500);
    endShape(CLOSE);
    fill(#918e7d);
    rect(0, 764, 1296, 864);
    rect(100, 525, 150, 450);
    for (int x = 32; x <= 1296; x += 32) {
      line(x, 764, x, 864);
      for (int y = 764+x%64/32*25; y < 864; y += 50) {
        line(x, y, x-32, y);
      }
    }
    rect(20, 740, 0, 764);
    rect(350, 740, 530, 764);
    fill(#a8ccd7);
    rect(50, 650, 100, 700);
    rect(150, 650, 200, 700);
    rect(250, 650, 300, 700);
    rect(340, 650, 390, 700);
    rect(490, 650, 540, 700);
    fill(#765c48);
    rect(410, 650, 470, 740);
    rect(650, 500, 1100, 764);
    stroke(50);
    strokeWeight(2);
    for (int y = 500; y < 764; y += 24) line(650, y, 1100, y);
    stroke(100, 100);
    fill(#55342b);
    strokeWeight(4);
    rect(700, 500, 740, 764);
    rect(1050, 500, 1010, 764);
    rect(650, 730, 1100, 764);
    rect(845, 730, 905, 640);
    fill(#a8ccd7);
    rect(760, 650, 810, 700);
    rect(990, 650, 940, 700);
    rect(760, 550, 810, 600);
    rect(990, 550, 940, 600);
    rect(850, 550, 900, 600);
    fill(50);
    rect(630, 400, 1120, 520);
    stroke(0);
    strokeCap(SQUARE);
    strokeWeight(6);
    line(0, 740, 1296, 740);
    for (int x = 0; x <= 1296; x += 16) line(x, 764, x, 724);
    noStroke();
    fill(150);
    beginShape();
    vertex(2796, 864);
    vertex(2896, 100);
    vertex(2996, 164);
    vertex(3096, 50);
    vertex(3396, 864);
    endShape();
    for (int x = 1471; x <= 3500; x += 200) {
      fill(#55342b);
      rect(x, 864, x+100, 664);
      fill(#01796f);
      triangle(x-100, 664, x+200, 664, x+50, 430);
      triangle(x-80, 500, x+180, 500, x+50, 290);
      triangle(x-50, 340, x+150, 340, x+50, 90);
    }
    for (int x = 1371; x <= 3500; x += 200) {
      fill(#331f1a);
      rect(x, 864, x+100, 714);
      fill(#014641);
      triangle(x-100, 714, x+200, 714, x+50, 480);
      triangle(x-80, 550, x+180, 550, x+50, 340);
      triangle(x-50, 390, x+150, 390, x+50, 140);
    }
    fill(#334d00);
    rect(1371, 764, 3500, 864);
    fill(0, 100);
    rect(1321, 0, 3500, 864);
    popMatrix();
    noFill();
    stroke(0);
    pushMatrix();
    translate(375, 732);
    strokeWeight(6);
    ellipse(0, 0, 32, 32);
    strokeWeight(2);
    rotate(animTime/75.0);
    line(-32, 0, 32, 0);
    line(0, -32, 0, 32);
    line(-32/sqrt(2), -32/sqrt(2), 32/sqrt(2), 32/sqrt(2));
    line(-32/sqrt(2), 32/sqrt(2), 32/sqrt(2),-32/sqrt(2));
    rotate(-animTime/75.0);
    translate(114, 0);
    strokeWeight(6);
    ellipse(0, 0, 32, 32);
    strokeWeight(2);
    rotate(animTime/75.0);
    line(-32, 0, 32, 0);
    line(0, -32, 0, 32);
    line(-32/sqrt(2), -32/sqrt(2), 32/sqrt(2), 32/sqrt(2));
    line(-32/sqrt(2), 32/sqrt(2), 32/sqrt(2), -32/sqrt(2));
    popMatrix();
    strokeWeight(6);
    strokeCap(ROUND);
    line(375, 732, 432, 732);
    ellipse(432, 732, 5, 5);
    line(375, 732, 404, 680);
    line(432, 732, 400, 672);
    line(396, 672, 404, 672);
    line(404, 680, 461, 680);
    line(447, 654, 489, 732);
    line(432, 732, 461, 680);
    strokeWeight(10);
    line(400, 672, 440, 684);
    line(432, 732, 440, 684);
    line(400, 672, 416, 630);
    line(416, 630, 447, 654);
    strokeWeight(24);
    point(422, 615);
    pushMatrix();
    translate(-animTime+510, 0);
    noStroke();
    fill(#55342b);
    rect(1271, 864, 1371, 664);
    rect(3250, 864, 3350, 664);
    fill(#01796f);
    triangle(1121, 664, 1521, 664, 1321, 350);
    triangle(1171, 500, 1471, 500, 1321, 220);
    triangle(1201, 340, 1441, 340, 1321, 0);
    triangle(3150, 664, 3450, 664, 3300, 350);
    triangle(3200, 500, 3400, 500, 3300, 220);
    triangle(3230, 340, 3370, 340, 3300, 0);
    popMatrix();
    animTime++;
  } else if (animTime <= 3500){
    background(127); //Scene 4: child sees a door in the mountain.
    stroke(100, 100);
    fill(#635133);
    quad(700, 864, 682, 205, 220, 290, 186, 864);
    stroke(0);
    line(443, 864, 443, 220);
    stroke(100, 100);
    fill(100);
    quad(216, 864, 150, 864, 220, 285, 275, 315);
    quad(675, 210, 664, 170, 215, 250, 200, 300);
    quad(664, 180, 700, 230, 720, 864, 680, 864);
    pushMatrix();
    rectMode(CENTER);
    fill(#c19a6b);
    translate(443, 700);
    rotate(PI/8.0);
    rect(0, 0, 500, 50);
    stroke(0);
    point(-245, -20);
    point(245, -20);
    point(-245, 20);
    point(245, 20);
    popMatrix();
    stroke(100, 100);
    pushMatrix();
    translate(443, 400);
    rotate(-PI/7.0);
    rect(0, 0, 550, 50);
    stroke(0);
    point(-270, -20);
    point(270, -20);
    point(-270, 20);
    point(270, 20);
    popMatrix();
    pushMatrix();
    translate(600, 532);
    scale(2);
    noStroke();
    fill(#c4a344);
    rectMode(CORNERS);
    rect(-15, 40, 15, 70);
    stroke(100, 100);
    fill(#850505);
    rectMode(CORNERS);
    strokeWeight(3);
    beginShape();
    vertex(-20, 60);
    bezierVertex(-10, 70, 10, 70, 20, 60);
    bezierVertex(70, 60, 70, 60, 80, 100);
    vertex(85, 125);
    bezierVertex(90, 150, 90, 150, 90, 200);
    vertex(60, 205);
    vertex(60, 220);
    bezierVertex(20, 225, -20, 225, -60, 220);
    vertex(-60, 205);
    vertex(-90, 200);
    bezierVertex(-90, 150, -90, 150, -85, 125);
    vertex(-80, 100);
    bezierVertex(-70, 60, -70, 60, -20, 60);
    endShape();
    fill(#8ac149);
    quad(80, 100, 85, 125, 60, 130, 55, 105);
    quad(-80, 100, -85, 125, -60, 130, -55, 105);
    quad(-62, 136, -55, 105, 55, 105, 62, 136);
    fill(#feebee);
    quad(81.5, 107.5, 83.5, 117.5, 58.5, 122.5, 56.5, 112.5);
    quad(-81.5, 107.5, -83.5, 117.5, -58.5, 122.5, -56.5, 112.5);
    quad(-60, 126, -57, 115, 57, 115, 60, 126);
    noStroke();
    fill(#c4a344);
    ellipse(0, 0, 60, 50);
    fill(#3d2622);
    ellipse(0, 0, 60, 55);
    beginShape();
    vertex(-65, 0);
    vertex(-65, 80);
    vertex(-52, 50);
    vertex(-39, 65);
    vertex(-26, 40);
    vertex(-13, 75);
    vertex(0, 40);
    vertex(13, 70);
    vertex(26, 50);
    vertex(39, 80);
    vertex(52, 55);
    vertex(65, 70);
    vertex(65, 0);
    endShape(CLOSE);
    fill(#311f1c);
    arc(0, -1, 60, 15, 0, PI);
    fill(#424242);
    arc(0, -6, 80, 10, 0, PI);
    quad(-80, -6, 80, -6, 60, -16, -60, -16);
    fill(#535252);
    arc(0, -16, 60, 50, PI, TWO_PI);
    popMatrix();
  } else if (animTime < 4300) {
    pushMatrix(); //Scene 5: child enters door while doors close behind them.
    translate(432, 532);
    scale(2);
    noStroke();
    fill(#c4a344);
    rectMode(CORNERS);
    rect(-15, 40, 15, 70);
    stroke(100, 100);
    fill(#850505);
    rectMode(CORNERS);
    strokeWeight(3);
    beginShape();
    vertex(-20, 60);
    bezierVertex(-10, 70, 10, 70, 20, 60);
    bezierVertex(70, 60, 70, 60, 80, 100);
    vertex(85, 125);
    bezierVertex(90, 150, 90, 150, 90, 200);
    vertex(60, 205);
    vertex(60, 220);
    bezierVertex(20, 225, -20, 225, -60, 220);
    vertex(-60, 205);
    vertex(-90, 200);
    bezierVertex(-90, 150, -90, 150, -85, 125);
    vertex(-80, 100);
    bezierVertex(-70, 60, -70, 60, -20, 60);
    endShape();
    fill(#8ac149);
    quad(80, 100, 85, 125, 60, 130, 55, 105);
    quad(-80, 100, -85, 125, -60, 130, -55, 105);
    quad(-62, 136, -55, 105, 55, 105, 62, 136);
    fill(#feebee);
    quad(81.5, 107.5, 83.5, 117.5, 58.5, 122.5, 56.5, 112.5);
    quad(-81.5, 107.5, -83.5, 117.5, -58.5, 122.5, -56.5, 112.5);
    quad(-60, 126, -57, 115, 57, 115, 60, 126);
    noStroke();
    fill(#c4a344);
    ellipse(0, 0, 60, 50);
    fill(#3d2622);
    ellipse(0, 0, 60, 55);
    beginShape();
    vertex(-65, 0);
    vertex(-65, 80);
    vertex(-52, 50);
    vertex(-39, 65);
    vertex(-26, 40);
    vertex(-13, 75);
    vertex(0, 40);
    vertex(13, 70);
    vertex(26, 50);
    vertex(39, 80);
    vertex(52, 55);
    vertex(65, 70);
    vertex(65, 0);
    endShape(CLOSE);
    fill(#311f1c);
    arc(0, -1, 60, 15, 0, PI);
    fill(#424242);
    arc(0, -6, 80, 10, 0, PI);
    quad(-80, -6, 80, -6, 60, -16, -60, -16);
    fill(#535252);
    arc(0, -16, 60, 50, PI, TWO_PI);
    popMatrix();
    fill(0, (animTime-3500)/3.0);
    rect(0, 0, 864, 864);
    fill(#635133);
    stroke(100, 100);
    rect(0, 0, 32+(animTime-3500)/2.0, 864);
    rect(864, 0, 832-(animTime-3500)/2.0, 864);
  } else if (animTime < 4600) {
    fill(#635133); //Scene fades.
    stroke(100, 100);
    rect(0, 0, 432, 864);
    rect(864, 0, 432, 864);
    fill(0, animTime-4300);
    rect(0, 0, 864, 864);
  } else {
    gameState = "menu"; //Switches to main menu.
  }
  smooth();
  animTime++;
}
void createMaze() {
  operatorScroll = createFont("8bitoperator.ttf", 18); //Loads fonts and images for the maze.
  brickLeft = loadImage("wallBrickLeft.png");
  brick = loadImage("wallBrick1.png");
  brickRight = loadImage("wallBrickRight.png");
  topLeft = loadImage("wallTopLeft.png");
  top = loadImage("wallTop.png");
  topRight = loadImage("wallTopRight.png");
  left = loadImage("wallLeft.png");
  right = loadImage("wallRight.png");
  backRight = loadImage("wallBackRight.png");
  backLeft = loadImage("wallBackLeft.png");
  cornerBR = loadImage("wallCornerBR.png");
  cornerBL = loadImage("wallCornerBL.png");
  cornerFR = loadImage("wallCornerFR.png");
  cornerFL = loadImage("wallCornerFL.png");
  back = loadImage("wallBack.png");
  pedestal = loadImage("pedestal.png");
  scroll = loadImage("scroll.png");
  title = loadImage("title.png");
  doorClosed = loadImage("doorClosed.png");
  doorOpen = loadImage("doorOpen.png");
  for (int i = 0; i < 4; i++) {
    torchLit[i] = loadImage("torchLit"+i+".png");
  }
  torchUnlit = loadImage("torchUnlit.png");
  int y, x = 0; //Codes the maze design into a 54 by 54 2D array (each hallway is four cells, and each wall is 2 cells).
  blueprint[x] [0] = "cornerFR"; //Layer 0
  for (x = 1; x < 24; x++)
    blueprint[x] [0] = "top";
  blueprint[24] [0] = "topRight";
  for (x = 25; x < 29; x++)
    blueprint[x] [0] = "door";
  blueprint[29] [0] = "left";
  blueprint[30] [0] = "cornerFR";
  for (x = 31; x < 53; x++)
    blueprint[x] [0] = "top";
  blueprint[53] [0] = "cornerFL";
  for (y = 1; y < 5; y++) {  //Layer 1 to 4
    blueprint[0] [y] = "right";
    blueprint[29] [y] = "left";
    blueprint[30] [y] = "right";
    blueprint[53] [y] = "left";
  }
  blueprint[19] [1] = "torch0";
  blueprint[21] [1] = "torch1";
  blueprint[23] [1] = "torch2";
  blueprint[0] [5] = "right"; //Layer 5
  blueprint[5] [5] = "backLeft";
  for (x = 6; x < 24; x++)
    blueprint[x] [5] = "back";
  blueprint[24] [5] = "backRight";
  blueprint[29] [5] = "left";
  blueprint[30] [5] = "right";
  blueprint[35] [5] = "backLeft";
  for (x = 36; x < 42; x++)
    blueprint[x] [5] = "back";
  blueprint[42] [5] = "backRight";
  blueprint[47] [5] = "backLeft";
  blueprint[48] [5] = "backRight";
  blueprint[53] [5] = "left";
  blueprint[0] [6] = "right"; //Layer 6
  blueprint[5] [6] = "topLeft";
  for (x = 6; x < 11; x++)
    blueprint[x] [6] = "top";
  blueprint[11] [6] = "cornerFL";
  blueprint[12] [6] = "cornerFR";
  for (x = 13; x < 23; x++)
    blueprint[x] [6] = "top";
  blueprint[23] [6] = "cornerFL";
  blueprint[24] [6] = "right";
  blueprint[29] [6] = "topLeft";
  blueprint[30] [6] = "topRight";
  blueprint[35] [6] = "left";
  blueprint[36] [6] = "cornerFR";
  for (x = 37; x < 41; x++) 
    blueprint[x] [6] = "top";
  blueprint[41] [6] = "cornerFL";
  blueprint[42] [6] = "right";
  blueprint[47] [6] = "left";
  blueprint[48] [6] = "right";
  blueprint[53] [6] = "left";
  for (y = 7; y < 11; y++) {  //Layer 7 to 10
    blueprint[0] [y] = "right";
    blueprint[11] [y] = "left";
    blueprint[12] [y] = "right";
    blueprint[23] [y] = "left";
    blueprint[24] [y] = "right";
    blueprint[35] [y] = "left";
    blueprint[36] [y] = "right";
    blueprint[41] [y] = "left";
    blueprint[42] [y] = "right";
    blueprint[47] [y] = "left";
    blueprint[48] [y] = "right";
    blueprint[53] [y] = "left";
  }
  blueprint[0] [11] = "cornerBR"; //Layer 11
  for (x = 1; x < 6; x++)
    blueprint[x] [11] = "back";
  blueprint[6] [11] = "backRight";
  blueprint[11] [11] = "left";
  blueprint[12] [11] = "right";
  blueprint[17] [11] = "backLeft";
  blueprint[18] [11] = "backRight";
  blueprint[23] [11] = "left";
  blueprint[24] [11] = "cornerBR";
  for (x = 25; x < 35; x++)
    blueprint[x] [11] = "back";
  blueprint[35] [11] = "cornerBL";
  blueprint[36] [11] = "right";
  blueprint[41] [11] = "left";
  blueprint[42] [11] = "right";
  blueprint[47] [11] = "left";
  blueprint[48] [11] = "cornerBR";
  for (x = 49; x < 53; x++)
    blueprint[x] [11] = "back";
  blueprint[53] [11] = "cornerBL";
  blueprint[0] [12] = "cornerFR"; //Layer 12
  for (x = 1; x < 5; x++)
    blueprint[x] [12] = "top";
  blueprint[5] [12] = "cornerFL";
  blueprint[6] [12] = "right";
  blueprint[11] [12] = "left";
  blueprint[12] [12] = "right";
  blueprint[17] [12] = "left";
  blueprint[18] [12] = "right";
  blueprint[23] [12] = "left";
  blueprint[24] [12] = "cornerFR";
  for (x = 25; x < 36; x++)
    blueprint[x] [12] = "top";
  blueprint[36] [12] = "topRight";
  blueprint[41] [12] = "left";
  blueprint[42] [12] = "right";
  blueprint[47] [12] = "topLeft";
  for (x = 48; x < 53; x++)
    blueprint[x] [12] = "top";
  blueprint[53] [12] = "cornerFL";
  for (y = 13; y < 17; y++) {  //Layer 13 to 16
    blueprint[0] [y] = "right";
    blueprint[5] [y] = "left";
    blueprint[6] [y] = "right";
    blueprint[11] [y] = "left";
    blueprint[12] [y] = "right";
    blueprint[17] [y] = "left";
    blueprint[18] [y] = "right";
    blueprint[23] [y] = "left";
    blueprint[24] [y] = "right";
    blueprint[41] [y] = "left";
    blueprint[42] [y] = "right";
    blueprint[53] [y] = "left";
  }
  blueprint[15] [8] = "morsePedestal";
  blueprint[14] [8] = "pbound";
  blueprint[0] [17] = "right"; //Layer 17
  blueprint[5] [17] = "left";
  blueprint[6] [17] = "right";
  blueprint[11] [17] = "left";
  blueprint[12] [17] = "right";
  blueprint[17] [17] = "left";
  blueprint[18] [17] = "cornerBR";
  for (x = 19; x < 23; x++)
    blueprint[x] [17] = "back";
  blueprint[23] [17] = "cornerBL";
  blueprint[24] [17] = "right";
  blueprint[29] [17] = "backLeft";
  blueprint[30] [17] = "backRight";
  blueprint[35] [17] = "backLeft";
  for (x = 36; x < 41; x++)
    blueprint[x] [17] = "back";
  blueprint[41] [17] = "cornerBL";
  blueprint[42] [17] = "cornerBR";
  for (x = 43; x < 48; x++)
    blueprint[x] [17] = "back";
  blueprint[48] [17] = "backRight";
  blueprint[53] [17] = "left";
  blueprint[0] [18] = "right"; //Layer 18
  blueprint[5] [18] = "topLeft";
  blueprint[6] [18] = "topRight";
  blueprint[11] [18] = "left";
  blueprint[12] [18] = "right";
  blueprint[17] [18] = "left";
  blueprint[18] [18] = "cornerFR";
  for (x = 19; x < 24; x++)
    blueprint[x] [18] = "top";
  blueprint[24] [18] = "topRight";
  blueprint[29] [18] = "left";
  blueprint[30] [18] = "right";
  blueprint[35] [18] = "left";
  blueprint[36] [18] = "cornerFR";
  for (x = 37; x < 47; x++)
    blueprint[x] [18] = "top";
  blueprint[47] [18] = "cornerFL";
  blueprint[48] [18] = "right";
  blueprint[53] [18] = "left";
  for (y = 19; y < 23; y++) {  //Layer 19 to 22
    blueprint[0] [y] = "right";
    blueprint[11] [y] = "left";
    blueprint[12] [y] = "right";
    blueprint[17] [y] = "left";
    blueprint[18] [y] = "right";
    blueprint[29] [y] = "left";
    blueprint[30] [y] = "right";
    blueprint[35] [y] = "left";
    blueprint[36] [y] = "right";
    blueprint[47] [y] = "left";
    blueprint[48] [y] = "right";
    blueprint[53] [y] = "left";
  }
  blueprint[45] [19] = "caesarPedestal";
  blueprint[44] [19] = "pbound";
  blueprint[0] [23] = "right"; //Layer 23
  blueprint[5] [23] = "backLeft";
  for (x = 6; x < 11; x++)
    blueprint[x] [23] = "back";
  blueprint[11] [23] = "cornerBL";
  blueprint[12] [23] = "right";
  blueprint[17] [23] = "left";
  blueprint[18] [23] = "right";
  blueprint[23] [23] = "backLeft";
  for (x = 24; x < 29; x++)
    blueprint[x] [23] = "back";
  blueprint[29] [23] = "cornerBL";
  blueprint[30] [23] = "right";
  blueprint[35] [23] = "left";
  blueprint[36] [23] = "right";
  blueprint[41] [23] = "backLeft";
  for (x = 42; x < 47; x++)
    blueprint[x] [23] = "back";
  blueprint[47] [23] = "cornerBL";
  blueprint[48] [23] = "right";
  blueprint[53] [23] = "left";
  blueprint[0] [24] = "right"; //Layer 24
  blueprint[5] [24] = "left";
  blueprint[6] [24] = "cornerFR";
  for (x = 7; x < 11; x++)
    blueprint[x] [24] = "top";
  blueprint[11] [24] = "cornerFL";
  blueprint[12] [24] = "right";
  blueprint[17] [24] = "topLeft";
  blueprint[18] [24] = "topRight";
  blueprint[23] [24] = "left";
  blueprint[24] [24] = "cornerFR";
  for (x = 25; x < 30; x++)
    blueprint[x] [24] = "top";
  blueprint[30] [24] = "topRight";
  blueprint[35] [24] = "left";
  blueprint[36] [24] = "right";
  blueprint[41] [24] = "left";
  blueprint[42] [24] = "cornerFR";
  for (x = 43; x < 48; x++)
    blueprint[x] [24] = "top";
  blueprint[48] [24] = "topRight";
  blueprint[53] [24] = "left";
  for (y = 25; y < 29; y++) {  //Layer 25 to 28
    blueprint[0] [y] = "right";
    blueprint[5] [y] = "left";
    blueprint[6] [y] = "right";
    blueprint[11] [y] = "left";
    blueprint[12] [y] = "right";
    blueprint[23] [y] = "left";
    blueprint[24] [y] = "right";
    blueprint[35] [y] = "left";
    blueprint[36] [y] = "right";
    blueprint[41] [y] = "left";
    blueprint[42] [y] = "right";
    blueprint[53] [y] = "left";
  }
  blueprint[9] [26] = "alphanumPedestal";
  blueprint[8] [26] = "pbound";
  blueprint[0] [29] = "right"; //Layer 29
  blueprint[5] [29] = "left";
  blueprint[6] [29] = "right";
  blueprint[11] [29] = "left";
  blueprint[12] [29] = "cornerBR";
  for (x = 13; x < 23; x++)
    blueprint[x] [29] = "back";
  blueprint[23] [29] = "cornerBL";
  blueprint[24] [29] = "right";
  blueprint[29] [29] = "backLeft";
  for (x = 30; x < 35; x++)
    blueprint[x] [29] = "back";
  blueprint[35] [29] = "cornerBL";
  blueprint[36] [29] = "right";
  blueprint[41] [29] = "left";
  blueprint[42] [29] = "right";
  blueprint[47] [29] = "backLeft";
  for (x = 48; x < 53; x++)
    blueprint[x] [29] = "back";
  blueprint[53] [29] = "cornerBL";
  blueprint[0] [30] = "right"; //Layer 30
  blueprint[5] [30] = "topLeft";
  blueprint[6] [30] = "topRight";
  blueprint[11] [30] = "left";
  blueprint[12] [30] = "cornerFR";
  for (x = 13; x < 24; x++)
    blueprint[x] [30] = "top";
  blueprint[24] [30] = "topRight";
  blueprint[29] [30] = "left";
  blueprint[30] [30] = "cornerFR";
  for (x = 31; x < 35; x++)
    blueprint[x] [30] = "top";
  blueprint[35] [30] = "cornerFL";
  blueprint[36] [30] = "right";
  blueprint[41] [30] = "left";
  blueprint[42] [30] = "right";
  blueprint[47] [30] = "left";
  blueprint[48] [30] = "cornerFR";
  for (x = 49; x < 53; x++)
    blueprint[x] [30] = "top";
  blueprint[53] [30] = "cornerFL";
  for (y = 31; y < 35; y++) {  //Layer 31 to 34
    blueprint[0] [y] = "right";
    blueprint[11] [y] = "left";
    blueprint[12] [y] = "right";
    blueprint[29] [y] = "left";
    blueprint[30] [y] = "right";
    blueprint[35] [y] = "left";
    blueprint[36] [y] = "right";
    blueprint[41] [y] = "left";
    blueprint[42] [y] = "right";
    blueprint[47] [y] = "left";
    blueprint[48] [y] = "right";
    blueprint[53] [y] = "left";
  }
  blueprint[0] [35] = "right"; //Layer 35
  blueprint[5] [35] = "backLeft";
  for (x = 6; x < 11; x++)
    blueprint[x] [35] = "topRight";
  blueprint[11] [35] = "cornerBL";
  blueprint[12] [35] = "right";
  blueprint[17] [35] = "backLeft";
  blueprint[18] [35] = "backRight";
  blueprint[23] [35] = "backLeft";
  for (x = 24; x < 29; x++)
    blueprint[x] [35] = "back";
  blueprint[29] [35] = "cornerBL";
  blueprint[30] [35] = "right";
  blueprint[35] [35] = "left";
  blueprint[36] [35] = "right";
  blueprint[41] [35] = "left";
  blueprint[42] [35] = "right";
  blueprint[47] [35] = "left";
  blueprint[48] [35] = "right";
  blueprint[53] [35] = "left";
  blueprint[0] [35] = "right"; //Layer 35
  blueprint[5] [35] = "backLeft";
  for (x = 6; x < 11; x++)
    blueprint[x] [35] = "back";
  blueprint[11] [35] = "cornerBL";
  blueprint[12] [35] = "right";
  blueprint[17] [35] = "backLeft";
  blueprint[18] [35] = "backRight";
  blueprint[23] [35] = "backLeft";
  for (x = 24; x < 29; x++)
    blueprint[x] [35] = "back";
  blueprint[29] [35] = "cornerBL";
  blueprint[30] [35] = "right";
  blueprint[35] [35] = "left";
  blueprint[36] [35] = "right";
  blueprint[41] [35] = "left";
  blueprint[42] [35] = "right";
  blueprint[47] [35] = "left";
  blueprint[48] [35] = "right";
  blueprint[53] [35] = "left";
  blueprint[0] [36] = "right"; //Layer 36
  blueprint[5] [36] = "topLeft";
  for (x = 6; x < 11; x++)
    blueprint[x] [36] = "top";
  blueprint[11] [36] = "cornerFL";
  blueprint[12] [36] = "right";
  blueprint[17] [36] = "left";
  blueprint[18] [36] = "right";
  blueprint[23] [36] = "topLeft";
  for (x = 24; x < 29; x++)
    blueprint[x] [36] = "top";
  blueprint[29] [36] = "cornerFL";
  blueprint[30] [36] = "right";
  blueprint[35] [36] = "left";
  blueprint[36] [36] = "right";
  blueprint[41] [36] = "left";
  blueprint[42] [36] = "right";
  blueprint[47] [36] = "topLeft";
  blueprint[48] [36] = "topRight";
  blueprint[53] [36] = "left";
  for (y = 37; y < 41; y++) {  //Layer 37 to 40
    blueprint[0] [y] = "right";
    blueprint[11] [y] = "left";
    blueprint[12] [y] = "right";
    blueprint[17] [y] = "left";
    blueprint[18] [y] = "right";
    blueprint[29] [y] = "left";
    blueprint[30] [y] = "right";
    blueprint[35] [y] = "left";
    blueprint[36] [y] = "right";
    blueprint[41] [y] = "left";
    blueprint[42] [y] = "right";
    blueprint[53] [y] = "left";
  }
  blueprint[0] [41] = "cornerBR"; //Layer 41
  for (x = 1; x < 6; x++)
    blueprint[x] [41] = "back";
  blueprint[6] [41] = "backRight";
  blueprint[11] [41] = "left";
  blueprint[12] [41] = "right";
  blueprint[17] [41] = "left";
  blueprint[18] [41] = "cornerBR";
  for (x = 19; x < 24; x++)
    blueprint[x] [41] = "back";
  blueprint[24] [41] = "backRight";
  blueprint[29] [41] = "left";
  blueprint[30] [41] = "right";
  blueprint[35] [41] = "left";
  blueprint[36] [41] = "right";
  blueprint[41] [41] = "left";
  blueprint[42] [41] = "right";
  blueprint[47] [41] = "backLeft";
  for (x = 48; x < 53; x++)
    blueprint[x] [41] = "back";
  blueprint[53] [41] = "cornerBL";
  blueprint[0] [42] = "cornerFR"; //Layer 42
  for (x = 1; x < 6; x++)
    blueprint[x] [42] = "top";
  blueprint[6] [42] = "topRight";
  blueprint[11] [42] = "left";
  blueprint[12] [42] = "right";
  blueprint[17] [42] = "topLeft";
  for (x = 18; x < 23; x++)
    blueprint[x] [42] = "top";
  blueprint[23] [42] = "cornerFL";
  blueprint[24] [42] = "right";
  blueprint[29] [42] = "topLeft";
  blueprint[30] [42] = "topRight";
  blueprint[35] [42] = "topLeft";
  blueprint[36] [42] = "topRight";
  blueprint[41] [42] = "left";
  blueprint[42] [42] = "right";
  blueprint[47] [42] = "topLeft";
  for (x = 48; x < 53; x++)
    blueprint[x] [42] = "top";
  blueprint[53] [42] = "cornerFL";
  for (y = 43; y < 47; y++) {  //Layer 43 to 46
    blueprint[0] [y] = "right";
    blueprint[11] [y] = "left";
    blueprint[12] [y] = "right";
    blueprint[23] [y] = "left";
    blueprint[24] [y] = "right";
    blueprint[41] [y] = "left";
    blueprint[42] [y] = "right";
    blueprint[53] [y] = "left";
  }
  blueprint[0] [47] = "right"; //Layer 47
  blueprint[5] [47] = "backLeft";
  for (x = 6; x < 11; x++)
    blueprint[x] [47] = "back";
  blueprint[11] [47] = "cornerBL";
  blueprint[12] [47] = "cornerBR";
  for (x = 13; x < 18; x++)
    blueprint[x] [47] = "back";
  blueprint[18] [47] = "backRight";
  blueprint[23] [47] = "left";
  blueprint[24] [47] = "cornerBR";
  for (x = 25; x < 41; x++)
    blueprint[x] [47] = "back";
  blueprint[41] [47] = "cornerBL";
  blueprint[42] [47] = "cornerBR";
  for (x = 43; x < 48; x++)
    blueprint[x] [47] = "back";
  blueprint[48] [47] = "backRight";
  blueprint[53] [47] = "left";
  blueprint[0] [48] = "right"; //Layer 48
  blueprint[5] [48] = "topLeft";
  for (x = 6; x < 18; x++)
    blueprint[x] [48] = "top";
  blueprint[18] [48] = "topRight";
  blueprint[23] [48] = "left";
  blueprint[24] [48] = "cornerFR";
  for (x = 25; x < 48; x++)
    blueprint[x] [48] = "top";
  blueprint[48] [48] = "topRight";
  blueprint[53] [48] = "left";
  for (y = 49; y < 53; y++) { //Layer 49 to 52
    blueprint[0] [y] = "right";
    blueprint[23] [y] = "left";
    blueprint[24] [y] = "right";
    blueprint[53] [y] = "left";
  }
  blueprint[0] [53] = "cornerBR"; //Layer 53
  for (x = 1; x < 23; x++)
    blueprint[x] [53] = "back";
  blueprint[23] [53] = "cornerBL";
  blueprint[24] [53] = "cornerBR";
  for (x = 25; x < 53; x++)
    blueprint[x] [53] = "back";
  blueprint[53] [53] = "cornerBL";
}
void createCharlie() { //Loads the walking animations of the protagonist.
  for (int i = 0; i < 4; i++) {
    charlieForms[i] = loadImage("charlieRight"+i+".png");;
  }
  for (int i = 4; i < 8; i++) {
    charlieForms[i] = loadImage("charlieFront"+(i%4)+".png");;
  }
  for (int i = 8; i < 12; i++) {
    charlieForms[i] = loadImage("charlieLeft"+(i%4)+".png");;
  }
  for (int i = 12; i < 16; i++) {
    charlieForms[i] = loadImage("charlieBack"+(i%4)+".png");;
  }
}
void createMenu() { //Loads the images for the menu background animation.
  for (int i = 0; i < 5; i++) menuForms[i] = loadImage("menu"+i+".png");
}
void createTest() { //Loads the images for the vault image and the font.
  operatorVault = createFont("8bitoperator.ttf", 60);
  vault = loadImage("vault.png");
}
void setVarTest() {
  startTime = millis(); //Sets the starting time (using millis()) of the game.
  timeLeft = 64; //Initial variable assignment.
  for (int i = 0; i < 5; i++) typed[i] = '_';
  wrongTime = 255;
  countdown = true;
  letter1 = false;
  letter2 = false;
  letter3 = false;
  letter4 = false;
  letter5 = false;
  enterButton = false;
  showWrong = false;
  letterInput = '_';
  code = (int) random(0, 8.9);
  cipher = (int) random(0, 2.9);
  clue = "Clue: ";
  String reference = "ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ";
  if (cipher == 0) {
    for (int i = 0; i < 5; i++) {
      clue += (reference.indexOf(passwords[code].charAt(i))+1)+" ";
    }
  } else if (cipher == 1){
    int codeKey = (int) random(0, 25.9);
    for (int i = 0; i < 5; i++) {
      clue += reference.charAt(reference.indexOf(passwords[code].charAt(i))+codeKey);
    }
    clue += "\nKey: "+codeKey;
  } else {
    for (int i = 0; i < 5; i++) {
      clue += morse[reference.indexOf(passwords[code].charAt(i))]+" / ";
    }
  }
}
void loadTest() { //Loads the game of testing.
  image(vault, 0, 0); //Shows image of vault.
  if (timeLeft < 1 || wonTest) { //If true, transitions back to menu.
    completedTest = true;
    mainButtonTest = false;
    nextButton = false;
  }
  textFont(operator);
  textAlign(TOP, LEFT);
  fill(0);
  rectMode(CORNERS);
  text(clue, 400, 480, 700, 750);
  textFont(operatorVault);
  textAlign(CENTER, CENTER);
  stroke(0);
  strokeWeight(8);
  fill(#033B01);
  rect(332, 132, 420, 275);
  rect(436, 132, 524, 275);
  rect(540, 132, 628, 275);
  rect(644, 132, 732, 275);
  rect(748, 132, 836, 275);
  rect(14, 14, 200, 64);
  fill(#65FF00);
  textAlign(LEFT, TOP);
  textFont(operatorButton);
  if (timeLeft <= 60) text("TIME: "+timeLeft, 20, 16);
  else text("TIME: 60", 20, 16);
  textAlign(CENTER, CENTER);
  textFont(operatorVault);
  if ((mouseX > 332 && mouseX < 420 && mouseY > 132 && mouseY < 275) || letter1) fill(255); //Lets the digit boxes change colour when hovered.
  text(typed[0], 376, 192);
  fill(#65FF00);
  if ((mouseX > 436 && mouseX < 524 && mouseY > 132 && mouseY < 275) || letter2) fill(255);
  text(typed[1], 480, 192);
  fill(#65FF00);
  if ((mouseX > 540 && mouseX < 628 && mouseY > 132 && mouseY < 275) || letter3) fill(255);
  text(typed[2], 584, 192);
  fill(#65FF00);
  if ((mouseX > 644 && mouseX < 732 && mouseY > 132 && mouseY < 275) || letter4) fill(255);
  text(typed[3], 688, 192);
  fill(#65FF00);
  if ((mouseX > 768 && mouseX < 836 && mouseY > 132 && mouseY < 275) || letter5) fill(255);
  text(typed[4], 792, 192);
  fill(100);
  if (mouseX > 104 && mouseX < 334 && mouseY > 565 && mouseY < 665) fill(150);
  rect(104, 565, 334, 665);
  fill(255);
  textFont(operatorButton); //The "OPEN" button.
  text("OPEN", 219, 610);
  if (showWrong) {
    textFont(operatorVault); //Shows the "WRONG ANSWER" message.
    fill(255, 0, 0, wrongTime);
    text("WRONG ANSWER", 432, 432);
    if (wrongTime <= 0) {
      showWrong = false;
      wrongTime = -1;
    }
    wrongTime--;
  }
  if (countdown) {
    textFont(operatorVault); //Shows the countdown at the beginning of the game of testing.
    fill(255);
    if (timeLeft-60 > 0) text(timeLeft-60, 432, 432);
    else countdown = false;
  }
  vaultInput();
  if (completedTest) {
    fill(255, fadeTime); //Switches to menu.
    if (fadeTime == 300) gameState = "menu";
    gameAnim = 0;
    menuTime = 0;
    fadeTime++;
    noStroke();
    rectMode(CORNERS);
    rect(0, 0, 864, 864);
  }
  if (!completedTest) {
    timeLeft = 64000+startTime-millis(); //Counts the time down.
    timeLeft /= 1000;
  } else highscore = max(highscore, timeLeft); //Sets the highscore to the time left if it is greater.
}
void vaultInput() { //Takes the keyboard input for the game of testing.
  if (letter1) {
    typed[0] = char(letterInput);
  } else if (letter2) {
    typed[1] = char(letterInput);
  } else if (letter3) {
    typed[2] = char(letterInput);
  } else if (letter4) {
    typed[3] = char(letterInput);
  } else if (letter5) {
    typed[4] = char(letterInput);
  }
  if (enterButton) {
    enterButton = false;
    String input = new String(typed);
    if (input.equals(passwords[code]) || wonTest) {
      wonTest = true;
      fadeTime = 0;
    } else {
      showWrong = true;
      wrongTime = 255;
    }
  }
}
void showClue(int x, int y) { //Shows the clues from the pedestals.
  if (mazeInteract && dist(0, 0, -xpos+x*72, -ypos+y*72) <= 170 && !nextButton && readable) {
    nextButton = false;
    stopMovement = true;
    mazeInteract = true;
    textFont(operator);
    textAlign(LEFT, TOP);
    image(scroll, 0, 0);
    fill(0);
    rectMode(CORNERS);
    switch (blueprint[x] [y]) {
      case "alphanumPedestal": text(showScript("The alphanumeric cipher (or A1Z26 cipher) is a substitution cipher that uses the numbers 1 to 26 to replace each of the 26 letters of the alphabet, where A = 1, B = 2, C = 3 ... Z = 26.", scriptTime), 192, 160, 672, 848);
      if (!foundAlphanum) firstAlphanum = true;
      foundAlphanum = true;
      break;
      case "morsePedestal": textFont(operatorScroll);
      text(showScript("Morse code was invented as a universal method for communicating through binary information-carrying mediums (something that could be on or off) like electric current and light.\nThe alphabetic reference follows:\nA = "+morse[0]+" / B = "+morse[1]+" / C = "+morse[2]+" / D = "+morse[3]+"\nE = "+morse[4]+" / F = "+morse[5]+" / G = "+morse[6]+" / H = "+morse[7]+"\nI = "+morse[8]+" / J = "+morse[9]+" / K = "+morse[10]+" / L = "+morse[11]+"\nM = "+morse[12]+" / N = "+morse[13]+" / O = "+morse[14]+" / P = "+morse[15]+"\nQ = "+morse[16]+" / R = "+morse[17]+" / S = "+morse[18]+"/ T = "+morse[19]+"\nU = "+morse[20]+" / V = "+morse[21]+" / W = "+morse[22]+" / X = "+morse[23]+"\nY = "+morse[24]+" / Z = "+morse[25], scriptTime), 192, 160, 672, 848);
      if (!foundMorse) firstMorse = true;
      foundMorse = true;
      break;
      case "caesarPedestal": textFont(operatorScroll);
      text(showScript("The Caesar cipher is a cipher that replaces each letter with another letter, which could then be decrypted with a \"key\". To encrypt, take a string of the alphabet in order, your original alphabet, and shift it however many letters to the right, where the unpaired encrypted letters correspond with the unpaired original letters. The number of letters you shift is your key, and you replace each letter of your original script with its encrypted partner to encrypt the message.", scriptTime), 192, 160, 672, 848);
      if (!foundCaesar) firstCaesar = true;
      foundCaesar = true;
    }  
    fill(#815400);
    if (mouseX < 750 && mouseX > 550 && mouseY > 760 && mouseY < 840) {
      fill(#B48A3A);
    }
    rectMode(CENTER);
    stroke(0);
    strokeWeight(4);
    rect(650, 800, 200, 80);
    textFont(operatorButton);
    textAlign(CENTER, CENTER);
    fill(255);
    text("Great!", 650, 796);
    scriptTime++;
    fadeTime = 0;
  } else {
    mazeInteract = false;
    stopMovement = false;
    if (firstAlphanum || firstMorse || firstCaesar) {
      textFont(operator);
      textAlign(CENTER, CENTER);
      rectMode(CENTER);
      fill(255, 400-fadeTime);
      text("You found a match! Maybe you could light something with it...", 432, 600, 800, 200);
      if (fadeTime == 400) {
        if (firstAlphanum) firstAlphanum = false;
        else if (firstMorse) firstMorse = false;
        else firstCaesar = false;
        fadeTime = 0;
        scriptTime = 0;
      } else fadeTime++;
    }
  }
}
void checkTorches() { //Updates the number of matches the protagonist has.
  matches = 0;
  if (foundAlphanum) matches++;
  if (foundMorse) matches++;
  if (foundCaesar) matches++;
  if (torchesLit[0]) matches--;
  if (torchesLit[1]) matches--;
  if (torchesLit[2]) matches--;
}
void lightTorches(int x, int y) { //Updates torches' status.
  if (mazeInteract && dist(0, 0, -xpos+x*72, -ypos+y*72) <= 170 && matches > 0) {
    switch (blueprint[x] [y]) {
      case "torch0":
      if (!torchesLit[0]) {
        torchesLit[0] = true;
      }
      break;
      case "torch1": 
      if (!torchesLit[1]) {
        torchesLit[1] = true;
      }
      break;
      case "torch2": 
      if (!torchesLit[2]) {
        torchesLit[2] = true;
      }
    }
  }
}
void mazeEndSequence() {
  if (escapedMaze) {
    completedMaze = true;
    escapedMaze = true;
    stopMovement = true;
    if (menuTime > 275) {
      gameState = "menu";
      menuTime = 0;
      fill(255, 255);
      mainButtonMaze = false;
      nextButton = false;
    } else {
      menuTime++;
      fill(255, menuTime);
    }
    rectMode(CORNER);
    noStroke();
    
    rect(0, 0, 864, 864);
  }
}
void setVarMaze() { //Initial variable assignment.
  torchesLit[0] = false;
  torchesLit[1] = false;
  torchesLit[2] = false;
  xpos = 1944;
  ypos = 196;
  charlieDir = 1;
  walkTime = 0;
  scriptTime = 0;
  pedestalX = -100;
  pedestalY = -100;
  fadeTime = 0;
  matches = 0;
  torchTime = 0;
  mLeft = false;
  mRight = false;
  mUp = false;
  mDown = false;
  inWall = false;
  mainButtonMaze = true;
  mainButtonTest = false;
  mainButtonExit = false;
  nextButton = false;
  open = false;
  mazeInteract = false;
  stopMovement = false;
  readable = false;
  foundAlphanum = false;
  foundMorse = false;
  foundCaesar = false;
  firstAlphanum = false;
  firstMorse = false;
  firstCaesar = false;
  escapedMaze = false;
}
void updateCharlie() {
  charlieState = charlieForms[charlieDir*4+walkTime/25];
  image(charlieState, 402, 432-76);
}

void mazeInput() { //Takes input for maze of learning.
  if (mUp) {
    ypos-=3;
    charlieDir = 3;
  } else if (mDown) {
    ypos+=3;
    charlieDir = 1;
  }
  if (mLeft) {
    xpos-=3;
    charlieDir = 2;
  } else if (mRight) {
    xpos+=3;
    charlieDir = 0;
  }
  if (mUp || mDown || mRight || mLeft) {
    walkTime++;
    walkTime %= 100;
  } else {
    walkTime = 0;
  }
  if (inWall) walkTime = 0;
}
void loadMaze() { //Loads the nearby chunks from blueprint[] [] onto the screen.
  int chunkX = xpos/72, chunkY = (ypos)/72;
  int loadX = chunkX-9, loadY;
  while (loadX <= chunkX+7) {
    loadY = chunkY-9;
    while (loadY <= chunkY-1) {
      readMaze(loadX, loadY);
      loadY++;
    }
    loadX++;
  }
  updateCharlie();
  loadX = chunkX-7;
  while (loadX <= chunkX+7) {
    loadY = chunkY;
    while (loadY <= chunkY+7) {
      readMaze(loadX, loadY);
      loadY++;
    }
    loadX++;
  }
  showClue(pedestalX, pedestalY);
}
void readMaze(int x, int y) { //According to blueprint[] [], this program will show its corresponding image.
  if (x >= 0 && x <= 53 && y >= 0 && y <= 53) {
    fill(#a0937e);
    noStroke();
    rectMode(CORNER);
    if (blueprint[x] [y] == null) rect(width/2-xpos+x*72, height/2-ypos+y*72+160, 72, 72);
    else if (blueprint[x] [y].length() > 9){ //The longest string pertaining to a maze wall, "backRight", has 9 characters. The pedestal identifiers are all longer than 9 characters.
      readable = true;
      rect(width/2-xpos+x*72, height/2-ypos+y*72+160, 72, 72);
      image(pedestal, width/2-xpos+x*72-72, height/2-ypos+y*72+92);
      pedestalX = x;
      pedestalY = y;
    } else {
      if (!readable && !escapedMaze) {
        mazeInteract = false;
        stopMovement = false;
        nextButton = false;
        scriptTime = 0;
      }
      if (nextButton) {
        readable = false;
      }
      switch (blueprint[x] [y]) {
        case "top": 
        image(top, width/2-xpos+x*72, height/2-ypos+y*72);
        image(brick, width/2-xpos+x*72, height/2-ypos+y*72+72);
        break;
        case "topLeft": image(topLeft, width/2-xpos+x*72, height/2-ypos+y*72);
        image(brickLeft, width/2-xpos+x*72, height/2-ypos+y*72+72);
        break;
        case "topRight": image(topRight, width/2-xpos+x*72, height/2-ypos+y*72);
        image(brickRight, width/2-xpos+x*72, height/2-ypos+y*72+72);
        break;
        case "left": image(left, width/2-xpos+x*72, height/2-ypos+y*72);
        break;
        case "right": image(right, width/2-xpos+x*72, height/2-ypos+y*72);
        break;
        case "back": image(back, width/2-xpos+x*72, height/2-ypos+y*72);
        break;
        case "backLeft": image(backLeft, width/2-xpos+x*72, height/2-ypos+y*72);
        break;
        case "backRight": image(backRight, width/2-xpos+x*72, height/2-ypos+y*72);
        break;
        case "cornerBR": image(cornerBR, width/2-xpos+x*72, height/2-ypos+y*72);
        break;
        case "cornerBL": image(cornerBL, width/2-xpos+x*72, height/2-ypos+y*72);
        break;
        case "cornerFR": image(cornerFR, width/2-xpos+x*72, height/2-ypos+y*72);
        break;
        case "cornerFL": image(cornerFL, width/2-xpos+x*72, height/2-ypos+y*72);
        break;
        case "door":
        if (blueprint[x-1] [y] != "door") {
          if (torchesLit[0]  &&torchesLit[1] && torchesLit[2]) image(doorOpen, width/2-xpos+x*72, height/2-ypos+y*72);
          else image(doorClosed, width/2-xpos+x*72, height/2-ypos+y*72);
        }
        break;
        case "torch0":
        rect(width/2-xpos+x*72, height/2-ypos+y*72+160, 72, 72);
        lightTorches(x, y);
        if (torchesLit[0]) image(torchLit[torchTime/10], width/2-xpos+x*72, height/2-ypos+y*72+95);
        else image(torchUnlit, width/2-xpos+x*72, height/2-ypos+y*72+95);
        break;
        case "torch1":
        rect(width/2-xpos+x*72, height/2-ypos+y*72+160, 72, 72);
        lightTorches(x, y);
        if (torchesLit[1]) image(torchLit[torchTime/10], width/2-xpos+x*72, height/2-ypos+y*72+95);
        else image(torchUnlit, width/2-xpos+x*72, height/2-ypos+y*72+95);
        break;
        case "torch2":
        rect(width/2-xpos+x*72, height/2-ypos+y*72+160, 72, 72);
        lightTorches(x, y);
        if (torchesLit[2]) image(torchLit[torchTime/10], width/2-xpos+x*72, height/2-ypos+y*72+95);
        else image(torchUnlit, width/2-xpos+x*72, height/2-ypos+y*72+95);
        break;
        default: rect(width/2-xpos+x*72, height/2-ypos+y*72+160, 72, 72);
      }
    }
  } else {
    fill(0);
    noStroke();
    rect(width/2-xpos+x*72, height/2-ypos+y*72, 72, 72);
  }
}
void checkBoundary() {
  if (!stopMovement & !escapedMaze) { //Reads the blueprint[] [] cells around it and determines whether there is space or an obstacle, then reverses track if there is a wall.
    inWall = false;
    if (mUp||mDown) {
      if (blueprint[xpos/72] [(ypos-88)/72] != null) {
        mUp = false;
        inWall = true;
        while (blueprint[xpos/72] [(ypos-88)/72] != null) {
          ypos += 3;
        }
        if (blueprint[xpos/72] [(ypos-128)/72].equals("door") && torchesLit[0] && torchesLit[1] && torchesLit[2]) {
          completedMaze = true;
          escapedMaze = true;
        }
      } else if (blueprint[xpos/72] [(ypos-61)/72] != null) {
        mDown = false;
        inWall = true;
        while (blueprint[xpos/72] [(ypos-61)/72] != null) {
          ypos -= 3;
        }
      }
      if (blueprint[(xpos-30)/72] [(ypos-79)/72] != null) {
        mLeft = false;
        inWall = true;
        while (blueprint[(xpos-30)/72] [(ypos-79)/72] != null) {
          xpos += 3;
        }
      } else if (blueprint[(xpos+30)/72] [(ypos-79)/72] != null) {
        mRight = false;
        inWall = true;
        while (blueprint[(xpos+30)/72] [(ypos-79)/72] != null) {
          xpos -= 3;
        }
      }
    } else {
      if (blueprint[(xpos-30)/72] [(ypos-79)/72] != null) {
        mLeft = false;
        inWall = true;
        while (blueprint[(xpos-30)/72] [(ypos-79)/72] != null) {
          xpos += 3;
        }
      } else if (blueprint[(xpos+30)/72] [(ypos-79)/72] != null) {
        mRight = false;
        inWall = true;
        while (blueprint[(xpos+30)/72] [(ypos-79)/72] != null) {
          xpos -= 3;
        }
      }
      if (blueprint[xpos/72] [(ypos-88)/72] != null) {
        mUp = false;
        inWall = true;
        while (blueprint[xpos/72] [(ypos-88)/72] != null) {
          ypos += 3;
        }
      } else if (blueprint[xpos/72] [(ypos-61)/72] != null) {
        mDown = false;
        inWall = true;
        while (blueprint[xpos/72] [(ypos-61)/72] != null) {
          ypos -= 3;
        }
      }
    }
  }
}
