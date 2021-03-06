//////////////////////////////////////////////////////////////
///////    CS3483 Multimodal interface design        /////////
///////                                              /////////
///////             Group Project                    /////////
///////      Gesture-Controlled Presentation         /////////
///////                                              /////////
///////     LI Shiying       54380728                /////////
///////     WANG Yanfei      54014697                /////////
///////     YANG Siyue       54381055                /////////
//////////////////////////////////////////////////////////////

import java.awt.*;
import java.util.*;
import gab.opencv.*;
import processing.video.*;


import org.opencv.core.Core;
import org.opencv.core.Mat;
import org.opencv.core.Size;
import org.opencv.core.Point;
import org.opencv.core.Scalar;
import org.opencv.core.CvType;
import org.opencv.imgproc.Imgproc;

import org.opencv.core.MatOfInt;
import org.opencv.core.MatOfInt4;
import org.opencv.core.MatOfPoint;

OpenCV opencv;
Capture cam;
Movie movie;
Movie movieJr;

//global vars for gesture detection 
Contour hand;
PImage src,dst, hist, histMask;
ArrayList<Contour> contours;
ArrayList<PVector> defectPoints;
ArrayList<PVector> fingerPoints;

Contour convexHull;
PVector hullCenter;

Mat skinHistogram;

//camera attributes
int camWidth = 320;
int camHeight = 240;

PGraphics glow;

PFont ARB, IMP, Arial, bold; //start screen title
PImage yourface;
PImage bkg, bkg2, raise, braise;//img cover
PImage wraisel, wraiser, greenraise;
PImage pagefoot, pagefoot2, pagefoot3; //footpage img
PImage lefthand, righthand, stophand, twohand, modehand; //hand img
PImage upload, scan;
PImage setting, file; //icons
PImage glowselect;
PImage p1, p2, p3, p4, p5, p6; //slides
PImage ppt1, ppt2, ppt3, ppt4, ppt5;
PImage timer, navigator, language, handmode, keyboard;

//static fields
static int GC_ERROR = -1;
static int GC_DEFAULT = 0;
static int GC_RIGHT = 1;
static int GC_LEFT = 2;
static int GC_VICTORY = 3;
static int GC_BYE = 4;

//control logic modules
int flag = GC_DEFAULT;//for ingterface control
int gFlag = GC_DEFAULT;//for gesture detection
int msgFlag = GC_DEFAULT;//for showing message

boolean successreg = false; //the rasing hand image turns to green
boolean lefthandmode = false;

boolean glue = false;  //to control the glue rect to display
boolean select = false;  //to show the select interface
boolean nextFile = false; //to choose the next file in file selection
boolean lastFile = false;
boolean practice = false;
boolean presen = false;
boolean rolling = false; //tutorial rolling plane

boolean startDetect = true;

//main menu
boolean selectfile = false;
boolean tutorial = false;
boolean setts = false;
boolean handmodeselect = false;

//presentation
boolean next = false;
boolean large = false;

int currentPage = 6; //pageP
//float transp = 0;
int x = 0;
int chooseFileCount = 0;
int rollingCount = 0;
int largeCount = 0;
int preCount = 0;

int pptpage = 1;

void setup() {
	size(1000, 600);
	background(0);
	textAlign(CENTER, CENTER);
	
	frameRate(60);
	
  //initialize webcam input
	cam = new Capture(this, camWidth, camHeight);
	cam.start();
  src = new PImage(camWidth, camHeight,RGB);
	
	//movie = new Movie(this, "moivefile.MP4");
  movie = new Movie(this, "filedemo.mov");
  movieJr = new Movie(this, "presendemo.mov");
  movieJr.loop();
	movie.loop();
	
  //load fonts 
	ARB = loadFont("ARBERKLEY-48.vlw");
	IMP = loadFont("Calibri-48.vlw");
	Arial = loadFont("ArialMT-48.vlw");
	bold = loadFont("ArialRoundedMTBold-48.vlw");
	
  //load images
	bkg = loadImage("background.jpg");
	bkg2 = loadImage("bkg2.jpg");
  yourface = loadImage("smile.png");
	raise = loadImage("raisinghand.png");
	braise = loadImage("blackraising.png");
	pagefoot = loadImage("pagefoot.png");
	pagefoot2 = loadImage("pagefoot2.png");
	pagefoot3 = loadImage("pagefoot3.png");

	wraisel = loadImage("whiteraisingleft.png");
	wraiser = loadImage("whiteraisingright.png");
  greenraise = loadImage("greenraisingright.png");
	
	setting = loadImage("gearwheel.png");
	file = loadImage("fileselect.png");
	glowselect = loadImage("glowselect.png");

  upload = loadImage("upload.png");
  scan = loadImage("scan.png");
	
	lefthand = loadImage("lefthand.png");
	righthand = loadImage("righthand.png");
  stophand = loadImage("handicon.png");
  twohand = loadImage("handvictory.png");
  modehand = loadImage("handlove.png");
	
	p1 = loadImage("ppt1.jpg");
	p2 = loadImage("ppt2.jpg");
	p3 = loadImage("ppt4.png");
	p4 = loadImage("ppt4.png");
	p5 = loadImage("ppt5.jpg");
	p6 = loadImage("ppt6.jpg");
	
	ppt1 = loadImage("0001.jpg");
	ppt2 = loadImage("0002.jpg");
	ppt3 = loadImage("0003.jpg");
	ppt4 = loadImage("0004.jpg");
	ppt5 = loadImage("0005.jpg");
	
	timer = loadImage("timer.png");
	navigator = loadImage("navigator.png");
	language = loadImage("language.png");
	handmode = loadImage("handmode.png");
  keyboard = loadImage("keyboard.png");

	glow = createGraphics(width, height, JAVA2D);
	glow.beginDraw();
	glow.smooth();
	glow.noStroke();
	glow.fill(255);
	glow.rect(width/2-260, 125, 520, 320);
	glow.filter(BLUR,6);
	glow.image(ppt1, width/2-250, 135, 500, 300);
	glow.endDraw();
 
}

