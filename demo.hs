{-# LANGUAGE NoMonomorphismRestriction, RankNTypes, TypeOperators #-}

-- no substitutions in comments
-- numeric a b c = (a * b - c) / (a + b + c)
{- numeric a b c = (a * b - c) / (a + b + c) -}

-- just the right amount of composition
import Control.Monad
tameCompose = Control.Monad.void.void . void
a .: b = a.b . a
data (a :. b) = Nil

numeric a b c = (a * b - c) / (a + b + c)

arrows :: (Monad m) =>
          (a -> m b) ->
          (b -> m c) ->
          a ->
          m c
arrows f g x = do
    _ <- (f >=> g) x
    (g <=< f) x

logical :: Bool -> Bool -> Bool -> Bool
logical a b c = not a && b || c

equalityComparison a b = [
    a == b,
    a /= b,
    a < b,
    a <= b,
    a > b,
    a >= b
    ]

-- some identifiers
misc :: forall a. a
misc = undefined

main = pure ()
