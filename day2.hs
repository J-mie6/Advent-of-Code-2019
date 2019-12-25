{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
import Data.Array.IO
import Control.Monad.List
import Control.Monad.Trans
import IntCode

instance (Read a, Show a) => MonadInput IO a where
  input  = readLn
  output = print

runWithValues :: Val -> Val -> IO Val
runWithValues x y =
  do xs <- Main.input
     arr <- initialise @IO @IOArray xs
     writeArray arr 1 x
     writeArray arr 2 y
     execute arr

task1 :: IO Val
task1 = runWithValues 12 2

-- The ListT monad, though usually dodgy, works well here
-- It does not, however, short circuit
-- We non-deterministically choose two numbers between 0 to 99
-- We run this program with those values
task2 :: IO [(Val, Val)]
task2 = runListT $
  do let val = 19690720
     x <- ListT (return [0..99])
     y <- ListT (return [0..99])
     z <- lift $ runWithValues x y
     guard (z == val)
     return (x, y)

split :: (a -> Bool) -> [a] -> [[a]]
split f = foldr g [[]]
  where
    g x (ys:yss) 
      | f x  = []:ys:yss
      | otherwise = (x:ys):yss

input :: IO [Val]
input = map read . split (== ',') <$> readFile "day2-input.txt"
