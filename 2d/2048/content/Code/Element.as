class Element : Behaviour {
    Vector2 position
    {
        get const {
            return realPosition;
        }
        set {
            realPosition = value;
            if(@transform !is null) {
                transform.Position = Vector3(realPosition[0], realPosition[1], 0.0f);
            }
        }
    }
    private Vector2 realPosition;
    private Vector2 currentPosition;
    
    int value
    {
        get const {
            return realValue;
        } 
        set {
            realValue = value;
            if(@label !is null) {
                label.Text = "" + pow(2.0f, value);
            }
            if(@back !is null) {
                back.Color = TileColors[value - 1];
            }
            if(realValue > 2) {
                label.Color = Vector4(0.97647f, 0.9647f, 0.949f, 1.0f);
            }
            scale = 0.80f;
        }
    }
    private int realValue = 0;
    
    private array<Vector4> TileColors = {Vector4(238.0f / 255, 228.0f / 255, 218.0f / 255, 1.0f),
                                         Vector4(237.0f / 255, 224.0f / 255, 200.0f / 255, 1.0f),
                                         Vector4(242.0f / 255, 177.0f / 255, 121.0f / 255, 1.0f),
                                         Vector4(245.0f / 255, 149.0f / 255,  99.0f / 255, 1.0f),
                                         Vector4(246.0f / 255, 124.0f / 255,  95.0f / 255, 1.0f),
                                         Vector4(246.0f / 255,  94.0f / 255,  59.0f / 255, 1.0f),
                                         Vector4(237.0f / 255, 207.0f / 255, 114.0f / 255, 1.0f),
                                         Vector4(237.0f / 255, 204.0f / 255,  97.0f / 255, 1.0f),
                                         Vector4(237.0f / 255, 200.0f / 255,  80.0f / 255, 1.0f),
                                         Vector4(237.0f / 255, 197.0f / 255,  63.0f / 255, 1.0f),
                                         Vector4(237.0f / 255, 194.0f / 255,  46.0f / 255, 1.0f)};
    
    private TextRender @label = null;
    private SpriteRender @back = null;
    private Transform @transform = null;
    
    private float scale = 0.80f;

    void start() override {
        @label = cast<TextRender>(actor().componentInChild("TextRender"));
        @back = cast<SpriteRender>(actor().component("SpriteRender"));
        value = (irand(0, 10) == 0) ? 2 : 1;
        
        @transform = actor().transform();
        
        currentPosition = realPosition;
        
        transform.Scale = Vector3(scale, scale, 1.0f);
        transform.Position = Vector3(currentPosition[0], currentPosition[1], 0.0f);
    }

    void update() override {
        if(scale < 0.95f) {
            scale += 0.025f;
            transform.Scale = Vector3(scale, scale, 1.0f);
        }
        bool moved = false;
        if(currentPosition[0] < realPosition[0]) {
            currentPosition += Vector2(0.5f, 0.0f);
            moved = true;
        }
        if(currentPosition[0] > realPosition[0]) {
            currentPosition -= Vector2(0.5f, 0.0f);
            moved = true;
        }
        if(currentPosition[1] < realPosition[1]) {
            currentPosition += Vector2(0.0f, 0.5f);
            moved = true;
        }
        if(currentPosition[1] > realPosition[1]) {
            currentPosition -= Vector2(0.0f, 0.5f);
            moved = true;
        }
        if(moved) {
            transform.Position = Vector3(currentPosition[0], currentPosition[1], 0.0f);
        }
    }
}
