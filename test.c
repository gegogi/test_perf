#include <stdio.h>

int fb()
{
	volatile long x = 0;
	for (long i = 0; i < 10000; i++) x += i;
	printf("b\n");
}

int fa()
{
	volatile long x = 0;
	for (long i = 0; i < 10000; i++) x += i;
	printf("a\n");
	fb();
}

int main()
{
	while (1) {
		fa();
	}
}
