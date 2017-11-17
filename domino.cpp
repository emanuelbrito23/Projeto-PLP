#include <iostream>
#include <string>
#include <stdlib.h>
#include <vector>
#include <unistd.h>
using namespace std;

struct DominoPiece
{
    int left_number;
    int right_number;
};

struct Player
{
    string name;
    bool isRobot = true;
    vector<DominoPiece> dominoPieces;
};

const int TOTAL_PLAYERS = 4;
const string LEFT_SIDE = "l";
const string RIGHT_SIDE = "r";
Player players[TOTAL_PLAYERS];
vector<DominoPiece> dominoPieces(0);
bool finishGame;
string table[3][19];
int leftTip[2];
int rightTip[2];

void startGame();
void openMenu();
void createDominoPieces();
void deletePiece(int index);
void randomDominoPieces();
void firstMove();
void nextMove(int n_player, int n_passedMoves);
bool humanMove(int n_players);
bool robotMove(int n_players);
void countScores();
void createTable();
void showTable();
string showHand(int n_players);
string toStringPiece(DominoPiece dominoPiece);
string toStringReversePiece(DominoPiece dominoPiece);
bool insertTable(DominoPiece dominoPiece, string tableSide);
void updateRightTip();
void updateLeftTip();
void deleteHandPiece(int n_players, int pieceNumber);
void exitGame();

int main()
{
    openMenu();

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

    while (option < 0 || option > 1)
    {
        cout << "\nOpção inválida.\n";
        cout << "Digite a opção desejada: ";
        cin >> option;
    }
    switch (option)
    {
    case 1:
        cout << "\nJOGO INICIADO.\n";
        startGame();
        break;
    case 0:
        exitGame();
        break;
    }
}

void startGame()
{
    finishGame = false;
    createDominoPieces();
    createTable();

    int totalHumanPlayers = 0;
    while (totalHumanPlayers < 1 || totalHumanPlayers > 4)
    {
        cout << "\nEscolha a quantidade de jogadores na partida [1-4]: ";
        cin >> totalHumanPlayers;
        if (totalHumanPlayers < 1 || totalHumanPlayers > 4)
        {
            cout << "Quantidade de Jogadores inválida. Digite valores de 1-4." << endl;
        }
    }

    for (int n = 0; n < totalHumanPlayers; n++)
    {
        cout << "Digite o nome do " + to_string(n + 1) + "º jogador: ";
        cin >> players[n].name;
        players[n].isRobot = false;
    }

    for (int n = totalHumanPlayers, aux = totalHumanPlayers + 1; n < 4; n++, aux++)
    {
        players[n].name = "Jogador " + to_string(aux);
    }

    randomDominoPieces();

    firstMove();
}

void exitGame()
{
    cout << "\nATÉ MAIS.\n";
}

void firstMove()
{
    //achar carroção de 6
    for (int n_players = 0; n_players < TOTAL_PLAYERS; n_players++)
    {
        for (int n_dominoPieces = 0; n_dominoPieces < players[n_players].dominoPieces.size(); n_dominoPieces++)
        {
            if (players[n_players].dominoPieces[n_dominoPieces].left_number == 6 && players[n_players].dominoPieces[n_dominoPieces].right_number == 6)
            {
                //                cout << players[n_players].name + " está com o carroção\n";
                //                cout << "[" + to_string(players[n_players].dominoPieces[n_dominoPieces].left_number) + "|" + to_string(players[n_players].dominoPieces[n_dominoPieces].rigth_number) + "] ";

                string sideTable;
                insertTable(players[n_players].dominoPieces[n_dominoPieces], sideTable);
                deleteHandPiece(n_players, n_dominoPieces);
                cout << endl;
                showTable();
                nextMove((n_players + 1) % TOTAL_PLAYERS, 0);
            }
        }
    }
}

void nextMove(int n_players, int n_passedMoves)
{
    if (!finishGame && n_passedMoves < 4)
    {
        bool pass;
        if (players[n_players].isRobot)
        {
            pass = robotMove(n_players);
        }
        else
        {
            pass = humanMove(n_players);
        }

        if (pass)
        {
            n_passedMoves++;
        }
        else
        {
            n_passedMoves = 0;
        }

        showTable();

        nextMove((n_players + 1) % TOTAL_PLAYERS, n_passedMoves);
    }
    else
    {
        if (finishGame)
        {
            cout << players[(n_players - 1) % TOTAL_PLAYERS].name << " é o vencedor!!!" << endl;
            n_passedMoves = 0;
            exitGame();
        }
        else if (n_passedMoves == 4)
        {
            cout << "Jogo empatado durante a partida, na contagem dos pontos...";
            n_passedMoves = 0;
            countScores();
        }
    }
}

