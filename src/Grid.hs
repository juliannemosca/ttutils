import System.Environment

import Data.List (isInfixOf)
import Data.Char (isLower)
import Data.Maybe
import Text.Read

import TTUtils

data Quality = Minor | Major | Diminished | Augmented | Perfect
    deriving (Show, Enum, Eq)

-- Evaluates qualitative inversion
invertQuality q
    | q == Minor        = Major
    | q == Major        = Minor
    | q == Diminished   = Augmented
    | q == Augmented    = Diminished
    | otherwise         = q

-- Evaluates the difference between two indexes
difference (t1,t2) = abs (t1-t2)

-- Evaluates the tone-interval Quality
-- of an index-pair interval
intervalQuality (t1,t2)
    | d == 0 = Perfect
    | d == 1 = Minor
    | d == 2 = Major
    | d == 3 = Minor
    | d == 4 = Major
    | d == 5 = Perfect
    | d == 6 = Augmented
    | d == 7 = Perfect
    | d == 8 = Minor
    | d == 9 = Major
    | d == 10 = Minor
    | d == 11 = Major
    where d = difference (t1,t2)

-- Evaluates the distance between the start and end
-- indexes of a qualified tone interval
distanceOfQualifiedInterval interv q
    | interv == 1                    = 0
    | interv == 2 && q == Minor      = 1
    | interv == 2 && q == Major      = 2
    | interv == 3 && q == Minor      = 3
    | interv == 3 && q == Major      = 4
    | interv == 4 && q == Diminished = 4
    | interv == 4 && q == Minor      = 4 -- FIX-ME: using Minor as 'Diminished'
    | interv == 4 && q == Perfect    = 5
    | interv == 4 && q == Augmented  = 6
    | interv == 5 && q == Diminished = 6
    | interv == 5 && q == Minor      = 6 -- FIX-ME: using Minor as 'Diminished'
    | interv == 5 && q == Perfect    = 7
    | interv == 5 && q == Augmented  = 8
    | interv == 6 && q == Minor = 8
    | interv == 6 && q == Major = 9
    | interv == 7 && q == Minor = 10
    | interv == 7 && q == Major = 11
    | interv == 8               = 12

-- Translate the difference between two indexes
-- to a tone-interval
diffToInterv d
    | d == 0 = 1
    | d == 1 = 2
    | d == 2 = 2
    | d == 3 = 3
    | d == 4 = 3
    | d == 5 = 4
    | d == 6 = 4
    | d == 7 = 5
    | d == 8 = 6
    | d == 9 = 6
    | d == 10 = 7
    | d == 11 = 7

-- Evaluates from a start index, a tone-interval and the interval's Quality
-- to an index-pair, always ascending interval, between start and the described
-- tone-interval
intervalIndexFrom start interv qual = if result >= scaleLen then result - scaleLen else result where
    result = start + (distanceOfQualifiedInterval interv qual)

-- Evaluates an index-pair interval to a tone-interval
interval = diffToInterv . difference

-- From an index-pair interval calculates the inverted
-- in tone-interval form, e.g.: (0,9) -> 3, as (0,9) is
-- a 6th in interval-tone form and its inversion is a 3rd
invertInterval (t1,t2) = (9 - (interval (t1,t2)))

-- Calculates the inversion of an index-pair interval
calcInversion (t1,t2) = (t1,t3) where 
    t3 = 
        if t1 < t2 then 
            intervalIndexFrom t1 (invertInterval (t1,t2)) (invertQuality (intervalQuality (t1,t2)))
        else
            intervalIndexFrom t1 (interval (t1,t2)) (intervalQuality (t1,t2))

-- Move the index-pair interval to a new index
transposeTo (t1,t2) n = (t1',t2') 
    where
        t1' = n
        transposed = n - (t1-t2)
        t2'
            | transposed < 0 = transposed + scaleLen
            | transposed >= scaleLen = transposed - scaleLen
            | otherwise = transposed

-- Remove duplicates and reverse the list
uniqnrev [] acc = acc
uniqnrev (x:xs) acc = 
    if x `elem` acc then 
        uniqnrev xs acc 
    else 
        uniqnrev xs (x:acc)

-- Takes a p.c. set and evaluates to its inversion
invertSet (x:[]) acc    = uniqnrev acc []
invertSet (x:y:set) acc = invertSet (y:set) (r2:r1:acc)
    where
        (r1,r2) = inverted `transposeTo` newIndex
        inverted = calcInversion(x,y)
        newIndex = if length acc == 0 then x else head acc

-- Transpose the index-pair interval n places
transpose (t1,t2) n = (r1,r2)
    where
        r1 = result t1 n
        r2 = result t2 n
        result t n = if r < 0 || r >= scaleLen then move r else r
            where r = move n+t
        move t
            | t < 0 = t + scaleLen
            | t >= scaleLen = t - scaleLen
            | otherwise = t

-- Transpose a whole set n places
transposeSet (x:[]) _ acc = uniqnrev acc []
transposeSet (x:y:set) n acc = transposeSet (y:set) n (r2:r1:acc)
    where
        (r1,r2) = transpose (x,y) n

-- Calculates all the transpositions of an original set to a list of indexes
calcTranspositions :: [Int] -> [Int] -> [[Int]] -> [[Int]]
calcTranspositions [] _ acc = reverse acc
calcTranspositions ixs orig [] = calcTranspositions ixs orig [orig]
calcTranspositions (ix:ixs) orig acc = calcTranspositions ixs orig ((transposeSet orig n []):acc)
    where
        n = scaleLen-(head orig)+ix

-- Based on an original set generates the standard grid
-- that contains the Original/Inverted/Retrograde/Inverted-Retrograde forms
-- of the set
generateGrid set = grid
    where
        grid = calcTranspositions (tail (invertSet set [])) set []

main = do
    args <- getArgs
    if length args /= 12 || not (areUnique args) then
        -- TO-DO: better error handling
        error "A standard twelve-tone pitch class set must be provided to be able to generate a grid"
    else
        do
            let g = map toTones $ generateGrid (toSetIndexes args)
            let p = (prettifyGrid g)
            putStrLn $ unlines p
    where

        toSetIndexes set = map ( fromEnum . strToTone ) set

        toTones :: [Int] -> [Tone]
        toTones set = map toEnum set

        areUnique :: (Eq a) => [a] -> Bool
        areUnique [] = True
        areUnique (x:xs) = notElem x xs && areUnique xs

        strToTone :: String -> Tone
        strToTone t = case (readMaybe t :: Maybe Tone) of
            Just x -> x
            Nothing -> handleNoTone
            where
                handleNoTone
                    -- TO-DO: better error handling
                    | isInfixOf "#" t =
                        error (t ++ " is not a valid tone. Please remember to use 'b' instead of '#'s")
                    | isLower (head t) =
                        error ("tones must be entered with upper-case letters and flats with an un-spaced 'b' character after")
                    | otherwise =
                        error (t ++ " is not a valid tone")
