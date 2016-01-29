// SWIG interface file to define rpi_ws281x library python wrapper.
// Author: Tony DiCola (tony@tonydicola.com), Jeremy Garff (jer@jers.net)

// Define module name rpi_ws281x.  This will actually be imported under
// the name _rpi_ws281x following the SWIG & Python conventions.
%module rpi_ws281x

// Include standard SWIG types & array support for support of uint32_t
// parameters and arrays.
%include "stdint.i"
%include "carrays.i"

// Declare functions which will be exported as anything in the ws2811.h header.
%{
#include "../ws2811.h"
%}

// Process ws2811.h header and export all included functions.
%include "../ws2811.h"

//To pass a list as an array
%typemap(in) (int lednumber, uint32_t *colors) {
  int i;
  if (!PyList_Check($input)) {
    PyErr_SetString(PyExc_ValueError, "Expecting a list");
    return NULL;
  }
  $1 = PyList_Size($input);
  $2 = (uint32_t *) malloc(($1)*sizeof(uint32_t));
  for (i = 0; i < $1; i++) {
    PyObject *s = PyList_GetItem($input,i);
    if (!PyInt_Check(s)) {
        free($2);
        PyErr_SetString(PyExc_ValueError, "List items must be integers");
        return NULL;
    }
    $2[i] = (uint32_t) PyInt_AsLong(s);
  }
}

%typemap(freearg) (int lednumber, uint32_t *colors) {
   if ($2) free($2);
}


%inline %{
    int ws2811_leds_set(ws2811_channel_t *channel, int lednumber, uint32_t* colors)
    {
        if (lednumber > channel->count)
        {
            return -1;
        }
        uint32_t i;
        uint32_t lednum = (uint32_t) lednumber;
        for (i=0; i<lednum; i++){
            channel->leds[i] = colors[i];
        }

        return 0;
    }

%}

%inline %{
    uint32_t ws2811_led_get(ws2811_channel_t *channel, int lednum)
    {
        if (lednum >= channel->count)
        {
            return -1;
        }

        return channel->leds[lednum];
    }

    int ws2811_led_set(ws2811_channel_t *channel, int lednum, uint32_t color)
    {
        if (lednum >= channel->count)
        {
            return -1;
        }

        channel->leds[lednum] = color;

        return 0;
    }


    ws2811_channel_t *ws2811_channel_get(ws2811_t *ws, int channelnum)
    {
        return &ws->channel[channelnum];
    }
%}
