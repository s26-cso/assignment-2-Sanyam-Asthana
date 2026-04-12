#include <stdio.h>

struct Node {
    int val;
    struct Node* left;
    struct Node* right;
};

struct Node* make_node(int val);
struct Node* insert(struct Node* root, int val);
struct Node* get(struct Node* root, int val);

int main() {
    struct Node* root = make_node(5);;
    insert(root, 6);
    insert(root, 4);

    struct Node* four = get(root, 4);
    printf("%d\n", four->val);

    return 0;
}
