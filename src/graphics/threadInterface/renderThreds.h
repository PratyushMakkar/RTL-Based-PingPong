#ifndef __RENDER_THREAD_H__
#define __RENDER_THREAD_H__

#include <pthread.h>
#include <VPingPong.h>
#include <defs.h>

#include <SDL2/SDL.h>

typedef struct {
  GameState_t* state;
  VPingPong* pong;
  pthread_mutex_t mut;
} gameInput_t;

void *computeState(void* param);
inline std::pair<uint16_t, uint16_t> CastUintAsPair(uint32_t val);
inline uint32_t CastPairAsUint32_t(std::pair<uint16_t, uint16_t> pair);
#endif