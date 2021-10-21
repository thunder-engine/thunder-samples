namespace GameState {
    bool gameOver = false;
};

class GameController : Behaviour {
    private int score = 0;

    RigidBody @bird = null;
    Actor @ui = null;

    void start() override {
        connect(bird, _SIGNAL("entered()"), this, _SLOT("onBirdCollide()"));
        GameState::gameOver = false;
    }

    void update() override {
        if(!GameState::gameOver && Input::isMouseButtonDown(Input::MouseButton::LEFT) && (bird !is null)) {
            bird.applyImpulse(Vector3(0.0f, 5.0f, 0.0f), Vector3(0.0f, 0.0f, 0.0f));
        }
    }
    
    private void onBirdCollide() { // slot definition
        GameState::gameOver = true;
        // Show Game Over UI
    }
};
