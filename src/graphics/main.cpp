#include <iostream>
#include <SDL2/SDL.h>

#include "defs.h"
#include "drawables/paddle.h"
#include "drawables/playerScore.h"
#include "ball.h"
#include <gameState.h>
#include <VPingPong.h>

#include <thread>
#include <chrono>

int _SCREEN_WIDTH{700};
int _SCREEN_HEIGHT{400};

GameState_t state = {};
VPingPong pong{};
static void InitializePong(VPingPong &pong);
static void ComputeState(VPingPong &pong);

static inline uint32_t CastPairAsUint32_t(std::pair<uint16_t, uint16_t> pair) {
  uint32_t val = ((uint32_t) (pair.first << 16)) | ((uint32_t) pair.second);
  return val;
}

static inline std::pair<uint16_t, uint16_t> CastUintAsPair(uint32_t val) {
  std::pair<uint16_t, uint16_t> pair{};
  pair.first = (uint16_t) (val >> 16);
  pair.second = ((uint16_t) (val & 0x0000FFFF));
  return pair;
}

static inline uint32_t CastUint32_t(uint16_t one, uint16_t two) {
  uint32_t dimensions = ((uint32_t) (one << 16)) | ((uint32_t) two);
  return dimensions;
}

static inline void CastUintBack(uint16_t val, uint8_t* one, uint8_t* two) {
  *one = ((uint8_t) (val >> 8));
  *two = ((uint8_t) (val & 0x00FF));
}

static inline void CastUint32Back(uint32_t val, uint16_t* one, uint16_t* two) {
  *one = ((uint16_t) (val >> 16));
  *two = (uint16_t) (val & 0x0000FFFF);
}

int main(int agrc, char** argv) {
  InitializePong(pong);
  
  SDL_Window* window = nullptr;
  SDL_Renderer* render = nullptr;
  SDL_Surface* window_surface = nullptr;

  SDLApp app{window, render};
  app.prepareScene();
  app.presentScene();

  Paddle left_paddle{PADDLE_TYPE::LEFT, render};
  Paddle right_paddle{PADDLE_TYPE::RIGHT, render};
  app.InsertPaddle(&left_paddle);
  app.InsertPaddle(&right_paddle);

  Ball ball{render};
  PlayerScore PlayerScore{render};

  SDL_SetWindowSize(window, _SCREEN_WIDTH, _SCREEN_HEIGHT);
  SDL_Event event;
  bool quit = false;
  
  while (!quit) {
    if (SDL_PollEvent(&event)) {
      ComputeState(pong);
      app.prepareScene();
      PlayerScore.UpdateScore(state.score.first, state.score.second);
      ball.handleInput(state.ballPosition);
      switch (event.type) {
        case SDL_QUIT:
          quit = true;
          break;
        default:
          app.handleInput(event);
          break;
      }
      app.presentScene();      
    }
  }

  SDL_Quit();
  return 0;
}

void InitalizeWindowAndRenderer(SDL_Window* &window_ptr, SDL_Renderer* &render_ptr) {
  if (SDL_Init(SDL_INIT_VIDEO) < 0) {
    std::cout << "Failed to initialize the SDL2 library \n";
  }

  window_ptr = SDL_CreateWindow("Pong Game", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 640, 480, 0);
  if (!window_ptr) {
    std::cout<<"Unable to create window \n";
  }

  render_ptr = SDL_CreateRenderer(window_ptr, -1, 0);
  if (!render_ptr) {
    std::cout<< "Unable to create renderer for window \n";
  }
}

void PrepareScene(SDL_Renderer* &render) {
  SDL_SetRenderDrawColor(render, 96, 128, 255, 255);
	SDL_RenderClear(render);
}

void PresentScene(SDL_Renderer* &render) {
  SDL_RenderPresent(render);
}

static void InitializePong(VPingPong &pong) {
  pong.clk = 0;
  pong.rst = 1;
  state.dimensions = std::pair<uint16_t, uint16_t>{_SCREEN_WIDTH, _SCREEN_HEIGHT};
  state.ballPosition = std::pair<uint16_t, uint16_t>{_SCREEN_WIDTH/2, _SCREEN_HEIGHT/2};
  state.ballVelocity = std::pair<uint16_t, uint16_t>{5, 5};
  state.leftPaddlePosition = std::pair<uint16_t, uint16_t>{10, 50};
  state.rightPaddlePosition = std::pair<uint16_t, uint16_t>{700-10, _SCREEN_HEIGHT/2};
  state.score = std::pair<uint8_t, uint8_t>{0,0};
}

static void ComputeState(VPingPong &pong) {
  
  pong.rst = 1;
  std::this_thread::sleep_for(std::chrono::milliseconds(100));
  pong.dimensions = CastPairAsUint32_t(state.dimensions);
  pong.ballPosition = CastPairAsUint32_t(state.ballPosition);
  pong.ballVelocity = CastPairAsUint32_t(state.ballVelocity);
  pong.leftPaddlePosition = CastPairAsUint32_t(state.leftPaddlePosition);
  pong.rightPaddlePosition = CastPairAsUint32_t(state.rightPaddlePosition);

  pong.eval();
  pong.clk ^= 1;
  pong.eval();
  pong.clk ^= 1;
  pong.eval();

  state.dimensions =  CastUintAsPair(pong.dimensions);
  state.ballPosition =  CastUintAsPair(pong.ballPositionOut);
  state.ballVelocity = CastUintAsPair(pong.ballVelocityOut);
  state.leftPaddlePosition =  CastUintAsPair(pong.leftPaddlePositionOut);
  state.rightPaddlePosition =  CastUintAsPair(pong.rightPaddlePositionOut);
  state.score = std::pair<uint8_t, uint8_t>{(pong.scoreOut >>8), pong.scoreOut & 0x00FF};
}