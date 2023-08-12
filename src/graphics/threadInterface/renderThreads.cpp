#include <renderThreds.h>
#include <cstdint>

#define msleep(seconds) usleep(1000*seconds)

inline uint32_t CastPairAsUint32_t(std::pair<uint16_t, uint16_t> pair) {
  uint32_t val = ((uint32_t) (pair.first << 16)) | ((uint32_t) pair.second);
  return val;
}

inline std::pair<uint16_t, uint16_t> CastUintAsPair(uint32_t val) {
  std::pair<uint16_t, uint16_t> pair{};
  pair.first = (uint16_t) (val >> 16);
  pair.second = ((uint16_t) (val & 0x0000FFFF));
  return pair;
}

void *computeState(void* param){
  while (true) {
    gameInput_t* input = (gameInput_t*) param;
    VPingPong *pong = input->pong;
    GameState_t *state = input->state;
    msleep(50);
    pong->rst = 1;
    
    pong->dimensions = CastPairAsUint32_t(state->dimensions);
    pong->ballPosition = CastPairAsUint32_t(state->ballPosition);
    pong->ballVelocity = CastPairAsUint32_t(state->ballVelocity);
    pong->leftPaddlePosition = CastPairAsUint32_t(state->leftPaddlePosition);
    pong->rightPaddlePosition = CastPairAsUint32_t(state->rightPaddlePosition);

    pong->eval();
    pong->clk ^= 1;
    pong->eval();
    pong->clk ^= 1;
    pong->eval();

    state->dimensions =  CastUintAsPair(pong->dimensions);
    state->ballPosition =  CastUintAsPair(pong->ballPositionOut);
    state->ballVelocity = CastUintAsPair(pong->ballVelocityOut);
    state->leftPaddlePosition =  CastUintAsPair(pong->leftPaddlePositionOut);
    state->rightPaddlePosition =  CastUintAsPair(pong->rightPaddlePositionOut);
    state->score = std::pair<uint8_t, uint8_t>{(pong->scoreOut >>8), pong->scoreOut & 0x00FF};
    
  }
}
