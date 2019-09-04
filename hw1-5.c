/* Andrew Navratil */
/* MAE 495 Numerical Methods */
/* HW 1-5 Due 9/4/19 */

#include <stdio.h>
#include <float.h>

int main()
{
	float x = 1.17;
	printf("x = %g\n", x);

	while (x < FLT_MAX)
	{
		x *= x;
		printf("x = %g\n", x);
	}
}
