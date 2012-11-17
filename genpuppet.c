#include <stdio.h>

FILE *fp;

extern void begin_package ();
extern void end_package ();
extern void begin_file ();
extern void end_file ();
extern void begin_service ();
extern void end_service ();
extern void begin_exec ();
extern void end_exec ();

main (int argc, char ** argv) {
   char manifest[20];

   printf ("Manifest name: [%s] ", manifest);
   scanf ("%s", manifest);

   if (manifest == "") manifest = "init.pp";

   if ((fp = fopen (manifest, "w")) == NULL) {
       printf ("Error writing to %s... exiting\n", manifest);
       exit (1);
   }

   fclose(fp);
}
