#include <iostream>
#include <string>
#include <stdlib.h>
#include <vector>
using namespace std;

struct DominoPiece {
    int left_number;
    int rigth_number;
};

struct Player {
    string name;
    vector<DominoPiece> dominoPieces;
};

const int TOTAL_PLAYERS = 4;
Player players[TOTAL_PLAYERS];
vector<DominoPiece> dominoPieces(0);

void startGame();
void openMenu();
void createDominoPieces();
void deletePiece(int index);
void randomDominoPieces();

int main() {
    openMenu();
    
    return 0;
}

void openMenu() {
    cout << "----------DOMINÓ----------\n";
    cout << "\n";
    cout << "[1] INICIAR JOGO\n";
    cout << "[0] SAIR\n";
    cout << "\n";
    cout << "Digite a opção desejada: ";

    int option;
    cin >> option;

    switch (option) {
        case 1:
            cout << "\nJOGO INICIADO.\n";
            startGame();
            break;
        case 0:
            cout << "\nATÉ MAIS.\n";
            break;
    }
}

void startGame() {
    createDominoPieces();

    int totalHumanPlayers = 0;
    while (totalHumanPlayers < 1 || totalHumanPlayers > 4) {
        cout << "\nEscolha a quantidade de jogadores na partida [1-4]: ";
        cin >> totalHumanPlayers;
        if (totalHumanPlayers < 1 || totalHumanPlayers > 4) {
            cout << "Quantidade de Jogadores inválida. Digite valores de 1-4.\n";
        }
    }

    for (int n = 0; n < totalHumanPlayers; n++) {
        cout << "Digite o nome do " + to_string(n+1) + "º jogador: ";
        cin >> players[n].name;
    }

    for (int n = totalHumanPlayers, aux = 1; n < 4; n++, aux++) {
        players[n].name = "Jogador " + to_string(aux);
    }

    randomDominoPieces();

    for (int n_players = 0; n_players < TOTAL_PLAYERS; n_players++) {
        cout << players[n_players].name + "\n";
        for (int n_dominoPieces = 0; n_dominoPieces < players[n_players].dominoPieces.size(); n_dominoPieces++) {
            cout << "[" + to_string(players[n_players].dominoPieces[n_dominoPieces].left_number) + "|" + to_string(players[n_players].dominoPieces[n_dominoPieces].rigth_number) + "] ";
        }
        cout << "\n";
    }
}

void createDominoPieces() {
    dominoPieces.push_back({left_number: 0, rigth_number: 0});
    dominoPieces.push_back({left_number: 0, rigth_number: 1});
    dominoPieces.push_back({left_number: 0, rigth_number: 2});
    dominoPieces.push_back({left_number: 0, rigth_number: 3});
    dominoPieces.push_back({left_number: 0, rigth_number: 4});
    dominoPieces.push_back({left_number: 0, rigth_number: 5});
    dominoPieces.push_back({left_number: 0, rigth_number: 6});
    dominoPieces.push_back({left_number: 1, rigth_number: 1});
    dominoPieces.push_back({left_number: 1, rigth_number: 2});
    dominoPieces.push_back({left_number: 1, rigth_number: 3});
    dominoPieces.push_back({left_number: 1, rigth_number: 4});
    dominoPieces.push_back({left_number: 1, rigth_number: 5});
    dominoPieces.push_back({left_number: 1, rigth_number: 6});
    dominoPieces.push_back({left_number: 2, rigth_number: 2});
    dominoPieces.push_back({left_number: 2, rigth_number: 3});
    dominoPieces.push_back({left_number: 2, rigth_number: 4});
    dominoPieces.push_back({left_number: 2, rigth_number: 5});
    dominoPieces.push_back({left_number: 2, rigth_number: 6});
    dominoPieces.push_back({left_number: 3, rigth_number: 3});
    dominoPieces.push_back({left_number: 3, rigth_number: 4});
    dominoPieces.push_back({left_number: 3, rigth_number: 5});
    dominoPieces.push_back({left_number: 3, rigth_number: 6});
    dominoPieces.push_back({left_number: 4, rigth_number: 4});
    dominoPieces.push_back({left_number: 4, rigth_number: 5});
    dominoPieces.push_back({left_number: 4, rigth_number: 6});
    dominoPieces.push_back({left_number: 5, rigth_number: 5});
    dominoPieces.push_back({left_number: 5, rigth_number: 6});
    dominoPieces.push_back({left_number: 6, rigth_number: 6});
}

void deletePiece(int index) {
    for (int n = index; n < (dominoPieces.size() - 1); n++) {
        dominoPieces[n] = dominoPieces[n + 1];
    }

    dominoPieces.pop_back();
}

void randomDominoPieces() {
    int value;
    int size = dominoPieces.size();

    for (int n = 0; n < size; n++) {
        value = rand() % dominoPieces.size();
        players[dominoPieces.size() % TOTAL_PLAYERS].dominoPieces.push_back(dominoPieces[value]);
        deletePiece(value);
    }
}