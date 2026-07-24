from machine import Pin
from time import sleep_ms, ticks_diff, ticks_ms

PIN_LDR = 34
PIN_RESET = 27
TEMPO_MICRO_PARADA_MS = 5000
TEMPO_DEBOUNCE_MS = 50

ldr = Pin(PIN_LDR, Pin.IN)
botao_reset = Pin(PIN_RESET, Pin.IN, Pin.PULL_UP)

total_pecas = 0
sensor_bloqueado = ldr.value() == 1
inicio_bloqueio = ticks_ms() if sensor_bloqueado else None
alerta_enviado = False
botao_anterior = botao_reset.value()


def resetar_turno(agora):
    global total_pecas, inicio_bloqueio, alerta_enviado

    total_pecas = 0
    inicio_bloqueio = agora if sensor_bloqueado else None
    alerta_enviado = False
    print("Turno resetado com sucesso. Contadores zerados.")


print("Contador de Producao Inicializado")

while True:
    agora = ticks_ms()
    bloqueado = ldr.value() == 1  # DO fica em 1 quando há pouca luz

    if bloqueado and not sensor_bloqueado:
        sensor_bloqueado = True
        inicio_bloqueio = agora
        alerta_enviado = False

    elif not bloqueado and sensor_bloqueado:
        sensor_bloqueado = False
        inicio_bloqueio = None
        alerta_enviado = False
        total_pecas += 1
        print("Peca detectada! Total: {}".format(total_pecas))

    elif (
        sensor_bloqueado
        and not alerta_enviado
        and ticks_diff(agora, inicio_bloqueio) >= TEMPO_MICRO_PARADA_MS
    ):
        alerta_enviado = True
        print("Alerta: Micro-parada detectada!")

    botao_atual = botao_reset.value()  # Pressionado = 0

    # Executa o reset quando o botão é solto
    if botao_anterior == 0 and botao_atual == 1:
        sleep_ms(TEMPO_DEBOUNCE_MS)

        if botao_reset.value() == 1:
            resetar_turno(agora)

    botao_anterior = botao_atual
    sleep_ms(10)