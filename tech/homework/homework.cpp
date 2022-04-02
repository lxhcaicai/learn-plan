#include <string>
#include <iostream>

using namespace std;

int main() {
    string str;
    cin >> str;
    // .size() 获取长度
    // for(int i = 0; i < str.size(); i ++) {
    //     str[i] = str[i] + 1;
    // }

    for(char c: str) {
        c = c + 1;
    }

    cout << str << endl;
    return 0;
}