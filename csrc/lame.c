#include "lame/lame.h"
#include <stdio.h>
#include <stdlib.h>

#define BUFF_SIZE 8192

void lame_decode(char *filename) {
  // decode mp3 file
  printf("Decoding %s\n", filename);

  FILE *mp3 = fopen(filename, "rb");
  FILE *wav = fopen("converted.wav", "wb");

  if (mp3 == NULL || wav == NULL) {
    printf("Error opening files\n");
    return;
  }

  hip_t hip = hip_decode_init();

  if (hip == NULL) {
    printf("Error initializing decoder\n");
    return;
  }

  unsigned char mp3_buffer[BUFF_SIZE];
  short int pcm_l[BUFF_SIZE], pcm_r[BUFF_SIZE];

  size_t read;
  while ((read = fread(mp3_buffer, 1, sizeof(mp3_buffer), mp3)) > 0) {
    int samples = hip_decode(hip, mp3_buffer, read, pcm_l, pcm_r);
    if (samples > 0) {
      fwrite(pcm_l, 2, samples, wav);
      fwrite(pcm_r, 2, samples, wav);
    } else if (samples < 0) {
      printf("Error decoding mp3\n");
      break;
    }
  }

  hip_decode_exit(hip);
  fclose(mp3);
  fclose(wav);
}
