#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

static int compar(const void* rhs_ptr, const void* lhs_ptr) {
  int32_t rhs = *(int32_t*)rhs_ptr;
  int32_t lhs = *(int32_t*)lhs_ptr;
  if (rhs > lhs) {
    return 1;
  } else if (rhs < lhs) {
    return -1;
  } else {
    return 0;
  }
}

int main(void) {
  int32_t array[] = {1, 5, -10, 3, 9, 8, 7, 13};

  qsort(array, sizeof(array) / sizeof(array[0]), sizeof(array[0]), compar);

  for (uint32_t i = 0; i < sizeof(array) / sizeof(array[0]); i++) {
    printf("%d\n", array[i]);
  }
  return 0;
}