void draw(){
  if(cam.available())cam.read();
  else msgFlag = GC_ERROR;
  
	//the first page 
	if (currentPage == 0) {
		tint(200);
    noStroke(); 
		image(bkg, 0, 0, width, height);
		Cover();
    
    fill(125);
    rect(70,25,400,50,12);
    textFont(IMP,20);
    fill(255);
    if(msgFlag==GC_ERROR){
      fill(255,0,0);
      text("!!! Cannot detect camera !!!",270,50);
    }else{
      text("//CS3483 PROJECT DEMO//",270,50);
    }
    
	} 
	else if (currentPage == 1) {
    noStroke(); 
		Tutorial();
    
	}
	else if (currentPage == 2){
		tint(255);
		noStroke();
		fill(255);
		rect(0, 0, width, height);
		Menu();  
    fill(125);
    rect(70,25,400,50,12);
    textFont(IMP,20);
    fill(255);
    text("//CS3483 PROJECT DEMO//",270,50);
    
	}
	else if (currentPage == 3) {
		frameRate(60);
		tint(255);
		noStroke();
		fill(64);
		rect(0, 0, width, height);
		ModeSelection();
    fill(125);
    rect(70,25,400,50,12);
	}
	else if (currentPage == 4) {
		frameRate(60);
		tint(255);
    noStroke(); 
		fill(255);
		rect(0, 0, width, height);
		Settings();
    
	}
	else if (currentPage == 5) {
		frameRate(60);
		tint(255);
    noStroke(); 
		fill(64);
		rect(0, 0, width, height);
		Practice();
    fill(125);
    rect(70,15,400,50,12);
    textFont(IMP,20);
    fill(255);
    text("//CS3483 PROJECT DEMO//",270,40);
	}
  else if (currentPage == 6) {
    frameRate(60);
    tint(255);
    noStroke(); 
    fill(64);
    rect(0, 0, width, height);
    pptpage = 1;
    Presentation();
    
    fill(125);
    rect(70,15,400,50,12);
    textFont(IMP,20);
    fill(255);
    text("//CS3483 PROJECT DEMO//",270,40);
  }
  
}

void movieEvent(Movie m) {
     m.read();
}

void keyPressed() {
	//if (keyCode == ENTER) currentPage++;
	if (keyCode == DOWN) currentPage++;
	if (keyCode == UP) currentPage--;

	if (currentPage == 0) {
		if (key == 'r') successreg = true; //if the hand is detect, 
	}
	else if (currentPage == 1) {
    rolling = false;
		if (keyCode == RIGHT) rolling = true; rollingCount = 0;
	}
	else if (currentPage == 2) {
		largeCount = 0;
		select = false;
		if (key == 'i') {
		  selectfile = true; 
		}
    if (key == 't') tutorial = true;
    if (key == 'y') setts = true;
	}
	else if (currentPage == 3) {
		if(key == 'g') glue = true; //add white glow rect to the current file
		if(key == 's') {
		  select = true; //change to the mode selection mode
		}
		if(!select){
  		if(key == 't') currentPage = 4;
  		if(keyCode == RIGHT) {
        lastFile = false;
        nextFile = true;
        chooseFileCount = 0;
      }
  		if(keyCode == LEFT) {
  			lastFile = true;
  			nextFile = false;
  			chooseFileCount = 0;
  		}
		}
		else if(select){
  		if (keyCode == RIGHT) practice = true; presen = false;
  		if (keyCode == LEFT) presen = true; practice = true;
  		if (keyCode == ENTER && practice) currentPage = 5;
      if (keyCode == ENTER && presen) currentPage = 6;
  	}
	}
	else if (currentPage == 4) {
		if (key == 'h') handmodeselect = true;
    if (keyCode == RIGHT) lefthandmode = true; else lefthandmode = false;
    if (keyCode == UP) currentPage--;
	} 
	else if (currentPage == 5) {
		if (key == 't') currentPage = 4;
	}
  else if (currentPage == 6) {
    next = false;
    large = false;
    if (keyCode == RIGHT) {
      preCount = 0; next = true;
    }
    else if (keyCode == LEFT) {
      preCount = 0; 
      large = true;
    }
  }
}

