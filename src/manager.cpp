#include <stdio.h>
#include "manager.h"

void * managerserver (void *ptr)
{
fprintf(stdout, "Test in thread\n");
while (true) {}
}
