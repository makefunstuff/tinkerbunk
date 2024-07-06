#include "lame/lame.h"
#include <stdio.h>
#include <stdlib.h>

#define BUFF_SIZE 8192

void write_wav_header(FILE *wav, int sample_rate, int num_samples) {
  int byte_rate = sample_rate * 2 * 2; // sample_rate * num_channels * bytes_per_sample
  int data_size = num_samples * 2 * 2; // num_samples * num_channels * bytes_per_sample

  // RIFF header
  fwrite("RIFF", 1, 4, wav);
  int chunk_size = 36 + data_size;
  fwrite(&chunk_size, 4, 1, wav);
  fwrite("WAVE", 1, 4, wav);

  // fmt subchunk
  fwrite("fmt ", 1, 4, wav);
  int subchunk1_size = 16;
  fwrite(&subchunk1_size, 4, 1, wav);
  short audio_format = 1;
  fwrite(&audio_format, 2, 1, wav);
  short num_channels = 2;
  fwrite(&num_channels, 2, 1, wav);
  fwrite(&sample_rate, 4, 1, wav);
  fwrite(&byte_rate, 4, 1, wav);
  short block_align = 4; // num_channels * bytes_per_sample
  fwrite(&block_align, 2, 1, wav);
  short bits_per_sample = 16;
  fwrite(&bits_per_sample, 2, 1, wav);

  // data subchunk
  fwrite("data", 1, 4, wav);
  fwrite(&data_size, 4, 1, wav);
}

void lame_decode(char *filename) {
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
  int sample_rate = 44100; // Default sample rate, might want to adjust this

  write_wav_header(wav, sample_rate, 0); // Placeholder for num_samples

  size_t read;
  int total_samples = 0;
  while ((read = fread(mp3_buffer, 1, sizeof(mp3_buffer), mp3)) > 0) {
    int samples = hip_decode(hip, mp3_buffer, read, pcm_l, pcm_r);
    if (samples > 0) {
      total_samples += samples;
      for (int i = 0; i < samples; i++) {
        fwrite(&pcm_l[i], 2, 1, wav);
        fwrite(&pcm_r[i], 2, 1, wav);
      }
    } else if (samples < 0) {
      printf("Error decoding mp3\n");
      break;
    }
  }

  hip_decode_exit(hip);
  fclose(mp3);

  // Update WAV header with actual number of samples
  fseek(wav, 0, SEEK_SET);
  write_wav_header(wav, sample_rate, total_samples);

  fclose(wav);
}
