module Main where

import Data.Default (def)
import Plutarch (compile, plam)
import Plutarch.Prelude (pconstant)

main :: IO ()
main = do
  print $ compile def $ plam $ const $ pconstant (42 :: Integer)
