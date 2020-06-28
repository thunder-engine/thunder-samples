#ifndef BOARD_H
#define BOARD_H

#include <component.h>
#include <actor.h>
#include <transform.h>
#include <log.h>
#include <input.h>
#include <timer.h>

#include <camera.h>
#include <textrender.h>

#include <vector>

#include "Element.cpp"

#define SCORE(x) x * x * 100

class Board : public NativeBehaviour {
    A_REGISTER(Board, NativeBehaviour, Components)

    A_NOPROPERTIES()
    A_NOMETHODS()

    uint32_t score  = 0;

    uint32_t width  = 6;
    uint32_t height = 8;
    uint8_t types   = 5;

    bool move       = false;

    Element *selected   = nullptr;
    Element *target     = nullptr;

    TextRender *textRender  = nullptr;

    vector<vector<Element *>>   grid;

public:
    void start() {
        Actor *p = static_cast<Actor *>(actor()->parent());
        textRender = dynamic_cast<TextRender *>(p->componentInChild("TextRender"));

        grid.resize(width);
        for(uint32_t x = 0; x < width; x++) {
            grid[x].resize(height);
            for(uint32_t y = 0; y < height; y++) {
                grid[x][y]  = nullptr;
            }
        }

        Material *material  = dynamic_cast<Material *>(Engine::loadResource(".embedded/DefaultSprite.mtl"));
        Texture *texture    = dynamic_cast<Texture *>(Engine::loadResource("Sprites/Cell.png"));

        Actor *parent   = actor();
        // Fill grid
        for(uint32_t x = 0; x < width; x++) {
            for(uint32_t y = 0; y < height; y++) {
                bool hole   = false;
                int32_t id  = rand() % types;
                if(!hole) {
                    Actor *cell = Engine::objectCreate<Actor>("", parent);
                    SpriteRender *sprite = dynamic_cast<SpriteRender *>(cell->addComponent("SpriteRender"));
                    if(sprite) {
                        sprite->setMaterial(material);
                        sprite->setTexture(texture);
                    }
                    cell->transform()->setPosition(Vector3(x, y, -1.0f));
                    cell->transform()->setScale(Vector3(0.95f, 0.95f, 1.0f));
                }

                Actor *actor = Engine::objectCreate<Actor>("", parent);
                Element *element = dynamic_cast<Element *>(actor->addComponent("Element"));

                element->column = x;
                element->row = y;
                element->id = (hole) ? -1 : id;

                actor->transform()->setPosition(Vector3(x, y, 0.0f));

                grid[x][y]  = element;
            }
        }
    }

    void update() {
        bool animation  = false;
        for(uint32_t x = 0; x < width; x++) {
            for(uint32_t y = 0; y < height; y++) {
                if(grid[x][y] != nullptr && grid[x][y]->animated) {
                    animation   = true;
                    break;
                }
            }
        }

        if(!animation) {
            if(Input::isMouseButton(Input::LEFT) ||
               Input::touchCount() > 0) {
                Vector4 pos = Input::mousePosition();
                if(Input::touchCount() > 0) {
                    pos = Input::touchPosition(0);
                }
                Camera *camera  = Camera::current();
                if(camera) {
                    Ray ray = camera->castRay(pos.z, pos.w);
                    for(uint32_t x = 0; x < width; x++) {
                        for(uint32_t y = 0; y < height; y++) {
                            if(grid[x][y] != nullptr) {
                                Transform *t = grid[x][y]->actor()->transform();
                                if(ray.intersect(t->worldPosition(), 0.5f, nullptr)) {
                                    if(selected && selected != grid[x][y] &&
                                       Vector2((float)x - selected->column, (float)y - selected->row).length() == 1.0f) {
                                        swapElements(x, y);
                                        move = true;
                                        return;
                                    } else {
                                        if(selected) {
                                            selected->setSelected(false);
                                        }
                                        selected = grid[x][y];
                                        selected->setSelected(true);
                                    }
                                    break;
                                }
                            }
                        }
                    }
                }
            }

            if(move) {
                move    = false;
                if(!findMatches()) {
                    // Swap back
                    if(selected && target) {
                        swapElements(target->column, target->row);

                        selected->setSelected(false);

                        selected    = nullptr;
                        target      = nullptr;
                    }
                    return;
                } else {
                    move    = true;
                }
                refillGrid();
            }

        }
    }

