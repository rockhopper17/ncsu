#include <stdio.h>
#include <stdlib.h>
#include <step2.h>

void step2(const double* f1, const double* f2, double* out, int numel)
{
	int i;
	for (i=0; i < numel; i++)
	{
		out[i] = f1[i] + f2[i];
	}
}
