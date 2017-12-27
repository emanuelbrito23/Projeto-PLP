import System.IO
import System.IO.Error
import System.Process
import System.Random
import System.IO.Unsafe
import Data.Matrix

type Tip = ((Integer, Integer), [Char])

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

humanMove :: [(Integer,Integer)] -> [(Integer,Integer)] -> IO Tip
humanMove hand table =
    if (hasPiece hand table) then do
        side <- getLine
        num <- getLine
        validMove <- (playPiece side hand (read num) table)
        if (validMove == ((-1, -1), "")) then do
            putStrLn "Jogada Inválida"
            humanMove hand table
        else return validMove
    else return ((-1, -1), "")
 
hasPiece [] table = False
hasPiece (hand: hands) table =
  if ((fst (hand) == fst (head table)) || (snd (hand) == fst (head table)) || (fst (hand) == snd (last table)) || (snd (hand) == snd (last table))) then True else hasPiece hands table

playPiece :: [Char] -> [(Integer,Integer)] -> Int -> [(Integer,Integer)] -> IO Tip
playPiece side hand num table = do
  print side
  print hand
  print num
  print table
  if side == "r" then 
    if checkPiece (getPiece hand num) (snd (last table)) then 
        return ((getPiece hand num), side)
    else return ((-1, -1), "")
  else 
    if checkPiece (getPiece hand num) (fst (head table)) then 
        return ((getPiece hand num), side)
    else return ((-1, -1), "")

getPiece :: [(Integer,Integer)] -> Int -> (Integer,Integer)
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
  let initialPlayer = viewStart (head:body) 1
  let message = "O jogador " ++ (show (initialPlayer)) ++ " comecou a partida"
  let newHands = updateHands initialPlayer (head:body) (6,6)
  putStrLn message
  nextMove (((viewStart (head:body) 1) `mod` 4) + 1) newHands qtdHumanPlayer newTable

move :: Int -> [(Integer,Integer)] -> Int -> [(Integer,Integer)] -> IO Tip
move numPlayer hand qtdHumanPlayer table = 
    if numPlayer <= qtdHumanPlayer then do
        putStrLn "HumanMove"
        humanMove hand table
    else do
        putStrLn "robotMove"
        robotMove hand table

nextMove :: Int -> [[(Integer,Integer)]] -> Int -> [(Integer,Integer)] -> IO ()
nextMove numPlayer (head:body) qtdHumanPlayer table = do
    print numPlayer
    print (head:body)
    print qtdHumanPlayer
    print table

    if not (blockedGame (head:body) table) then 
        if not (finishGame (head:body)) then do
                validMove <- (move numPlayer (selectHand (head:body) numPlayer) qtdHumanPlayer table)
                let nextPlayer = ((numPlayer `mod` 4) + 1)
                if validMove == ((-1, -1), "") then 
                    nextMove nextPlayer (head:body) qtdHumanPlayer table
                else do
                    let newTable = updateTable validMove table
                    let piece = (fst validMove)
                    let newHands = updateHands numPlayer (head:body) piece
                    nextMove nextPlayer newHands qtdHumanPlayer newTable
        else putStrLn "Fim Else 2"
    else putStrLn "Fim Else 1"
   
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

updateTable :: ((Integer,Integer), [Char]) -> [(Integer,Integer)] -> [(Integer,Integer)]
updateTable move table 
    | (side == "l") && ((snd piece) == leftTip) = [piece] ++ table
    | (side == "l") && ((fst piece) == leftTip) = [(snd piece, fst piece)] ++ table
    | (side == "r") && ((fst piece) == rightTip) = table ++ [piece]
    | (side == "r") && ((snd piece) == rightTip) = table ++ [(snd piece, fst piece)]
    | otherwise = table
    where
        piece = fst move
        side = snd move
        leftTip = fst (head table)
        rightTip = snd (last table)

robotMove :: [(Integer,Integer)] -> [(Integer,Integer)] -> IO Tip
robotMove hand table
    | ((hasPiece hand table) == True) = (robotPlay hand table)
    | otherwise = return ((-1,-1),"")

robotPlay :: [(Integer,Integer)] -> [(Integer,Integer)] -> IO Tip
robotPlay hand table
    | length specialPieces /= 0 = selectSide (maximum specialPieces) table
    | otherwise = selectSide (maximum possiblePieces) table
    where
        numbersTable = [fst (head table), snd (last table)]
        possiblePieces = [x | x <- hand, any (== (fst x)) numbersTable || any (== (snd x)) numbersTable]
        specialPieces = [x | x <- possiblePieces, fst x == snd x ]
    
selectSide :: (Integer,Integer) -> [(Integer,Integer)] -> IO Tip
selectSide piece table
    | left == True = return (piece, "l")
    | otherwise = return (piece, "r")
    where
        left = (fst piece) == (fst (head table)) || (snd piece) == (fst (head table))