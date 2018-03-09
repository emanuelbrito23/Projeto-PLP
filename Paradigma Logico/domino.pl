%% O read_line_to_codes não precisa do ponto final na hora de ler.
%% Porém precisa de converções
	%% atom_string(A1, A2),
 	%% atom_number(A2, Option)
%% É legal usar o read_line_to_string pois o input ja vem em string.
%% usar sleep(2) para o tempo.
%% nth0(?Index, ?List, ?Elem)
%% delete(+List, +Elem, -NewList),
%% A seguir temos um append de listas, se vc quiser adicionar um elemento, diga que esse elemento é uma lista
%% Adicionar no inicio:
%% append([Elem], List, -NewList),
%% Adicionar no final:
%% append(List, [Elem], -NewList),
%% updateHands(+OldElem, +NewElem, +List, -List)

%% Para executar: swipl -q -f domino.pl

updateHands(_, _, [], []).
updateHands(OldHand, Hand, [OldHand|Os], [Hand|Hs]):- 
	updateHands(OldHand, Hand, Os, Hs).

updateHands(OldHand, Hand, [Z|Os], [Z|Hs]):- 
	OldHand \== Z,
	updateHands(OldHand, Hand, Os, Hs).


getDominoPieces(AllPieces) :-
	AllPieces = 
	[
	(0, 0), (0, 1),
	(0, 2), (0, 3), 
	(0, 4), (0, 5), 
	(0, 6), (1, 1), 
	(1, 2), (1, 3), 
	(1, 4), (1, 5),	
	(1, 6), (2, 2), 
	(2, 3), (2, 4), 
	(2, 5), (2, 6), 
	(3, 3), (3, 4), 
	(3, 5), (3, 6), 
	(4, 4), (4, 5), 
	(4, 6), (5, 5), 
	(5, 6), (6, 6)
	].


updateTable(Piece, "l", Table, NewTable) :-
	append([Piece], Table, NewTable).

updateTable(Piece, "r", Table, NewTable) :-
	append(Table, [Piece], NewTable).


printNumberPiece(L, NumberPiece):-
	(L >= NumberPiece) -> write('  '),
		write(NumberPiece),
		write('   '),
		NumberPiece0 is (NumberPiece + 1),
		printNumberPiece(L, NumberPiece0);
		nl.


getPieceSide(Piece, "l", N):-
	Piece =.. Piece0,
	nth0(1, Piece0, N).

getPieceSide(Piece, "r", N):-
	Piece =.. Piece0,
	nth0(2, Piece0, N).


showHand(Hand, Length, NumberPiece):-
	nth1(NumberPiece, Hand, Piece),
	getPieceSide(Piece, "l", LP),
	getPieceSide(Piece, "r", RP),
	write('['),
	write(LP),
	write('|'),
	write(RP),
	write('] '),
	NumberPiece0 is (NumberPiece + 1),
	(Length >= NumberPiece0) ->
		showHand(Hand, Length, NumberPiece0);
		nl, nl.

showHand(Hand):-
	length(Hand, L),
	printNumberPiece(L, 1),
	showHand(Hand, L, 1).


validateMove(Hand, NumberPiece, "r", Table):-
	last(Table, TablePiece),
	nth1(NumberPiece, Hand, Piece),
	getPieceSide(Piece, "l", LP),
	getPieceSide(Piece, "r", RP),
	getPieceSide(TablePiece, "r", T),
	(LP =:= T ; RP =:= T).

validateMove(Hand, NumberPiece, "l", [TablePiece|_]):-
	nth1(NumberPiece, Hand, HandPiece),
	getPieceSide(HandPiece, "l", LP),
	getPieceSide(HandPiece, "r", RP),
	getPieceSide(TablePiece, "l", Table),
	(LP =:= Table ; RP =:= Table).


isHuman(Player, TotalHumanPlayers):-
	Player =< TotalHumanPlayers.

isRobot(Player, TotalHumanPlayers):-
	Player > TotalHumanPlayers.


playPiece(Hand, NumberPiece, "l", [TPiece|TablePieces], NewHand, NewTable):-
	nth1(NumberPiece, Hand, HandPiece),
	getPieceSide(HandPiece, "r", RHandPiece),
	getPieceSide(TPiece, "l", LTablePiece),
	RHandPiece =:= LTablePiece,
	append([HandPiece], [TPiece|TablePieces], NewTable),
	updateTable(HandPiece, "l", [TPiece|TablePieces], NewTable),
	removePiece(Hand, HandPiece, NewHand).

playPiece(Hand, NumberPiece, "l", [TPiece|TablePieces], NewHand, NewTable):-
	nth1(NumberPiece, Hand, HandPiece),
	getPieceSide(HandPiece, "l", LHandPiece),
	getPieceSide(TPiece, "l", LTablePiece),
	LHandPiece =:= LTablePiece,
	getPieceSide(HandPiece, "r", RHandPiece),
	append([(RHandPiece, LHandPiece)], [TPiece|TablePieces], NewTable),
	updateTable((RHandPiece, LHandPiece), "l", [TPiece|TablePieces], NewTable),
	removePiece(Hand, HandPiece, NewHand).

