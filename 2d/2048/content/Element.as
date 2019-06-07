class Element : Behaviour {
    int row    = 0;
    int column = 0;

    int score = 2;

    void start() override {
        TextRender @label = cast<TextRender>(actor().createComponent("TextRender"));
        if(label !is null) {
            label.Text = formatInt(score);
        }
    }

    void update() override {

    }
}
