#ifndef ELEMENT_H
#define ELEMENT_H

#include <component.h>

#include <spriterender.h>
#include <sprite.h>
#include <material.h>
#include <actor.h>
#include <transform.h>
#include <timer.h>

static Material *material  = nullptr;

class Element : public NativeBehaviour {
    A_REGISTER(Element, NativeBehaviour, Components)
    
public:
    uint32_t row    = 0;
    uint32_t column = 0;
    int32_t id      = -1;

    bool animated   = false;
    bool selected   = false;
    bool direction  = false;

    float factor    = 0.0f;
    
    

    Vector3 position;

    void start() {
        if(material == nullptr) {
            material = dynamic_cast<Material *>(Engine::loadResource(".embedded/DefaultSprite.mtl"));
        }

        if(id != -1) {
            SpriteRender *render = dynamic_cast<SpriteRender *>(actor()->addComponent("SpriteRender"));
            if(render) {
                string name = string("Sprites/") + to_string(id) + ".png";
                Sprite *sprite = dynamic_cast<Sprite *>(Engine::loadResource(name));

                render->setMaterial(material);
                render->setSprite(sprite);
            }
        }
    }

    void update() {
        Transform *t = actor()->transform();

        if(selected) {
            float euler = t->rotation().z + ((direction) ? 90.0f : -90.0f) * Timer::deltaTime();
            if(euler < -20.0f || euler > 20.0f) {
                direction = !direction;
                euler = CLAMP(euler, -20.0f, 20.0f);
            }

            t->setRotation(Vector3(0, 0, euler));
        }

        Vector3 target(column, row, position.z);

        if(animated) {
            factor += 5.0f * Timer::deltaTime();

            if(factor < 1.0f) {
                t->setPosition(MIX(position, target, factor));
            } else {
                t->setPosition(target);
                factor = 0.0f;
                animated = false;
            }
        }
    }

    void setTarget(uint8_t x, uint8_t y) {
        column  = x;
        row = y;

        position = actor()->transform()->position();
        factor = 0.0f;

        animated = true;
    }

    void setSelected(bool value) {
        selected = value;
        if(!selected) {
            Transform *t    = actor()->transform();
            t->setRotation(Vector3(0, 0, 0));
        }
    }
};

#endif
