#include "paddle.h"
#include <iostream>

void Paddle::Draw() {
  SDL_Renderer* render = this->render;
  SDL_SetRenderDrawColor(render, 255, 255, 255, 255);

  this->paddle = SDL_Rect {
        .h = PADDLE_HEIGHT,
        .y = position.first,
        .x = position.second,
        .w = PADDLE_WIDTH,
  };
  
  if (SDL_RenderFillRect(render, &this->paddle) != 0) {
    std::cout<< "Failed to render paddle \n";
  }
}

Paddle::Paddle(PADDLE_TYPE m_type, SDL_Renderer* render) {
  this->render = render;
  this->type = m_type;
  const int initialHeight = (_SCREEN_HEIGHT-PADDLE_HEIGHT)/2;

  switch (m_type) {
    case (PADDLE_TYPE::LEFT):
      this->position = std::pair<int, int>{initialHeight, SCREEN_PADDING};
      break;

    case (PADDLE_TYPE::RIGHT):
      this->position = std::pair<int, int>{initialHeight, (_SCREEN_WIDTH-PADDLE_WIDTH)-SCREEN_PADDING};
      break;
  }
}

Paddle::~Paddle() {}

void Paddle::handleInput(const SDL_Event &event) {
  if (this->type == PADDLE_TYPE::LEFT) {
    this->Draw();
    return;
  }

  if (event.type != SDL_KEYDOWN) {
    this->Draw();
    return;
  }

  switch (event.key.keysym.sym) {
    case SDLK_w:
      if (position.first <= 0) break;
      position.first = position.first - 5;
      break;
    case SDLK_s:
    if (position.first + PADDLE_HEIGHT > _SCREEN_HEIGHT) break;
      position.first = position.first + 5;
      break;
    default: break;
  }
  state.rightPaddlePosition = position;
  this->Draw();
}