bool hasPieces(int n_players)
{
    bool result = false;
    int sideRightTip;
    int sideLeftTip;
    for (int n_dominoPieces = 0; n_dominoPieces < players[n_players].dominoPieces.size(); n_dominoPieces++)
    {
        if (rightTip[0] == 2)
        {
            sideRightTip = 1;
        }
        else
        {
            sideRightTip = 3;
        }
        if (leftTip[0] == 0)
        {
            sideLeftTip = 3;
        }
        else
        {
            sideLeftTip = 1;
        }

        if (players[n_players].dominoPieces[n_dominoPieces].right_number == (int)table[rightTip[0]][rightTip[1]][sideRightTip] - 48)
        {
            result = true;
        }
        else if (players[n_players].dominoPieces[n_dominoPieces].left_number == (int)table[rightTip[0]][rightTip[1]][sideRightTip] - 48)
        {
            result = true;
        }
        else if (players[n_players].dominoPieces[n_dominoPieces].right_number == (int)table[leftTip[0]][leftTip[1]][sideLeftTip] - 48)
        {
            result = true;
        }
        else if (players[n_players].dominoPieces[n_dominoPieces].left_number == (int)table[leftTip[0]][leftTip[1]][sideLeftTip] - 48)
        {
            result = true;
        }
    }

    return result;
}

bool humanMove(int n_players)
{
    bool result = false;
    cout << players[n_players].name << ": " << endl;
    cout << showHand(n_players);
    if (!hasPieces(n_players))
    {

        cout << endl << " Você não tem peças, próximo jogador... " << endl;
        sleep(3);
        result = true;
    }
    else
    {
        players[n_players].dominoPieces.size();
        string tableSide; //l or r
        int pieceNumber;

        cout << " \nDigite o número da peça seguido de um espaço e do lado em que quer jogar (l/r): ";

        cin >> pieceNumber >> tableSide;

        if (insertTable(players[n_players].dominoPieces[pieceNumber - 1], tableSide))
        {
            deleteHandPiece(n_players, (pieceNumber - 1));
            if (players[n_players].dominoPieces.size() == 0)
            {
                finishGame = true;
            }
        }
        else
        {
            showTable();
            cout << "Jogada invalida, por favor, jogue novamente." << endl;

            nextMove(n_players, 0);
        }
    }
    return result;
}

void deleteHandPiece(int n_players, int pieceNumber)
{
    for (int i = pieceNumber; i < (players[n_players].dominoPieces.size() - 1); i++)
    {
        players[n_players].dominoPieces[i] = players[n_players].dominoPieces[i + 1];
    }
    players[n_players].dominoPieces.pop_back();
}

string showHand(int n_players)
{
    string handPieces = "";
    string numbers = "";
    for (int n_dominoPieces = 0; n_dominoPieces < players[n_players].dominoPieces.size(); n_dominoPieces++)
    {
        numbers += "  " + to_string(n_dominoPieces + 1) + "   ";
        handPieces += toStringPiece(players[n_players].dominoPieces[n_dominoPieces]);
    }

    string result = handPieces + "\n" + numbers;
    return result;
}

void countScores()
{
    int playersScore[4] = {0, 0, 0, 0};
    int indexWinnerPlayer = -1;
    for (int i = 0; i < TOTAL_PLAYERS; i++){

        for (int j = 0; j < players[i].dominoPieces.size(); j++){
            playersScore[i] += players[i].dominoPieces[j].right_number;
            playersScore[i] += players[i].dominoPieces[j].left_number;
        }
    }

    int minScore = playersScore[0];
    bool tied = false;

    // Impressão primeiro jogador
    cout << endl << players[0].name << ": " << endl;
    cout << showHand(0) << " = " << to_string(playersScore[0]) << " pontos.";

    for (int i = 1; i < TOTAL_PLAYERS; i++)
    {
        cout << endl << players[i].name << ": " << endl;

        cout << showHand(i) << " = " << to_string(playersScore[i]) << " pontos.";
        if (playersScore[i] <= minScore)
        {
            if (playersScore[i] == minScore)
            {
                minScore = playersScore[i];
                tied = true;
            }
            else
            {
                minScore = playersScore[i];
                tied = false;
                indexWinnerPlayer = i;
            }
        }
    }
    sleep(2);
    if (tied)
    {

        cout << endl << "...Jogo terminou! Continou empatado mesmo na contagem dos pontos." << endl;
    }
    else
    {
        string result = "..." + players[indexWinnerPlayer].name + " venceu o jogo com menos pontos.";
        cout << endl << result << endl;
    }

    exitGame();
    exit(0);
}

