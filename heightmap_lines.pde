import processing.svg.*;
import processing.dxf.*;

boolean drawMesh = false;
boolean drawTerrain = true;

int scl = 5;
int spacer = 1;
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
  smooth(4);

  heightmap = loadImage(heightmap_name);
  heightmap.filter(GRAY);
  calc_terrain();
}

int index(int x, int y, PImage image) {
  return x + y * image.width;
}

void calc_terrain() {
  cols = heightmap.height / scl;
  rows = heightmap.width / scl;
  terrain = new float[rows][cols];

  for(int y = 0; y < cols; y++) {
    for(int x = 0; x < rows; x++) {
      color pix = heightmap.pixels[index(x*scl, y*scl, heightmap)];
      float oldR = red(pix);
      terrain[x][y] = map(oldR, 0, 255, -50, 50);
    }
  }
}

void draw(){
  if(recordSvg) {
    String filename = "output_" + split(heightmap_name, '.')[0] + "_" + year() + month() + day() + "_" + hour() + minute() + "_####.svg";
    beginRaw(SVG, filename);
  }
  if(recordDxf) {
    String filename = "output_" + split(heightmap_name, '.')[0] + "_" + year() + month() + day() + "_" + hour() + minute() + "_####.dxf";
    beginRaw(DXF, filename);
  }

  if (rotating) {
    rotation+=rotation_step;
  }

  background(227);
  stroke(0);
  noFill();

  translate(width/2, height/2);
  rotateX(PI/rotate_x);
  rotateZ(radians(rotation)); 
  translate(-heightmap.width/2, -heightmap.height/2);
  translate(offset_x, offset_y);

  if (drawMesh) {
    for(int y = 0; y < cols-1; y++) {
      beginShape(TRIANGLE_STRIP);
      for(int x = 0; x < rows; x++) {
        vertex(x*scl, y*scl, terrain[x][y]);
        vertex(x*scl, (y+1)*scl, terrain[x][y+1]);
      }
      endShape();
    }
  }

  strokeWeight(stroke);
  if (drawTerrain) {
    if(flip) {
      stroke(62, 50, 47);
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
      stroke(162, 150, 147);
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
    recordSvg = false;
    recordDxf = false;
  }
}


void keyPressed()
{
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
  if(key == '1') {
    recordSvg = true;
  }
  if(key == '2') {
    recordDxf = true;
  }
  if(key == 't') {
    rotation = 0;
  }
  if(key == 'e') {
    rotation += 90;
  }
}