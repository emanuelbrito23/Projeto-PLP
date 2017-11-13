#include <iostream>
#include <string>
#include <stdlib.h>
#include <array>
using namespace std;

string players[4];
array<string, 28> domino_pieces {
    "[0|0]", "[0|1]", "[0|2]", "[0|3]",
    "[0|4]", "[0|5]", "[0|6]", "[1|1]",
    "[1|2]", "[1|3]", "[1|4]", "[1|5]",
    "[1|6]", "[2|2]", "[2|3]", "[2|4]",
    "[2|5]", "[2|6]", "[3|3]", "[3|4]",
    "[3|5]", "[3|6]", "[4|4]", "[4|5]",
    "[4|6]", "[5|5]", "[5|6]", "[6|6]"
};

void startGame();
void openMenu();

int main() 
{
    int value;

    for (int n = 0; n < domino_pieces.size(); n++)
    {
        value = rand() % 28;
        cout << "\nRandom:" + to_string(value);
    }
    
    return 0;
}

void openMenu()
{
    cout << "----------DOMINÓ----------\n";
    cout << "\n";
    cout << "[1] INICIAR JOGO\n";
    cout << "[0] SAIR\n";
    cout << "\n";
    cout << "Digite a opção desejada: ";

    int option;
    cin >> option;

    switch (option)
    {
        case 1:
            cout << "\nJOGO INICIADO.\n";
            startGame();
            break;
        case 0:
            cout << "\nATÉ MAIS.\n";
            break;
    }
}

void startGame()
{
    int totalHumanPlayers = 0;
    while (totalHumanPlayers < 1 || totalHumanPlayers > 4)
    {
        cout << "\nEscolha a quantidade de jogadores na partida [1-4]: ";
        cin >> totalHumanPlayers;
        if (totalHumanPlayers < 1 || totalHumanPlayers > 4)
        {
            cout << "Quantidade de Jogadores inválida. Digite valores de 1-4.\n";
        }
    }

    for (int n = 0; n < totalHumanPlayers; n++)
    {
        cout << "Digite o nome do " + to_string(n+1) + "º jogador: ";
        cin >> players[n];
    }

    for (int n = totalHumanPlayers, aux = 1; n < 4; n++, aux++)
    {
        players[n] = "Jogador " + to_string(aux);
    }
}