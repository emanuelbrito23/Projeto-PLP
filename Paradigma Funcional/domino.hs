import System.IO
import System.IO.Error
import System.Process
import System.Random

main :: IO()
main = do
    system "cls"
    system "clear"
    openMenu
    
randomInt :: Int -> Int -> IO Int
randomInt x y = getStdRandom (randomR (x,y))

openMenu = do
    putStrLn "----------DOMINÓ----------\n"
    putStrLn "[1] INICIAR JOGO"
    putStrLn "[0] SAIR\n"
    putStrLn "Digite a opção desejada: "
    option <- getLine

    if (read option) == 1 then startGame else putStrLn "\nATÉ LOGO"

startGame = do 
    putStrLn "\nJOGO INICIADO"
    let dominoPieces = createDominoPieces []
    printDominoPieces dominoPieces
    a <- randomInt 1 (length dominoPieces)
    putStrLn (show a)


createDominoPieces [] = createDominoPieces [(0, 0)] 
createDominoPieces xs = if second == 6 then (if first == 6 then xs else createDominoPieces (xs ++ [((first + 1), (first + 1))])) else createDominoPieces (xs ++ [(first, (second + 1))])
    where
        first = fst(last xs)
        second = snd(last xs)

printDominoPieces [] = putStrLn ""
printDominoPieces (x:xs) = do
                            let test = show (fst x) ++ ":" ++ show (snd x)
                            print test
                            printDominoPieces xs

humanMove hand table =
    if (hasPiece hand table) then do
        side <- getLine
        num <- getLine
        let numPiece = (read num)
        if ((playPiece side hand numPiece table) == (- 1, - 1)) then do
            putStrLn "Jogada Inválida"
            humanMove hand table side numPiece
        else (playPiece side hand numPiece table)
    else (- 1, - 1)
 
hasPiece [] table = False
hasPiece (hand: hands) table =
  if ((fst (hand) == fst (head table)) || (snd (hand) == fst (head table)) || (fst (hand) == snd (last table)) || (snd (hand) == snd (last table))) then True else hasPiece hands table
 
playPiece side hand num table =
  if side == "r" then  if checkPiece (getPiece hand num) (snd (last table)) then (getPiece hand num, side) else (- 1, -1)
 else if checkPiece (getPiece hand num) (fst (head table)) then (getPiece hand num, side) else (- 1, -1)
 
getPiece (head:body) 1 = head
getPiece (head:body) num = getPiece body (num - 1)
 
checkPiece pieceHand num =
  if (fst (pieceHand) == num) || snd (pieceHand) == num then True else False
 
 showHand hand =
    {- Concatena showPieces (showPieces hand) e numbersHand (numbersHand hand 1) quebrando linha de um pra outro-}
 
showPieces [] = ""
showPieces (head:body)=
  "[" ++ (show (fst (head))) ++ "|" ++ (show (snd (head))) ++ "] " ++ (showPieces body)
 
numbersHand [] num = ""
numbersHand (head:body) num =
  "  " ++ (show (num)) ++ "   " ++ numbersHand body (num+1)

firstMove (head:body) = do
  insertTable (6,6)
  putStrLn "O jogador " ++ (show (viewStart (head:body) 1) ++ "comecou a partida"
  nextMove (mod ((viewStart (head:body) 1)) 4) + 1) (firstTable (viewStart (head:body) 1) (head:body) (6,6))
   
viewStart (head:body) num =
  if viewPiece head then num else viewStart body (num + 1)
 
viewPiece [] = False
viewPiece (head:body) =
  if (head == (6,6)) then True else viewPiece body
 
nextMove numPlayer (head:body) qtdHumanPlayer  table =
 	if not (blockedGame (head:body) table) then 
	  if not (finishGame (head:body)) then 
	    if numPlayer <= qtdHumanPlayer then
	      if (fst (humanMove (selectHand (head:body) numPlayer) table)) == (- 1, - 1) then 
	        nextMove ((mod numPlayer 4) + 1) (head:body) qtdHumanPlayer table 
	      else do
	        showPieces table {-fazer funcionar os dois comandos (showPieces e nextMove) retornando o que nextMove retorna-} 
    
finishGame [] = False
finishGame (head:body) = 
  if length head == 0 then True else finishGame body
  

selectHand (head:body) numPlayer =
  if numPlayer == 1 then head else selectHand body (numPlayer - 1)
  
updateHands num (head:body) piece =
  if num == 1 then [(removePiece head piece)] ++ body else [head] ++ updateHands (num - 1) body piece
  
removePiece (head:body) piece
  | piece == head = body
  | otherwise = [head] ++ (removePiece body piece)

blockedGame [] table = True
blockedGame (hand:hands) table =
  if hasPiece hand table then False else blockedGame hands table

updateTable piece table 
    | side == "l" && snd newPiece == head = [newPiece] ++ table
    | side == "l" && fst newPiece == head = [(snd newPiece, fst newPiece)] ++ table
    | side == "r" && fst newPiece == last = table ++ [newPiece]
    | side == "r" && snd newPiece == last = table ++ [(snd newPiece, fst newPiece)]
    | otherwise = table
    where
        newPiece = fst piece
        side = snd piece
        head = fst (head table)
        last = snd (last table)

robotMove hand table
    | temp == True = (robotPlay hand table)
    | otherwise = ((-1,-1),"")
    where
        temp = (hasPiece hand table)
    
robotPlay hand table
    | length specialPieces /= 0 = selectSide (maximum specialPieces) table
    | otherwise = selectSide (maximum possiblePieces) table
    where
        numbersTable = [fst (head table), snd (last table)]
        possiblePieces = [x | x <- hand, any (== (fst x)) numbersTable || any (== (snd x)) numbersTable]
        specialPieces = [x | x <- possiblePieces, fst x == snd x ]
    
selectSide piece table
    | left == True = (piece, "l")
    | otherwise = (piece, "r")
    where
        left = fst piece == fst (head table) || snd piece == fst (head table)