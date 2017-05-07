module TTUtils
    (
      Tone(..)
    , scaleLen
    , padL
    , prettifySet
    , prettifyGrid
    ) where

import Data.List (intercalate)

data Tone = C | Db | D | Eb | E | F | Gb
    | G | Ab | A | Bb | B
    deriving (Read, Show, Enum, Eq, Ord)

scaleLen :: Int
scaleLen = 12

padL :: Int -> String -> String
padL n s
    | length s < n  = s ++ replicate (n - length s) ' '
    | otherwise     = s

prettifySet set = (intercalate " " . map ((padL 2) . show)) set
prettifyGrid grid = map prettifySet grid
