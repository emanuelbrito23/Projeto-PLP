import System.IO
import System.IO.Error
import System.Process
import System.Random
import System.IO.Unsafe
import Data.Matrix

-- Consts
rightTip = (2,10)
leftTip = (2,10)

main = do
    system "cls"
    system "clear"
    openMenu
    
randomInt :: Int -> Int -> Int
randomInt x y = unsafePerformIO (getStdRandom (randomR (x, y)))

openMenu = do
    putStrLn "----------DOMINÓ----------\n"
    putStrLn "[1] INICIAR JOGO"
    putStrLn "[0] SAIR\n"
    putStrLn "Digite a opção desejada: "
    option <- getLine

    if (read option) == 1 then do
        putStrLn "\nJOGO INICIADO"
        startGame 
    else putStrLn "\nATÉ LOGO"

startGame = do 
    let dominoPieces = createDominoPieces []
    let hands = createHands dominoPieces
    let table = []

    putStrLn "\nEscolha a quantidade de jogadores na partida [1-4]: "
    totalHumanPlayers <- getLine

    if ((read totalHumanPlayers) < 0) || ((read totalHumanPlayers) > 4) then do
        putStrLn "Quantidade de Jogadores inválida. Digite valores de 1-4."
        startGame
    else do
        firstMove hands (read totalHumanPlayers) table

createTable = matrix 3 19 $ \(i,j) -> "      "

createHands pieces = [hand1, hand2, hand3, hand4]
    where
        randomPieces = randomDominoPieces pieces 28
        hand1 = getIntervalPieces randomPieces 1 7
        hand2 = getIntervalPieces randomPieces 8 14
        hand3 = getIntervalPieces randomPieces 15 21
        hand4 = getIntervalPieces randomPieces 22 28

randomDominoPieces pieces number = do
   if (number > 0) then [piece] ++ randomDominoPieces (removePiece pieces (getPiece pieces random)) (number - 1) else []
    where
        random = randomInt 1 (length pieces)
        piece = getPiece pieces random

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
    if (hasPiece hand table) then 
        -- side <- getLine
        -- num <- getLine
        ((0,0), "z")
        -- if ((playPiece side hand (read num) table) == (- 1, - 1)) then do
        --     putStrLn "Jogada Inválida"
        --     humanMove hand table
        -- else (playPiece side hand (read num) table)
    else ((- 1, - 1), "x")
 
hasPiece [] table = False
hasPiece (hand: hands) table =
  if ((fst (hand) == fst (head table)) || (snd (hand) == fst (head table)) || (fst (hand) == snd (last table)) || (snd (hand) == snd (last table))) then True else hasPiece hands table
 
-- playPiece side hand num table =
--   if side == "r" then  if checkPiece (getPiece hand num) (snd (last table)) then ((getPiece hand num, side), side) else ((- 1, -1), "x")
--  else if checkPiece (getPiece hand num) (fst (head table)) then ((getPiece hand num, side), side) else ((- 1, -1), "x")
 
getPiece pieces 1 = head pieces
getPiece pieces num = getPiece (tail pieces) (num - 1)

getIntervalPieces pieces first last = if (first <= last) then [getPiece pieces first] ++ getIntervalPieces pieces (first + 1) last else []
 
checkPiece pieceHand num =
  if (fst (pieceHand) == num) || snd (pieceHand) == num then True else False
 
showPieces [] = ""
showPieces (head:body)=
  "[" ++ (show (fst (head))) ++ "|" ++ (show (snd (head))) ++ "] " ++ (showPieces body)
 
-- numbersHand [] num = ""
-- numbersHand (head:body) num =
--   "  " ++ (show (num)) ++ "   " ++ numbersHand body (num+1)

firstMove :: [[(Integer,Integer)]] -> Int -> [(Integer,Integer)] -> IO ()
firstMove (head:body) qtdHumanPlayer table = do
  let newTable = table ++ [(6,6)]
  let message = "O jogador " ++ (show (viewStart (head:body) 1)) ++ " comecou a partida"
  print newTable
  putStrLn message
  nextMove (((viewStart (head:body) 1) `mod` 4) + 1) (head:body) qtdHumanPlayer newTable

nextMove numPlayer (head:body) qtdHumanPlayer table =
    if not (blockedGame (head:body) table) then 
        if not (finishGame (head:body)) then 
            if numPlayer <= qtdHumanPlayer then
                if (humanMove (selectHand (head:body) numPlayer) table) == ((- 1, - 1), "x") then 
                    nextMove ((numPlayer `mod` 4) + 1) (head:body) qtdHumanPlayer table 
                else
                    putStrLn "Entrei aqui"
        --             showPieces table {-fazer funcionar os dois comandos (showPieces e nextMove) retornando o que nextMove retorna-} 
            else do 
                putStrLn "Entrei aqui 2"
                return ()
        else return ()
    else return ()
  
-- insertTable :: (Integer,Integer) -> Matrix [Char] -> Matrix [Char]
-- insertTable (left,rigth) table = do
--     let piece = "[" ++ (show left) ++ "|" ++ (show rigth) ++ "]"
--     setElem piece (rightTip) table

   
viewStart (head:body) num =
  if viewPiece head then num else viewStart body (num + 1)
 
viewPiece [] = False
viewPiece (head:body) =
  if (head == (6,6)) then True else viewPiece body
    
finishGame [] = False
finishGame (head:body) = 
  if length head == 0 then True else finishGame body

selectHand (head:body) numPlayer = if numPlayer == 1 then head else selectHand body (numPlayer - 1)
  
updateHands num (head:body) piece =
  if num == 1 then [(removePiece head piece)] ++ body else [head] ++ updateHands (num - 1) body piece
  
removePiece (head:body) piece
  | piece == head = body
  | otherwise = [head] ++ (removePiece body piece)

blockedGame [] table = True
blockedGame (hand:hands) table =
  if hasPiece hand table then False else blockedGame hands table

-- updateTable piece table 
--     | side == "l" && snd newPiece == head = [newPiece] ++ table
--     | side == "l" && fst newPiece == head = [(snd newPiece, fst newPiece)] ++ table
--     | side == "r" && fst newPiece == last = table ++ [newPiece]
--     | side == "r" && snd newPiece == last = table ++ [(snd newPiece, fst newPiece)]
--     | otherwise = table
--     where
--         newPiece = fst piece
--         side = snd piece
--         head = fst (head table)
--         last = snd (last table)

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