bool robotMove(int n_players)
{
    int sideRightTip;
    int sideLeftTip;
    if (rightTip[0] == 2)
    {
        sideRightTip = 1;
    }
    else
    {
        sideRightTip = 3;
    }
    if (leftTip[0] == 0)
    {
        sideLeftTip = 3;
    }
    else
    {
        sideLeftTip = 1;
    }
    string tableSide;
    int n_dominoPieceMax = -1;
    bool result = false;
    cout << players[n_players].name << " realizando jogada..." << endl;

    sleep(3);
    if (!hasPieces(n_players))
    {

        cout << "Passou a vez..." << endl;
        sleep(3);
        result = true;
    }
    else
    {
        for (int n_dominoPieces = 0; n_dominoPieces < players[n_players].dominoPieces.size(); n_dominoPieces++)
        {
            if ((players[n_players].dominoPieces[n_dominoPieces].right_number == (int)table[rightTip[0]][rightTip[1]][sideRightTip] - 48) &&
                (players[n_players].dominoPieces[n_dominoPieces].left_number == (int)table[rightTip[0]][rightTip[1]][sideRightTip] - 48))
            {
                if (n_dominoPieceMax == -1)
                {
                    n_dominoPieceMax = n_dominoPieces;
                    tableSide = RIGHT_SIDE;
                }
                else if (players[n_players].dominoPieces[n_dominoPieces].left_number >
                         players[n_players].dominoPieces[n_dominoPieceMax].left_number)
                {
                    n_dominoPieceMax = n_dominoPieces;
                    tableSide = RIGHT_SIDE;
                }
            }
            if ((players[n_players].dominoPieces[n_dominoPieces].right_number == (int)table[leftTip[0]][leftTip[1]][sideLeftTip] - 48) &&
                (players[n_players].dominoPieces[n_dominoPieces].left_number == (int)table[leftTip[0]][leftTip[1]][sideLeftTip] - 48))
            {
                if (n_dominoPieceMax == -1)
                {
                    n_dominoPieceMax = n_dominoPieces;
                    tableSide = LEFT_SIDE;
                }
                else if (players[n_players].dominoPieces[n_dominoPieces].left_number >
                         players[n_players].dominoPieces[n_dominoPieceMax].left_number)
                {
                    n_dominoPieceMax = n_dominoPieces;
                    tableSide = LEFT_SIDE;
                }
            }
        }
        if (n_dominoPieceMax == -1)
        {
            for (int n_dominoPieces = 0; n_dominoPieces < players[n_players].dominoPieces.size(); n_dominoPieces++)
            {
                if (players[n_players].dominoPieces[n_dominoPieces].right_number == (int)table[rightTip[0]][rightTip[1]][sideRightTip] - 48)
                {
                    if (n_dominoPieceMax == -1)
                    {
                        n_dominoPieceMax = n_dominoPieces;
                        tableSide = RIGHT_SIDE;
                    }
                    else if (players[n_players].dominoPieces[n_dominoPieces].right_number > players[n_players].dominoPieces[n_dominoPieceMax].right_number)
                    {
                        n_dominoPieceMax = n_dominoPieces;
                        tableSide = RIGHT_SIDE;
                    }
                }
                else if (players[n_players].dominoPieces[n_dominoPieces].left_number == (int)table[rightTip[0]][rightTip[1]][sideRightTip] - 48)
                {
                    if (n_dominoPieceMax == -1)
                    {
                        n_dominoPieceMax = n_dominoPieces;
                        tableSide = RIGHT_SIDE;
                    }
                    else if (players[n_players].dominoPieces[n_dominoPieces].left_number > players[n_players].dominoPieces[n_dominoPieceMax].left_number)
                    {
                        n_dominoPieceMax = n_dominoPieces;
                        tableSide = RIGHT_SIDE;
                    }
                }
                else if (players[n_players].dominoPieces[n_dominoPieces].right_number == (int)table[leftTip[0]][leftTip[1]][sideLeftTip] - 48)
                {
                    if (n_dominoPieceMax == -1)
                    {
                        n_dominoPieceMax = n_dominoPieces;
                        tableSide = LEFT_SIDE;
                    }
                    else if (players[n_players].dominoPieces[n_dominoPieces].right_number > players[n_players].dominoPieces[n_dominoPieceMax].right_number)
                    {
                        n_dominoPieceMax = n_dominoPieces;
                        tableSide = LEFT_SIDE;
                    }
                }
                else if (players[n_players].dominoPieces[n_dominoPieces].left_number == (int)table[leftTip[0]][leftTip[1]][sideLeftTip] - 48)
                {
                    if (n_dominoPieceMax == -1)
                    {
                        n_dominoPieceMax = n_dominoPieces;
                        tableSide = LEFT_SIDE;
                    }
                    else if (players[n_players].dominoPieces[n_dominoPieces].left_number > players[n_players].dominoPieces[n_dominoPieceMax].left_number)
                    {
                        n_dominoPieceMax = n_dominoPieces;
                        tableSide = LEFT_SIDE;
                    }
                }
            }
        }
        if (insertTable(players[n_players].dominoPieces[n_dominoPieceMax], tableSide))
        {
            deleteHandPiece(n_players, (n_dominoPieceMax));
            if (players[n_players].dominoPieces.size() == 0)
            {
                finishGame = true;
            }
        }
    }
    return result;
}

