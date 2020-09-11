def printGrid(g):
    for i in range(8):
        print(g[i])

def insertVal(g,x,y,val):
    g[y][x] = val

def changePlayer(p): return 'N' if player == 'B' else 'B'

def inside(x,y): return 0<=x<8 and 0<=y<8


def checkRecursive3(g,x,y,p,i,j,lnb):
    if not inside(x+j,y+i) or g[y+i][x+j] == ' ': return False,lnb
    if g[y+i][x+j] == p: return True,lnb

    if checkRecursive3(g,x+j,y+i,p,i,j,lnb):
        if p == 'N':
            lnb[0]+=1
            lnb[1]-=1
        else:
            lnb[0]-=1
            lnb[1]+=1
        g[y][x] = p
        g[y+i][x+j] = p
        #checkCoords(g,x,y,p)
        return True,lnb
    return False,lnb



def checkRecursive(g,x,y,p):
    if inside(x+2,y) and g[y][x+2] == p and g[y][x+1] != p:
        g[y][x] = p
        g[y][x+1] = p
        checkRecursive(g,x+1,y, p)
    if inside(x,y+2) and g[y+2][x] == p and g[y+1][x] != p:
        g[y][x] = p
        g[y+1][x] = p
        checkRecursive(g,x,y+1,p)
    if inside(x-2,y) and g[y][x-2] == p and g[y][x-1] != p:
        g[y][x] = p
        g[y][x-1] = p
        checkRecursive(g,x-1,y,p)
    if inside(x,y-2) and g[y-2][x] == p and g[y-1][x] != p:
        g[y][x] = p
        g[y-1][x] = p
        checkRecursive(g,x,y-1,p)
    if inside(x+2,y+2) and g[y+2][x+2] == p and g[y+1][x+1] != p:
        g[y][x] = p
        g[y+1][x+1] = p
        checkRecursive(g,x+1,y+1,p)
    if inside(x-2,y-2) and g[y-2][x-2] == p and g[y-1][x-1] != p:
        g[y][x] = p
        g[y-1][x-1] = p
        checkRecursive(g,x-1,y-1,p)
    if inside(x+2,y-2) and g[y-2][x+2] == p and g[y-1][x+1]:
        g[y][x] = p
        g[y-1][x+1] = p
        checkRecursive(g,x+1,y-1,p)
    if inside(x-2,y+2) and g[y+2][x-2] == p and g[y+1][x-1]:
        g[y][x] = p
        g[y+1][x-1] = p
        checkRecursive(g,x-1,y+1,p)

def checkRecursive2(g,x,y,p):
    dir1 = [(1,0),(0,1),(-1,0),(0,-1),(1,1),(-1,-1),(1,-1),(-1,1)]
    dir2 = [(2,0),(0,2),(-2,0),(0,-2),(2,2),(-2,-2),(2,-2),(-2,2)]

    for i in range(8):
        if inside(x + dir2[i][1], y + dir2[i][0]) and g[y + dir2[i][0]][x + dir2[i][1]] == p \
                and g[y + dir1[i][0]][x + dir1[i][1]] != p:
            g[y][x] = p
            g[y + dir1[i][0]][x + dir1[i][1]] = p
            checkRecursive(g, x + dir1[i][1], y + dir1[i][0], p)

def checkCoords(g,x,y,p,lnb):
    if g[y][x] == ' ':
        for i in range(-1, 2):
            for j in range(-1, 2):
                if i == 0 and j == 0: continue
                print(checkRecursive3(g,x,y,p,i,j,lnb))




matrix = [[' ' for _ in range(8)] for _ in range(8)]
matrix[3][3] = 'B'
matrix[3][4] = 'N'
matrix[4][4] = 'B'
matrix[4][3] = 'N'

a = 0
player = 'N'
printGrid(matrix)
lnb = [2,2]

while True:
    print("Current player: "+player)
    coords = input("Cordinate")

    if coords == 'STOP': break

    # coords[0] = X , coords[1] = Y
    coords = (ord(coords[0])-97, int(coords[1])-1)
    checkCoords(matrix, coords[0], coords[1], player, lnb)

    printGrid(matrix)
    player = changePlayer(player)