void Cover() {
	//footpage 
	tint(255);
	image(pagefoot, 870, 470, 150, 150);
	stroke(255);
	fill(0);
	triangle(904,600,1000,600,1000,505);
	//hand
	tint(230);
	image(righthand, 925,550,80,50);
	fill(200);
	textFont(Arial, 20);
	text("Show your index finger   Turn to the next page", 500, 570);
	//blocks
  noStroke();
  fill(175,173,173,200);
  rect(100,80,350,430,20);
  rect(550,80,350,430,20);
  //border
  stroke(247,247,247,200);
  noFill();
  rect(105,85,340,420,20);
  rect(555,85,340,420,20);
  //text
  textFont(ARB, 40);
  fill(255);
  text("Gesture-Controlled", 275, 160);
  text("Presentation", 275, 200);
  textFont(IMP, 30);
  text("Free your hand!", 275, 380);
  text("Free your mind!", 275, 420);
  textFont(IMP,35);
  text("Please raise your", 725, 150);
  fill(25);
  textFont(IMP,45);
  text("Dominant Hand", 725, 195); 
  fill(255);
  textFont(IMP,35);
  text("to set the hand mode", 725, 240);
  tint(255);

  OpenCV opencv_face = new OpenCV( this ,320,240); // Initialises the OpenCV object
  opencv_face.loadCascade(OpenCV.CASCADE_FRONTALFACE); // Opens a video capture stream
  OpenCV opencv_hand=new OpenCV(this, 320, 240);
  opencv_hand.loadCascade("fist.xml",false);
  
  opencv_face.loadImage(cam);    
  opencv_hand.loadImage(cam);
  
  Rectangle[] faces = opencv_face.detect();
  Rectangle[] hands = opencv_hand.detect();
  pushMatrix();
  scale(-1,1);
  image(cam,-885,260, 320,240);
  popMatrix();
  scale(1,1);
  image(yourface, 650, 268, 140, 200);
  
  if(faces.length>0 && hands.length>0)
     if(hands[0].x<faces[0].x) gFlag=GC_RIGHT;
     else gFlag = GC_LEFT;
  

  if (gFlag==GC_RIGHT) {
    fill(145,255,82); //green
    textFont(Arial, 20);
    text("Right hand detected!", 725, 457);
  }
  else if (gFlag==GC_LEFT){
    fill(145,255,82); //green
    textFont(Arial, 20);
    text("Left hand detected!", 725, 457);
  }
  detectGesture();
  
}

void Tutorial() {
	noStroke();
	fill(65);
	rect(0,0,width,height);
	//big white ellipse
	fill(255);
	ellipse(30, height/2, height+80, height+80);
	
	//footpage 
	tint(255);
	image(pagefoot, 870, 470, 150, 150);
	stroke(255);
	fill(0);
	triangle(904,600,1000,600,1000,505);
	//hand
	tint(230);
	image(righthand, 925,550,80,50);
	
	
  
	if (rolling) {
    rollingCount= rollingCount +2;
    image(movie, 260+150+30, 100, 500, 300);
    fill(255);
    text("This vedio demostrates the most important workflow of this project. ", 695, 440);
    text("When users enter the File Selection interface, they can select a the “Select”", 670, 462);
    text("gesture and then enter the Mode Selection interface. Similarly, they can either", 668, 484);
    text("Practice Mode or Presentation Mode again using the “Select” gesture.", 639, 506);
  } else {
    image(movieJr, 260+150+30, 100, 500, 300);
  
  }
	fill(65);
  noStroke();
	ellipse(max(260-rollingCount,210), max(height/2-3*rollingCount, height/2-150), max(150-rollingCount,100),  max(150-rollingCount,100));
	ellipse(max(210-1.7*rollingCount,110), max(height/2-150-1.5*rollingCount, 65), 100, 100);
	ellipse(max(110-2*rollingCount, -100), max(65-2*rollingCount, -100), 100, 100);
	ellipse(min(210+rollingCount,260), max(height/2+150-3*rollingCount, height/2), min(100+rollingCount,150),  min(100+rollingCount,150));
	ellipse(min(110+1.7*rollingCount,210), max(height/2+235-1.7*rollingCount, height/2+150), 100, 100);
	ellipse(min(-100+3*rollingCount, 110), max(700-3*rollingCount, height/2+235), 100, 100);
	//text
	fill(255);
	textFont(IMP, constrain(23-rollingCount,17, 23));
	text("Presentation", max(260-rollingCount,210), max(height/2-10-3*rollingCount, height/2-10-150));
	text("Demo", max(260-rollingCount,210), max(height/2+10-3*rollingCount, height/2-150+10));
	textFont(IMP, 17);
	text("Customize", max(210-1.7*rollingCount,110), max(height/2-10-150-1.5*rollingCount, 65-10));
	text("Setting", max(210-1.7*rollingCount,110), max(height/2-150+10-1.5*rollingCount, 65+10));
	textFont(IMP, constrain(17+rollingCount, 17, 23));
	text("File Select", min(210+rollingCount,260), max(height/2+150-10-3*rollingCount, height/2-10));
	text("Demo",  min(210+rollingCount,260), max(height/2+150+10-3*rollingCount, height/2+10));
	textFont(IMP, 17);
	text("Quick", max(110-2*rollingCount, -100), max(65-10-2*rollingCount, -100));
	text("Start", max(110-2*rollingCount, -100), max(65+10-2*rollingCount, -100));
	textFont(IMP, 17);
	text("File", min(110+1.7*rollingCount,210), max(height/2+235-10-1.7*rollingCount, height/2+150-10));
	text("Management", min(110+1.7*rollingCount,210), max(height/2+235+10-1.7*rollingCount, height/2+150+10));
	text("Quick", min(-100+3*rollingCount, 110), max(700-3*rollingCount-10, height/2+235-10));
	text("Start", min(-100+3*rollingCount, 110), max(700-3*rollingCount+10, height/2+235+10));  
}

