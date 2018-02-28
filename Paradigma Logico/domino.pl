%% O read_line_to_codes não precisa do ponto final na hora de ler.
%% Porém precisa de converções
	%% atom_string(A1, A2),
 	%% atom_number(A2, Option)
%% É legal usar o read_line_to_string pois o input ja vem em string.
%% usar sleep(2) para o tempo.
%% nth0(?Index, ?List, ?Elem)
%% delete(-List, -Elem, +NewList),
%% A seguir temos um append de listas, se vc quiser adicionar um elemento, diga que esse elemento é uma lista
%% Adicionar no inicio:
%% append([Elem], List, +NewList),
%% Adicionar no final:
%% append(List, [Elem], +NewList),


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
	append(Piece, Table, NewTable).

updateTable(Piece, "r", Table, NewTable) :-
	append(Table, Piece, NewTable).

%% Descobrir como remover elemento de matriz (Lista de lista)
removePiece([Hand|Hs], Player, Piece, NewHands).
nextMove(Hands, Player, Table).
%implementar as 2 regras a cima

firstMove(Hands, Player, Hands, Player).
firstMove(Hands, H, P) :-
	firstPlayer(Hands, Player0),
	removePiece(Hands, Player0, (6,6), NewHands),
	firstMove(Hands, Player0, H, P).
	
firstPlayer(Hands, Player) :-
	firstPlayer(Hands, 1, Player).

firstPlayer([], Player, Player).

firstPlayer([Hand|Hs], Player0, Player) :-
	(member((6,6), Hand) -> firstPlayer([], Player0, Player); 
 		NextPlayer is (Player0 + 1), 
 		firstPlayer(Hs, NextPlayer, Player)).


transferPiecesToHands(Pieces, TotalPieces, 7, Hand, Hands, Hands, Pieces).

transferPiecesToHands(Pieces, TotalPieces, HandLength, Hand, Hands, H, P) :-
	random(0, TotalPieces, Index), 
	nth0(Index, Pieces, RandomPiece),
	delete(Pieces, RandomPiece, NewPieces),
	append([RandomPiece], Hand, NewHand),
	NewTotalPieces is (TotalPieces - 1),
	length(NewHand, HL),
	((HL =:= 7) -> 	append([NewHand], Hands, NewHands), transferPiecesToHands(NewPieces, NewTotalPieces, HL, NewHand, NewHands, H, P);
	transferPiecesToHands(NewPieces, NewTotalPieces, HL, NewHand, Hands, H, P)).


startGame(Hands) :-
	write('Escolha a quantidade de jogadores na partida [1-4]: '),
	read_line_to_string(user_input, A1),
 	atom_number(A1, TotalHumanPlayers),
 	((TotalHumanPlayers < 0) ; (TotalHumanPlayers > 4)) ->
		writeln('Quantidade de jogadores inválida. Digite valores do intervalo [1,4].'),
		startGame(Hands);
		firstMove(Hands, NewHands, Player),
		nextMove(NewHands, Player, [(6,6)]).

startGame :-
	getDominoPieces(AllPieces),
	transferPiecesToHands(AllPieces, 28, 0, [], [], Hands, AllPieces1),
	transferPiecesToHands(AllPieces1, 21, 0, [], Hands, Hands1, AllPieces2),
	transferPiecesToHands(AllPieces2, 14, 0, [], Hands1, Hands2, AllPieces3),
	transferPiecesToHands(AllPieces3, 7, 0, [], Hands2, Hands3, AllPieces4),

	startGame(Hands3), nl.


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
	((Option =:= "1") -> writeln('JOGO INICIADO'), startGame; writeln('ATÉ LOGO')),
	halt(0).