void createTable()
{
    int row = end(table) - begin(table);
    for (int i = 0; i < row; i++)
    {

        int col = end(table[i]) - begin(table[i]);
        for (int j = 0; j < col; j++)
        {
            table[i][j] = "      ";
        }
    }

    //table[1][9] é a posição da primeira peça.
    rightTip[0] = 1;
    rightTip[1] = 9;
    leftTip[0] = 1;
    leftTip[1] = 9;
}

bool insertTable(DominoPiece dominoPiece, string tableSide)
{
    bool result = false;
    if (dominoPiece.left_number == 6 && dominoPiece.right_number == 6)
    {
        table[1][9] = toStringPiece(dominoPiece);
    }
    else
    {
        if (tableSide == LEFT_SIDE)
        {

            if (leftTip[0] == 0)
            {
                if (dominoPiece.right_number == (int)table[leftTip[0]][leftTip[1]][3] - 48)
                {
                    updateLeftTip();
                    table[leftTip[0]][leftTip[1]] = toStringReversePiece(dominoPiece);

                    result = true;
                }
                else if (dominoPiece.left_number == (int)table[leftTip[0]][leftTip[1]][3] - 48)
                {
                    updateLeftTip();
                    table[leftTip[0]][leftTip[1]] = toStringPiece(dominoPiece);
                    result = true;
                }
            }
            else
            {
                if (dominoPiece.right_number == (int)table[leftTip[0]][leftTip[1]][1] - 48)
                {
                    updateLeftTip();
                    if (leftTip[0] == 0)
                    {
                        table[leftTip[0]][leftTip[1]] = toStringReversePiece(dominoPiece);
                    }
                    else
                    {
                        table[leftTip[0]][leftTip[1]] = toStringPiece(dominoPiece);
                    }
                    result = true;
                }
                else if (dominoPiece.left_number == (int)table[leftTip[0]][leftTip[1]][1] - 48)
                {
                    updateLeftTip();

                    if (leftTip[0] == 0)
                    {
                        table[leftTip[0]][leftTip[1]] = toStringPiece(dominoPiece);
                    }
                    else
                    {
                        table[leftTip[0]][leftTip[1]] = toStringReversePiece(dominoPiece);
                    }
                    result = true;
                }
            }
        }
        else if (tableSide == RIGHT_SIDE)
        {
            if (rightTip[0] == 2)
            {
                if (dominoPiece.right_number == (int)table[rightTip[0]][rightTip[1]][1] - 48)
                {

                    updateRightTip();
                    table[rightTip[0]][rightTip[1]] = toStringPiece(dominoPiece);
                    result = true;
                }
                else if (dominoPiece.left_number == (int)table[rightTip[0]][rightTip[1]][1] - 48)
                {

                    updateRightTip();
                    table[rightTip[0]][rightTip[1]] = toStringReversePiece(dominoPiece);
                    result = true;
                }
            }
            else
            {
                if (dominoPiece.right_number == (int)table[rightTip[0]][rightTip[1]][3] - 48)
                {
                    updateRightTip();
                    if (rightTip[0] == 2)
                    {
                        table[rightTip[0]][rightTip[1]] = toStringPiece(dominoPiece);
                    }
                    else
                    {
                        table[rightTip[0]][rightTip[1]] = toStringReversePiece(dominoPiece);
                    }
                    result = true;
                }
                else if (dominoPiece.left_number == (int)table[rightTip[0]][rightTip[1]][3] - 48)
                {
                    updateRightTip();
                    if (rightTip[0] == 2)
                    {
                        table[rightTip[0]][rightTip[1]] = toStringReversePiece(dominoPiece);
                    }
                    else
                    {
                        table[rightTip[0]][rightTip[1]] = toStringPiece(dominoPiece);
                    }
                    result = true;
                }
            }
        }
    }

    return result;
}

