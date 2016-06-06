#include "stm32f4xx_conf.h"
#include <stm32f4xx.h>
#include <stm32f4xx_rcc.h>
#include <stm32f4xx_gpio.h>
#include <stm32f4xx_tim.h>
#include <stm32f4xx_dma.h>
#include <stm32f4xx_usart.h>
#include <misc.h>
#include "delay.h"
#include "ws2812.h"

uint8_t receive_counter = 0;
uint8_t Data_packet[5];	//0 - LED Number; 1 - Option; 2 - R; 3 - G; 4 - B;
struct led backup[FRAMEBUFFER_SIZE];


void ClockConfig() {
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_USART6, ENABLE);
	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOC, ENABLE);
}

void Config_USART() {
	USART_InitTypeDef USART_InitStructure;
	USART_InitStructure.USART_BaudRate = 9600;
	USART_InitStructure.USART_WordLength = USART_WordLength_8b;
	USART_InitStructure.USART_StopBits = USART_StopBits_1;
	USART_InitStructure.USART_Parity = USART_Parity_No;
	USART_InitStructure.USART_HardwareFlowControl =
			USART_HardwareFlowControl_None;
	USART_InitStructure.USART_Mode = USART_Mode_Rx | USART_Mode_Tx;
	USART_Init(USART6, &USART_InitStructure);
}


void Config_Tx() {
	GPIO_PinAFConfig(GPIOC, GPIO_PinSource6, GPIO_AF_USART6);
	GPIO_InitTypeDef GPIO_InitStructure;
	GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
	GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_UP;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF;
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_6;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(GPIOC, &GPIO_InitStructure);
}

void Config_Rx() {
	GPIO_PinAFConfig(GPIOC, GPIO_PinSource7, GPIO_AF_USART6);
	GPIO_InitTypeDef GPIO_InitStructure;
	GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
	GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_UP;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF;
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_7;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(GPIOC, &GPIO_InitStructure);
}


void Config_NVIC() {
	NVIC_PriorityGroupConfig(NVIC_PriorityGroup_4);
	NVIC_InitTypeDef NVIC_InitStructure;
	USART_ITConfig(USART6, USART_IT_RXNE, ENABLE);
	NVIC_InitStructure.NVIC_IRQChannel = USART6_IRQn;
	NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0;
	NVIC_InitStructure.NVIC_IRQChannelSubPriority = 0;
	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
	NVIC_Init(&NVIC_InitStructure);
}


void USART6_IRQHandler(void) {
	if (USART_GetFlagStatus(USART6, USART_FLAG_RXNE)) {
		uint8_t data = USART_ReceiveData(USART6);

		if (receive_counter < 5) {
			Data_packet[receive_counter] = data;
			receive_counter++;
		}

		if (receive_counter == 5) {
			receive_counter = 0;

			if (Data_packet[0] != 100) {
				ws2812_framebuffer[Data_packet[0]].red = Data_packet[2];
				ws2812_framebuffer[Data_packet[0]].blue = Data_packet[3];
				ws2812_framebuffer[Data_packet[0]].green = Data_packet[4];

				backup[Data_packet[0]] = ws2812_framebuffer[Data_packet[0]];
				} else {
				int i = 0;
				for (i = 0; i < FRAMEBUFFER_SIZE; i++) {
					ws2812_framebuffer[i].red = Data_packet[2];
					ws2812_framebuffer[i].blue = Data_packet[3];
					ws2812_framebuffer[i].green = Data_packet[4];

					backup[i] = ws2812_framebuffer[i];
				}

			}

		}
	}
}


int main(void)
{
	SystemInit();
	SystemCoreClockUpdate();
	init_systick();	//Initialize delay function
	ClockConfig();
	Config_Tx();
	Config_Rx();
	Config_USART();
	Config_NVIC();	//Initialize interruption
	ws2812_init();	//Initialize LED strip
	USART_Cmd(USART6, ENABLE);
	NVIC_EnableIRQ(USART6_IRQn);

	while(1) {

		switch (Data_packet[1]) {
		case 0:	//None option
			break;
		case 1:	//Flickering option
			for (int i = 0; i < FRAMEBUFFER_SIZE; i++) ws2812_framebuffer[i].red = ws2812_framebuffer[i].green = ws2812_framebuffer[i].blue = 0;
			delay_ms(500);
			for (int i = 0; i < FRAMEBUFFER_SIZE; i++) ws2812_framebuffer[i] = backup[i];
			delay_ms(500);
			break;
		case 2:	//Passing option
			for (int i = FRAMEBUFFER_SIZE - 1; i >= 0; i--) {
				ws2812_framebuffer[i].red = ws2812_framebuffer[i].green = ws2812_framebuffer[i].blue = 0;
				delay_ms(100);
			}

			for (int i = 0; i < FRAMEBUFFER_SIZE; i++) {
				ws2812_framebuffer[i] = backup[i];
				delay_ms(100);
			}
			break;
		}
	}
	
}



