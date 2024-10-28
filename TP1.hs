import qualified Data.List
import qualified Data.Array
import qualified Data.Bits

-- PFL 2024/2025 Practical assignment 1

-- Uncomment the some/all of the first three lines to import the modules, do not change the code of these lines.

type City = String
type Path = [City]
type Distance = Int

type RoadMap = [(City,City,Distance)]

-- cities

removeDups :: [City] -> [City]
removeDups [] = []
removeDups (x:xs) = x : removeDups (filter (/= x) xs)

cities :: RoadMap -> [City]
cities [] = []
cities ((city1,city2,distance):xs) = removeDups(city1 : city2 : cities xs)

-- areAdjacent

areAdjacent :: RoadMap -> City -> City -> Bool
areAdjacent [] _ _ = False;
areAdjacent ((city1,city2,distance):xs) x y
  | city1 == x && city2 == y = True
  | city1 == y && city2 == x = True
  | otherwise = areAdjacent xs x y

-- distance

distance :: RoadMap -> City -> City -> Maybe Distance
distance [] _ _ = Nothing
distance ((city1, city2, d):xs) x y
    | city1 == x && city2 == y = Just d
    | city1 == y && city2 == x = Just d
    | otherwise = distance xs x y

-- adjacent

adjacent :: RoadMap -> City -> [(City,Distance)]
adjacent [] _ = []
adjacent ((city1, city2, d):xs) x
    | city1 == x = (city2, d) : adjacent xs x
    | city2 == x = (city1, d) : adjacent xs x
    | otherwise = adjacent xs x

-- pathDistance

pathDistance :: RoadMap -> Path -> Maybe Distance
pathDistance _ [] = Just 0
pathDistance _ [_] = Just 0
pathDistance roadmap (y1:y2:ys) = do
    a <- distance roadmap y1 y2
    b <- pathDistance roadmap (y2:ys)
    return (a + b)

-- rome

maxDegree :: RoadMap -> Int
maxDegree [] = 0
maxDegree ((city1, city2, d):xs) = do
    a <- maxDegree xs
    b <-  length (adjacent ((city1, city2, d):xs) city1)
    c <- length (adjacent ((city1, city2, d):xs) city2)
    maximum [a, b, c]

rome :: RoadMap -> [City]
rome ((city1, city2, d):xs)
    | length (adjacent ((city1, city2, d):xs) city1) == maxDegree ((city1, city2, d):xs) = city1 : rome xs
    | length (adjacent ((city1, city2, d):xs) city2) == maxDegree ((city1, city2, d):xs) = city2 : rome xs
    | otherwise = rome xs

-- isStronglyConnected

isStronglyConnected :: RoadMap -> Bool
isStronglyConnected = undefined

-- shortestPath

shortestPath :: RoadMap -> City -> City -> [Path]
shortestPath = undefined

-- travelSales

travelSales :: RoadMap -> Path
travelSales = undefined

-- tspBruteForce

tspBruteForce :: RoadMap -> Path
tspBruteForce = undefined -- only for groups of 3 people; groups of 2 people: do not edit this function

-- Some graphs to test your work
gTest1 :: RoadMap
gTest1 = [("7","6",1),("8","2",2),("6","5",2),("0","1",4),("2","5",4),("8","6",6),("2","3",7),("7","8",7),("0","7",8),("1","2",8),("3","4",9),("5","4",10),("1","7",11),("3","5",14)]

gTest2 :: RoadMap
gTest2 = [("0","1",10),("0","2",15),("0","3",20),("1","2",35),("1","3",25),("2","3",30)]

gTest3 :: RoadMap -- unconnected graph
gTest3 = [("0","1",4),("2","3",2)]

