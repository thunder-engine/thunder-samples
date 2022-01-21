namespace GameState {
    bool gameOver = false;
};

class GameController : Behaviour {
    private int score = 0;

    Actor @panel = null;
    Button @startBtn = null;
    
    RigidBody @bird = null;
    
    private Chunk @chunk = null;

    void start() override {
        connect(startBtn, _SIGNAL("clicked()"), this, _SLOT("onStartClicked()"));
        
        GameState::gameOver = false;
    }

    void update() override {
        if(!GameState::gameOver && Input::isMouseButtonDown(Input::MouseButton::LEFT) && (bird !is null)) {
            bird.applyImpulse(Vector3(0.0f, 5.0f, 0.0f), Vector3(0.0f, 0.0f, 0.0f));
        }
    }
      
    private void onStartClicked() {
        if(panel !is null) {
            panel.enabled = false;
        }

        @chunk = Engine::loadSceneChunk("Level.map", true);
        log("-------------------------------------");
        log("3_SIGNAL=" + _SIGNAL("entered()") + "_SLOT=" + _SLOT("onBirdCollide()"));
        // Find bird
        if(chunk !is null) {
            Actor @birdActor = cast<Actor>(chunk.find("Bird"));
            if(birdActor !is null) {
                @bird = cast<RigidBody>(birdActor.component("RigidBody"));
                if(bird !is null) {
                    
                    connect(bird, _SIGNAL("entered()"), this, _SLOT("onBirdCollide()"));
                    GameState::gameOver = false;
                }
            }
        }
    }
    
    private void onBirdCollide() { // slot definition
        GameState::gameOver = true;
        // Show Game Over UI
        if(panel !is null) {
            panel.enabled = true;
        }
        Engine::unloadSceneChunk(chunk);
    }
};
