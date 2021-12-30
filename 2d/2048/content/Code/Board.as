class Board : Behaviour {
    int Size = 4;

    Prefab@ ElementPrefab = null;

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
                label.text = "Score: " + realScore;
            }
        }
    }
    private int realScore = 0;
    
    void start() override {
        @Parent = actor();
        
        @label = cast<TextRender>(Parent.componentInChild("TextRender"));
        
        Grid.resize(Size, Size);

        Material @material = cast<Material>(Engine::loadResource(".embedded/DefaultSprite.mtl"));
        Sprite @sprite = cast<Sprite>(Engine::loadResource("Sprites/Cell.png"));

        for(int x = 0; x < Size; x++) {
            for(int y = 0; y < Size; y++) {
                Actor @cell = Engine::composeActor("SpriteRender", "Cell_" + x + "_" + y, Parent);
                SpriteRender @render = cast<SpriteRender>(cell.component("SpriteRender"));

                if(render !is null) {
                    render.material = material;
                    render.sprite = sprite;
                    render.color = Vector4(0.5f, 0.5f, 0.5f, 0.5f);
                }

                cell.transform().position = Vector3(x, y, -1.0f);
                cell.transform().scale = Vector3(0.8f, 0.8f, 1.0f);
            }
        }

        for(int i = 0; i < 2; i++) {
            placeTile();
        }
    }

    void update() override {
        if(Input::isKeyDown(Input::KeyCode::KEY_LEFT)) {
            moveTiles(Vector2(-1, 0));
        }
        if(Input::isKeyDown(Input::KeyCode::KEY_RIGHT)) {
            moveTiles(Vector2( 1, 0));
        }
        if(Input::isKeyDown(Input::KeyCode::KEY_DOWN)) {
            moveTiles(Vector2( 0,-1));
        }
        if(Input::isKeyDown(Input::KeyCode::KEY_UP)) {
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
        if(dir.x > 0) tX.reverse();
        if(dir.y > 0) tY.reverse();
        
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
                    } while((cell.x >= 0 && cell.x < Size && cell.y >= 0 && cell.y < Size) && @Grid[int(cell.x), int(cell.y)] is null);

                    Element @next = getElement(int(cell.x), int(cell.y));
                    if(next !is null && element.value == next.value) {
                        next.value += 1;
                        Score += int(pow(2.0f, next.value));
                        element.actor().deleteLater();
                        @Grid[x, y] = null;
                    } else {
                        int pX = int(previous.x);
                        int pY = int(previous.y);
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
            
            Actor @object = cast<Actor>(ElementPrefab.actor.clone(Parent));
            if(object !is null) {
                object.Name = "Element";
            
                Element @element = cast<Element>(getObject(cast<AngelBehaviour>(object.component("AngelBehaviour"))));
                if(element !is null) {
                    element.position = Vector2(x, y);
                    @Grid[x, y] = @element;
                }
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