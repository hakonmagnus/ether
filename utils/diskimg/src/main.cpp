#include <cstring>
#include <iostream>

void print_help() {}

int main(int argc, char** argv) {
    // Parse command line arguments
    if (argc > 1) {
        for (int i = 1; i < argc; ++i) {
            if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0) {
                print_help();
                return 0;
            } else {
                std::cout << "Error: Invalid option " << argv[i] << std::endl;
                return 1;
            }
        }
    }

    return 0;
}
