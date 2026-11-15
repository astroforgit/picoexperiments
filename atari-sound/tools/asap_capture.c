/* Compile beside upstream asap.c/asap.h, or use -I with their directory.
   Exposes a PAL frame boundary for arranging original register envelopes. */
#include "asap.c"
/* The generated ASAP C source leaves some accumulator fields uninitialized
   (notably sumDACOutputs). Zero the allocation before its constructor so WAV
   output does not depend on the previous contents of malloc's heap blocks. */
ASAP *Pico_New(void) {
    ASAP *self = (ASAP *)calloc(1, sizeof(ASAP));
    if (self != NULL) ASAP_Construct(self);
    return self;
}
void Pico_Frame(ASAP *self, unsigned char *out) {
    ASAP_DoFrame(self);
    for (int c = 0; c < 4; ++c) {
        out[c*2] = self->pokeys.basePokey.channels[c].audf;
        out[c*2+1] = self->pokeys.basePokey.channels[c].audc;
    }
    out[8] = self->pokeys.basePokey.audctl;
    out[9] = self->pokeys.basePokey.skctl;
}