    void swapElements(uint8_t x, uint8_t y) {
        target      = grid[x][y];
        grid[x][y]  = selected;
        grid[selected->column][selected->row]   = target;

        target->setTarget(selected->column, selected->row);
        selected->setTarget(x, y);
    }

    Element *findNext(uint32_t x, uint32_t from) {
        Element *result = nullptr;

        for(uint32_t y = from; y < height; y++) {
            Element *element    = grid[x][y];
            if(element) {
                if(element->id == -1) {
                    continue;
                }
                result  = element;
                break;
            }
        }

        return result;
    }

    void refillGrid() {
        Actor *parent = actor();
        for(uint32_t x = 0; x < width; x++) {
            uint8_t length  = 0;
            for(uint32_t y = 0; y < height; y++) {
                if(grid[x][y] == nullptr) {
                    if(y < height - 1) {
                        Element *element    = findNext(x, y + 1);
                        if(element) {
                            grid[x][y]      = element;
                            grid[x][element->row]  = nullptr;

                            element->setTarget(x, y);

                            y = -1;
                        }
                    } else {
                        Actor *actor    = Engine::objectCreate<Actor>("", parent);
                        actor->transform()->setPosition(Vector3(x, height + length, 0.0f));
                        length++;

                        Element *element= dynamic_cast<Element *>(actor->addComponent("Element"));
                        element->setTarget(x, y);
                        element->id     = rand() % types;

                        grid[x][y]      = element;
                        y = -1;
                    }
                }
            }
        }
    }

    bool findMatches() {
        bool result = false;
        // Check columns
        for(uint32_t x = 0; x < width; x++) {
            uint8_t from = 0;
            uint8_t matched = 0;
            if(checkLine(x, from, matched, true)) {
                deleteElements(x, from, matched, true);
                result = true;
            }
        }
        // Check rows
        for(uint32_t y = 0; y < height; y++) {
            uint8_t from = 0;
            uint8_t matched = 0;
            if(checkLine(y, from, matched, false)) {
                deleteElements(y, from, matched, false);
                result = true;
            }
        }
        return result;
    }

    bool checkLine(uint8_t pos, uint8_t &from, uint8_t &matched, bool vertical) {
        int32_t current = 0;
        uint8_t size = (vertical) ? height : width;
        for(uint32_t i = 0; i < size; i++) {
            uint8_t x = (vertical) ? pos : i;
            uint8_t y = (vertical) ? i : pos;
            if(grid[x][y] != nullptr) {
                int32_t id = grid[x][y]->id;
                if(id == current && id != -1) {
                    matched++;
                } else {
                    if(matched < 3) {
                        matched = 1;
                        from    = i;
                        current = id;
                    } else {
                        return true;
                    }
                }
            } else {
                matched = 0;
            }
        }
        return (matched > 2);
    }

    void deleteElements(uint8_t pos, uint8_t from, uint8_t size, bool vertical) {
        score   += SCORE(size);
        if(textRender) {
            textRender->setText(to_string(score));
        }
        if(selected) {
            selected->setSelected(false);
        }
        selected    = nullptr;
        target      = nullptr;

        for(uint32_t i = from; i < (from + size); i++) {
            uint8_t x = (vertical) ? pos : i;
            uint8_t y = (vertical) ? i : pos;
            Element *element    = grid[x][y];
            if(element) {
                element->actor()->deleteLater();
                grid[x][y]  = nullptr;
            }
        }
    }
};

#endif
