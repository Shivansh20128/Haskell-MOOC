powers :: Int -> Int -> [Int]
powers k max = takeWhile (<= max) [k^n | n <- [0..]]

main = do
    print(powers 5 33)