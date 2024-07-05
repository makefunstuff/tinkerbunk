
#include "cbrr.h"
#include <alsa/asoundlib.h>
#include <mpg123.h>
#include <stdio.h>
#include <stdlib.h>

#define PCM_DEVICE "default"

void brr_c(char *filename) {
  // Initialize the MPG123 library
  mpg123_init();
  mpg123_handle *mh = mpg123_new(NULL, NULL);
  if (mpg123_open(mh, filename) != MPG123_OK) {
    fprintf(stderr, "Error opening %s: %s\n", filename, mpg123_strerror(mh));
    return;
  }

  // Retrieve the format of the MP3 file
  long rate;
  int channels, encoding;
  if (mpg123_getformat(mh, &rate, &channels, &encoding) != MPG123_OK) {
    fprintf(stderr, "Error getting format: %s\n", mpg123_strerror(mh));
    return;
  }

  // Set the output format
  snd_pcm_t *pcm_handle;
  snd_pcm_hw_params_t *params;
  int pcm, dir;
  snd_pcm_uframes_t frames;
  char *buffer;
  int size;

  // Open the PCM device
  if (pcm = snd_pcm_open(&pcm_handle, PCM_DEVICE, SND_PCM_STREAM_PLAYBACK, 0) <
            0) {
    fprintf(stderr, "Error opening PCM device %s: %s\n", PCM_DEVICE,
            snd_strerror(pcm));
    return;
  }

  // Allocate hardware parameters object
  snd_pcm_hw_params_alloca(&params);
  snd_pcm_hw_params_any(pcm_handle, params);

  // Set the desired hardware parameters
  snd_pcm_hw_params_set_access(pcm_handle, params,
                               SND_PCM_ACCESS_RW_INTERLEAVED);
  snd_pcm_hw_params_set_format(pcm_handle, params, SND_PCM_FORMAT_S16_LE);
  snd_pcm_hw_params_set_channels(pcm_handle, params, channels);
  snd_pcm_hw_params_set_rate_near(pcm_handle, params, &rate, &dir);

  // Write the parameters to the driver
  if (pcm = snd_pcm_hw_params(pcm_handle, params) < 0) {
    fprintf(stderr, "Error setting HW params: %s\n", snd_strerror(pcm));
    return;
  }

  // Use a buffer large enough to hold one period
  snd_pcm_hw_params_get_period_size(params, &frames, &dir);
  size = frames * channels * 2; // 2 bytes/sample, 2 channels
  buffer = (char *)malloc(size);

  // Decode and play the MP3 file
  size_t buffer_size = mpg123_outblock(mh);
  unsigned char *mpg123_buffer =
      (unsigned char *)malloc(buffer_size * sizeof(unsigned char));
  size_t done;
  int err;

  while ((err = mpg123_read(mh, mpg123_buffer, buffer_size, &done)) ==
         MPG123_OK) {
    snd_pcm_writei(pcm_handle, mpg123_buffer, done / 4);
  }

  // Clean up
  free(buffer);
  free(mpg123_buffer);
  snd_pcm_drain(pcm_handle);
  snd_pcm_close(pcm_handle);
  mpg123_close(mh);
  mpg123_delete(mh);
  mpg123_exit();

  return;
}
