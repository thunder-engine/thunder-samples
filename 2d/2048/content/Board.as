class Board : Behaviour {
    int width = 4;
    int height = 4;

    Actor@ back = null;

    private array<array<Actor @>> grid;

    void start() override {
        grid.resize(width);
        for(int x = 0; x < width; x++) {
            grid[x].resize(height);
            for(int y = 0; y < height; y++) {
                @grid[x][y] = null;
            }
        }

        Material @material = cast<Material>(Engine::loadResource(".embedded/DefaultSprite.mtl"));
        Texture @texture = cast<Texture>(Engine::loadResource(".embedded/invalid.png"));

        Actor @parent = actor();
        for(int x = 0; x < width; x++) {
            for(int y = 0; y < height; y++) {
                Actor @cell = Actor();
                cell.Name = "Cell_" + x + "_" + y;
                cell.Parent = parent;

                SpriteRender @sprite = cast<SpriteRender>(cell.createComponent("SpriteRender"));

                if(sprite !is null) {
                    sprite.Material = material;
                    sprite.Texture = texture;
                }

                cell.transform().Position = Vector3(x, y, -1.0f);
                cell.transform().Scale = Vector3(0.95f, 0.95f, 1.0f);
            }
        }

        for(int i = 0; i < 2; i++) {
            placeTile();
        }
    }

    void update() override {
        if(Input::isKey(263)) {
            log("left");
        }
        if(Input::isKey(262)) {
            log("right");
        }
        if(Input::isKey(264)) {
            log("down");
        }
        if(Input::isKey(265)) {
            log("up");
        }
    }

    void placeTile() {
        Actor @parent = actor();
        int x = irand(0, width-1);
        int y = irand(0, height-1);

        if(@grid[x][y] == null) {
            Actor @object = cast<Actor>(back.clone());
            object.Parent = parent;
            object.transform().Position = Vector3(x, y, 0.0f);

            @grid[x][y] = object;
        }
    }
}