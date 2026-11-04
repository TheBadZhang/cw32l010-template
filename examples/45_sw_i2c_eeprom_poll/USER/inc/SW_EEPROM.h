#ifndef __SW_EEPROM_H
#define __SW_EEPROM_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

void SW_I2C_MasterSendDataToSlave(uint8_t u8SlaveAddr, uint16_t DataAddr, uint8_t* pu8Data, uint32_t u32Len);
void SW_I2C_MasterRecDataFromSlave(uint8_t u8SlaveAddr, uint16_t DataAddr, uint8_t* pu8Data, uint32_t u32Len);

#ifdef __cplusplus
}
#endif

#endif 

