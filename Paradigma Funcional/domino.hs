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