void Menu(){
	stroke(175);
	strokeWeight(1);
	noFill();
	pushMatrix();
	polygon(190, 480, 40, 6, true);  
	polygon(190, 550, 40, 6, true);
	polygon(250, 514, 40, 6, true);
	polygon(250, 514, 40, 6, true);
	polygon(310, 548, 40, 6, true);
	polygon(310, 548-70, 40, 6, true);
	polygon(110, 770, 40, 6, true);
	polygon(170, 804, 40, 6, true);
	polygon(170, 734, 40, 6, true);
	popMatrix();
	
	fill(64);
	textFont(IMP, 30);
	text("Gesture-Controlled", 235, 240);
	textFont(IMP, 45);
	text("Presentation", 235, 285);
	textFont(bold, 80 );
	text("GCP3", 235, 370);
	textFont(IMP, 30);
	text("Free your hand!", 235, 450);
	text("Free your mind!", 235, 490);
	
	fill(64);
	pushMatrix();
	//translate(width*0.8, height*0.5);
	polygon(230, 650, 120, 6, true);  // Heptagon
	polygon(400, 530, 80, 6, true); 
	polygon(420, 780, 100, 6, true);
	popMatrix();
	
	//text
	fill(255);
	textFont(IMP, 40);
	text("Select", 650, 210);
	text("File", 650, 260);
	text("Setting", 780, 420);
	textFont(IMP, 30);
	text("Tutorial", 530, 400);
	
	if (selectfile) {
		largeCount++;
		noStroke();
		fill(64);
		pushMatrix();
		polygon(230, 650, 120+10*largeCount, 6, true);  // Heptagon
		popMatrix();
		fill(255);
		textFont(IMP, 40+5*largeCount);
		if (largeCount < 50) {
		  text("Select", 650, 210);
		} else {
		  currentPage = 3;
		  selectfile = false;
		}
	}

  if (tutorial) {
    largeCount++;
    noStroke();
    fill(64);
    pushMatrix();
    polygon(400, 530, 80+10*largeCount, 6, true);  // Heptagon
    popMatrix();
    fill(255);
    textFont(IMP, 30+5*largeCount);
    if (largeCount < 40) {
      text("Tutorial", 530, 400);
    } else {
      currentPage = 1;
      tutorial = false;
    }
  }
  
  if (setts) {
    largeCount++;
    noStroke();
    fill(64);
    pushMatrix();
    polygon(420, 780, 100+10*largeCount, 6, true);  // Heptagon
    popMatrix();
    fill(255);
    textFont(IMP, 40+5*largeCount);
    if (largeCount < 50) {
      text("Setting", 780, 420);
    } else {
      currentPage = 4;
      setts = false;
      
    }
  }
}

