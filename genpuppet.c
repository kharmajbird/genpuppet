#include <stdio.h>
#include <string.h>

#define RABBIT 7
FILE *fp;
char top_requires[30][RABBIT];
char all_requires[30][RABBIT];
char top_includes[30][RABBIT];
char all_includes[30][RABBIT];
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
    char req[30];
    int i;

    printf("Name of manifest: ", manifest);
    scanf("%s", manifest);


    if ((fp = fopen (manifest, "w")) == NULL) {
        printf ("Error writing to %s... exiting\n", manifest);
        return (1);

    }
    printf("Opening %s for writing...\n\n", manifest);
    printf("Name of class: ");
    scanf("%s", classname);

   
    for (i = 0; i < RABBIT; i++) {
        printf("Require? ");
        fgets(req, 30, stdin);

        if (*req == '\0') break;

        strcpy(top_requires[i], req);
    }

    for (i = 0; i < RABBIT; i++) {
       printf("%s\n", top_requires[i]);
    }
    
    fclose(fp);
}
