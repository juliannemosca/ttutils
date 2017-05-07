import System.Random
import TTUtils

scale :: [Tone]
scale = [C,Db,D,Eb,E,F,Gb,G,Ab,A,Bb,B]

lookupTone :: Int -> Tone
lookupTone n = scale !! n

generateScale :: [Int] -> [Tone]
generateScale xs = toTones [] xs where
    toTones acc (n:ns) = toTones ((lookupTone n):acc) ns
    toTones acc _ = acc

generateScaleIndexes :: Eq a => [a] -> [a]
generateScaleIndexes xsRand = select [] xsRand where 
    select acc (x:xs) 
        | length acc == scaleLen    = acc
        | x `elem` acc              = select acc xs
        | otherwise                 = select (x:acc) xs

main = do  
    gen <- getStdGen  
    let randomIndexes = randomRs (0,scaleLen-1) gen  
        res = generateScale $ generateScaleIndexes randomIndexes
    putStrLn (prettifySet res)
