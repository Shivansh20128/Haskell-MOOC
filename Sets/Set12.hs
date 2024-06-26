module Set12 where

import Data.Functor
import Data.Foldable
import Data.List
import Data.Monoid

import Mooc.Todo


------------------------------------------------------------------------------
-- Ex 1: Implement the function incrementAll that takes a functor
-- value containing numbers and increments each number inside by one.
--
-- Examples:
--   incrementAll [1,2,3]     ==>  [2,3,4]
--   incrementAll (Just 3.0)  ==>  Just 4.0

incrementAll :: (Functor f, Num n) => f n -> f n
incrementAll = fmap (+1)

------------------------------------------------------------------------------
-- Ex 2: Sometimes one wants to fmap multiple levels deep. Implement
-- the functions fmap2 and fmap3 that map over nested functors.
--
-- Examples:
--   fmap2 on [[Int]]:
--     fmap2 negate [[1,2],[3]]
--       ==> [[-1,-2],[-3]]
--   fmap2 on [Maybe String]:
--     fmap2 head [Just "abcd",Nothing,Just "efgh"]
--       ==> [Just 'a',Nothing,Just 'e']
--   fmap3 on [[[Int]]]:
--     fmap3 negate [[[1,2],[3]],[[4],[5,6]]]
--       ==> [[[-1,-2],[-3]],[[-4],[-5,-6]]]
--   fmap3 on Maybe [Maybe Bool]
--     fmap3 not (Just [Just False, Nothing])
--       ==> Just [Just True,Nothing]

fmap2 :: (Functor f, Functor g) => (a -> b) -> f (g a) -> f (g b)
fmap2 func1 func2 = fmap (\t -> fmap func1 t) func2

fmap3 :: (Functor f, Functor g, Functor h) => (a -> b) -> f (g (h a)) -> f (g (h b))
fmap3 func1 func2 = fmap (\t -> fmap2 func1 t) func2

------------------------------------------------------------------------------
-- Ex 3: below you'll find a type Result that works a bit like Maybe,
-- but there are two different types of "Nothings": one with and one
-- without an error description.
--
-- Implement the instance Functor Result

data Result a = MkResult a | NoResult | Failure String
  deriving Show

instance Functor Result where
  fmap f NoResult = NoResult
  fmap f (Failure result) = Failure result
  fmap f (MkResult result) = MkResult (f result)

------------------------------------------------------------------------------
-- Ex 4: Here's a reimplementation of the Haskell list type. You might
-- remember it from Set6. Implement the instance Functor List.
--
-- Example:
--   fmap (+2) (LNode 0 (LNode 1 (LNode 2 Empty)))
--     ==> LNode 2 (LNode 3 (LNode 4 Empty))

data List a = Empty | LNode a (List a)
  deriving Show

instance Functor List where
 fmap :: (a -> b) -> List a -> List b
 fmap f (LNode node1 node2) = LNode (f node1) (fmap f node2)
 fmap f Empty = Empty

------------------------------------------------------------------------------
-- Ex 5: Here's another list type. This type every node contains two
-- values, so it's a type for a list of pairs. Implement the instance
-- Functor TwoList.
--
-- Example:
--   fmap (+2) (TwoNode 0 1 (TwoNode 2 3 TwoEmpty))
--     ==> TwoNode 2 3 (TwoNode 4 5 TwoEmpty)

data TwoList a = TwoEmpty | TwoNode a a (TwoList a)
  deriving Show

instance Functor TwoList where
  fmap f (TwoNode num1 num2 node) = TwoNode (f num1) (f num2) (fmap f node)
  fmap f TwoEmpty = TwoEmpty
------------------------------------------------------------------------------
-- Ex 6: Count all occurrences of a given element inside a Foldable.
--
-- Hint: you might find some useful functions from Data.Foldable.
-- Check the docs! Or then you can just implement count directly.
--
-- Examples:
--   count True [True,False,True] ==> 2
--   count 'c' (Just 'c') ==> 1

count :: (Eq a, Foldable f) => a -> f a -> Int
count elem list = length (filter (== elem) (toList list))

------------------------------------------------------------------------------
-- Ex 7: Return all elements that are in two Foldables, as a list.
--
-- Examples:
--   inBoth "abcd" "fobar" ==> "ab"
--   inBoth [1,2] (Just 2) ==> [2]
--   inBoth Nothing [3]    ==> []

inBoth :: (Foldable f, Foldable g, Eq a) => f a -> g a -> [a]
inBoth val1 val2 = filter (\t -> elem t $ toList val2) (toList val1)