void updateLeftTip()
{
    if (leftTip[1] == 0 && leftTip[0] == 1)
    {
        leftTip[0] = 0;
    }
    else
    {
        if (leftTip[0] == 1)
        {
            leftTip[1]--;
        }
        else if (leftTip[0] == 0)
        {
            leftTip[1]++;
        }
    }
}

void updateRightTip()
{
    if (rightTip[1] == 18 && rightTip[0] == 1)
    {
        rightTip[0] = 2;
    }
    else
    {
        if (rightTip[0] == 1)
        {
            rightTip[1]++;
        }
        else if (rightTip[0] == 2)
        {
            rightTip[1]--;
        }
    }
}

void showTable()
{
    system("clear");

    int row = end(table) - begin(table);
    for (int i = 0; i < row; i++)
    {

        int col = end(table[i]) - begin(table[i]);
        for (int j = 0; j < col; j++)
        {
            cout << table[i][j];
        }
        cout << endl;
    }
}
//testar os toStrings sem o espaço após o colchetes.
string toStringPiece(DominoPiece dominoPiece)
{
    return "[" + to_string(dominoPiece.left_number) + "|" + to_string(dominoPiece.right_number) + "] ";
}
string toStringReversePiece(DominoPiece dominoPiece)
{
    return "[" + to_string(dominoPiece.right_number) + "|" + to_string(dominoPiece.left_number) + "] ";
}

void createDominoPieces()
{
    dominoPieces.push_back({left_number : 0, right_number : 0});
    dominoPieces.push_back({left_number : 0, right_number : 1});
    dominoPieces.push_back({left_number : 0, right_number : 2});
    dominoPieces.push_back({left_number : 0, right_number : 3});
    dominoPieces.push_back({left_number : 0, right_number : 4});
    dominoPieces.push_back({left_number : 0, right_number : 5});
    dominoPieces.push_back({left_number : 0, right_number : 6});
    dominoPieces.push_back({left_number : 1, right_number : 1});
    dominoPieces.push_back({left_number : 1, right_number : 2});
    dominoPieces.push_back({left_number : 1, right_number : 3});
    dominoPieces.push_back({left_number : 1, right_number : 4});
    dominoPieces.push_back({left_number : 1, right_number : 5});
    dominoPieces.push_back({left_number : 1, right_number : 6});
    dominoPieces.push_back({left_number : 2, right_number : 2});
    dominoPieces.push_back({left_number : 2, right_number : 3});
    dominoPieces.push_back({left_number : 2, right_number : 4});
    dominoPieces.push_back({left_number : 2, right_number : 5});
    dominoPieces.push_back({left_number : 2, right_number : 6});
    dominoPieces.push_back({left_number : 3, right_number : 3});
    dominoPieces.push_back({left_number : 3, right_number : 4});
    dominoPieces.push_back({left_number : 3, right_number : 5});
    dominoPieces.push_back({left_number : 3, right_number : 6});
    dominoPieces.push_back({left_number : 4, right_number : 4});
    dominoPieces.push_back({left_number : 4, right_number : 5});
    dominoPieces.push_back({left_number : 4, right_number : 6});
    dominoPieces.push_back({left_number : 5, right_number : 5});
    dominoPieces.push_back({left_number : 5, right_number : 6});
    dominoPieces.push_back({left_number : 6, right_number : 6});
}

void deletePiece(int index)
{
    for (int n = index; n < (dominoPieces.size() - 1); n++)
    {
        dominoPieces[n] = dominoPieces[n + 1];
    }

    dominoPieces.pop_back();
}

void randomDominoPieces()
{
    int value;
    int size = dominoPieces.size();
    srand (time(NULL));

    for (int n = 0; n < size; n++)
    {
        value = rand() % dominoPieces.size();
        players[dominoPieces.size() % TOTAL_PLAYERS].dominoPieces.push_back(dominoPieces[value]);
        deletePiece(value);
    }
}
