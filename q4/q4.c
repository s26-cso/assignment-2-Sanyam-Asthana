#include<dlfcn.h>
#include<stdio.h>

int main() {
    char op_code[6];
    scanf("%5s", op_code);

    int arg1, arg2 = 0;
    scanf("%d", &arg1);
    scanf("%d", &arg2);

    char lib_name[16];
    snprintf(lib_name, sizeof(lib_name), "lib%s.so", op_code);

    void *lib_ptr = dlopen(lib_name, RTLD_LAZY);

    if(lib_ptr == NULL) {
        fprintf(stderr, "Cannot load the specified library: %s\n", lib_name);
        return 1;
    }

    int (*func)(int, int) = dlsym(lib_ptr, op_code);
    
    if(func == NULL) {
        fprintf(stderr, "Cannot find the specified opcode: %s\n", op_code);
        dlclose(lib_ptr);
        return 1;
    }

    printf("%d\n", func(arg1, arg2)); 
    dlclose(lib_ptr);

    return 0;
}