------------------------------------------------------------------------------
-- Ex 8: Implement the instance Foldable List.
--
-- Remember what the minimal complete definitions for Foldable were:
-- you should only need to implement one function.
--
-- After defining the instance, you'll be able to compute:
--   sum (LNode 1 (LNode 2 (LNode 3 Empty)))    ==> 6
--   length (LNode 1 (LNode 2 (LNode 3 Empty))) ==> 3

instance Foldable List where
  foldr :: (a -> b -> b) -> b -> List a -> b
  foldr func value (LNode num1 num2) = func num1 (foldr func value num2)
  foldr func value Empty = value

------------------------------------------------------------------------------
-- Ex 9: Implement the instance Foldable TwoList.
--
-- After defining the instance, you'll be able to compute:
--   sum (TwoNode 0 1 (TwoNode 2 3 TwoEmpty))    ==> 6
--   length (TwoNode 0 1 (TwoNode 2 3 TwoEmpty)) ==> 4

instance Foldable TwoList where
  foldr :: (a -> b -> b) -> b -> TwoList a -> b
  foldr func value (TwoNode num1 num2 list) = func num1 (func num2(foldr func value list))
  foldr func value TwoEmpty = value
------------------------------------------------------------------------------
-- Ex 10: (Tricky!) Fun a is a type that wraps a function Int -> a.
-- Implement a Functor instance for it.
--
-- Figuring out what the Functor instance should do is most of the
-- puzzle.

data Fun a = Fun (Int -> a)

runFun :: Fun a -> Int -> a
runFun (Fun f) x = f x

instance Functor Fun where

  fmap :: (a -> b) -> Fun a -> Fun b
  fmap func2 (Fun func1) = Fun (func2 . func1)

------------------------------------------------------------------------------
-- Ex 11: (Tricky!) You'll find the binary tree type from Set 5b
-- below. We'll implement a `Foldable` instance for it!
--
-- Implementing `foldr` directly for the Tree type is complicated.
-- However, there is another method in Foldable we can define instead:
--
--   foldMap :: Monoid m => (a -> m) -> Tree a -> m
--
-- There's a default implementation for `foldr` in Foldable that uses
-- `foldMap`.
--
-- Instead of implementing `foldMap` directly, we can build it with
-- these functions:
--
--   fmap :: (a -> m) -> Tree a -> Tree m
--   sumTree :: Monoid m => Tree m -> m
--
-- So your task is to define a `Functor` instance and the `sumTree`
-- function.
--
-- Examples:
--   using the [] Monoid with the (++) operation:
--     sumTree Leaf :: [a]
--       ==> []
--     sumTree (Node [3,4,5] (Node [1,2] Leaf Leaf) (Node [6] Leaf Leaf))
--       ==> [1,2,3,4,5,6]
--   using the Sum Monoid
--     sumTree Leaf :: Sum Int
--       ==> Sum 0
--     sumTree (Node (Sum 3) (Node (Sum 2) Leaf Leaf) (Node (Sum 1) Leaf Leaf))
--       ==> Sum 6
--
-- Once you're done, foldr should operate like this:
--   foldr (:) [] Leaf   ==>   []
--   foldr (:) [] (Node 2 (Node 1 Leaf Leaf) (Node 3 Leaf Leaf))  ==>   [1,2,3]
--
--   foldr (:) [] (Node 4 (Node 2 (Node 1 Leaf Leaf)
--                                (Node 3 Leaf Leaf))
--                        (Node 5 Leaf
--                                (Node 6 Leaf Leaf)))
--      ==> [1,2,3,4,5,6]
--
-- The last example more visually:
--
--        .4.
--       /   \
--      2     5     ====>  1 2 3 4 5 6
--     / \     \
--    1   3     6

data Tree a = Leaf | Node a (Tree a) (Tree a)
  deriving Show

instance Functor Tree where
  fmap :: (a -> b) -> Tree a -> Tree b
  fmap func Leaf = Leaf
  fmap func (Node num leaf1 leaf2) = Node (func num) (fmap func leaf1) (fmap func leaf2)

sumTree :: Monoid m => Tree m -> m
sumTree (Node num leaf1 leaf2) = sumTree leaf1 <> num <> sumTree leaf2
sumTree Leaf = mempty

instance Foldable Tree where
  foldMap :: Monoid m => (a -> m) -> Tree a -> m
  foldMap func tree = sumTree (fmap func tree)

------------------------------------------------------------------------------
-- Bonus! If you enjoyed the two last exercises (not everybody will),
-- you'll like the `loeb` function:
--
--   https://github.com/quchen/articles/blob/master/loeb-moeb.md
