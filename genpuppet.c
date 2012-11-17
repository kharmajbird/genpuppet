#include <stdio.h>
#include <string.h>

FILE *fp;
char top_requires[30][7];
char all_requires[30][7];
char top_includes[30][7];
char all_includes[30][7];
int nullmailer=0;
int setsemaphore=0;


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
    char classname[20];

    printf("Name of manifest: ", manifest);
    scanf("%s", manifest);


    if ((fp = fopen (manifest, "w")) == NULL) {
        printf ("Error writing to %s... exiting\n", manifest);
        return (1);

    }
    printf("Opening %s for writing...\n\n", manifest);
    printf("Name of class: ");
    scanf("%s", classname);
    printf("Require? ");
   
    fclose(fp);
}
