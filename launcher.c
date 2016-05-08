#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{

  // Usage info
  if(argc < 3)
  {
    printf("\n%s SPACE_SEPARATED_LIST_OF_GIDS FULL_PATH_TO_SHELL_SCRIPT\n\n", argv[0]);
    exit(0);
  }

  // Parse arguments into arrays of group ids
  int i = 1;
  gid_t * gids;
  gids = (gid_t *) malloc((argc-2)*sizeof(gid_t));
  for(; i < argc - 1; i++)
  {
    int gid = atoi(argv[i]);
    gids[i-1] = (gid_t) gid;
  }

  // Lower process privileges
  setgroups(argc-2, gids);
  setgid(gids[0]);
  setuid(gids[0]);

  // Launch process
  int entry = 1;
  char cmd[1024];
  int BUF_SIZE = 1024;
  char line[BUF_SIZE];
  sprintf(cmd, "/system/bin/sh %s", argv[argc-1]);
  FILE* output = popen(cmd, "r");
  while( fgets(line, BUF_SIZE-1, output))
  {
    printf("%5d: %s", entry++, line);
  }
}
