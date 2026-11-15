/* Generic regression smoke check, not a game-specific playthrough.
 * Build against upstream Atari800 7.2.1 --target=libatari800 --disable-sound.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "libatari800.h"
extern void POKEY_SetRandomCounter(unsigned int value);
extern int Colours_table[256];
int main(int argc,char **argv){
 if(argc!=5)return 2;
 char *machine=getenv("ATARI800_TEST_MACHINE");if(!machine)machine="-xl";
 char *args[]={"atari800","-config",argv[3],"-no-autosave-config",machine,"-xl-rev","altirra","-nobasic",strcmp(argv[4],"pal")==0?"-pal":"-ntsc","-run",argv[1],NULL};
 if(!libatari800_init(11,args))return 3;
 POKEY_SetRandomCounter(0);
 unsigned long long digest=1469598103934665603ULL;
 unsigned int first=0,last=0,changes=0;int errors=0,first_error=-1,frames=0;
 input_template_t in;
 for(int frame=0;frame<1200;frame++){
  libatari800_clear_input_array(&in);
  if(frame>=400&&frame<405)in.start=1;
  if(frame>=500&&frame<505)in.trig0=1;
  if(frame>=600&&frame<720)in.joy0=8;
  if(frame>=720&&frame<840)in.joy0=2;
  if(frame>=840&&frame<960)in.joy0=4;
  if(frame>=960&&frame<1080)in.joy0=1;
  int ok=libatari800_next_frame(&in);frames++;
  if(!ok && !(frame<120&&libatari800_error_code==LIBATARI800_DLIST_ERROR)){
   errors++;if(first_error<0)first_error=frame;
   if(libatari800_error_code!=LIBATARI800_DLIST_ERROR)break;
  }
  unsigned char *screen=libatari800_get_screen_ptr();unsigned int hash=2166136261u;
  for(int k=0;k<384*240;k++)hash=(hash^screen[k])*16777619u;
  digest=(digest^hash)*1099511628211ULL;
  if(frame==400)first=hash;
  if(frame>400&&last!=hash)changes++;
  last=hash;
 }
 char name[4096];snprintf(name,sizeof name,"%s.ppm",argv[2]);FILE *f=fopen(name,"wb");if(!f)return 4;
 fprintf(f,"P6\n384 240\n255\n");unsigned char *screen=libatari800_get_screen_ptr();
 for(int k=0;k<384*240;k++){int c=Colours_table[screen[k]];fputc(c>>16,f);fputc(c>>8,f);fputc(c,f);}fclose(f);
 snprintf(name,sizeof name,"%s.json",argv[2]);f=fopen(name,"w");if(!f)return 4;
 fprintf(f,"{\"frames\":%d,\"errors_after_boot\":%d,\"first_error_frame\":%d,\"frame_digest\":\"%016llx\",\"screen_changes_after_400\":%u,\"screen_400\":%u,\"screen_last\":%u}\n",frames,errors,first_error,digest,changes,first,last);fclose(f);
 libatari800_exit();return 0;
}
