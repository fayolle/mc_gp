#include <math.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>

#define RES 256
#define PI 3.14159f
#define NUM_PATHS 256

// Distance to a unit length square
float distToSquare(float px, float py) {
  float d1 = fabsf(px - 1.f);
  float d2 = fabsf(px);
  float d3 = fabsf(py - 1.f);
  float d4 = fabsf(py);
  return fminf(d1, fminf(d2, fminf(d3, d4)));
}

float distFunc(float px, float py) {
  return distToSquare(px, py); 
}

// Example of harmonic function 
float g(float px, float py) {
  return px*px - py*py; 
}

float boundaryFunc(float px, float py) {
  return g(px, py);
}

float randUnit() {
  int u = rand();
  return (float)u / (float)RAND_MAX;
}

void randCircle(float* px, float* py) {
  float t = 2.0f*PI*randUnit();
  *px = cosf(t);
  *py = sinf(t);
}

// Assume the boundary conditions boundaryFunc()
// and the distance to boundary distFunc()
float solveHarmonic(float p0x, float p0y, int num_paths) {
  // numerical tolerance
  float neps = 1e-3f;
  int max_steps = 128;
  float s = 0.f;

  float px, py;
  for (int i=0; i<num_paths; ++i) {
    px = p0x;
    py = p0y;
    int steps = 0;
    for (int j=0; j<max_steps; ++j) {
      // ball radius
      float r = distFunc(px, py);
      r = fabsf(r);
      if (r < neps) break;
      float ptx, pty;
      randCircle(&ptx, &pty);
      px = px + r*ptx;
      py = py + r*pty;
      steps = steps + 1;
    }
    s = s + boundaryFunc(px, py);
  }
  s = s / num_paths;

  return s;
}

void writeImage(char* fn, float* imagedata, int w, int h) {
  FILE* file = fopen(fn, "w+");
  float maxvalue = 255.0;
  if (!file) return;
  fprintf(file, "P2\n%u %u\n%u\n", w, h, (uint32_t)maxvalue);
  for (int row = 0; row < h; ++row) {
    for (int column = 0; column < w; ++column) {
      float pixel_value = (maxvalue + 1.0f) * imagedata[w * row + column];
      if(pixel_value > maxvalue) pixel_value = maxvalue;
      if(pixel_value < 0.0f) pixel_value = 0.0f;
      fprintf(file, "%u ", (uint32_t)(pixel_value));
    }
    fprintf(file, "\n");
  }
  fclose(file);
}

int main(int argc, char** argv) {
  float imagedata[RES * RES];
  for (int j = 0; j < RES; ++j) {
    for (int i = 0; i < RES; ++i) {
      float sx = 0.0f + ((float)i + 0.5f) / (float)RES;
      float sy = 1.0f - ((float)j + 0.5f) / (float)RES;
      *(imagedata + RES * j + i) = solveHarmonic(sx, sy, NUM_PATHS);
    }
  }
  writeImage("test.pgm", imagedata, RES, RES);
}