playPiece(Hand, NumberPiece, "r", Table, NewHand, NewTable):-
	nth1(NumberPiece, Hand, HandPiece),
	getPieceSide(HandPiece, "l", LHandPiece),
	last(Table, TPiece),
	getPieceSide(TPiece, "r", RTablePiece),
	LHandPiece =:= RTablePiece,
	updateTable(HandPiece, "r", Table, NewTable),
	removePiece(Hand, HandPiece, NewHand).

playPiece(Hand, NumberPiece, "r", Table, NewHand, NewTable):-
	nth1(NumberPiece, Hand, HandPiece),
	getPieceSide(HandPiece, "r", RHandPiece),
	last(Table, TPiece),
	getPieceSide(TPiece, "r", RTablePiece),
	RHandPiece =:= RTablePiece,
	getPieceSide(HandPiece, "l", LHandPiece),
	updateTable((RHandPiece, LHandPiece), "r", Table, NewTable),
	removePiece(Hand, HandPiece, NewHand).


move(Hand, Player, TotalHumanPlayers, Table, NewHand, NewTable):-
	isHuman(Player, TotalHumanPlayers),
	showHand(Hand),
	write('Digite o número da peça: '),
	read_line_to_string(user_input, A1),
 	atom_number(A1, NumberPiece),
 	nl,
 	write('Digite o lado em que quer jogar ("l" ou "r"): '),
 	read_line_to_string(user_input, Side),
 	(validateMove(Hand, NumberPiece, Side, Table) ->
 		playPiece(Hand, NumberPiece, Side, Table, NewHand, NewTable);
 		nl, writeln('Jogada inválida, jogue novamente.'),
 		sleep(2),
 		tty_clear,
 		showTable(Table),
 		write('Vez do jogador '),
 		writeln(Player), nl,
 		move(Hand, Player, TotalHumanPlayers, Table, NewHand, NewTable)).

move(Hand, Player, TotalHumanPlayers, Table, NewHand, NewTable):-
	isRobot(Player, TotalHumanPlayers),
	write('Jogador '),
	write(Player),
	write(' realizando jogada'),
	sleep(2).


getHand(Hands, Player, Hand):-
	nth1(Player, Hands, Hand).


hasPiece([], _):- 
	writeln('Você não tem peças, próximo jogador...'),
	sleep(2),
	false.

hasPiece([Piece|Hand], Table):-
	last(Table, LastTablePiece),
	getPieceSide(Piece, "r", RPiece),	
	getPieceSide(LastTablePiece, "r", RTablePiece),
	nth1(1, Table, FirstTablePiece),
	getPieceSide(Piece, "l", LPiece),
	getPieceSide(FirstTablePiece, "l", LTablePiece),
	((RPiece =:= LTablePiece ;
	  RPiece =:= RTablePiece;
	  LPiece =:= LTablePiece;
	  LPiece =:= RTablePiece) ->
		true;
		hasPiece(Hand, Table)).


continueGame(Hand, Player, Table):-
	length(Hand, L),
	(L > 0) -> true; finishGame(Player, Table).


nextMove(Hands, Player, TotalHumanPlayers, PassedMoves, Table):-
	showTable(Table),
	write('Vez do jogador '),
	writeln(Player), nl,
	getHand(Hands, Player, Hand),
	hasPiece(Hand, Table),
	move(Hand, Player, TotalHumanPlayers, Table, NewHand, NewTable),
	updateHands(Hand, NewHand, Hands, NewHands),
	continueGame(NewHand, Player, NewTable),
	NextPlayer0 is mod(Player, 4),
	NextPlayer is (NextPlayer0 + 1),
	tty_clear,
	NewPassedMoves is (0),
	nextMove(NewHands, NextPlayer, TotalHumanPlayers, NewPassedMoves, NewTable).

gameNotTied(PassedMoves):-
	(PassedMoves =:= 3) -> false; true.

nextMove(Hands, Player, TotalHumanPlayers, PassedMoves, Table):-
	gameNotTied(PassedMoves),
	NextPlayer0 is mod(Player, 4),
	NextPlayer is (NextPlayer0 + 1),	
	tty_clear,
	nextMove(Hands, NextPlayer, TotalHumanPlayers, (PassedMoves + 1), Table).

nextMove(Hands, Player, TotalHumanPlayers, PassedMoves, Table):-
	tty_clear,
	writeln('Jogo empatado durante a partida, na contagem dos pontos...'),
	gameTied(Hands, Winner),
	write('Jogador '),
	write(Winner),
	writeln(' é o vencedor!!!'),
	halt(0).

sumHandPieces(List, Result):-
    sumHandPieces(List, 0, Result).

sumHandPieces([], CurrentResult, CurrentResult).
sumHandPieces([Head|Tail], CurrentResult, Result):-
	getPieceSide(Head, "l", LP),
	getPieceSide(Head, "r", RP),
    NewCurrentResult is (CurrentResult + LP + RP),
    sumHandPieces(Tail, NewCurrentResult, Result).