void ModeSelection() {
 
	//files
	noStroke();
	//footpage 
	tint(255);
	image(pagefoot2, 870, -30, 150, 150);
	stroke(255);
	fill(0);
	triangle(904,-1,1000,-1,1000,96);
	tint(225);
	image(setting, 951, 10, 40, 40);
	
	//hand
	fill(0);
	tint(230);
	image(righthand, width/2 + 100,480,80,50);
	image(lefthand, width/2 - 180,480,80,50);
	tint(150);
  image(twohand, width/2 - 20, 470, 40, 50);  
  image(upload, 215, 485, 40, 40);
	image(stophand, 25, 25, 40, 50);
  image(scan, 757, 490, 40, 40);
	tint(255);

  if(startDetect){
    
    detectGesture();
    if(gFlag == 2){ 
      nextFile = true;
      lastFile = false;
    }
    if(gFlag == 3){
      lastFile = true;
      nextFile = false;
    }
    if(gFlag==1){
      select = true;
    }
  }
  
  //interaction of choosing the left and right file
  if (nextFile || lastFile){
    startDetect = false;
    if (nextFile) {
      chooseFileCount = chooseFileCount + 2;
      image(p5, constrain(width-80-142-6*chooseFileCount, 80, width-80-142), 275, 142, 86);
      image(p3, constrain(width/2+250-130+2*chooseFileCount, width/2+250-130,width-80-142), constrain(250+chooseFileCount,250,275), constrain(230-2*chooseFileCount, 142, 230), constrain(130-chooseFileCount,86, 130));  
      image(ppt1, constrain(width/2-250+3*chooseFileCount,width/2-250,width/2+250-130), constrain(135+chooseFileCount,135,250),constrain(500-2*chooseFileCount, 230, 500), constrain(300-1.5*chooseFileCount, 130,300));  
      image(p1, constrain(80+2*chooseFileCount, 80, 150), constrain(275-chooseFileCount,250,275), constrain(142+2*chooseFileCount, 142, 230), constrain(86+chooseFileCount,86,130)); 
      image(p2, constrain(150+2*chooseFileCount, 150, width/2-250), constrain(250-chooseFileCount,135,250), constrain(230+2.5*chooseFileCount,230,500), constrain(130+2*chooseFileCount,130,300));     
    } 
    if (lastFile) {
      chooseFileCount = chooseFileCount + 2;
      image(p5, constrain(80+5*chooseFileCount, 80, width-80-142), 275, 142, 86); 
      image(p1, constrain(150-chooseFileCount, 80, 150), constrain(250+chooseFileCount,250, 275), constrain(230-2.5*chooseFileCount,142,230), constrain(130-2*chooseFileCount,86,130));   
      image(p3, constrain(width-80-142-chooseFileCount, width/2+250-130, width-80-142), constrain(275-chooseFileCount,250,275), constrain(142+2.5*chooseFileCount,142,230), constrain(86+2*chooseFileCount,86,130));
      image(p2, constrain(width/2-250-3*chooseFileCount, 150, width/2-250), constrain(135+chooseFileCount,135,250),constrain(500-2*chooseFileCount, 230, 500), constrain(300-1.5*chooseFileCount,130,300));  
      image(ppt1, constrain(width/2+250-130-2*chooseFileCount,width/2-250,width/2+250-130), constrain(250-chooseFileCount,135,250), constrain(230+2*chooseFileCount, 230, 500), constrain(130+2*chooseFileCount,130,300));  
      //if(glue) image(glow, 0, 0);  
    }
    if (chooseFileCount>400) {startDetect = true;println(chooseFileCount+"");}
  } else {
    chooseFileCount = 0;
    image(p5, width-80-142, 275, 142, 86);
    image(p3, width/2+250-130,250,230,130);
    image(p1, 80, 275, 142, 86);
    image(p2, 150, 250, 230, 130); 
    //if(glue) image(glow, 0, 0);  
    //else 
      image(ppt1, width/2-250,135,500,300);    
  }
  
  if (select) {
    x++;
    image(glowselect, 0, 0);
    image(glow, min(5*x, 250), 0, max(1000-10*x,500), max(600-6*x, 300));
    //plane
    choosePlane(x, 0);
    if (practice) choosePlane(255, 2);
    if (presen) choosePlane(255,1);
    detectHand();
    if(gFlag ==2) {
      choosePlane(255, 2); 
      practice= true;
      presen = false;
      detectHand();
      if (gFlag==1) currentPage = 5;
    }
    if(gFlag==3) {
      choosePlane(255, 1); 
      detectHand();
      if (gFlag==1) currentPage = 6;
    }
  }

}

