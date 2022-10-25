import processing.sound.*;
SoundFile file;
//SoundFile("sneeze.mp3");

int gameFace = 0;

// decalring variables to determine how the covid virus moves 
float hover = .3;

float wind = 0.00001;
float resistence = 0.1;

// declaring score keeping varibales
int score = 0;
int maxScore = 100;
float total = 100;
float totalLoss = 1;
int totalDisplay = 60;

// covid appearence and mobility
float covidX, covidY;
float covidSpeedUD = 0; //speed of covid boucing up and down
float covidSpeedLR = 0; //speed of covid bouncing left to right 
float covidSize = 30;
color covidColor = color(117, 255, 51);

// mask appearence 
color maskColor = color(51, 255, 254);
float maskWidth = 100;
float maskHeight = 20;

// obstacle variables
int obstacleSpeed = 5;
int obstacleInt = 1000;
float time = 0;
int minSpaceHeight = 350;
int maxSpaceHeight = 275;
int obstacleWidth = 80;
color obstacleColors = color(random(255), random(255), random(255));

// background images
PImage b;
//int y;
PImage covid;
PImage mask;

//to determine the obstacles appearing 
ArrayList<int[]> obstacles = new ArrayList<int[]>();



void setup() {
  size(800, 800);
  // set the initial coordinates of the covid
  covidX=width/4;
  covidY=height/5;
  smooth();
   b = loadImage("virus3.png");
   b.resize(800, 800);
   covid = loadImage("covid.png");
   mask = loadImage("mask.png");
   //file("sneeze.mp3");
   
  
}



void draw() {
  background(b);
  // Display the contents of the current screen
  if (gameFace == 0) { 
    startingFace();
  } else if (gameFace == 1) { 
    gameFace();
  } else if (gameFace == 2) { 
    end();
  }
}


void startingFace() {
  background(0);
  textAlign( CENTER);
  fill(52, 73, 94);
  textSize(14);
 fill(255);
  text("CONTAGION DETECTED - USE THE BLUE MASK TO PROTECT YOURSELF AGAINST THE VIRUS", width/2, height/2);
 fill(255);
  textSize(15); 
  text("start game", width/2, height-30);
}


void gameFace() {
 // background(236, 240, 241);
 background(b);
 
  drawMask();
  maskBounce();
  drawcovid();
  applyhover();
  applyLRSpeed();
  boundry();
  displayedScore();
  printTotal();
  obstacleAdder();
  obstacleHandler();
}
void end() {
  background(0);
  textAlign(CENTER);
  fill(236, 240, 241);
  textSize(10);
  fill(255);
  text("CONTAGION DETECTED - YOU ARE INFECTED.", width/2, height/2 - 120);
  textSize(130);
  text(score, width/2, height/2);
  textSize(15);
  fill(255);
  text("Play Again ", width/2, height-30);
}




public void mousePressed() {
  // function to begin the game i.e. if clicked 
  if (gameFace==0) { 
    startGame();
   // soundFile("sneeze.mp3");
 //  file.play();
  }
  if (gameFace==2) {
    restart();
  }
}

 
void startGame() {
  gameFace=1;
}
void gameOver() {
  gameFace=2;
}

void restart() {
  score = 0;
  total = maxScore;
  covidX=width/4;
  covidY=height/5;
  time = 0;
  obstacles.clear();
  gameFace = 1;
}

void drawcovid() {
  fill(covidColor);
  ellipse(covidX, covidY, covidSize, covidSize);
}
void drawMask() {
  fill(maskColor);
  rectMode(CENTER);
  rect(mouseX, mouseY, maskWidth, maskHeight, 5);
}


//obstacles .... initially proposed to be in shape of virus but what too distarcting to thr goal

void obstacleAdder() {
  if (millis()-time > obstacleInt) {
    int randHeight = round(random(minSpaceHeight, maxSpaceHeight));
    int randY = round(random(0, height-randHeight));
    // {spaceWallX, spaceWallY, spaceWallWidth, spaceWallHeight, scored}
    int[] randWall = {width, randY, obstacleWidth, randHeight, 0}; 
    obstacles.add(randWall);
    time = millis();
  }
}
void obstacleHandler() {
  for (int i = 0; i < obstacles.size(); i++) {
    obstacleRemover(i);
    obstacleMover(i);
    obstacleDrawer(i);
    obstacleCollision(i);
  }
}
void obstacleDrawer(int index) {
  int[] obstacle = obstacles.get(index);

  int spaceWallX = obstacle[0];
  int spaceWallY = obstacle[1];
  int spaceWallWidth = obstacle[2];
  int spaceWallHeight = obstacle[3];
  
  rectMode(CORNER);
  noStroke();
  strokeCap(ROUND);
  fill(obstacleColors);
  rect(spaceWallX, 0, spaceWallWidth, spaceWallY, 0, 0, 15, 15);
  rect(spaceWallX, spaceWallY+spaceWallHeight, spaceWallWidth, height-(spaceWallY+spaceWallHeight), 15, 15, 0, 0);
}
void obstacleMover(int index) {
  int[] obstacle = obstacles.get(index);
  obstacle[0] -= obstacleSpeed;
}
void obstacleRemover(int index) {
  int[] obstacle = obstacles.get(index);
  if (obstacle[0]+obstacle[2] <= 0) {
    obstacles.remove(index);
  }
}

