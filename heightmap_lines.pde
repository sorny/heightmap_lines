import processing.svg.*;
import processing.dxf.*;

boolean drawMesh = false;
boolean drawMeshStroke = true;
boolean drawFill = false;
boolean drawTerrain = true;

int scl = 5;
int spacer = 1;
int shiftLines = 0;
int shiftPeaks = 0;
int cols;
int rows;
boolean flip = true;

String heightmap_name = "Heightmap.png";
PImage heightmap;
float[][] terrain;

float rotation = 0;
float rotation_step = 0.4;
boolean rotating = false;

int offset_x = 0;
int offset_y = 0;
float rotate_x = 3.5;
int stroke = 1;

boolean recordSvg = false;
boolean recordDxf = false;

void setup(){
  fullScreen(P3D);
  hint(ENABLE_DEPTH_SORT);
  smooth(4);

  heightmap = loadImage(heightmap_name);
  heightmap.filter(GRAY);
  calc_terrain();
}

int index(int x, int y, PImage image) {
  if (x > image.width) {
    x = image.width;
  }
  if (y > image.height) {
    y = image.height;
  }
  int index = x + y * image.width;
  if (index >= image.width*image.height){
    return image.width*image.height-1;
  }
  else {
    return index;
  }
}

String getOutputFilename(String filetype) {
  return "output/output_" + split(heightmap_name, '.')[0] + "_" + year() + month() + day() + "_" + hour() + minute() + "." + filetype;
}

void calc_terrain() {
  cols = heightmap.height / scl;
  rows = heightmap.width / scl;
  terrain = new float[rows][cols];

  for(int y = 0; y < cols; y++) {
    for(int x = 0; x < rows; x++) {
      color pix = heightmap.pixels[index(x*scl+shiftPeaks, y*scl+shiftLines, heightmap)];
      float oldR = red(pix);
      terrain[x][y] = map(oldR, 0, 255, -50, 50);
    }
  }
}

void draw(){
  if(recordSvg) {
    String filename = getOutputFilename("svg");
    println("Recording svg to: "+filename);
    beginRaw(SVG, filename);
  }
  if(recordDxf) {
    String filename = getOutputFilename("dxf");
    println("Recording dxf to: "+filename);
    beginRaw(DXF, filename);
  }

  if (rotating) {
    rotation+=rotation_step;
  }

  background(255);
  stroke(0);
  if (drawFill) {
    fill(255, 255, 255);
  } else {
    noFill();
  }

  translate(width/2, height/2);
  rotateX(PI/rotate_x);
  rotateZ(radians(rotation)); 
  translate(-heightmap.width/2, -heightmap.height/2);
  translate(offset_x, offset_y);

  if (drawMesh) {
    if (drawMeshStroke) {
      stroke(0);
    } else {
      noStroke();
    }
    for(int y = 0; y < cols-1; y+=spacer) {
      beginShape(TRIANGLE_STRIP);
      for(int x = 0; x < rows-1; x++) {
        vertex(x*scl, y*scl, terrain[x][y]);
        vertex(x*scl, (y+1)*scl, terrain[x][y+1]);
      }
      endShape();
    }
  }

  strokeWeight(stroke);
  if (drawTerrain) {
    if(flip) {
      stroke(0);
      for(int y = 0; y < cols; y+=spacer) {
        beginShape(LINES);
        for(int x = 0; x < rows-1; x++) {
          vertex(x*scl, y*scl, terrain[x][y]);
          vertex((x+1)*scl, y*scl, terrain[x+1][y]);
        }
        endShape();
      }
    }

    if(!flip) {
      stroke(0);
      float t = map(mouseX, 0, width, -5, 5);
      curveTightness(t);
      for(int y = 0; y < cols; y+=spacer) {
        beginShape();
        for(int x = 0; x < rows-1; x++) {
          curveVertex(x*scl, y*scl, terrain[x][y]);
        }
        endShape();
      }
    }
  }

  if(recordSvg || recordDxf) {
    endRaw();
    println("Done recording...");
    recordSvg = false;
    recordDxf = false;
  }
}


void keyPressed() {
  if(key == 'q') {
    rotating = !rotating;
  }
  if(key == 'w') {
    offset_y = offset_y - 10;
  }
  if(key == 'a') {
    offset_x = offset_x - 10;
  }
  if(key == 's') {
    offset_y = offset_y + 10;
  }
  if(key == 'd') {
    offset_x = offset_x + 10;
  }
  if(key == 'y') {
    rotate_x = rotate_x + 0.05;
  }
  if(key == 'x') {
    rotate_x = rotate_x - 0.05;
  }
  if(key == 'k') {
    scl++;
    calc_terrain();
  }
  if(key == 'j') {
    spacer++;
  }
  if(key == 'i') {
    if (scl>1) {
      scl--;
      calc_terrain();
    }
  }
  if(key == 'l') {
    if (spacer>1) {
      spacer--;
    }
  }
  if(key == 'm') {
    drawMesh = !drawMesh;
  }
  if(key == 'b') {
    stroke++;
  }
  if(key == 'n') {
    if (stroke>1) {
      stroke--;
    }
  }
  if(key == 'f') {
    flip = !flip;
  }
  if(key == 'p') {
    drawFill = !drawFill;
  }
  if(key == 'o') {
    drawMeshStroke = !drawMeshStroke;
  }
  if(key == '1') {
    recordSvg = true;
  }
  if(key == '2') {
    recordDxf = true;
  }
  if(key == '3') {
    String filename = getOutputFilename("tif");
    println("Recording tif to: "+filename);
    save(filename);
    println("Done recording...");
  }
  if(key == '4') {
    String filename = getOutputFilename("png");
    println("Recording png to: "+filename);
    save(filename);
    println("Done recording...");
  }
  if(key == 't') {
    rotation = 0;
  }
  if(key == 'e') {
    rotation += 90;
  }
  if (key == CODED) {
    if (keyCode == UP) {
      if (shiftLines>=scl-1) {
      } else {
        shiftLines++;
      }
      calc_terrain();
    } else if (keyCode == DOWN) {
      if (shiftLines>0) {
        shiftLines--;
        calc_terrain();
      }
    } else if (keyCode == LEFT) {
      if (shiftPeaks>=scl-1) {
      } else {
        shiftPeaks++;
      }
      calc_terrain();
    } else if (keyCode == RIGHT) {
      if (shiftPeaks>0) {
        shiftPeaks--;
        calc_terrain();
      }
    }
  }
}