void Settings () {
  tint(150);
  image(stophand, 25, 25, 40, 50);
	//footpage 
	//line(width/2, 0, width/2, 600);
	//tint(255);
	//image(pagefoot3, -15, 470, 150, 150);
	//stroke(255);
	//fill(0);
	//triangle(-1,500,100,600,-1,600);
	//image(file, 16, 551, 40, 40);
  
	//footpage 
	tint(255);
	image(pagefoot2, 870, -30, 150, 150);
	stroke(255);
	fill(0);
	triangle(904,-1,1000,-1,1000,96);
	tint(225);
	//image(setting, 951, 10, 40, 40);
  
	if (lefthandmode) {
		//polygon
		fill(64);
		noStroke();
		polygon(350, 300, 300, 6, false);
		polygon(650, 80, 65, 6, false); 
		polygon(730, 220, 65, 6, false); 
		if (handmodeselect) {
			noFill();
			stroke(64); 
			strokeWeight(3);
		} 
		else {
			noStroke();
			fill(64);
			strokeWeight(1);
		}
		polygon(650, 520, 65, 6, false); 
		noStroke();
		fill(64);
		strokeWeight(1);
		polygon(730, 380, 65, 6, false); 
		//icons
		noStroke(); 
		tint(255);
		image(timer, 613, 35, 80, 70);
		image(language, 700, 175, 80, 70);
		image(navigator, 690, 335, 90, 80);
		if (handmodeselect) {
			tint(64); 
		} 
		else {
			tint(255);
		}
		image(handmode, 615, 475, 80, 70);
		tint(255);
		//text
		fill(255);
		textFont(IMP, 23);
		text("Timer", 650, 115);
		textFont(IMP, 18);
		text("Language", 730, 256);
		text("Navigator", 733, 415);
		if (handmodeselect) {
			fill(64); 
		} 
		else {
			fill(255);
		}
		text("Hand mode", 650, 555);  

		fill(64);
		noStroke();
    
    if (handmodeselect) {
      polygon(350, 300, 300, 6, false);
      image(wraiser, -200+370, 120, 100, 140);
      image(raise, -200+605, 120, 100, 140);
      image(keyboard, -200+460, 280, 150, 100);
      fill(255);
      textFont(IMP, 40);
      text("Left hand mode", 350, 427);
    }
    else {
      polygon(350, 300, 300, 6, false);
    }

	} else {
		//polygon
		fill(64);
		noStroke();
		polygon(900-350, 300, 300, 6, false);
		polygon(900-650, 80, 65, 6, false); 
		polygon(900-730, 220, 65, 6, false); 
		if (handmodeselect) {
		noFill();
		stroke(64); 
		strokeWeight(3);
		} 
		else {
		noStroke();
		fill(64);
		strokeWeight(1);
		}
		polygon(900-650, 520, 65, 6, false); 
		noStroke();
		fill(64);
		strokeWeight(1);
		polygon(900-730, 380, 65, 6, false); 
		//icons
		noStroke(); 
		tint(255);
		image(timer, 825-613, 35, 80, 70);
		image(language, 830-700, 175, 80, 70);
		image(navigator, 820-690, 335, 90, 80);
		if (handmodeselect) {
			tint(64); 
		} 
		else {
			tint(255);
		}
		image(handmode, 828-615, 475, 80, 70);
		tint(255);
		//text
		fill(255);
		textFont(IMP, 23);
		text("Timer", 900-650, 115);
		textFont(IMP, 18);
		text("Language", 900-730, 256);
		text("Navigator", 900-733, 415);
		if (handmodeselect) {
			fill(64); 
		} 
		else {
			fill(255);
		}
		text("Hand mode", 900-650, 553);  

		fill(64);
		noStroke();
		
		if (handmodeselect) {
			polygon(900-350, 300, 300, 6, false);
			image(greenraise, 370, 120, 100, 140);
			image(wraisel, 605, 120, 100, 140);
      image(keyboard, 460, 280, 150, 100);
      fill(255);
      textFont(IMP, 40);
      text("Right hand mode", 900-350, 427);
		}
		else {
			polygon(900-350, 300, 300, 6, false);
		}
	}
}

void Practice() {
  tint(150);
  image(stophand, 25, 15, 40, 50);
	strokeWeight(1);
  stroke(255);
	tint(225);
	image(setting, 951, 10, 40, 40);
	
	fill(125,125,125,200);
	rect(25, 343, 320, 183, 12);
	//rect(190, 40, 170, 300, 12);
	//rect(10, 345, 350, 250, 12);
	image(ppt1, 32+10, 350, 130, 80);
  image(ppt2, 210-10, 350, 130, 80);
	image(ppt3, 32+10, 440, 130, 80);
  image(ppt4, 210-10, 440, 130, 80);
	//image(ppt3, 20, 245, 150, 90);
	
	image(ppt1, 380, 170, 600, 350);
	
	rect(385, 88, 190, 40, 12); 
	rect(590, 88, 190, 40, 12); 
	rect(790, 88, 190, 40, 12);
	
	//rect(790, 549, 190, 40, 12);
	
	//text
	fill(255);
	textFont(Arial, 18);
	text("Progress: 6/30", 487, 145-34);
	text("10:20", 685, 145-34);
	text("Next Speaker: David", 887, 145-34);
	
	textFont(IMP, 18);
	text("Mode: Practice", 900, 555); 

	if (cam.available() == true) cam.read();
	//opencv.loadImage(cam);
	image(cam, 25, 88);
}