void obstacleCollision(int index) {
  int[] obstacle = obstacles.get(index);
  // get space obstacle settings 
  int spaceWallX = obstacle[0];
  int spaceWallY = obstacle[1];
  int spaceWallWidth = obstacle[2];
  int spaceWallHeight = obstacle[3];
  int obstacleScored = obstacle[4];
  int obstacleTopX = spaceWallX;
  int obstacleTopY = 0;
  int obstacleTopWidth = spaceWallWidth;
  int obstacleTopHeight = spaceWallY;
  int obstacleBottomX = spaceWallX;
  int obstacleBottomY = spaceWallY+spaceWallHeight;
  int obstacleBottomWidth = spaceWallWidth;
  int obstacleBottomHeight = height-(spaceWallY+spaceWallHeight);

  if (
    (covidX+(covidSize/2)>obstacleTopX) &&
    (covidX-(covidSize/2)<obstacleTopX+obstacleTopWidth) &&
    (covidY+(covidSize/2)>obstacleTopY) &&
    (covidY-(covidSize/2)<obstacleTopY+obstacleTopHeight)
    ) {
    decreaseTotal();
  }
  if (
    (covidX+(covidSize/2)>obstacleBottomX) &&
    (covidX-(covidSize/2)<obstacleBottomX+obstacleBottomWidth) &&
    (covidY+(covidSize/2)>obstacleBottomY) &&
    (covidY-(covidSize/2)<obstacleBottomY+obstacleBottomHeight)
    ) {
    decreaseTotal();
  }

  if (covidX > spaceWallX+(spaceWallWidth/2) && obstacleScored==0) {
    obstacleScored=1;
    obstacle[4]=1;
    score();
  }
}


//function in score keeping 

void displayedScore() {
  noStroke();
  fill(189, 195, 199);
  rectMode(CORNER);
  rect(covidX-(totalDisplay/2), covidY - 30, totalDisplay, 5);
  if (total >= 100){
    won();
  }
  if (total > 60) {
    fill(46, 204, 113);
  } else if (total > 30) {
    fill(230, 126, 34);
  } else {
    fill(231, 76, 60);
  }
  rectMode(CORNER);
  rect(covidX-(totalDisplay/2), covidY - 30, totalDisplay*(total/maxScore), 5);
}


void won(){
    background(0);
  textAlign(CENTER);
  fill(236, 240, 241);
  textSize(10);
  fill(255);
  //text("YOU AVOIDED THE VIRUS - CONGRATS!", width/2, height/2 - 120);
  textSize(130);
  text(score, width/2, height/2);
  textSize(15);
  fill(255);
  text("Play Again ", width/2, height-30);
}

void decreaseTotal() {
  total -= totalLoss;
  if (total <= 0) {
    gameOver();
  }
}


void score() {
  score++;
}

//to dispaly score while playing 
void printTotal() {
  textAlign(CENTER);
  fill(255);
  textSize(30); 
  text(score, height/2, 50);
}

//functions to determine the virus beig deflected form the mask 

void maskBounce() {
  float overhead = mouseY - pmouseY;
  if ((covidX+(covidSize/2) > mouseX-(maskWidth/2)) && (covidX-(covidSize/2) < mouseX+(maskWidth/2))) {
    if (dist(covidX, covidY, covidX, mouseY)<=(covidSize/2)+abs(overhead)) {
      bounceSouth(mouseY);
      covidSpeedLR = (covidX - mouseX)/10;
    
      if (overhead<0) {
        covidY+=(overhead/2);
        covidSpeedUD+=(overhead/2);
      }
    }
  }
}
void applyhover() {
  covidSpeedUD += hover;
  covidY += covidSpeedUD;
  covidSpeedUD -= (covidSpeedUD * wind);
}
void applyLRSpeed() {
  covidX += covidSpeedLR;
  covidSpeedLR -= (covidSpeedLR * wind);
}
// if covid hits north, south, east or west
void bounceSouth(float surface) {
  covidY = surface-(covidSize/2);
  covidSpeedUD*=-1;
  covidSpeedUD -= (covidSpeedUD * resistence);
}

void bounceNorth(float surface) {
  covidY = surface+(covidSize/2);
  covidSpeedUD*=-1;
  covidSpeedUD -= (covidSpeedUD * resistence);
}

void bounceWest(float surface) {
  covidX = surface+(covidSize/2);
  covidSpeedLR*=-1;
  covidSpeedLR -= (covidSpeedLR * resistence);
}

void bounceEast(float surface) {
  covidX = surface-(covidSize/2);
  covidSpeedLR*=-1; //later refered to as west and east
  covidSpeedLR -= (covidSpeedLR * resistence);
}
// keep covid in the screen
void boundry() {
  // covid hits floor
  if (covidY+(covidSize/2) > height) { 
    bounceSouth(height);
  }
  // covid hits ceiling
  if (covidY-(covidSize/2) < 0) {
    bounceNorth(0);
  }
  // covid hits left of the screen
  if (covidX-(covidSize/2) < 0) {
    bounceWest(0);
  }
  // covid hits right of the screen
  if (covidX+(covidSize/2) > width) {
    bounceEast(width);
  }
}
