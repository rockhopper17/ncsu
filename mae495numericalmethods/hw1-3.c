/* Andrew Navratil */
/* MAE 495 Numerical Methods */
/* HW 1-3,1-4 Due 9/4/19 */

#include <stdio.h>
#include <float.h>

int main()
{
	/* HW 1-4 */

	/* max and min floats are stored in float.h header file */
	printf("max float = %g\n", FLT_MAX);
	printf("min float = %g\n", FLT_MIN);

	/* find significant decimal digits */
	printf("float significant digits = %d\n", FLT_DIG);

	/* find machine epsilon value (unit round) */
	printf("float epsilon = %g\n\n", FLT_EPSILON);

	/* HW 1-5 (optional) */
	
	/* max and min doubles are stored in float.h header file */
	printf("max double = %g\n", DBL_MAX);
	printf("min double = %g\n", DBL_MIN);

	/* find significant decimal digits */
	printf("double significant digits = %d\n", DBL_DIG);

	/* find machine epsilon value (unit round) */
	printf("double epsilon = %g\n", DBL_EPSILON);
}