void Presentation() {
  tint(150);
  image(stophand, 25, 15, 40, 50);
  tint(255);
  if (next) {
    preCount = preCount + 2;
    image(ppt2, 90, 70, 750, 450);
    image(ppt1, 90-preCount*6, 70, 750, 450);
    
    fill(64);
    noStroke();
    rect(0,70,90,450);
    
    if (preCount > 180) {
      
      pptpage = 2;
    }
  } else image(ppt1, 90, 70, 750, 450);
  
  
  if (large){
    preCount = preCount + 2;
    image(ppt3, 90, 70, 750, 450);
    if (preCount < 100) {
      image(ppt2, 90-preCount, 70-preCount, 750+10*preCount, 450+6*preCount);
    } else pptpage = 3;
    //else large = false;
    fill(64);
    noStroke();
    rect(0,70,90,460);
    rect(0, 0, width, 70);
    rect(840, 0, 160, height);
    rect(0, 520, width, 90);
  }
  
  
  else if (pptpage == 2) image(ppt2, 90, 70, 750, 450);
  else if (pptpage == 3) image(ppt3, 90, 70, 750, 450);
  
  
  //footpage 
  tint(255);
  image(pagefoot2, 870, -30, 150, 150);
  stroke(255);
  fill(0);
  triangle(904,-1,1000,-1,1000,96);
  tint(225);
  image(setting, 951, 10, 40, 40);
  
  fill(255);
  textFont(IMP, 18);
  text("Mode: Presentation", 900, 555); 
}

void choosePlane(int x, int pcolor) {
	strokeWeight(5);
  	stroke(225,225,225, min(3*x, 255));
	if (pcolor == 0)  {
		fill(175,173,173, min(-50+5*x, 200)); 
		//left 
		ellipse(width/2-300,380,300,300);
		ellipse(width/2-300,380,150,150);
		line(87,283,142,329);
		line(313,283,256,329);
		line(87,477,142,430);
		line(313,477,256,430);
		//right
		ellipse(width/2+300,380,300,300);
		ellipse(width/2+300,380,150,150);
		line(687,283,744,329);
		line(913,283,855,329);
		line(687,477,744,430);
		line(913,477,855,433);
	}
	else if (pcolor == 1) {
		fill(63,60,76);
		//left 
		ellipse(width/2-300,380,300,300);
		ellipse(width/2-300,380,150,150);
		line(87,283,142,329);
		line(313,283,256,329);
		line(87,477,142,430);
		line(313,477,256,430);
		fill(175,173,173, min(-50+5*x, 200)); 
		//right
		ellipse(width/2+300,380,300,300);
		ellipse(width/2+300,380,150,150);
		line(687,283,744,329);
		line(913,283,855,329);
		line(687,477,744,430);
		line(913,477,855,433);
	} 
	else if (pcolor == 2) {
		fill(175,173,173, min(-50+5*x, 200)); 
		//left 
		ellipse(width/2-300,380,300,300);
		ellipse(width/2-300,380,150,150);
		line(87,283,142,329);
		line(313,283,256,329);
		line(87,477,142,430);
		line(313,477,256,430);
		fill(175,173,173, min(-50+5*x, 200)); 
		fill(63,60,76);
		//right
		ellipse(width/2+300,380,300,300);
		ellipse(width/2+300,380,150,150);
		line(687,283,744,329);
		line(913,283,855,329);
		line(687,477,744,430);
		line(913,477,855,433);
	}
	//text
	fill(255,255,255, min(3*x, 255));
	textFont(IMP, 26);
	text("Presentation", width/2-300, 380);
	text("Practice", width/2+300, 380);
	textFont(IMP, 20);
	text("Navigator", width/2-300, 270);
	text("Navigator", width/2+300, 270);
	text("Language", width/2-300, 484);
	text("Language", width/2+300, 484);
	text("Hand", 86, 358);
	text("Mode", 86, 387);
	text("Hand", 686, 358);
	text("Mode", 686, 387);
	text("Timer", 313, 374);
	text("Timer", 911, 374); 
}

void polygon(float x, float y, float radius, int npoints, boolean vertical) {
	float angle = TWO_PI / npoints;
	beginShape();
	for (float a = 0; a < TWO_PI; a += angle) {
		float sx = x + cos(a) * radius;
		float sy = y + sin(a) * radius;
		if(vertical) vertex(sy, sx);
		else vertex(sx, sy);
	}
	endShape(CLOSE);
}
// in BGR
Scalar colorToScalar(color c){
  return new Scalar(blue(c), green(c), red(c));
}

void detectGesture(){
  //removeBackground();//not effective, discard
  detectSkin();
  if(hasHand()){
    detectHand();
  }else{
    println("No Hand detected");
  }
  
}
  
