class Board : Behaviour {
    int Size = 4;

    Actor@ ElementPrefab = null;

    private grid<Element @> Grid;
    private Actor @Parent = null;

    private TextRender @label = null;
    private int Score
    {
        get const {
            return realScore;
        }
        set {
            realScore = value;
            if(label !is null) {
                label.Text = "Score: " + realScore;
            }
        }
    }
    private int realScore = 0;
    
    void start() override {
        @Parent = actor();
        
        @label = cast<TextRender>(Parent.componentInChild("TextRender"));
        
        Grid.resize(Size, Size);

        Material @material = cast<Material>(Engine::loadResource(".embedded/DefaultSprite.mtl"));
        Texture @texture = cast<Texture>(Engine::loadResource("Sprites/Cell.png"));

        for(int x = 0; x < Size; x++) {
            for(int y = 0; y < Size; y++) {
                Actor @cell = Actor();
                cell.Name = "Cell_" + x + "_" + y;
                cell.Parent = Parent;

                SpriteRender @sprite = cast<SpriteRender>(cell.addComponent("SpriteRender"));

                if(sprite !is null) {
                    sprite.Material = material;
                    sprite.Texture = texture;
                    sprite.Color = Vector4(0.5f, 0.5f, 0.5f, 0.5f);
                }

                cell.transform().Position = Vector3(x, y, -1.0f);
                cell.transform().Scale = Vector3(0.8f, 0.8f, 1.0f);
            }
        }

        for(int i = 0; i < 2; i++) {
            placeTile();
        }
    }

    void update() override {
        if(Input::isKeyDown(263)) {
            moveTiles(Vector2(-1, 0));
        }
        if(Input::isKeyDown(262)) {
            moveTiles(Vector2( 1, 0));
        }
        if(Input::isKeyDown(264)) {
            moveTiles(Vector2( 0,-1));
        }
        if(Input::isKeyDown(265)) {
            moveTiles(Vector2( 0, 1));
        }
    }

    void moveTiles(Vector2 dir) {
        bool moved = false;
        
        array<int> tX(Size);
        array<int> tY(Size);

        for(int pos = 0; pos < Size; pos++) {
            tX[pos] = pos;
            tY[pos] = pos;
        }
        if(dir[0] > 0) tX.reverse();
        if(dir[1] > 0) tY.reverse();
        
        for(int c = 0; c < Size; c++) {
            for(int r = 0; r < Size; r++) {
                int x = tX[c];
                int y = tY[r];
                Element @element = getElement(x, y);
                if(@element !is null) {
                    Vector2 previous;
                    Vector2 cell(x, y);
                    do {
                        previous = cell;
                        cell = cell + dir;
                    } while((cell[0] >= 0 && cell[0] < Size && cell[1] >= 0 && cell[1] < Size) && @Grid[int(cell[0]), int(cell[1])] is null);

                    Element @next = getElement(int(cell[0]), int(cell[1]));
                    if(next !is null && element.value == next.value) {
                        next.value += 1;
                        Score += int(pow(2.0f, next.value));
                        element.actor().deleteLater();
                        @Grid[x, y] = null;
                    } else {
                        int pX = int(previous[0]);
                        int pY = int(previous[1]);
                        @Grid[x, y] = null;
                        @Grid[pX, pY] = @element;
                        
                        element.position = Vector2(pX, pY);
                    }
                    
                    if(element.position != cell) {
                        moved = true;
                    }
                }
            }
        }
        if(moved) {
            placeTile();
        }
    }
    
    void placeTile() {
        array<int> freeCol;
        array<int> freeRow;
        for(int x = 0; x < Size; x++) {
            for(int y = 0; y < Size; y++) {
                if(@Grid[x, y] is null) {
                    freeCol.insertLast(x);
                    freeRow.insertLast(y);
                }
            }
        }
        if(freeCol.length > 0) {
            int pos = irand(0, freeCol.length - 1);

            int x = freeCol[pos];
            int y = freeRow[pos];
            
            Actor @object = cast<Actor>(ElementPrefab.clone(Parent));
            object.Name = "Element";
            
            Element @element = cast<Element>(getObject(cast<AngelBehaviour>(object.component("AngelBehaviour"))));
            if(element !is null) {
                element.position = Vector2(x, y);
                @Grid[x, y] = @element;
            }
        } else {
            // No free tiles
        }
    }
    
    Element @getElement(int x, int y) {
        if(x < 0 || x >= Size || y < 0 || y >= Size) {
            return null;
        }
        return @Grid[x, y];
    }
}