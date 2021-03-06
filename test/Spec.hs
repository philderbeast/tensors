{-# LANGUAGE DataKinds           #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE PolyKinds           #-}
{-# LANGUAGE RankNTypes          #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies        #-}

module Main where

import           Data.Proxy
import           Data.Reflection
import           Data.Tensor
import           Data.Tensor.Type
import           GHC.TypeLits
import           Test.Hspec
import           Test.QuickCheck
import GHC.Exts(fromList)
import Data.Singletons

main = hspec spec

spec :: Spec
spec = do
  describe "Data.Tensor" specTensor

normalize :: [Int] -> [Int]
normalize = take 5 . fmap (`mod` 10)

specTensor = do
  context "viToti" $ do
    it "quickCheck" $ property $
      \s0 -> let s = normalize s0
                 n = [0..product s - 1]
            in fmap (tiTovi s . viToti s) n == n
    it "index" $ property $
      \i -> let i' = mod i 1000 + 1 :: Int
                go :: forall (s :: Nat). KnownNat s => Int -> Proxy s -> Bool
                go x _ = trace (identity :: Tensor '[s,s] Int) == x
            in reifyNat (toInteger i') (go i')
    -- it "det" $ property $
    --   \s0 -> let s = if null s0 then [1..25] else take 25 $ cycle s0
    --              a = fromList s :: Tensor '[5,5] Int
    --           in det a == det' a
    it "identity" $ property $
      \i s0 -> let n = mod i 20 + 1 :: Int
                   m = n * n
                   s = if null s0 then [1..m] else take m $ cycle s0
                   go :: forall (n :: Nat). KnownNat n => [Int] -> Proxy n -> Bool
                   go v _ = 
                     let a = fromList v :: Tensor '[n,n] Int
                         idt = identity :: Tensor '[n,n] Int
                     in a `dot` idt == idt `dot` a
               in reifyNat (toInteger n) (go s)
