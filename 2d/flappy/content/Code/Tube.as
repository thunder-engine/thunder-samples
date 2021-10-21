class Tube : Behaviour {
    SpriteRender @topTube = null;
    SpriteRender @bottomTube = null;

    private BoxCollider @topCollider = null;
    private BoxCollider @bottomCollider = null;

    void start() override {
        if(bottomTube !is null) {
            @bottomCollider = cast<BoxCollider>(bottomTube.actor().component("BoxCollider"));
        }
        
        if(topTube !is null) {
            @topCollider = cast<BoxCollider>(topTube.actor().component("BoxCollider"));
        }
        
        changeGate();
    }

    void update() override {
        if(GameState::gameOver == false) {
            Transform @t = actor().transform();
            if(t !is null) {
                Vector3 position = t.position + Vector3(-1.0f, 0.0f, 0.0f) * Timer::deltaTime();
    
                if(position[0] < -10.0f) {
                    position = Vector3(10.0f, 0.0f, 0.0);
                    changeGate();
                }
                
                t.position = position;
            }
        }
    }
    
    void changeGate() {
        int pos = irand(1.0f, 14.0f);
        if(@topTube !is null) {
            float size = 15.0f - pos;
            topTube.size = Vector2(2.05f, size);
            if(topCollider !is null) {
                topCollider.size = Vector3(1.0f, size, 0.0f);
            }
        }
        if(@bottomTube !is null) {
            bottomTube.size = Vector2(2.05f, pos);
            if(bottomCollider !is null) {
                bottomCollider.size = Vector3(1.0f, pos, 0.0f);
            }
        }
    }
};
