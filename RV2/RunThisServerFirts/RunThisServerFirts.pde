/**
 * RunThisServerFirts
 * created by Javier Vega Aguirre.
      
      * based on "WhichFace"
      * Daniel Shiffman
      * http://shiffman.net/2011/04/26/opencv-matching-faces-over-time/
      *
      * Modified by Jordi Tost (@jorditost) to work with the OpenCV library by Greg Borenstein:
      * https://github.com/atduskgreg/opencv-processing
      *
      * @url: https://github.com/jorditost/BlobPersistence/
      *
      * University of Applied Sciences Potsdam, 2014


  * Esta es una modificacion de la demo WhichFace de deteccion de caras,
  * para una practica de la asignatura de Realidad Virtual de la UOC,
  * del segundo semestre de 2016/12/12. Realizada por:
  * Javier Vega Aguirre.

  * Se trata de dos Sketches uno de captura de imagen y otro de representacion
  * del entorno 3D basado en el trabajo de Johny Chung Lee:
  
        * Johnny Lee. “Head Tracking for Desktop VR Displays using the WiiRemote”.
        * https:// www.youtube.com/watch?v=Jd3-eiid-Uw . 13 de Octubre de 2016.
  
  * La parte de J.V.A. Estara indicada de la suigiente manera:
  
  
        // **************INI******************* //
        Codigo......
        Codigo......
        // **************FIN******************* //
  */
  
import gab.opencv.*;
import processing.video.*;
import java.awt.*;

// **************INI******************* //
import processing.net.*;
float myX, myY,myZ,Xf,Yf,Zf;
float alisado=0;
Server s;
// **************FIN******************* //


Capture video;
OpenCV opencv;

// List of my Face objects (persistent)
ArrayList<Face> faceList;

// List of detected faces (every frame)
Rectangle[] faces;

// Number of faces detected over all time. Used to set IDs.
int faceCount = 0;

// Scaling down the video
int scl = 2;

void setup() {
  // **************INI******************* //
  frameRate(45); // Slow it down a little
  s = new Server(this, 12345); // Start a simple server on a port
  // **************FIN******************* //
  size(640, 480);
  video = new Capture(this, width/scl, height/scl);
  opencv = new OpenCV(this, width/scl, height/scl);
  opencv.gray();
  opencv.blur(12); 
  opencv.threshold(70);
  opencv.findCannyEdges(20,75);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  
  
  faceList = new ArrayList<Face>();
  
  video.start();
}

void draw() {
  alisado=0.1;
  scale(scl);
  opencv.loadImage(video);

  image(video, 0, 0 );
  
  detectFaces();

  // Draw all the faces
  for (int i = 0; i < faces.length; i++) {
    noFill();
    strokeWeight(1);
    stroke(255,0,0);
    //rect(faces[i].x*scl,faces[i].y*scl,faces[i].width*scl,faces[i].height*scl);
    rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
  }
  
  for (Face f : faceList) {
    strokeWeight(0.5);
    f.display();
  }
  
}

void detectFaces() {
  
  // Faces detected in this frame
  faces = opencv.detect();

  // Check if the detected faces already exist are new or some has disappeared. 
  
  // SCENARIO 1 
  // faceList is empty
  if (faceList.isEmpty()) {
    // Just make a Face object for every face Rectangle
    for (int i = 0; i < faces.length; i++) {
      println("+++ New face detected with ID: " + faceCount);
      faceList.add(new Face(1, faces[i].x,faces[i].y,faces[i].width,faces[i].height));
      faceCount++;
    }
  
  // SCENARIO 2 
  // We have fewer Face objects than face Rectangles found from OPENCV
  } else if (faceList.size() <= faces.length) {
    boolean[] used = new boolean[faces.length];
    // Match existing Face objects with a Rectangle
    for (Face f : faceList) {
       // Find faces[index] that is closest to face f
       // set used[index] to true so that it can't be used twice
       float record = 50000;
       int index = -1;
       
       for (int i = 0; i < faces.length; i++) {
         float d = dist(faces[i].x,faces[i].y,f.r.x,f.r.y);
// **************INI******************* //
         /*CAPTURAMOS EL MOVIMIENTO AQUI*/
       
         myX = ceil(faces[i].x/0.011);
         myY = ceil(faces[i].y/0.011);
         myZ = ceil(faces[i].width/0.011)/10;
         Xf=int(myX);
         Yf=int(myY);
         Zf=int(myZ);
         println("i= "+alisado);
         int xl = int(((Xf)*(alisado/5))*5);
         int yl = int(((Yf)*(alisado/5))*5);
         int zl = int(((Zf)*(alisado/5))*5);
         //println("X= " + myX+" XL="+xl);
         
         
        

          /*ENVIAMOS LAS COORDENADAS */
          
           s.write(int(xl) + " " + int(yl) + " " + int(zl) + "\n");
           //println("X= " + xl+" Y= " + yl+" Z= " + zl);
          
// **************FIN******************* //          
          
          
          
          
         if (d < record && !used[i]) {
           record = d;
           index = i;
         } 
       }
       // Update Face object location
       used[index] = true;
       f.update(faces[index]);
    }
    // Add any unused faces
    for (int i = 0; i < faces.length; i++) {
      if (!used[i]) {
        println("+++ New face detected with ID: " + faceCount);
        faceList.add(new Face(faceCount, faces[i].x,faces[i].y,faces[i].width,faces[i].height));
        faceCount++;
      }
    }
    
  // SCENARIO 3 
  // We have more Face objects than face Rectangles found
  } else {
    // All Face objects start out as available
    for (Face f : faceList) {
      f.available = true;
    } 
    // Match Rectangle with a Face object
    for (int i = 0; i < faces.length; i++) {
      // Find face object closest to faces[i] Rectangle
      // set available to false
       float record = 50000;
       int index = -1;
       for (int j = 0; j < faceList.size(); j++) {
         Face f = faceList.get(j);
         float d = dist(faces[i].x,faces[i].y,f.r.x,f.r.y);
         if (d < record && f.available) {
           record = d;
           index = j;
         } 
       }
       // Update Face object location
       Face f = faceList.get(index);
       f.available = false;
       f.update(faces[i]);
    } 
    // Start to kill any left over Face objects
    for (Face f : faceList) {
      if (f.available) {
        f.countDown();
        if (f.dead()) {
          f.delete = true;
        } 
      }
    } 
  }
  
  // Delete any that should be deleted
  for (int i = faceList.size()-1; i >= 0; i--) {
    Face f = faceList.get(i);
    if (f.delete) {
      faceList.remove(i);
    } 
  }
}

void captureEvent(Capture c) {
  c.read();
}