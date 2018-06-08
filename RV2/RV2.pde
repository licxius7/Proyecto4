/*PARTE DE 3D*/
float xmag, ymag = 0,mh,mv, horizontal, vertical, fondo, nH, nV, nF;


/*INICIO PARTE DE CAMARA REAL*/
  // **************Server******************* //
import processing.net.*;
Client c;
String input;
int data[];
float myX, myY, myZ;
  // **************FIN******************* //
import processing.video.*;

Movie video;

void setup() {
  
  // **************Server******************* //
  frameRate(45); // Slow it down a little
  c = new Client(this, "127.0.0.1", 12345); // Replace with your server's IP and port
  // **************FIN******************* //
  //size(2400, 1400, P3D);
  size(480, 320, P3D);
  
 
  video = new Movie(this, "window.mp4");

  video.loop();

  colorMode(RGB, 225); 
  textureMode(NORMAL);
  
}

void movieEvent (Movie m) {
  m.read ();
}


void draw() {

  background(0);

    // **************Captura de coordenadas******************* //
  if (c.available() > 0) {
    input = c.readString();
    try {
      input = input.substring(0, input.indexOf("\n")); // una linea cada vez
      data = int(split(input, ' ')); // corta cuando detecta un espacio y lo mete en un array
      myX = data[0];//capturamos los datos para x
      myY = data[1];//capturamos los datos para y
      myZ = data[2];//capturamos los datos para y
      //println("X= " +myX+" Y= " + myY+" Z= " + myZ+" ");//linea de comprobacion
    }
    catch (Exception e) {//si falla la captura introducimos los datos por defecto
      myX = 132;
      myY = 46;
      myZ = 79;
    }
    println("X= " +myX+" Y= " + myY+" Z= " + myZ+" ");//linea de comprobacion
  }
  // **************MAPEO******************* //
  nH = map(myX, 4, 9671, -26, 349);
  nV = map(myY, 11, 3256, -10, 96);
  nF = map(myZ, 1, 100, 1, 115);
  //println("X= " +nH+" Y= " + nV+" Z= " + nF+" ");//linea de comprobacion
  // **************FIN de Captura de coordenadas******************* //  
  
   // **************CAMARA******************* //
      /* DEFINIREMOS LA CAMARA Y SU MOVIMIENTO*/
  camera(412-nF, -18+nV, -18+nH, 0, -nV, -nH, 0.000, 0.01, 0.000);//Posicionamiento de la camara y de el punto de mira
  frustum(-18, 16, -15, 14, 20, 162);//fustrum
  perspective(1.066, 1.085, 11.52, -0.30);//perspectiva
  // **************FIN de CAMARA******************* //    
  
  // **************LUCES******************* //
 pushMatrix();
  translate(219, -8, 27);
  spotLight(1, 9, 7, 80, 51, 121, 14, -23, -71, PI/2, 2);
  directionalLight(7, 1, 9, -46, 79, 54);
  ambientLight(2, 12, 20, 227, 82, 77);
  popMatrix();
  // **************FIN de LUCES******************* // 
  
  
  // **************LA HABITACION******************* //
  pushMatrix();
  rotateX(0.0);
  rotateY(0.0);
  translate(219, -9, 0);
  stroke(0);
  box(235, 75, 99);
  popMatrix();
  // **************FIN de LA HABITACION******************* // 
 // **************/*EL CUBO*/******************* //
 
  spotLight(1, 10, 126, 80, 40, 61, 14, -15, -28, PI/2, 2);
  pushMatrix();
  rotateX(0.0);
  rotateY(0.0);
  translate(219, -15, 0);
  fill(255);
  noStroke();
  scale(40);
  texture(video);
  popMatrix();
    // **************FIN de EL CUBO ******************* // 

}