getIndex(List, Elem, IndexElem):- getIndex(List, Elem, 0, IndexElem).

getIndex([], Elem, CurrentIndex, CurrentIndex).
getIndex([Head|Tail], Elem, CurrentIndex, IndexElem):-
	Head =:= Elem -> getIndex([], Elem, CurrentIndex, IndexElem); NewCurrentIndex is (CurrentIndex + 1), getIndex(Tail, Elem, NewCurrentIndex, IndexElem).

gameTied(Hands, Winner):-
	nth1(1, Hands, Hand1),
	nth1(2, Hands, Hand2),
	nth1(3, Hands, Hand3),
	nth1(4, Hands, Hand4),
	sumHandPieces(Hand1, TotalHand1),
	sumHandPieces(Hand2, TotalHand2),
	sumHandPieces(Hand3, TotalHand3),
	sumHandPieces(Hand4, TotalHand4),
	append([], [TotalHand1], List1),
	append(List1, [TotalHand2], List2),
	append(List2, [TotalHand3], List3),
	append(List3, [TotalHand4], FinalList),
	max_list(FinalList, MaxElem),
	getIndex(FinalList, MaxElem, Index),
	Winner is (Index + 1).


finishGame(Player, Table):-
	tty_clear,
	showTable(Table),
	write('Jogador '),
	write(Player),
	writeln(' é o vencedor!!!'),
	halt(0).

showTable(Table):- 
	length(Table, L),
	showHand(Table, L, 1).


removePiece(Hand, Piece, NewHand):- delete(Hand, Piece, NewHand).

removePiece(Hands, Player, Piece, NewHands):-
	getHand(Hands, Player, Hand),
	delete(Hand, Piece, NewHand),
	updateHands(Hand, NewHand, Hands, NewHands).

firstMove(Hands, Hs, NextPlayer) :-
	firstPlayer(Hands, Player0),
	removePiece(Hands, Player0, (6,6), Hs),
	tty_clear,
	write('O jogador '),
	write(Player0), 
	writeln(' começou a partida'), nl,
	NextPlayer is (mod(Player0, 4) + 1).

firstPlayer(Hands, Player) :-
	firstPlayer(Hands, 1, Player).
	
firstPlayer([], Player, Player).
firstPlayer([Hand|Hs], Player0, Player) :-
	(member((6,6), Hand) -> firstPlayer([], Player0, Player); 
 		NextPlayer is (Player0 + 1), 
 		firstPlayer(Hs, NextPlayer, Player)).

transferPiecesToHands_(Pieces, _, _, Hands, Hands, Pieces).

transferPiecesToHands(Pieces, TotalPieces, Hand, Hands, HandsResult, PiecesResult) :-
	random(0, TotalPieces, Index), 
	nth0(Index, Pieces, RandomPiece),
	delete(Pieces, RandomPiece, NewPieces),
	append([RandomPiece], Hand, NewHand),
	NewTotalPieces is (TotalPieces - 1),
	length(NewHand, HandLength),
	((HandLength =:= 7) -> append([NewHand], Hands, NewHands), transferPiecesToHands_(NewPieces, NewTotalPieces, NewHand, NewHands, HandsResult, PiecesResult);
		transferPiecesToHands(NewPieces, NewTotalPieces, NewHand, Hands, HandsResult, PiecesResult)).

startGame(Hands) :-
	write('Escolha a quantidade de jogadores na partida [1-4]: '),
	read_line_to_string(user_input, A1),
 	atom_number(A1, TotalHumanPlayers),
 	((TotalHumanPlayers >= 0), (TotalHumanPlayers =< 4)) ->
		firstMove(Hands, NewHands, Player),
		PassedMoves is (0),
		nextMove(NewHands, Player, TotalHumanPlayers, PassedMoves, [(6,6)]);
		writeln('Quantidade de jogadores inválida. Digite valores do intervalo [1,4].'),
		startGame(Hands).
		
configureGame :-
	getDominoPieces(AllPieces),
	transferPiecesToHands(AllPieces, 28, [], [], Hands, AllPieces1),
	transferPiecesToHands(AllPieces1, 21, [], Hands, Hands1, AllPieces2),
	transferPiecesToHands(AllPieces2, 14, [], Hands1, Hands2, AllPieces3),
	transferPiecesToHands(AllPieces3, 7, [], Hands2, HandsFinal, _),

	startGame(HandsFinal), nl.


printMenu(Option) :-
	tty_clear,
	writeln('----------DOMINÓ----------'),
	writeln('[1] INICIAR JOGO'),
	writeln('[0] SAIR'),
	write('Digite a opção desejada: '),	
	read_line_to_string(user_input, Option),
	tty_clear.
	

:- initialization main.
main :-
	printMenu(Option),
	((Option =:= "1") -> configureGame; writeln('ATÉ LOGO')),
	halt(0).