void removeBackground(){
  
}
void detectSkin(){
  
  src.loadPixels();
  cam.loadPixels();
  arrayCopy(cam.pixels,src.pixels);
  src.updatePixels();
  
  //image(cam,0,0);
  
    opencv = new OpenCV(this, src, true);  
    skinHistogram = Mat.zeros(256, 256, CvType.CV_8UC1);
    Core.ellipse(skinHistogram, new Point(113.0, 155.6), new Size(40.0, 25.2), 43.0, 0.0, 360.0, new Scalar(255, 255, 255), Core.FILLED);

   histMask = createImage(256,256, ARGB);
   opencv.toPImage(skinHistogram, histMask);
 
   dst = opencv.getOutput();
   dst.loadPixels();
 
 for(int i = 0; i < dst.pixels.length; i++){
    
    Mat input = new Mat(new Size(1, 1), CvType.CV_8UC3);
    input.setTo(colorToScalar(dst.pixels[i]));
    Mat output = opencv.imitate(input);
    Imgproc.cvtColor(input, output, Imgproc.COLOR_BGR2YCrCb );
    double[] inputComponents = output.get(0,0);
    if(skinHistogram.get((int)inputComponents[1], (int)inputComponents[2])[0] > 0){
      dst.pixels[i] = color(255);
    } else {
      dst.pixels[i] = color(0);
    }
 }
 
 dst.updatePixels();
 
 OpenCV oc = new OpenCV(this, dst);
 contours = oc.findContours();
   
  }
  
boolean hasHand(){
  noFill();
  strokeWeight(3);
  
  for (Contour contour : contours) {
    
    if(contour.area()>3600&&contour.area()<15000){
    
    hand = contour;
    return true;
    }
  }
  return false;

}

void detectHand(){
  
  convexHull = hand.getPolygonApproximation().getConvexHull();
  hullCenter = new PVector(convexHull.getBoundingBox().x + convexHull.getBoundingBox().width/2, 
  convexHull.getBoundingBox().y + convexHull.getBoundingBox().height/2);

  //find defects
  MatOfInt4 defects = new MatOfInt4();
  MatOfInt hull = new MatOfInt();
  MatOfPoint points = new MatOfPoint(hand.pointMat);
  Imgproc.convexHull(points, hull, true);
  Imgproc.convexityDefects(points, hull, defects);
  
  defectPoints  = new ArrayList<PVector>();
  

  ArrayList<Integer> defectIndices = new ArrayList<Integer>();
  
  for (int i = 0; i < defects.height(); i++) {
    //int startIndex = (int)defects.get(i, 0)[0];
    //int endIndex = (int)defects.get(i, 0)[1];
    int defectIndex = (int)defects.get(i, 0)[2];
    if (defects.get(i, 0)[3] > 10000) {
      defectIndices.add( defectIndex );
      defectPoints.add(hand.getPoints().get(defectIndex));
      
    }
  }
  
  for(int i = 1;i<defectPoints.size();i++)
    if(defectPoints.get(i-1).dist(defectPoints.get(i))<100)
      defectPoints.remove(i);  
      
  ArrayList<PVector> allPoints = new ArrayList<PVector>();
  allPoints = convexHull.getPoints();
  fingerPoints =  new ArrayList<PVector>();
  for(PVector p:allPoints)
   if(p.y<src.height-80) 
     fingerPoints.add(p);
  for(int i = 1;i<fingerPoints.size();i++)
    if(fingerPoints.get(i-1).dist(fingerPoints.get(i))<100)
      fingerPoints.remove(i);   

  noFill();
  strokeWeight(3);
  
  switch(defectPoints.size()){
    case 0:
      if(fingerPoints.size()>0 && fingerPoints.size()<=2)
        if(fingerPoints.get(0).x-hullCenter.x<0)
          gFlag = 2;//next item
        else gFlag = 3;//previous item
      break;
    case 1:
      if(fingerPoints.size()==2)
        gFlag = 1;//confirm
      break;
    case 4:
      if(fingerPoints.size()>3)
        gFlag = 4;//wave to exit;
      break;
    default:
      println("unrecognized gesture");
      break;
  }
  
  if(currentPage ==0 && gFlag==1)
    currentPage = 1;
    
  //drawResults();
 
}

//void drawResults(){
  
//  image(dst,1000-cam.width,0);
//  stroke(0,0,255);
//  strokeWeight(1);
//  noFill();
//  hand.getPolygonApproximation().draw();
//  stroke(255,0,0);
//  hand.getConvexHull().draw();
  
//   int d = 0;
//   fill(0,255,255);
   
//   for(PVector p : fingerPoints){
//     ellipse(p.x,p.y, 5, 5);
//     textSize(32);
//     text(""+d,p.x,p.y);
//     d++;
//     if(gFlag == 2){
//       text("next",p.x,p.y);
//     }else if(gFlag==3){
//       text("pre",p.x,p.y);
//       }
//   } 
//   stroke(0,0,0);
//   fill(255,255,0);
//   for(PVector p : defectPoints){
//     ellipse(p.x,p.y, 10, 10);
     
//   }
   
//   if(flag ==1){
//     stroke(255,255,255);
//     fill(255,255,255);
//     rect(640,300,20,20);
//   }
   
//   fill(0,255,0);
//   stroke(0,255,0);
//   ellipse(hullCenter.x, hullCenter.y, 5, 5);
//}